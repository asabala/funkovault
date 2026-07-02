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
    throw UnimplementedError();
  }

  @override
  Future<AuthState> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
      data: {
        'display_name': displayName,
      },
    );

    return _mapUserToAuthState(response.user);
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
    final user = Supabase.instance.client.auth.currentUser;

    return _mapUserToAuthState(user);
  }

  AuthState _mapUserToAuthState(User? user) {
    if (user == null) {
      return AuthState.guest();
    }

    return AuthState(
      status: AuthStatus.authenticated,
      email: user.email,
      displayName: user.userMetadata?['display_name'] as String?,
      isPremium: false,
      emailVerified: user.emailConfirmedAt != null,
    );
  }
}