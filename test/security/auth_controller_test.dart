import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/security/auth_controller.dart';
import 'package:funkovault2/security/auth_service.dart';
import 'package:funkovault2/security/auth_state.dart';

class _FakeAuthService implements AuthService {
  AuthState registerResult = AuthState.guest();

  String? registeredDisplayName;
  String? registeredEmail;
  String? registeredPassword;

  @override
  Future<AuthState> currentUser() async {
    return AuthState.guest();
  }

  @override
  Future<AuthState> signIn({
    required String email,
    required String password,
  }) async {
    return AuthState.guest();
  }

  @override
  Future<AuthState> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    registeredDisplayName = displayName;
    registeredEmail = email;
    registeredPassword = password;

    return registerResult;
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<void> sendPasswordResetEmail(
      String email,
      ) async {}

  @override
  Future<void> resendVerificationEmail() async {}

  @override
  Future<AuthState> refreshUser() async {
    return AuthState.guest();
  }
}

void main() {
  test(
    'registration keeps Atlas logged out when service returns guest',
        () async {
      final authService = _FakeAuthService();

      final controller = AuthController(
        authService: authService,
      );

      await controller.register(
        displayName: 'Arthur',
        email: 'arthur@example.com',
        password: 'password123',
      );

      expect(
        authService.registeredDisplayName,
        'Arthur',
      );

      expect(
        authService.registeredEmail,
        'arthur@example.com',
      );

      expect(
        authService.registeredPassword,
        'password123',
      );

      expect(
        controller.state.status,
        AuthStatus.guest,
      );

      expect(
        controller.isLoggedIn,
        isFalse,
      );

      controller.dispose();
    },
  );
}