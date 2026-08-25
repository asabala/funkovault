import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/atlas/catalog/services/atlas_barcode_catalog_resolver.dart';
import 'package:funkovault2/atlas/scan/models/scan_code.dart';
import 'package:funkovault2/atlas/scan/models/scan_session.dart';
import 'package:funkovault2/atlas/scan/models/scanner_type.dart';
import 'package:funkovault2/atlas/scan/workflow/scan_intent.dart';
import 'package:funkovault2/atlas/scan/workflow/scan_performance_mode.dart';
import 'package:funkovault2/models/pop.dart';
import 'package:funkovault2/screens/pop/add_pop_screen.dart';
import 'package:funkovault2/screens/scanner/atlas_scan_result_screen.dart';
import 'package:funkovault2/services/app_state.dart';
import 'package:provider/provider.dart';

class _ScannerTestAppState extends AppState {
  final List<String> requestedCollectionNames = <String>[];

  List<Pop> popsForRequestedCollection = const <Pop>[];

  @override
  List<Pop> popsForCollection(String collectionName) {
    requestedCollectionNames.add(collectionName);

    return List<Pop>.unmodifiable(popsForRequestedCollection);
  }
}

void main() {
  const String capturedCollectionName = 'Arthur Collection';

  ScanCode scanCode() {
    return ScanCode(
      rawValue: '889698123456',
      normalizedValue: '889698123456',
      format: ScanCodeFormat.upcA,
      source: ScanCodeSource.camera,
      capturedAt: DateTime.utc(2026, 8, 25),
      isValid: true,
      confidence: 1.0,
    );
  }

  ScanSession scanSession() {
    final ScanCode code = scanCode();

    return ScanSession(
      sessionId: 'scanner-context-test',
      startedAt: DateTime.utc(2026, 8, 25),
      status: ScanSessionStatus.completed,
      intent: ScanIntent.identifyProduct,
      performanceMode: ScanPerformanceMode.fastBarcodeOnly,
      scannerType: ScannerType.mobileScanner,
      detectedCodes: <ScanCode>[code],
      bestCandidate: code,
    );
  }

  Future<void> pumpResult(
    WidgetTester tester, {
    required AppState state,
    required AtlasBarcodeResolution resolution,
    String collectionName = capturedCollectionName,
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
          home: AtlasScanResultScreen(
            session: scanSession(),
            catalogResolution: resolution,
            collectionName: collectionName,
          ),
        ),
      ),
    );

    await tester.pump();
  }

  testWidgets('manual add receives the captured scan collection', (
    WidgetTester tester,
  ) async {
    final _ScannerTestAppState state = _ScannerTestAppState();

    await pumpResult(
      tester,
      state: state,
      resolution: AtlasBarcodeResolution.invalid(
        barcode: scanCode().normalizedValue,
      ),
    );

    expect(state.selectedCollection, isNot(capturedCollectionName));

    final Finder manualAddButton = find.text('Enter Product Manually');

    expect(manualAddButton, findsOneWidget);

    await tester.tap(manualAddButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(AddPopScreen), findsOneWidget);

    final AddPopScreen addScreen = tester.widget<AddPopScreen>(
      find.byType(AddPopScreen),
    );

    expect(addScreen.collectionName, capturedCollectionName);
  });

  testWidgets(
    'missing captured collection is forwarded instead of falling back',
    (WidgetTester tester) async {
      final _ScannerTestAppState state = _ScannerTestAppState();

      const String deletedCollectionName = 'Deleted Collection';

      await pumpResult(
        tester,
        state: state,
        collectionName: deletedCollectionName,
        resolution: AtlasBarcodeResolution.invalid(
          barcode: scanCode().normalizedValue,
        ),
      );

      final Finder manualAddButton = find.text('Enter Product Manually');

      expect(manualAddButton, findsOneWidget);

      await tester.tap(manualAddButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(AddPopScreen), findsOneWidget);

      final AddPopScreen addScreen = tester.widget<AddPopScreen>(
        find.byType(AddPopScreen),
      );

      expect(addScreen.collectionName, deletedCollectionName);

      expect(addScreen.collectionName, isNot(state.selectedCollection));
    },
  );

  testWidgets('no-match Vault lookup uses the captured collection', (
    WidgetTester tester,
  ) async {
    final _ScannerTestAppState state = _ScannerTestAppState();

    await pumpResult(
      tester,
      state: state,
      resolution: AtlasBarcodeResolution.noMatch(
        barcode: scanCode().normalizedValue,
      ),
    );

    expect(state.requestedCollectionNames, isNotEmpty);

    expect(
      state.requestedCollectionNames.every(
        (String collectionName) => collectionName == capturedCollectionName,
      ),
      isTrue,
    );

    expect(
      state.requestedCollectionNames,
      isNot(contains(state.selectedCollection)),
    );
  });
}
