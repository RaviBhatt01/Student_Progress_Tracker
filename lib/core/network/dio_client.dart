import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../errors/failures.dart';
import '../storage/storage_service.dart';

class DioClient {
  late final Dio _dio;

  DioClient(StorageService storageService) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(
          milliseconds: AppConstants.connectTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: AppConstants.receiveTimeout,
        ),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Attach interceptors
    _dio.interceptors.addAll([
      _AuthInterceptor(storageService),
      LogInterceptor(requestBody: true, responseBody: true),
    ]);
  }

  Dio get dio => _dio;
}

/// Automatically attaches Bearer token to every request.
/// On 401, clears storage (logout) — the router guard will
/// redirect the user to the login screen.
class _AuthInterceptor extends Interceptor {
  final StorageService _storageService;

  _AuthInterceptor(this._storageService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _storageService.getString(AppConstants.keyAuthToken);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token expired or invalid — clear local session
      _storageService.clear();
      // AutoRoute guard will pick this up and redirect to login
    }
    handler.next(err);
  }
}

/// Converts DioException into typed Failures for the repository layer.
Failure dioExceptionToFailure(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
      return const NetworkFailure('Connection timed out. Check your internet.');
    case DioExceptionType.badResponse:
      final statusCode = e.response?.statusCode;
      if (statusCode == 401) {
        return const AuthFailure('Session expired. Please log in again.');
      }
      if (statusCode == 404) {
        return const ServerFailure('Resource not found.');
      }
      if (statusCode != null && statusCode >= 500) {
        return const ServerFailure('Server error. Please try again later.');
      }
      return ServerFailure(
        e.response?.data?['message'] ?? 'Something went wrong.',
      );
    case DioExceptionType.unknown:
      return const NetworkFailure('No internet connection.');
    default:
      return const ServerFailure('An unexpected error occurred.');
  }
}
