import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/screens/settings/premium_settings_screen.dart';
import 'package:funkovault2/security/auth_controller.dart';
import 'package:funkovault2/security/auth_provider.dart';
import 'package:funkovault2/security/auth_service.dart';
import 'package:funkovault2/security/auth_state.dart';
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
  Future<void> sendPasswordResetEmail(
      String email,
      ) async {}

  @override
  Future<void> resendVerificationEmail() async {}

  @override
  Future<AuthState> refreshUser() async {
    return authState;
  }
}

class _TestAuthProvider extends AuthProvider {
  _TestAuthProvider({
    required AuthState authState,
  }) : _testController = AuthController(
    authService: _TestAuthService(
      authState,
    ),
  );

  final AuthController _testController;

  @override
  AuthController get controller =>
      _testController;

  @override
  bool get isPremium =>
      _testController.isPremium;

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
  Future<void> pumpPremiumSettings(
      WidgetTester tester, {
        required AuthState authState,
      }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(
      1200,
      2400,
    );

    final authProvider = _TestAuthProvider(
      authState: authState,
    );

    await authProvider.initializeForTest();

    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
      authProvider.dispose();
    });

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: authProvider,
        child: const MaterialApp(
          home: PremiumSettingsScreen(),
        ),
      ),
    );

    await tester.pump();
  }

  testWidgets(
    'basic account shows basic premium state',
        (tester) async {
      await pumpPremiumSettings(
        tester,
        authState: const AuthState(
          status: AuthStatus.authenticated,
          email: 'arthur@example.com',
          displayName: 'Arthur',
          isPremium: false,
          emailVerified: true,
        ),
      );

      expect(
        find.text('Atlas Premium'),
        findsOneWidget,
      );

      expect(
        find.text('Basic Plan'),
        findsOneWidget,
      );

      expect(
        find.text('Premium Active'),
        findsNothing,
      );

      await tester.pumpWidget(
        const SizedBox.shrink(),
      );
    },
  );

  testWidgets(
    'premium account shows premium state from AuthState',
        (tester) async {
      await pumpPremiumSettings(
        tester,
        authState: const AuthState(
          status: AuthStatus.authenticated,
          email: 'arthur@example.com',
          displayName: 'Arthur',
          isPremium: true,
          emailVerified: true,
        ),
      );

      expect(
        find.text('Premium Active'),
        findsOneWidget,
      );

      expect(
        find.text('Premium Plan'),
        findsOneWidget,
      );

      expect(
        find.text(
          'Premium tools are enabled for your Atlas account.',
        ),
        findsOneWidget,
      );

      expect(
        find.text('Basic Plan'),
        findsNothing,
      );

      await tester.pumpWidget(
        const SizedBox.shrink(),
      );
    },
  );
}