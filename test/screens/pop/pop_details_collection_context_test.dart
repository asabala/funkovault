import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/models/activity.dart';
import 'package:funkovault2/models/pop.dart';
import 'package:funkovault2/screens/pop/edit_pop_screen.dart';
import 'package:funkovault2/screens/pop/pop_details_screen.dart';
import 'package:funkovault2/services/app_state.dart';
import 'package:provider/provider.dart';

class _TestAppState extends AppState {
  Pop? updatedPop;
  String? updatedCollectionName;
  String? updatedExistingRecordKey;
  bool updateSucceeds = true;

  String? deletedPopId;
  String? deletedCollectionName;
  String? deletedRecordKey;
  bool deleteSucceeds = true;

  final List<Activity> recordedActivities = <Activity>[];

  @override
  Future<Pop?> updatePop(
    Pop pop, {
    String? collectionName,
    String? existingRecordKey,
  }) async {
    updatedPop = pop;
    updatedCollectionName = collectionName;
    updatedExistingRecordKey = existingRecordKey;

    return updateSucceeds ? pop : null;
  }

  @override
  Future<bool> deletePop(
    String popId, {
    String? collectionName,
    String? recordKey,
  }) async {
    deletedPopId = popId;
    deletedCollectionName = collectionName;
    deletedRecordKey = recordKey;

    return deleteSucceeds;
  }

  @override
  Future<void> addActivity(Activity activity) async {
    recordedActivities.add(activity);
  }
}

void main() {
  const collectionName = 'Arthur Collection';

  Pop pop() {
    return const Pop(
      id: 'shared-id',
      name: 'Batman',
      number: '01',
      category: 'Heroes',
      series: 'Batman',
      variant: 'Chase',
      value: 25,
      pricePaid: 10,
      quantity: 1,
      itemCondition: 'Mint',
      boxCondition: 'Near Mint',
      imageUrl: '',
      owner: 'Shared',
      isWishlist: false,
    );
  }

  Future<void> pumpDetails(
    WidgetTester tester,
    _TestAppState state,
    Pop displayedPop,
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
        child: MaterialApp(
          home: PopDetailsScreen(
            pop: displayedPop,
            collectionName: collectionName,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Finder appBarIcon(IconData icon) {
    return find.descendant(
      of: find.byType(AppBar),
      matching: find.byIcon(icon),
    );
  }

  testWidgets('Edit receives the originating collection', (tester) async {
    final state = _TestAppState();
    await pumpDetails(tester, state, pop());

    await tester.tap(appBarIcon(Icons.edit_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(EditPopScreen), findsOneWidget);

    final editor = tester.widget<EditPopScreen>(find.byType(EditPopScreen));
    expect(editor.collectionName, collectionName);
    expect(editor.pop.collectionRecordKey, pop().collectionRecordKey);
  });

  testWidgets('wishlist update is scoped by collection and record identity', (
    tester,
  ) async {
    final state = _TestAppState();
    final displayedPop = pop();
    await pumpDetails(tester, state, displayedPop);

    await tester.tap(appBarIcon(Icons.favorite_border));
    await tester.pump();

    expect(state.updatedPop?.isWishlist, isTrue);
    expect(state.updatedCollectionName, collectionName);
    expect(state.updatedExistingRecordKey, displayedPop.collectionRecordKey);
    expect(state.recordedActivities.single.action, 'wishlist_added');
  });

  testWidgets('failed scoped update records no activity or local change', (
    tester,
  ) async {
    final state = _TestAppState()..updateSucceeds = false;
    await pumpDetails(tester, state, pop());

    await tester.tap(appBarIcon(Icons.favorite_border));
    await tester.pump();

    expect(state.recordedActivities, isEmpty);
    expect(appBarIcon(Icons.favorite_border), findsOneWidget);
    expect(
      find.text('This Pop could not be found. No changes were saved.'),
      findsOneWidget,
    );
  });
}
