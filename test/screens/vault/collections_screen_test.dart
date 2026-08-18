import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/models/pop.dart';
import 'package:funkovault2/screens/vault/collections_screen.dart';
import 'package:funkovault2/screens/vault/entire_vault_screen.dart';
import 'package:funkovault2/services/app_state.dart';
import 'package:funkovault2/vault/collector_vault_screen.dart';
import 'package:provider/provider.dart';

class _TestAppState extends AppState {
  CollectionOperationResult addResult = CollectionOperationResult.success;
  CollectionOperationResult selectResult = CollectionOperationResult.success;
  CollectionOperationResult renameResult = CollectionOperationResult.success;
  CollectionOperationResult deleteResult = CollectionOperationResult.success;

  String? requestedCreate;
  String? requestedSelect;
  ({String currentName, String newName})? requestedRename;
  String? requestedDelete;

  String _selectedCollection = 'Entire Family Collection';

  @override
  String get selectedCollection => _selectedCollection;

  @override
  Future<CollectionOperationResult> addCollection(String name) async {
    requestedCreate = name;
    return addResult;
  }

  @override
  Future<CollectionOperationResult> setSelectedCollection(String value) async {
    requestedSelect = value;
    if (selectResult == CollectionOperationResult.success) {
      _selectedCollection = value;
      notifyListeners();
    }
    return selectResult;
  }

  @override
  Future<CollectionOperationResult> renameCollection(
    String currentName,
    String newName,
  ) async {
    requestedRename = (currentName: currentName, newName: newName);
    return renameResult;
  }

  @override
  Future<CollectionOperationResult> deleteCollection(String name) async {
    requestedDelete = name;
    return deleteResult;
  }
}

class _RecordingNavigatorObserver extends NavigatorObserver {
  Route<dynamic>? lastPushedRoute;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (previousRoute != null) {
      lastPushedRoute = route;
    }
  }
}

void main() {
  Pop pop(String id, double value) {
    return Pop(
      id: id,
      name: 'Pop $id',
      number: id,
      category: 'Heroes',
      series: 'Test',
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

  Future<void> pumpScreen(
    WidgetTester tester,
    _TestAppState state, {
    Widget child = const CollectionsScreen(),
    NavigatorObserver? navigatorObserver,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 2400);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
      state.dispose();
    });

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(
          navigatorObservers: navigatorObserver == null
              ? const <NavigatorObserver>[]
              : <NavigatorObserver>[navigatorObserver],
          home: child,
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> pumpTransition(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('active collection is visibly indicated', (tester) async {
    final state = _TestAppState();
    await pumpScreen(tester, state);

    expect(find.text('Active'), findsOneWidget);
    expect(find.text(state.selectedCollection), findsWidgets);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('create collection succeeds', (tester) async {
    final state = _TestAppState();
    await pumpScreen(tester, state);

    await tester.tap(find.text('Create Collection'));
    await pumpTransition(tester);
    await tester.enterText(find.byType(TextFormField), 'Display Room');
    await tester.tap(find.widgetWithText(FilledButton, 'Create'));
    await pumpTransition(tester);

    expect(state.requestedCreate, 'Display Room');
    expect(find.text('Collection created.'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('duplicate collection failure is surfaced', (tester) async {
    final state = _TestAppState()
      ..addResult = CollectionOperationResult.duplicateName;
    await pumpScreen(tester, state);

    await tester.tap(find.text('Create Collection'));
    await pumpTransition(tester);
    await tester.enterText(find.byType(TextFormField), 'display room');
    await tester.tap(find.widgetWithText(FilledButton, 'Create'));
    await pumpTransition(tester);

    expect(state.requestedCreate, 'display room');
    expect(
      find.text('A collection with that name already exists.'),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('active collection selection is requested', (tester) async {
    final state = _TestAppState();
    await pumpScreen(tester, state);

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await pumpTransition(tester);
    await tester.tap(find.text('Arthur Collection').last);
    await pumpTransition(tester);

    expect(state.requestedSelect, 'Arthur Collection');
    expect(state.selectedCollection, 'Arthur Collection');

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('opening a collection uses scoped Entire Vault', (tester) async {
    final state = _TestAppState();
    final navigatorObserver = _RecordingNavigatorObserver();
    await pumpScreen(tester, state, navigatorObserver: navigatorObserver);

    final openButton = tester.widget<OutlinedButton>(
      find.byKey(const ValueKey('open-Arthur Collection')),
    );
    openButton.onPressed!();
    await tester.idle();

    expect(state.requestedSelect, 'Arthur Collection');
    final route = navigatorObserver.lastPushedRoute as MaterialPageRoute<void>;
    final screen = route.builder(
      tester.element(find.byType(CollectionsScreen)),
    );
    expect(screen, isA<EntireVaultScreen>());
    expect((screen as EntireVaultScreen).collectionName, 'Arthur Collection');

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('rename collection request is forwarded', (tester) async {
    final state = _TestAppState();
    await pumpScreen(tester, state);

    await tester.tap(
      find.byKey(const ValueKey('actions-Entire Family Collection')),
    );
    await pumpTransition(tester);
    await tester.tap(find.text('Rename'));
    await pumpTransition(tester);
    await tester.enterText(find.byType(TextFormField), 'Family Vault');
    await tester.tap(find.widgetWithText(FilledButton, 'Rename'));
    await pumpTransition(tester);

    expect(state.requestedRename, (
      currentName: 'Entire Family Collection',
      newName: 'Family Vault',
    ));

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('delete confirmation shows totals and forwards request', (
    tester,
  ) async {
    final state = _TestAppState();
    state.collections['Entire Family Collection']!.addAll([
      pop('1', 12),
      pop('2', 30),
    ]);
    await pumpScreen(tester, state);

    await tester.tap(
      find.byKey(const ValueKey('actions-Entire Family Collection')),
    );
    await pumpTransition(tester);
    await tester.tap(find.text('Delete'));
    await pumpTransition(tester);

    expect(
      find.textContaining('2 Pops • \$42.00 current value'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await pumpTransition(tester);
    expect(state.requestedDelete, 'Entire Family Collection');

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('canonical Vault exposes collection management', (tester) async {
    final state = _TestAppState();
    await pumpScreen(tester, state, child: const CollectorVaultScreen());

    await tester.tap(find.byTooltip('Manage Collections'));
    await pumpTransition(tester);

    expect(find.byType(CollectionsScreen), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
