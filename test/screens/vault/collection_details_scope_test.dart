import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/screens/vault/collection_details_screen.dart';
import 'package:funkovault2/services/app_state.dart';
import 'package:provider/provider.dart';

class RecordingAppState extends AppState {
  String? requestedMergeCollection;
  int mergeCallCount = 0;

  @override
  Future<bool> mergeDuplicates({String? collectionName}) async {
    mergeCallCount += 1;
    requestedMergeCollection = collectionName;

    return true;
  }
}

void main() {
  testWidgets('merge duplicates targets the collection shown by the screen', (
    tester,
  ) async {
    final state = RecordingAppState();

    expect(state.selectedCollection, 'Entire Family Collection');

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: const MaterialApp(
          home: CollectionDetailsScreen(collectionName: 'Arthur Collection'),
        ),
      ),
    );

    await tester.pump();

    await tester.tap(find.byTooltip('Merge Duplicates'));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(state.mergeCallCount, 1);

    expect(state.requestedMergeCollection, 'Arthur Collection');

    expect(state.selectedCollection, 'Entire Family Collection');

    expect(find.text('Duplicates merged'), findsOneWidget);
  });
}
