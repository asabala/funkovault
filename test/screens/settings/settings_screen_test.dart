import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/screens/auth/login_screen.dart';
import 'package:funkovault2/screens/settings/settings_screen.dart';
import 'package:funkovault2/security/auth_provider.dart';
import 'package:provider/provider.dart';

class _TestAuthProvider extends AuthProvider {
  _TestAuthProvider({required this.loggedIn});

  bool loggedIn;
  bool signOutCalled = false;

  @override
  bool get isLoggedIn => loggedIn;

  @override
  Future<void> signOut() async {
    signOutCalled = true;
    loggedIn = false;
    notifyListeners();
  }
}

void main() {
  Future<void> pumpSettings(
    WidgetTester tester,
    _TestAuthProvider authProvider,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 2400);

    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
      authProvider.dispose();
    });

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: authProvider,
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );

    await tester.pump();
  }

  testWidgets('guest sees Sign In instead of Sign Out', (tester) async {
    final authProvider = _TestAuthProvider(loggedIn: false);

    await pumpSettings(tester, authProvider);

    expect(find.text('Sign In'), findsOneWidget);

    expect(find.text('Sign Out'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('authenticated user sees Sign Out instead of Sign In', (
    tester,
  ) async {
    final authProvider = _TestAuthProvider(loggedIn: true);

    await pumpSettings(tester, authProvider);

    expect(find.text('Sign Out'), findsOneWidget);

    expect(find.text('Sign In'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Sign Out clears session and returns to Login', (tester) async {
    final authProvider = _TestAuthProvider(loggedIn: true);

    await pumpSettings(tester, authProvider);

    await tester.tap(find.text('Sign Out'));

    await tester.pumpAndSettle();

    expect(authProvider.signOutCalled, isTrue);

    expect(authProvider.isLoggedIn, isFalse);

    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
