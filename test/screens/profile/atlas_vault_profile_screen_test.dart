import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/screens/profile/atlas_vault_profile_screen.dart';
import 'package:funkovault2/security/auth_controller.dart';
import 'package:funkovault2/security/auth_provider.dart';
import 'package:funkovault2/security/auth_service.dart';
import 'package:funkovault2/security/auth_state.dart';
import 'package:funkovault2/services/app_state.dart';
import 'package:provider/provider.dart';

class _TestAuthService implements AuthService {
  _TestAuthService(this.authState);

  final AuthState authState;

  @override
  Future<AuthState> currentUser() async {
    return authState;
  }

  @override
  Future<AuthState> signIn({
    required String email,
    required String password,
  }) async {
    return authState;
  }

  @override
  Future<AuthState> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    return authState;
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> resendVerificationEmail() async {}

  @override
  Future<AuthState> refreshUser() async {
    return authState;
  }
}

class _TestAuthProvider extends AuthProvider {
  _TestAuthProvider({required AuthState authState})
    : _testController = AuthController(
        authService: _TestAuthService(authState),
      );

  final AuthController _testController;

  @override
  AuthController get controller => _testController;

  @override
  bool get isLoggedIn => _testController.isLoggedIn;

  Future<void> initializeForTest() async {
    await _testController.loadCurrentUser();
    notifyListeners();
  }

  @override
  void dispose() {
    _testController.dispose();
    super.dispose();
  }
}

void main() {
  Future<void> pumpProfile(
    WidgetTester tester, {
    required AuthState authState,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 2400);

    final appState = AppState();

    final authProvider = _TestAuthProvider(authState: authState);

    await authProvider.initializeForTest();

    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();

      appState.dispose();
      authProvider.dispose();
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppState>.value(value: appState),
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ],
        child: const MaterialApp(home: AtlasVaultProfileScreen()),
      ),
    );

    await tester.pump();
  }

  testWidgets('guest profile shows guest account state', (tester) async {
    await pumpProfile(tester, authState: AuthState.guest());

    expect(find.text('Atlas Account'), findsOneWidget);

    expect(find.text('Using Atlas as Guest'), findsOneWidget);

    expect(
      find.text(
        'Sign in to connect this collector profile to an Atlas account.',
      ),
      findsOneWidget,
    );

    expect(find.text('Email verified'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('verified account shows email and verified state', (
    tester,
  ) async {
    await pumpProfile(
      tester,
      authState: const AuthState(
        status: AuthStatus.authenticated,
        email: 'arthur@example.com',
        displayName: 'Arthur',
        isPremium: false,
        emailVerified: true,
      ),
    );

    expect(find.text('Atlas Account'), findsOneWidget);

    expect(find.text('arthur@example.com'), findsOneWidget);

    expect(find.text('Email verified'), findsOneWidget);

    expect(find.text('Using Atlas as Guest'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('unverified account shows pending verification', (tester) async {
    await pumpProfile(
      tester,
      authState: const AuthState(
        status: AuthStatus.authenticated,
        email: 'arthur@example.com',
        displayName: 'Arthur',
        isPremium: false,
        emailVerified: false,
      ),
    );

    expect(find.text('arthur@example.com'), findsOneWidget);

    expect(find.text('Email verification pending'), findsOneWidget);

    expect(find.text('Email verified'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
