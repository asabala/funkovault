import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/models/pop.dart';
import 'package:funkovault2/screens/catalog/funko_catalog_screen.dart';
import 'package:funkovault2/screens/vault/atlas_room_screen.dart';
import 'package:funkovault2/services/app_state.dart';
import 'package:provider/provider.dart';

class _TestAppState extends AppState {}

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
  Pop pop({
    required String id,
    required String name,
    required double value,
    bool isWishlist = false,
  }) {
    return Pop(
      id: id,
      name: name,
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
      isWishlist: isWishlist,
    );
  }

  Future<void> pumpRoom(
    WidgetTester tester,
    _TestAppState state, {
    required String collectionName,
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
          home: AtlasRoomScreen(
            roomName: collectionName,
            description: 'Collection room',
            icon: Icons.folder_outlined,
            collectionName: collectionName,
          ),
        ),
      ),
    );

    await tester.pump();
  }

  testWidgets('collection room uses only the requested collection', (
    tester,
  ) async {
    final state = _TestAppState();

    state.collections['Entire Family Collection']!.add(
      pop(id: 'family-pop', name: 'Family Pop', value: 10),
    );

    state.collections['Arthur Collection']!.add(
      pop(id: 'arthur-pop', name: 'Arthur Pop', value: 25, isWishlist: true),
    );

    await pumpRoom(tester, state, collectionName: 'Arthur Collection');

    expect(find.text('Arthur Pop'), findsOneWidget);

    expect(find.text('Family Pop'), findsNothing);

    expect(find.text('\$25'), findsWidgets);

    expect(find.text('1'), findsWidgets);

    expect(find.byKey(const ValueKey('start-shelf-scan')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('browse catalog preserves collection scope', (tester) async {
    final state = _TestAppState();
    final navigatorObserver = _RecordingNavigatorObserver();

    await pumpRoom(
      tester,
      state,
      collectionName: 'Arthur Collection',
      navigatorObserver: navigatorObserver,
    );

    final browseButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Browse Catalog'),
    );

    browseButton.onPressed!();

    await tester.idle();

    final route =
        navigatorObserver.lastPushedRoute as MaterialPageRoute<dynamic>;

    final screen = route.builder(tester.element(find.byType(AtlasRoomScreen)));

    expect(screen, isA<FunkoCatalogScreen>());

    expect((screen as FunkoCatalogScreen).collectionName, 'Arthur Collection');

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
