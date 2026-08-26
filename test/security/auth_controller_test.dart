import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/security/auth_controller.dart';
import 'package:funkovault2/security/auth_service.dart';
import 'package:funkovault2/security/auth_state.dart';

class _FakeAuthService implements AuthService {
  AuthState currentUserResult = AuthState.guest();
  AuthState signInResult = AuthState.guest();
  AuthState registerResult = AuthState.guest();

  String? signedInEmail;
  String? signedInPassword;

  String? registeredDisplayName;
  String? registeredEmail;
  String? registeredPassword;

  String? passwordResetEmail;

  bool signOutCalled = false;

  @override
  Future<AuthState> currentUser() async {
    return currentUserResult;
  }

  @override
  Future<AuthState> signIn({
    required String email,
    required String password,
  }) async {
    signedInEmail = email;
    signedInPassword = password;

    return signInResult;
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
  Future<void> signOut() async {
    signOutCalled = true;
  }

  @override
  Future<void> sendPasswordResetEmail(
      String email,
      ) async {
    passwordResetEmail = email;
  }

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
  test(
    'loadCurrentUser restores authenticated session',
        () async {
      final authService = _FakeAuthService()
        ..currentUserResult = const AuthState(
          status: AuthStatus.authenticated,
          email: 'arthur@example.com',
          displayName: 'Arthur',
          isPremium: false,
          emailVerified: true,
        );

      final controller = AuthController(
        authService: authService,
      );

      await controller.loadCurrentUser();

      expect(
        controller.isLoggedIn,
        isTrue,
      );

      expect(
        controller.state.email,
        'arthur@example.com',
      );

      controller.dispose();
    },
  );

  test(
    'signIn updates controller to authenticated state',
        () async {
      final authService = _FakeAuthService()
        ..signInResult = const AuthState(
          status: AuthStatus.authenticated,
          email: 'arthur@example.com',
          displayName: 'Arthur',
          isPremium: false,
          emailVerified: true,
        );

      final controller = AuthController(
        authService: authService,
      );

      await controller.signIn(
        email: 'arthur@example.com',
        password: 'password123',
      );

      expect(
        authService.signedInEmail,
        'arthur@example.com',
      );

      expect(
        controller.isLoggedIn,
        isTrue,
      );

      controller.dispose();
    },
  );

  test(
    'signOut resets controller to guest',
        () async {
      final authService = _FakeAuthService()
        ..signInResult = const AuthState(
          status: AuthStatus.authenticated,
          email: 'arthur@example.com',
          displayName: 'Arthur',
          isPremium: false,
          emailVerified: true,
        );

      final controller = AuthController(
        authService: authService,
      );

      await controller.signIn(
        email: 'arthur@example.com',
        password: 'password123',
      );

      expect(
        controller.isLoggedIn,
        isTrue,
      );

      await controller.signOut();

      expect(
        authService.signOutCalled,
        isTrue,
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

  test(
    'password reset is forwarded to auth service',
        () async {
      final authService = _FakeAuthService();

      final controller = AuthController(
        authService: authService,
      );

      await controller.sendPasswordResetEmail(
        'arthur@example.com',
      );

      expect(
        authService.passwordResetEmail,
        'arthur@example.com',
      );

      controller.dispose();
    },
  );
}