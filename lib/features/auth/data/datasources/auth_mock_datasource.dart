import '../models/auth_models.dart';
import 'auth_remote_datasource.dart';

class AuthMockDataSource implements AuthRemoteDataSource {
  // Simulate network latency so loading states are visible
  static const _delay = Duration(milliseconds: 800);

  // Hardcoded test credentials — any password ≥6 chars works
  static const _testUserId = 'mock-user-001';

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    await Future.delayed(_delay);

    // Simulate wrong password rejection so error states are testable
    if (request.password.length < 6) {
      throw Exception('Invalid credentials');
    }

    return AuthResponse(
      token: 'mock-jwt-token-${DateTime.now().millisecondsSinceEpoch}',
      user: UserModel(
        id: _testUserId,
        name: _nameFromEmail(request.email),
        email: request.email,
      ),
    );
  }

  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    await Future.delayed(_delay);

    return AuthResponse(
      token: 'mock-jwt-token-${DateTime.now().millisecondsSinceEpoch}',
      user: UserModel(
        id: _testUserId,
        name: request.name,
        email: request.email,
      ),
    );
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // No-op — local session is cleared by the repository
  }

  /// Derives a display name from the email prefix (e.g. john.doe@... → John Doe)
  String _nameFromEmail(String email) {
    final prefix = email.split('@').first;
    return prefix
        .split(RegExp(r'[._]'))
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}
