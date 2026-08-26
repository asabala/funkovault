import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import 'auth_service.dart';
import 'auth_state.dart';

class SupabaseAuthService implements AuthService {
  const SupabaseAuthService();

  @override
  Future<AuthState> currentUser() async {
    final user = Supabase.instance.client.auth.currentUser;

    return _mapUserToAuthState(user);
  }

  @override
  Future<AuthState> signIn({
    required String email,
    required String password,
  }) async {
    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );

    return _mapUserToAuthState(response.user);
  }

  @override
  Future<AuthState> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    final response = await Supabase.instance.client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'display_name': displayName.trim(),
      },
    );

    if (response.session != null) {
      await Supabase.instance.client.auth.signOut();
    }

    return AuthState.guest();
  }

  @override
  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(
      String email,
      ) async {
    await Supabase.instance.client.auth.resetPasswordForEmail(
      email.trim(),
    );
  }

  @override
  Future<void> resendVerificationEmail() async {
    // Supabase resend verification needs an email address.
    // The current AuthService contract does not pass one in yet.
    // We will wire this later when the verification screen is improved.
  }

  @override
  Future<AuthState> refreshUser() async {
    final user = Supabase.instance.client.auth.currentUser;

    return _mapUserToAuthState(user);
  }

  AuthState _mapUserToAuthState(User? user) {
    if (user == null) {
      return AuthState.guest();
    }

    final appMetadata = user.appMetadata;

    final bool isPremium =
        appMetadata['is_premium'] == true ||
            appMetadata['tier'] == 'premium';

    return AuthState(
      status: AuthStatus.authenticated,
      userId: user.id,
      email: user.email,
      displayName: user.userMetadata?['display_name'] as String?,
      isPremium: isPremium,
      emailVerified: user.emailConfirmedAt != null,
    );
  }
}