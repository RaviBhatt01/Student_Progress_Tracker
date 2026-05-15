import 'package:dio/dio.dart';


import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/storage_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import 'package:student_tracker/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:student_tracker/features/auth/data/models/auth_models.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final StorageService _storage;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required StorageService storage,
  }) : _remote = remote,
       _storage = storage;

  @override
  Future<({UserEntity user, Failure? failure})> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remote.login(
        LoginRequest(email: email, password: password),
      );
      await _persistSession(response);
      return (user: _toEntity(response.user), failure: null);
    } on DioException catch (e) {
      return (user: _emptyUser, failure: dioExceptionToFailure(e));
    } catch (_) {
      return (
        user: _emptyUser,
        failure: const ServerFailure('Unexpected error during login.'),
      );
    }
  }

  @override
  Future<({UserEntity user, Failure? failure})> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remote.register(
        RegisterRequest(name: name, email: email, password: password),
      );
      await _persistSession(response);
      return (user: _toEntity(response.user), failure: null);
    } on DioException catch (e) {
      return (user: _emptyUser, failure: dioExceptionToFailure(e));
    } catch (_) {
      return (
        user: _emptyUser,
        failure: const ServerFailure('Unexpected error during registration.'),
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remote.logout();
    } catch (_) {
      // Server logout is best-effort — always clear locally
    } finally {
      await _storage.clear();
    }
  }

  @override
  UserEntity? getCachedUser() {
    final id = _storage.getString(AppConstants.keyUserId);
    if (id == null) return null;
    // In a real app you'd cache the full user object as JSON.
    // For now we return a minimal entity from stored fields.
    return UserEntity(
      id: id,
      name: _storage.getString('user_name') ?? '',
      email: _storage.getString('user_email') ?? '',
    );
  }

  // --- Helpers ---

  Future<void> _persistSession(AuthResponse response) async {
    await _storage.setString(AppConstants.keyAuthToken, response.token);
    await _storage.setString(AppConstants.keyUserId, response.user.id);
    await _storage.setString('user_name', response.user.name);
    await _storage.setString('user_email', response.user.email);
  }

  UserEntity _toEntity(UserModel model) =>
      UserEntity(id: model.id, name: model.name, email: model.email);

  static const _emptyUser = UserEntity(id: '', name: '', email: '');
}
