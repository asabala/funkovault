import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/atlas/catalog/services/atlas_barcode_catalog_resolver.dart';
import 'package:funkovault2/atlas/scan/models/scan_code.dart';
import 'package:funkovault2/atlas/scan/models/scan_session.dart';
import 'package:funkovault2/atlas/scan/models/scanner_type.dart';
import 'package:funkovault2/atlas/scan/workflow/scan_intent.dart';
import 'package:funkovault2/atlas/scan/workflow/scan_performance_mode.dart';
import 'package:funkovault2/models/pop.dart';
import 'package:funkovault2/screens/catalog/funko_catalog_screen.dart';
import 'package:funkovault2/screens/scanner/atlas_scan_result_screen.dart';
import 'package:funkovault2/services/app_state.dart';
import 'package:provider/provider.dart';

class _CatalogNavigationTestAppState extends AppState {
  @override
  List<Pop> popsForCollection(String collectionName) {
    return const <Pop>[];
  }
}

void main() {
  const String capturedCollectionName = 'Arthur Collection';
  const String barcodeValue = '889698123456';

  ScanCode scanCode() {
    return ScanCode(
      rawValue: barcodeValue,
      normalizedValue: barcodeValue,
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
      sessionId: 'scanner-catalog-context-test',
      startedAt: DateTime.utc(2026, 8, 25),
      status: ScanSessionStatus.completed,
      intent: ScanIntent.identifyProduct,
      performanceMode: ScanPerformanceMode.fastBarcodeOnly,
      scannerType: ScannerType.mobileScanner,
      detectedCodes: <ScanCode>[code],
      bestCandidate: code,
    );
  }

  Future<void> pumpScanResult(
    WidgetTester tester,
    _CatalogNavigationTestAppState state, {
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
            catalogResolution: AtlasBarcodeResolution.noMatch(
              barcode: barcodeValue,
            ),
            collectionName: collectionName,
          ),
        ),
      ),
    );

    await tester.pump();
  }

  Finder searchCatalogButton() {
    return find.textContaining('Search Catalog', findRichText: true);
  }

  testWidgets('scanner Search Catalog forwards captured collection', (
    WidgetTester tester,
  ) async {
    final _CatalogNavigationTestAppState state =
        _CatalogNavigationTestAppState();

    await pumpScanResult(tester, state);

    expect(state.selectedCollection, isNot(capturedCollectionName));

    expect(searchCatalogButton(), findsOneWidget);

    await tester.tap(searchCatalogButton());

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(FunkoCatalogScreen), findsOneWidget);

    final FunkoCatalogScreen catalogScreen = tester.widget<FunkoCatalogScreen>(
      find.byType(FunkoCatalogScreen),
    );

    expect(catalogScreen.collectionName, capturedCollectionName);

    expect(catalogScreen.collectionName, isNot(state.selectedCollection));
  });

  testWidgets(
    'missing captured collection is forwarded to Catalog without fallback',
    (WidgetTester tester) async {
      final _CatalogNavigationTestAppState state =
          _CatalogNavigationTestAppState();

      const String missingCollectionName = 'Deleted Scan Collection';

      await pumpScanResult(
        tester,
        state,
        collectionName: missingCollectionName,
      );

      expect(state.selectedCollection, isNot(missingCollectionName));

      expect(searchCatalogButton(), findsOneWidget);

      await tester.tap(searchCatalogButton());

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(FunkoCatalogScreen), findsOneWidget);

      final FunkoCatalogScreen catalogScreen = tester
          .widget<FunkoCatalogScreen>(find.byType(FunkoCatalogScreen));

      expect(catalogScreen.collectionName, missingCollectionName);

      expect(catalogScreen.collectionName, isNot(state.selectedCollection));
    },
  );
}
