import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/screens/home/atlas_home_screen.dart';
import 'package:funkovault2/security/auth_provider.dart';
import 'package:funkovault2/services/app_state.dart';
import 'package:provider/provider.dart';

class _TestAuthProvider extends AuthProvider {
  _TestAuthProvider({required this.loggedIn});

  bool loggedIn;

  @override
  bool get isLoggedIn => loggedIn;
}

void main() {
  Future<void> pumpHome(WidgetTester tester, {required bool isLoggedIn}) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 2400);

    final appState = AppState();
    final authProvider = _TestAuthProvider(loggedIn: isLoggedIn);

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
        child: const MaterialApp(home: AtlasHomeScreen()),
      ),
    );

    await tester.pump();
  }

  testWidgets('guest account status does not claim user is signed in', (
    tester,
  ) async {
    await pumpHome(tester, isLoggedIn: false);

    expect(find.text('Using Atlas as Guest'), findsOneWidget);

    expect(find.text('Sign in to connect your Atlas account.'), findsOneWidget);

    expect(find.text('Signed in as Arthur'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('authenticated account status shows signed in state', (
    tester,
  ) async {
    await pumpHome(tester, isLoggedIn: true);

    expect(find.text('Signed in as Arthur'), findsOneWidget);

    expect(find.text('Using Atlas as Guest'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
