import 'package:flutter/material.dart';

import 'auth_controller.dart';
import '../subscriptions/revenuecat_subscription_service.dart';
import 'supabase_auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider()
      : _controller = AuthController(
    authService: const SupabaseAuthService(),
  );

  final AuthController _controller;

  AuthController get controller => _controller;

  bool get isLoggedIn => _controller.isLoggedIn;

  bool get isPremium => _controller.isPremium;

  Future<void> initialize() async {
    await _controller.loadCurrentUser();

    final userId = _controller.state.userId;

    if (_controller.isLoggedIn && userId != null) {
      await RevenueCatSubscriptionService.logIn(
        userId,
      );
    }

    notifyListeners();
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _controller.signIn(
      email: email,
      password: password,
    );

    final userId = _controller.state.userId;

    if (_controller.isLoggedIn && userId != null) {
      await RevenueCatSubscriptionService.logIn(
        userId,
      );
    }

    notifyListeners();
  }

  Future<void> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    await _controller.register(
      displayName: displayName,
      email: email,
      password: password,
    );

    notifyListeners();
  }

  Future<void> signOut() async {
    await RevenueCatSubscriptionService.logOut();

    await _controller.signOut();

    notifyListeners();
  }
}