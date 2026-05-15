import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Returns the authenticated [UserEntity] on success, or a [Failure].
  Future<({UserEntity user, Failure? failure})> login({
    required String email,
    required String password,
  });

  Future<({UserEntity user, Failure? failure})> register({
    required String name,
    required String email,
    required String password,
  });

  /// Clears local session. Server call is best-effort.
  Future<void> logout();

  /// Returns the locally cached user if a session exists.
  UserEntity? getCachedUser();
}
