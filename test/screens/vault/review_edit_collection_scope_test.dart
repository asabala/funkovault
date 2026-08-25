import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/models/pop.dart';
import 'package:funkovault2/screens/pop/edit_pop_screen.dart';
import 'package:funkovault2/screens/vault/duplicate_group_review_screen.dart';
import 'package:funkovault2/screens/vault/multiple_copies_screen.dart';
import 'package:funkovault2/services/app_state.dart';
import 'package:funkovault2/services/hive_service.dart';
import 'package:funkovault2/vault/duplicate_review/duplicate_review_engine.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class _ReviewEditTestAppState extends AppState {
  _ReviewEditTestAppState({
    this.collectionResolutionOverrides = const <String, List<String>>{},
  });

  final Map<String, List<String>> collectionResolutionOverrides;

  @override
  List<String> collectionNamesContainingPop(Pop pop) {
    if (collectionResolutionOverrides.containsKey(pop.id)) {
      return List<String>.unmodifiable(
        collectionResolutionOverrides[pop.id]!,
      );
    }

    return super.collectionNamesContainingPop(pop);
  }
}

void main() {
  late Directory hiveDirectory;

  setUpAll(() async {
    hiveDirectory = await Directory.systemTemp.createTemp(
      'review_edit_collection_scope_test_',
    );
    Hive.init(hiveDirectory.path);
    await Hive.openBox(HiveService.boxName);
  });

  setUp(() async {
    await Hive.box(HiveService.boxName).clear();
  });

  tearDownAll(() async {
    await Hive.close();
    await hiveDirectory.delete(recursive: true);
  });

  Pop pop({
    required String id,
    required String name,
    String number = '77',
    double value = 25,
    int quantity = 1,
  }) {
    return Pop(
      id: id,
      name: name,
      number: number,
      category: 'Heroes',
      series: 'Test',
      variant: 'Common',
      value: value,
      pricePaid: 0,
      quantity: quantity,
      itemCondition: 'Mint',
      boxCondition: 'Mint',
      imageUrl: '',
      owner: 'Shared',
      isWishlist: false,
    );
  }

  String duplicateGroupKey(List<Pop> pops) {
    const engine = DuplicateReviewEngine();
    final groups = engine.buildGroups(pops);

    expect(groups, hasLength(1));

    return groups.single.key;
  }

  Future<void> pumpScreen(
      WidgetTester tester,
      AppState state,
      Widget screen,
      ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 5000);

    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
      state.dispose();
    });

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(home: screen),
      ),
    );

    await tester.pump();
  }

  testWidgets(
    'Multiple Copies explicit scope forwards collection to editor',
        (tester) async {
      final state = _ReviewEditTestAppState();

      final target = pop(
        id: 'multiple-explicit',
        name: 'Multiple Explicit',
        quantity: 2,
      );

      state.collections['Arthur Collection']!.add(target);

      await pumpScreen(
        tester,
        state,
        const MultipleCopiesScreen(
          collectionName: 'Arthur Collection',
        ),
      );

      expect(find.text('Edit Quantity'), findsOneWidget);

      await tester.tap(find.text('Edit Quantity'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(EditPopScreen), findsOneWidget);

      final editor = tester.widget<EditPopScreen>(
        find.byType(EditPopScreen),
      );

      expect(editor.collectionName, 'Arthur Collection');
      expect(editor.pop.id, 'multiple-explicit');
    },
  );

  testWidgets(
    'Multiple Copies global edit resolves exactly one collection',
        (tester) async {
      final state = _ReviewEditTestAppState();

      final target = pop(
        id: 'multiple-global-one',
        name: 'Multiple Global One',
        quantity: 2,
      );

      state.collections['Arthur Collection']!.add(target);

      await pumpScreen(
        tester,
        state,
        const MultipleCopiesScreen(),
      );

      await tester.tap(find.text('Edit Quantity'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(EditPopScreen), findsOneWidget);

      final editor = tester.widget<EditPopScreen>(
        find.byType(EditPopScreen),
      );

      expect(editor.collectionName, 'Arthur Collection');
      expect(editor.pop.id, 'multiple-global-one');
    },
  );

  testWidgets(
    'Multiple Copies global edit blocks zero collection matches',
        (tester) async {
      final state = _ReviewEditTestAppState(
        collectionResolutionOverrides: {
          'multiple-global-zero': <String>[],
        },
      );

      final target = pop(
        id: 'multiple-global-zero',
        name: 'Multiple Global Zero',
        quantity: 2,
      );

      state.collections['Arthur Collection']!.add(target);

      await pumpScreen(
        tester,
        state,
        const MultipleCopiesScreen(),
      );

      await tester.tap(find.text('Edit Quantity'));
      await tester.pump();

      expect(find.byType(EditPopScreen), findsNothing);
      expect(
        find.text(
          'Could not edit this Pop because its collection could not be resolved safely.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Multiple Copies global edit blocks multiple collection matches',
        (tester) async {
      final state = _ReviewEditTestAppState(
        collectionResolutionOverrides: {
          'multiple-global-many': <String>[
            'Arthur Collection',
            'Entire Family Collection',
          ],
        },
      );

      final target = pop(
        id: 'multiple-global-many',
        name: 'Multiple Global Many',
        quantity: 2,
      );

      state.collections['Arthur Collection']!.add(target);

      await pumpScreen(
        tester,
        state,
        const MultipleCopiesScreen(),
      );

      await tester.tap(find.text('Edit Quantity'));
      await tester.pump();

      expect(find.byType(EditPopScreen), findsNothing);
      expect(
        find.text(
          'Could not edit this Pop because its collection could not be resolved safely.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Duplicate Review explicit scope forwards collection to editor',
        (tester) async {
      final state = _ReviewEditTestAppState();

      final first = pop(
        id: 'duplicate-explicit-a',
        name: 'Duplicate Explicit',
      );

      final second = pop(
        id: 'duplicate-explicit-b',
        name: 'Duplicate Explicit',
      );

      final duplicates = <Pop>[first, second];

      state.collections['Arthur Collection']!.addAll(duplicates);

      await pumpScreen(
        tester,
        state,
        DuplicateGroupReviewScreen(
          groupKey: duplicateGroupKey(duplicates),
          collectionName: 'Arthur Collection',
        ),
      );

      final editButton = find.widgetWithText(
        OutlinedButton,
        'Edit Details',
      );

      expect(editButton, findsNWidgets(2));

      await tester.tap(editButton.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(EditPopScreen), findsOneWidget);

      final editor = tester.widget<EditPopScreen>(
        find.byType(EditPopScreen),
      );

      expect(editor.collectionName, 'Arthur Collection');
    },
  );

  testWidgets(
    'Duplicate Review global edit resolves exactly one collection',
        (tester) async {
      final state = _ReviewEditTestAppState();

      final first = pop(
        id: 'duplicate-global-one-a',
        name: 'Duplicate Global One',
      );

      final second = pop(
        id: 'duplicate-global-one-b',
        name: 'Duplicate Global One',
      );

      final duplicates = <Pop>[first, second];

      state.collections['Arthur Collection']!.addAll(duplicates);

      await pumpScreen(
        tester,
        state,
        DuplicateGroupReviewScreen(
          groupKey: duplicateGroupKey(duplicates),
        ),
      );

      await tester.tap(
        find.widgetWithText(
          OutlinedButton,
          'Edit Details',
        ).first,
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(EditPopScreen), findsOneWidget);

      final editor = tester.widget<EditPopScreen>(
        find.byType(EditPopScreen),
      );

      expect(editor.collectionName, 'Arthur Collection');
    },
  );

  testWidgets(
    'Duplicate Review global edit blocks zero collection matches',
        (tester) async {
      final state = _ReviewEditTestAppState(
        collectionResolutionOverrides: {
          'duplicate-global-zero-a': <String>[],
          'duplicate-global-zero-b': <String>[],
        },
      );

      final first = pop(
        id: 'duplicate-global-zero-a',
        name: 'Duplicate Global Zero',
      );

      final second = pop(
        id: 'duplicate-global-zero-b',
        name: 'Duplicate Global Zero',
      );

      final duplicates = <Pop>[first, second];

      state.collections['Arthur Collection']!.addAll(duplicates);

      await pumpScreen(
        tester,
        state,
        DuplicateGroupReviewScreen(
          groupKey: duplicateGroupKey(duplicates),
        ),
      );

      await tester.tap(
        find.widgetWithText(
          OutlinedButton,
          'Edit Details',
        ).first,
      );

      await tester.pump();

      expect(find.byType(EditPopScreen), findsNothing);
      expect(
        find.text(
          'Could not edit this Pop because its collection could not be resolved safely.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Duplicate Review global edit blocks multiple collection matches',
        (tester) async {
      final state = _ReviewEditTestAppState(
        collectionResolutionOverrides: {
          'duplicate-global-many-a': <String>[
            'Arthur Collection',
            'Entire Family Collection',
          ],
          'duplicate-global-many-b': <String>[
            'Arthur Collection',
            'Entire Family Collection',
          ],
        },
      );

      final first = pop(
        id: 'duplicate-global-many-a',
        name: 'Duplicate Global Many',
      );

      final second = pop(
        id: 'duplicate-global-many-b',
        name: 'Duplicate Global Many',
      );

      final duplicates = <Pop>[first, second];

      state.collections['Arthur Collection']!.addAll(duplicates);

      await pumpScreen(
        tester,
        state,
        DuplicateGroupReviewScreen(
          groupKey: duplicateGroupKey(duplicates),
        ),
      );

      await tester.tap(
        find.widgetWithText(
          OutlinedButton,
          'Edit Details',
        ).first,
      );

      await tester.pump();

      expect(find.byType(EditPopScreen), findsNothing);
      expect(
        find.text(
          'Could not edit this Pop because its collection could not be resolved safely.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Duplicate Review Add Value resolves collection and preserves value focus',
        (tester) async {
      final state = _ReviewEditTestAppState();

      final first = pop(
        id: 'duplicate-value-a',
        name: 'Duplicate Needs Value',
        value: 0,
      );

      final second = pop(
        id: 'duplicate-value-b',
        name: 'Duplicate Needs Value',
        value: 0,
      );

      final duplicates = <Pop>[first, second];

      state.collections['Arthur Collection']!.addAll(duplicates);

      await pumpScreen(
        tester,
        state,
        DuplicateGroupReviewScreen(
          groupKey: duplicateGroupKey(duplicates),
        ),
      );

      final addValueButton = find.widgetWithText(
        FilledButton,
        'Add Value',
      );

      expect(addValueButton, findsNWidgets(2));

      await tester.tap(addValueButton.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(EditPopScreen), findsOneWidget);

      final editor = tester.widget<EditPopScreen>(
        find.byType(EditPopScreen),
      );

      expect(editor.collectionName, 'Arthur Collection');
      expect(editor.focusValueField, isTrue);
    },
  );
}