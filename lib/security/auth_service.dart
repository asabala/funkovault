import 'auth_state.dart';

abstract class AuthService {
  Future<AuthState> currentUser();

  Future<AuthState> signIn({required String email, required String password});

  Future<AuthState> register({
    required String displayName,
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> sendPasswordResetEmail(String email);

  Future<void> resendVerificationEmail();

  Future<AuthState> refreshUser();
}
