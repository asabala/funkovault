import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/models/pop.dart';
import 'package:funkovault2/screens/pop/pop_details_screen.dart';
import 'package:funkovault2/screens/vault/possible_duplicates_screen.dart';
import 'package:funkovault2/services/app_state.dart';
import 'package:provider/provider.dart';

void main() {
  const collectionName = 'Arthur Collection';

  Pop duplicatePop({
    required String id,
  }) {
    return Pop(
      id: id,
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

  Future<AppState> pumpScreen(
      WidgetTester tester,
      ) async {
    final state = AppState();

    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(
      1200,
      5000,
    );

    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
      state.dispose();
    });

    expect(
      state.selectedCollection,
      'Entire Family Collection',
    );

    state.collections[collectionName]!.addAll(
      [
        duplicatePop(
          id: 'scoped-batman-1',
        ),
        duplicatePop(
          id: 'scoped-batman-2',
        ),
      ],
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: const MaterialApp(
          home: PossibleDuplicatesScreen(
            collectionName: collectionName,
          ),
        ),
      ),
    );

    await tester.pump();

    return state;
  }

  testWidgets(
    'uses the collection passed to the screen instead of selected collection',
        (tester) async {
      final state = await pumpScreen(
        tester,
      );

      expect(
        state.selectedCollection,
        'Entire Family Collection',
      );

      expect(
        find.text('Scoped Batman'),
        findsWidgets,
      );

      expect(
        find.text('1 Exact Duplicates'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Open Details preserves the collection passed to the screen',
        (tester) async {
      final state = await pumpScreen(
        tester,
      );

      final openDetails = find.text(
        'Open Details',
      );

      expect(
        openDetails,
        findsNWidgets(2),
      );

      await tester.tap(
        openDetails.first,
      );

      await tester.pump();
      await tester.pump(
        const Duration(
          milliseconds: 300,
        ),
      );

      expect(
        find.byType(PopDetailsScreen),
        findsOneWidget,
      );

      final details =
      tester.widget<PopDetailsScreen>(
        find.byType(PopDetailsScreen),
      );

      expect(
        details.collectionName,
        collectionName,
      );

      expect(
        details.pop.name,
        'Scoped Batman',
      );

      expect(
        state.selectedCollection,
        'Entire Family Collection',
      );
    },
  );
}