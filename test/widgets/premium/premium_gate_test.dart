import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/widgets/premium/premium_gate.dart';

void main() {
  testWidgets(
    'shows premium content when access is enabled',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PremiumGate(
              isPremium: true,
              lockedTitle: 'Premium Feature',
              lockedDescription: 'Premium access required.',
              child: Text('Unlocked Content'),
            ),
          ),
        ),
      );

      expect(
        find.text('Unlocked Content'),
        findsOneWidget,
      );

      expect(
        find.text('Premium Feature'),
        findsNothing,
      );
    },
  );

  testWidgets(
    'shows premium lock when access is disabled',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PremiumGate(
              isPremium: false,
              lockedTitle: 'Premium Feature',
              lockedDescription: 'Premium access required.',
              child: Text('Unlocked Content'),
            ),
          ),
        ),
      );

      expect(
        find.text('Premium Feature'),
        findsOneWidget,
      );

      expect(
        find.text('Premium access required.'),
        findsOneWidget,
      );

      expect(
        find.text('Upgrade to Premium'),
        findsOneWidget,
      );

      expect(
        find.text('Unlocked Content'),
        findsNothing,
      );
    },
  );

  testWidgets(
    'runs upgrade action for locked feature',
        (tester) async {
      var upgradePressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PremiumGate(
              isPremium: false,
              lockedTitle: 'Premium Feature',
              lockedDescription: 'Premium access required.',
              onUpgrade: () {
                upgradePressed = true;
              },
              child: const Text('Unlocked Content'),
            ),
          ),
        ),
      );

      await tester.tap(
        find.text('Upgrade to Premium'),
      );

      await tester.pump();

      expect(
        upgradePressed,
        isTrue,
      );
    },
  );
}