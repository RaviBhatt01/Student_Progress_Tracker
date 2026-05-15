import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:student_tracker/features/auth/domain/entities/user_entity.dart';

part 'auth_state.freezed.dart';

@freezed
sealed class AuthState with _$AuthState {
  /// App just launched — checking local storage for a token
  const factory AuthState.initial() = AuthInitial;

  /// Waiting for API response
  const factory AuthState.loading() = AuthLoading;

  /// Token found or login/register succeeded
  const factory AuthState.authenticated(UserEntity user) = AuthAuthenticated;

  /// No token or logout completed
  const factory AuthState.unauthenticated() = AuthUnauthenticated;

  /// API or network error
  const factory AuthState.error(String message) = AuthError;
}
