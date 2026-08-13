import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/academy/models/academy_request_submission_result.dart';
import 'package:funkovault2/widgets/academy/shared/academy_topic_request_card.dart';

void main() {
  Widget buildCard({
    required AcademyRequestStorageBehavior storageBehavior,
    Future<bool> Function(String topic)? onSubmit,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: AcademyTopicRequestCard(
          storageBehavior: storageBehavior,
          onSubmit: onSubmit,
        ),
      ),
    );
  }

  testWidgets('clears topic only after successful submission', (tester) async {
    await tester.pumpWidget(
      buildCard(
        storageBehavior: AcademyRequestStorageBehavior.sessionOnly,
        onSubmit: (_) async => true,
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'Sticker history');
    await tester.pump();
    await tester.tap(find.byTooltip('Submit topic request'));
    await tester.pumpAndSettle();

    expect(find.text('Sticker history'), findsNothing);
  });

  testWidgets('retains topic after unsuccessful submission', (tester) async {
    await tester.pumpWidget(
      buildCard(
        storageBehavior: AcademyRequestStorageBehavior.sessionOnly,
        onSubmit: (_) async => false,
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'Sticker history');
    await tester.pump();
    await tester.tap(find.byTooltip('Submit topic request'));
    await tester.pumpAndSettle();

    expect(find.text('Sticker history'), findsOneWidget);
  });

  testWidgets('blocks duplicate submission while pending', (tester) async {
    final Completer<bool> completer = Completer<bool>();
    int submissionCount = 0;

    await tester.pumpWidget(
      buildCard(
        storageBehavior: AcademyRequestStorageBehavior.sessionOnly,
        onSubmit: (_) {
          submissionCount++;
          return completer.future;
        },
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'Sticker history');
    await tester.tap(find.byTooltip('Submit topic request'));
    await tester.pump();
    await tester.tap(find.byTooltip('Submit topic request'));
    await tester.pump();

    expect(submissionCount, 1);

    completer.complete(true);
    await tester.pumpAndSettle();
  });

  testWidgets('disables form when storage is unavailable', (tester) async {
    await tester.pumpWidget(
      buildCard(storageBehavior: AcademyRequestStorageBehavior.unavailable),
    );

    final TextFormField field = tester.widget<TextFormField>(
      find.byType(TextFormField),
    );

    expect(field.enabled, isFalse);
    expect(find.text('Requests Unavailable'), findsOneWidget);
    expect(
      find.text(
        'Topic requests will be enabled when durable request storage is connected.',
      ),
      findsOneWidget,
    );
  });
}
