import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'auth_state.dart';

class AuthController extends ChangeNotifier {
  AuthController({required this._authService});

  final AuthService _authService;

  AuthState _state = AuthState.guest();

  AuthState get state => _state;

  bool get isLoggedIn => _state.isLoggedIn;

  bool get isPremium => _state.isPremium;

  Future<void> loadCurrentUser() async {
    _state = await _authService.currentUser();

    notifyListeners();
  }

  Future<void> signIn({required String email, required String password}) async {
    _state = await _authService.signIn(email: email, password: password);

    notifyListeners();
  }

  Future<void> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    _state = await _authService.register(
      displayName: displayName,
      email: email,
      password: password,
    );

    notifyListeners();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  Future<void> signOut() async {
    await _authService.signOut();

    _state = AuthState.guest();

    notifyListeners();
  }
}
