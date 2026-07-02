enum AuthStatus {
  guest,
  authenticated,
}

class AuthState {
  const AuthState({
    required this.status,
    required this.email,
    required this.displayName,
    required this.isPremium,
    required this.emailVerified,
  });

  final AuthStatus status;
  final String? email;
  final String? displayName;
  final bool isPremium;
  final bool emailVerified;

  bool get isLoggedIn =>
      status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    String? email,
    String? displayName,
    bool? isPremium,
    bool? emailVerified,
  }) {
    return AuthState(
      status: status ?? this.status,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isPremium: isPremium ?? this.isPremium,
      emailVerified:
      emailVerified ?? this.emailVerified,
    );
  }

  factory AuthState.guest() {
    return const AuthState(
      status: AuthStatus.guest,
      email: null,
      displayName: null,
      isPremium: false,
      emailVerified: false,
    );
  }
}