import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/screens/catalog/funko_catalog_screen.dart';
import 'package:funkovault2/screens/pop/add_pop_screen.dart';
import 'package:funkovault2/services/app_state.dart';
import 'package:provider/provider.dart';

class _CatalogCollectionTestAppState extends AppState {
  _CatalogCollectionTestAppState({required this.currentSelection});

  final String currentSelection;

  @override
  String get selectedCollection => currentSelection;
}

void main() {
  testWidgets(
    'explicit catalog collection is preserved instead of selected collection',
    (WidgetTester tester) async {
      final _CatalogCollectionTestAppState state =
          _CatalogCollectionTestAppState(
            currentSelection: 'Entire Family Collection',
          );

      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1200, 8000);

      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: state,
          child: const MaterialApp(
            home: FunkoCatalogScreen(collectionName: 'Arthur Collection'),
          ),
        ),
      );

      await tester.pump();

      final FunkoCatalogScreen catalogScreen = tester
          .widget<FunkoCatalogScreen>(find.byType(FunkoCatalogScreen));

      expect(catalogScreen.collectionName, 'Arthur Collection');

      expect(catalogScreen.collectionName, isNot(state.selectedCollection));
    },
  );

  testWidgets(
    'catalog without explicit collection preserves legacy entry behavior',
    (WidgetTester tester) async {
      final _CatalogCollectionTestAppState state =
          _CatalogCollectionTestAppState(
            currentSelection: 'Entire Family Collection',
          );

      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1200, 8000);

      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: state,
          child: const MaterialApp(home: FunkoCatalogScreen()),
        ),
      );

      await tester.pump();

      expect(find.byType(FunkoCatalogScreen), findsOneWidget);
    },
  );

  testWidgets('AddPopScreen keeps explicit collection when opened directly', (
    WidgetTester tester,
  ) async {
    final _CatalogCollectionTestAppState state = _CatalogCollectionTestAppState(
      currentSelection: 'Entire Family Collection',
    );

    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 8000);

    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: const MaterialApp(
          home: AddPopScreen(collectionName: 'Arthur Collection'),
        ),
      ),
    );

    await tester.pump();

    final AddPopScreen addScreen = tester.widget<AddPopScreen>(
      find.byType(AddPopScreen),
    );

    expect(addScreen.collectionName, 'Arthur Collection');

    expect(addScreen.collectionName, isNot(state.selectedCollection));
  });
}
