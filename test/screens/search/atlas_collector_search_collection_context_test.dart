import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/models/pop.dart';
import 'package:funkovault2/screens/pop/pop_details_screen.dart';
import 'package:funkovault2/screens/search/atlas_collector_search_screen.dart';
import 'package:funkovault2/services/app_state.dart';
import 'package:provider/provider.dart';

class _SearchCollectionTestAppState extends AppState {
  _SearchCollectionTestAppState({required this.collectionLocations});

  final Map<String, List<String>> collectionLocations;

  @override
  List<String> collectionNamesContainingPop(Pop pop) {
    return List<String>.unmodifiable(
      collectionLocations[pop.collectionRecordKey] ?? const <String>[],
    );
  }
}

void main() {
  Pop testPop({String id = 'search-pop-1'}) {
    return Pop(
      id: id,
      name: 'Batman',
      number: '01',
      category: 'Heroes',
      series: 'Batman',
      variant: 'Common',
      value: 25,
      pricePaid: 10,
      quantity: 1,
      itemCondition: 'Mint',
      boxCondition: 'Near Mint',
      imageUrl: '',
      owner: 'Arthur',
      isWishlist: false,
    );
  }

  Future<void> pumpDetailsRoute(
    WidgetTester tester, {
    required _SearchCollectionTestAppState state,
    required Pop pop,
    required String? collectionName,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 8000);

    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return FilledButton(
                  onPressed: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) {
                          return PopDetailsScreen(
                            pop: pop,
                            collectionName: collectionName,
                          );
                        },
                      ),
                    );
                  },
                  child: const Text('Open Details'),
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Details'));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('unique global-search result opens scoped Pop Details', (
    WidgetTester tester,
  ) async {
    final Pop pop = testPop();

    final _SearchCollectionTestAppState state = _SearchCollectionTestAppState(
      collectionLocations: <String, List<String>>{
        pop.collectionRecordKey: <String>['Arthur Collection'],
      },
    );

    final List<String> collectionNames = state.collectionNamesContainingPop(
      pop,
    );

    expect(collectionNames, <String>['Arthur Collection']);

    final String? collectionName = collectionNames.length == 1
        ? collectionNames.single
        : null;

    await pumpDetailsRoute(
      tester,
      state: state,
      pop: pop,
      collectionName: collectionName,
    );

    expect(find.byType(PopDetailsScreen), findsOneWidget);

    final PopDetailsScreen details = tester.widget<PopDetailsScreen>(
      find.byType(PopDetailsScreen),
    );

    expect(details.collectionName, 'Arthur Collection');
  });

  testWidgets('zero-location global-search result stays unscoped', (
    WidgetTester tester,
  ) async {
    final Pop pop = testPop();

    final _SearchCollectionTestAppState state = _SearchCollectionTestAppState(
      collectionLocations: const <String, List<String>>{},
    );

    final List<String> collectionNames = state.collectionNamesContainingPop(
      pop,
    );

    expect(collectionNames, isEmpty);

    final String? collectionName = collectionNames.length == 1
        ? collectionNames.single
        : null;

    await pumpDetailsRoute(
      tester,
      state: state,
      pop: pop,
      collectionName: collectionName,
    );

    final PopDetailsScreen details = tester.widget<PopDetailsScreen>(
      find.byType(PopDetailsScreen),
    );

    expect(details.collectionName, isNull);
  });

  testWidgets('ambiguous multi-collection result stays unscoped', (
    WidgetTester tester,
  ) async {
    final Pop pop = testPop();

    final _SearchCollectionTestAppState state = _SearchCollectionTestAppState(
      collectionLocations: <String, List<String>>{
        pop.collectionRecordKey: <String>[
          'Entire Family Collection',
          'Arthur Collection',
        ],
      },
    );

    final List<String> collectionNames = state.collectionNamesContainingPop(
      pop,
    );

    expect(collectionNames, hasLength(2));

    final String? collectionName = collectionNames.length == 1
        ? collectionNames.single
        : null;

    await pumpDetailsRoute(
      tester,
      state: state,
      pop: pop,
      collectionName: collectionName,
    );

    final PopDetailsScreen details = tester.widget<PopDetailsScreen>(
      find.byType(PopDetailsScreen),
    );

    expect(details.collectionName, isNull);
  });

  testWidgets(
    'Atlas global search screen remains available without collection scope',
    (WidgetTester tester) async {
      final _SearchCollectionTestAppState state = _SearchCollectionTestAppState(
        collectionLocations: const <String, List<String>>{},
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
          child: const MaterialApp(home: AtlasCollectorSearchScreen()),
        ),
      );

      await tester.pump();

      expect(find.byType(AtlasCollectorSearchScreen), findsOneWidget);
    },
  );
}
