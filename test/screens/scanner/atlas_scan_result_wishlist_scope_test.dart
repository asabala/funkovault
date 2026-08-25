import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/atlas/catalog/services/atlas_barcode_catalog_resolver.dart';
import 'package:funkovault2/atlas/scan/models/scan_code.dart';
import 'package:funkovault2/atlas/scan/models/scan_session.dart';
import 'package:funkovault2/atlas/scan/models/scanner_type.dart';
import 'package:funkovault2/atlas/scan/workflow/scan_intent.dart';
import 'package:funkovault2/atlas/scan/workflow/scan_performance_mode.dart';
import 'package:funkovault2/models/pop.dart';
import 'package:funkovault2/screens/scanner/atlas_scan_result_screen.dart';
import 'package:funkovault2/services/app_state.dart';
import 'package:provider/provider.dart';

class _WishlistScannerTestAppState extends AppState {
  _WishlistScannerTestAppState({
    required this.collectionPops,
    this.wishlistedIdentityKeys = const <String>{},
  });

  final List<Pop> collectionPops;
  final Set<String> wishlistedIdentityKeys;

  final List<String> requestedCollectionNames = <String>[];

  Pop? addedWishlistPop;
  String? addedWishlistCollectionName;

  Pop? removedWishlistPop;
  String? removedWishlistCollectionName;

  @override
  List<Pop> popsForCollection(String collectionName) {
    requestedCollectionNames.add(collectionName);

    return List<Pop>.unmodifiable(collectionPops);
  }

  @override
  Set<String> ownedWishlistIdentityKeysForCollection(String collectionName) {
    requestedCollectionNames.add(collectionName);

    return Set<String>.unmodifiable(wishlistedIdentityKeys);
  }

  @override
  Future<void> addOwnedPopToWishlist(Pop pop, {String? collectionName}) async {
    addedWishlistPop = pop;
    addedWishlistCollectionName = collectionName;
  }

  @override
  Future<void> removeOwnedPopFromWishlist(
    Pop pop, {
    String? collectionName,
  }) async {
    removedWishlistPop = pop;
    removedWishlistCollectionName = collectionName;
  }
}

void main() {
  const String capturedCollectionName = 'Arthur Collection';
  const String barcodeValue = '889698123456';

  Pop ownedPop() {
    return const Pop(
      id: 'owned-pop-1',
      name: 'Batman',
      number: '01',
      category: 'Heroes',
      series: 'Batman',
      variant: 'Common',
      sourceUpc: barcodeValue,
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
      sessionId: 'scanner-wishlist-scope-test',
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
    WidgetTester tester,
    _WishlistScannerTestAppState state,
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
          home: AtlasScanResultScreen(
            session: scanSession(),
            catalogResolution: AtlasBarcodeResolution.noMatch(
              barcode: barcodeValue,
            ),
            collectionName: capturedCollectionName,
          ),
        ),
      ),
    );

    await tester.pump();
  }

  Finder addWishlistAction() {
    return find.textContaining('Add to Wishlist', findRichText: true);
  }

  Finder removeWishlistAction() {
    return find.textContaining('Remove from Wishlist', findRichText: true);
  }

  testWidgets('owned Pop wishlist add uses captured collection', (
    WidgetTester tester,
  ) async {
    final Pop pop = ownedPop();

    final _WishlistScannerTestAppState state = _WishlistScannerTestAppState(
      collectionPops: <Pop>[pop],
    );

    await pumpResult(tester, state);

    expect(state.selectedCollection, isNot(capturedCollectionName));

    expect(addWishlistAction(), findsOneWidget);

    await tester.tap(addWishlistAction());

    await tester.pump();

    expect(state.addedWishlistPop?.id, pop.id);

    expect(state.addedWishlistCollectionName, capturedCollectionName);

    expect(state.addedWishlistCollectionName, isNot(state.selectedCollection));

    expect(state.removedWishlistPop, isNull);
  });

  testWidgets('owned Pop wishlist remove uses captured collection', (
    WidgetTester tester,
  ) async {
    final Pop pop = ownedPop();

    final _WishlistScannerTestAppState state = _WishlistScannerTestAppState(
      collectionPops: <Pop>[pop],
      wishlistedIdentityKeys: <String>{pop.collectibleIdentityKey},
    );

    await pumpResult(tester, state);

    expect(state.selectedCollection, isNot(capturedCollectionName));

    expect(removeWishlistAction(), findsOneWidget);

    await tester.tap(removeWishlistAction());

    await tester.pump();

    expect(state.removedWishlistPop?.id, pop.id);

    expect(state.removedWishlistCollectionName, capturedCollectionName);

    expect(
      state.removedWishlistCollectionName,
      isNot(state.selectedCollection),
    );

    expect(state.addedWishlistPop, isNull);
  });

  testWidgets('wishlist intelligence reads only the captured collection', (
    WidgetTester tester,
  ) async {
    final Pop pop = ownedPop();

    final _WishlistScannerTestAppState state = _WishlistScannerTestAppState(
      collectionPops: <Pop>[pop],
    );

    await pumpResult(tester, state);

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
