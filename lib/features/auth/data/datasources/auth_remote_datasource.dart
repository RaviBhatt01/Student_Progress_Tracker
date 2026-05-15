import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../models/auth_models.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> login(LoginRequest request);
  Future<AuthResponse> register(RegisterRequest request);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(DioClient dioClient) : _dio = dioClient.dio;

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _dio.post(
      '/auth/login',
      data: request.toJson(),
    );
    return AuthResponse.fromJson(response.data);
  }

  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    final response = await _dio.post(
      '/auth/register',
      data: request.toJson(),
    );
    return AuthResponse.fromJson(response.data);
  }

  @override
  Future<void> logout() async {
    // Inform the server to invalidate the token (fire and forget)
    await _dio.post('/auth/logout');
  }
}