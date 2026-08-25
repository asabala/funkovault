import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/models/pop.dart';
import 'package:funkovault2/screens/pop/add_pop_screen.dart';
import 'package:funkovault2/screens/pop/pop_details_screen.dart';
import 'package:funkovault2/screens/vault/collection_details_screen.dart';
import 'package:funkovault2/services/app_state.dart';
import 'package:provider/provider.dart';

class RecordingAppState extends AppState {
  String? requestedMergeCollection;
  int mergeCallCount = 0;

  String? deletedPopId;
  String? deletedCollectionName;
  String? deletedRecordKey;
  int deleteCallCount = 0;

  @override
  Future<bool> mergeDuplicates({String? collectionName}) async {
    mergeCallCount += 1;
    requestedMergeCollection = collectionName;

    return true;
  }

  @override
  Future<bool> deletePop(
      String popId, {
        String? collectionName,
        String? recordKey,
      }) async {
    deleteCallCount += 1;
    deletedPopId = popId;
    deletedCollectionName = collectionName;
    deletedRecordKey = recordKey;

    return true;
  }
}

void main() {
  const collectionName = 'Arthur Collection';

  Pop testPop() {
    return const Pop(
      id: 'scoped-pop',
      name: 'Scoped Batman',
      number: '01',
      category: 'Heroes',
      series: 'Batman',
      variant: 'Common',
      value: 25,
      pricePaid: 10,
      quantity: 1,
      itemCondition: 'Mint',
      boxCondition: 'Mint',
      imageUrl: '',
      owner: 'Shared',
      isWishlist: false,
    );
  }

  Future<void> pumpCollectionDetails(
      WidgetTester tester,
      RecordingAppState state, {
        bool includePop = false,
      }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 5000);

    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
      state.dispose();
    });

    if (includePop) {
      state.collections[collectionName]!.add(testPop());
    }

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: const MaterialApp(
          home: CollectionDetailsScreen(
            collectionName: collectionName,
          ),
        ),
      ),
    );

    await tester.pump();
  }

  testWidgets(
    'merge duplicates targets the collection shown by the screen',
        (tester) async {
      final state = RecordingAppState();

      expect(state.selectedCollection, 'Entire Family Collection');

      await pumpCollectionDetails(
        tester,
        state,
      );

      await tester.tap(find.byTooltip('Merge Duplicates'));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(state.mergeCallCount, 1);
      expect(state.requestedMergeCollection, collectionName);
      expect(state.selectedCollection, 'Entire Family Collection');
      expect(find.text('Duplicates merged'), findsOneWidget);
    },
  );

  testWidgets(
    'Pop Details receives the collection shown by the screen',
        (tester) async {
      final state = RecordingAppState();

      await pumpCollectionDetails(
        tester,
        state,
        includePop: true,
      );

      expect(find.text('Scoped Batman'), findsOneWidget);

      await tester.tap(find.text('Scoped Batman'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(PopDetailsScreen), findsOneWidget);

      final details = tester.widget<PopDetailsScreen>(
        find.byType(PopDetailsScreen),
      );

      expect(details.collectionName, collectionName);
      expect(details.pop.id, 'scoped-pop');
      expect(state.selectedCollection, 'Entire Family Collection');
    },
  );

  testWidgets(
    'Add Pop receives the collection shown by the screen',
        (tester) async {
      final state = RecordingAppState();

      await pumpCollectionDetails(
        tester,
        state,
      );

      await tester.tap(find.text('Add Pop'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(AddPopScreen), findsOneWidget);

      final addScreen = tester.widget<AddPopScreen>(
        find.byType(AddPopScreen),
      );

      expect(addScreen.collectionName, collectionName);
      expect(state.selectedCollection, 'Entire Family Collection');
    },
  );

  testWidgets(
    'delete targets collection and exact record identity',
        (tester) async {
      final state = RecordingAppState();
      final displayedPop = testPop();

      await pumpCollectionDetails(
        tester,
        state,
        includePop: true,
      );

      final dismissible = find.byKey(
        const Key('scoped-pop'),
      );

      expect(dismissible, findsOneWidget);

      await tester.drag(
        dismissible,
        const Offset(-800, 0),
      );

      await tester.pumpAndSettle();

      expect(find.text('Delete Pop'), findsOneWidget);

      await tester.tap(
        find.widgetWithText(
          ElevatedButton,
          'Delete',
        ),
      );

      await tester.pumpAndSettle();

      expect(state.deleteCallCount, 1);
      expect(state.deletedPopId, displayedPop.id);
      expect(state.deletedCollectionName, collectionName);
      expect(
        state.deletedRecordKey,
        displayedPop.collectionRecordKey,
      );

      expect(state.selectedCollection, 'Entire Family Collection');
    },
  );
}