import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:student_tracker/features/auth/domain/repositories/auth_repository.dart';

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(const AuthState.initial());

  /// Called from SplashPage — checks if a session already exists locally.
  /// This determines whether to go to TaskList or Login on launch.
  Future<void> checkSession() async {
    final user = _repository.getCachedUser();
    if (user != null && user.id.isNotEmpty) {
      emit(AuthState.authenticated(user));
    } else {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> login({required String email, required String password}) async {
    emit(const AuthState.loading());
    final result = await _repository.login(email: email, password: password);

    if (result.failure != null) {
      emit(AuthState.error(result.failure!.message));
    } else {
      emit(AuthState.authenticated(result.user));
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(const AuthState.loading());
    final result = await _repository.register(
      name: name,
      email: email,
      password: password,
    );

    if (result.failure != null) {
      emit(AuthState.error(result.failure!.message));
    } else {
      emit(AuthState.authenticated(result.user));
    }
  }

  Future<void> logout() async {
    emit(const AuthState.loading());
    await _repository.logout();
    emit(const AuthState.unauthenticated());
  }
}
