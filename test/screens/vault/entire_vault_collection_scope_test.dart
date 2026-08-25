import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/models/pop.dart';
import 'package:funkovault2/screens/pop/edit_pop_screen.dart';
import 'package:funkovault2/screens/pop/pop_details_screen.dart';
import 'package:funkovault2/screens/vault/entire_vault_screen.dart';
import 'package:funkovault2/services/app_state.dart';
import 'package:funkovault2/services/hive_service.dart';
import 'package:funkovault2/widgets/atlas/atlas_stat_tile.dart';
import 'package:funkovault2/widgets/vault/components/vault_pop_tile.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

void main() {
  late Directory hiveDirectory;

  setUpAll(() async {
    hiveDirectory = await Directory.systemTemp.createTemp(
      'entire_vault_collection_scope_test_',
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
    required double value,
    String variant = 'Common',
  }) {
    return Pop(
      id: id,
      name: name,
      number: id,
      category: 'Heroes',
      series: 'Test',
      variant: variant,
      value: value,
      pricePaid: 0,
      quantity: 1,
      itemCondition: 'Mint',
      boxCondition: 'Mint',
      imageUrl: '',
      owner: 'Shared',
      isWishlist: false,
    );
  }

  AppState populatedState() {
    final state = AppState();
    state.collections['Entire Family Collection']!.addAll([
      pop(id: 'family-low', name: 'Family Low', value: 0),
      pop(id: 'family-high', name: 'Family High', value: 80),
    ]);
    state.collections['Arthur Collection']!.add(
      pop(id: 'arthur-only', name: 'Arthur Only', value: 35),
    );
    return state;
  }

  Future<void> pumpVault(
    WidgetTester tester,
    AppState state,
    EntireVaultScreen screen,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 8000);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(home: screen),
      ),
    );
    await tester.pump();
  }

  testWidgets('null collection scope preserves global Entire Vault', (
    tester,
  ) async {
    final state = populatedState();
    await pumpVault(tester, state, const EntireVaultScreen());

    expect(
      find.descendant(
        of: find.byType(VaultPopTile),
        matching: find.text('Family Low'),
      ),
      findsOneWidget,
    );
    expect(find.text('Family High'), findsOneWidget);
    expect(find.text('Arthur Only'), findsOneWidget);
    expect(find.text('Entire Vault'), findsWidgets);

    final popStat = tester
        .widgetList<AtlasStatTile>(find.byType(AtlasStatTile))
        .firstWhere((tile) => tile.label == 'Pops');
    expect(popStat.value, '3');
  });

  testWidgets('provided scope shows only the named collection', (tester) async {
    final state = populatedState();
    await pumpVault(
      tester,
      state,
      const EntireVaultScreen(collectionName: 'Arthur Collection'),
    );

    expect(find.text('Arthur Only'), findsOneWidget);
    expect(find.text('Family Low'), findsNothing);
    expect(find.text('Family High'), findsNothing);
    expect(find.text('Arthur Collection • Entire Vault'), findsOneWidget);

    final popStat = tester
        .widgetList<AtlasStatTile>(find.byType(AtlasStatTile))
        .firstWhere((tile) => tile.label == 'Pops');
    expect(popStat.value, '1');
  });

  testWidgets('missing scope never falls back to global data', (tester) async {
    final state = populatedState();
    await pumpVault(
      tester,
      state,
      const EntireVaultScreen(collectionName: 'Missing Collection'),
    );

    expect(find.text('Family Low'), findsNothing);
    expect(find.text('Arthur Only'), findsNothing);
    expect(find.text('This Collection Is Empty'), findsOneWidget);
  });

  testWidgets('search, filter, sort, and statistics use scoped data', (
    tester,
  ) async {
    final state = populatedState();
    await pumpVault(
      tester,
      state,
      const EntireVaultScreen(
        collectionName: 'Entire Family Collection',
        initialSortKey: 'highestValue',
      ),
    );

    expect(
      tester.getTopLeft(find.text('Family High')).dy,
      lessThan(tester.getTopLeft(find.text('Family Low')).dy),
    );

    final topStats = tester
        .widgetList<AtlasStatTile>(find.byType(AtlasStatTile))
        .where((tile) => {'Pops', 'Value', 'Need Value'}.contains(tile.label))
        .take(3)
        .toList();
    expect(topStats.map((tile) => tile.value), containsAll(['2', '\$80', '1']));

    await tester.enterText(find.byType(TextField).first, 'Family Low');
    await tester.pump();
    expect(
      find.descendant(
        of: find.byType(VaultPopTile),
        matching: find.text('Family Low'),
      ),
      findsOneWidget,
    );
    expect(find.text('Family High'), findsNothing);
    expect(find.textContaining('Showing 1 of 2 Pops'), findsOneWidget);

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: const MaterialApp(
          home: EntireVaultScreen(
            key: ValueKey('needs-value-scope'),
            collectionName: 'Entire Family Collection',
            initialFilterKey: 'needsValue',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Family Low'), findsOneWidget);
    expect(find.text('Family High'), findsNothing);
    expect(find.text('Arthur Only'), findsNothing);
  });

  testWidgets('scoped Vault tile forwards collection context to Pop Details', (
    tester,
  ) async {
    final state = populatedState();

    await pumpVault(
      tester,
      state,
      const EntireVaultScreen(collectionName: 'Arthur Collection'),
    );

    await tester.tap(find.text('Arthur Only'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(PopDetailsScreen), findsOneWidget);

    final details = tester.widget<PopDetailsScreen>(
      find.byType(PopDetailsScreen),
    );

    expect(details.collectionName, 'Arthur Collection');
  });

  testWidgets('scoped Needs Value editor forwards collection context', (
    tester,
  ) async {
    final state = populatedState();

    await pumpVault(
      tester,
      state,
      const EntireVaultScreen(
        collectionName: 'Entire Family Collection',
        initialFilterKey: 'needsValue',
      ),
    );

    final addValueButton = find.text('Add Value');

    expect(addValueButton, findsOneWidget);

    await tester.tap(addValueButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(EditPopScreen), findsOneWidget);

    final editor = tester.widget<EditPopScreen>(find.byType(EditPopScreen));

    expect(editor.collectionName, 'Entire Family Collection');
    expect(editor.pop.id, 'family-low');
  });
}
