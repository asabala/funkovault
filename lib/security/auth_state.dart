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
    this.userId,
  });

  final AuthStatus status;
  final String? userId;
  final String? email;
  final String? displayName;
  final bool isPremium;
  final bool emailVerified;

  bool get isLoggedIn =>
      status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? email,
    String? displayName,
    bool? isPremium,
    bool? emailVerified,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
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
      userId: null,
      email: null,
      displayName: null,
      isPremium: false,
      emailVerified: false,
    );
  }
}