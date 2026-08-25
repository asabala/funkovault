import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/models/pop.dart';
import 'package:funkovault2/screens/settings/import_csv_screen.dart';
import 'package:funkovault2/services/app_state.dart';
import 'package:provider/provider.dart';

class _ImportCsvTestAppState extends AppState {
  String _selectedCollection = 'Captured Collection';

  String? requestedCollectionName;
  List<Pop>? requestedPops;

  @override
  String get selectedCollection => _selectedCollection;

  @override
  Future<CollectionOperationResult> setSelectedCollection(String value) async {
    _selectedCollection = value;
    notifyListeners();
    return CollectionOperationResult.success;
  }

  @override
  Future<PopImportResult> importPopsSafely(
    List<Pop> importedPops, {
    String? collectionName,
  }) async {
    requestedPops = List<Pop>.from(importedPops);
    requestedCollectionName = collectionName;

    return PopImportResult(
      attempted: importedPops.length,
      added: importedPops.length,
      skipped: 0,
    );
  }
}

void main() {
  testWidgets(
    'ImportCsvScreen preserves collection captured when screen opens',
    (tester) async {
      final state = _ImportCsvTestAppState();

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
          child: const MaterialApp(home: ImportCsvScreen()),
        ),
      );

      await tester.pump();

      expect(state.selectedCollection, 'Captured Collection');

      await state.setSelectedCollection('Later Collection');

      await tester.pump();

      await tester.enterText(
        find.byType(TextField),
        'Name,Reference Number\nBatman,01',
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Import'));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(state.requestedCollectionName, 'Captured Collection');

      expect(state.requestedPops, isNotNull);

      expect(state.requestedPops, hasLength(1));

      expect(state.requestedPops!.single.name, 'Batman');

      expect(state.selectedCollection, 'Later Collection');

      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
