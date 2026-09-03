import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/atlas/scan/authenticity/services/atlas_grail_guard_service.dart';
import 'package:funkovault2/atlas/scan/models/scan_session.dart';
import 'package:funkovault2/atlas/scan/results/market_value_snapshot.dart';
import 'package:funkovault2/atlas/scan/workflow/scan_intent.dart';
import 'package:funkovault2/atlas/scan/workflow/scan_performance_mode.dart';
import 'package:funkovault2/atlas/scan/models/scanner_type.dart';
import 'package:funkovault2/models/pop.dart';

void main() {
  test('service uses current market snapshot for grail guard threshold', () {
    final ScanSession session = ScanSession(
      sessionId: 'grail-service-test',
      startedAt: DateTime.utc(2026, 9, 3),
      intent: ScanIntent.addToVault,
      performanceMode: ScanPerformanceMode.fullAnalysis,
      scannerType: ScannerType.mobileScanner,
      marketSnapshot: MarketValueSnapshot(
        currencyCode: 'USD',
        estimatedValue: 250.0,
        lastUpdated: DateTime.utc(2026, 9, 3),
      ),
    );

    final Pop product = Pop(
      id: '1',
      name: 'Test Pop',
      number: '1',
      category: 'Pop!',
      series: 'Test',
      value: 0,
      pricePaid: 0,
      quantity: 1,
      itemCondition: '',
      boxCondition: '',
      imageUrl: '',
      owner: 'Shared',
      isWishlist: false,
    );

    final result = const AtlasGrailGuardService().evaluate(
      session: session,
      product: product,
      collectorValueThreshold: 100.0,
    );

    expect(result.isRecommended, isTrue);
    expect(result.reasons, contains('Collector value threshold exceeded'));
  });

  test(
    'ordinary low-risk item does not receive grail guard recommendation',
    () {
      final ScanSession session = ScanSession(
        sessionId: 'standard-service-test',
        startedAt: DateTime.utc(2026, 9, 3),
        intent: ScanIntent.addToVault,
        performanceMode: ScanPerformanceMode.fullAnalysis,
        scannerType: ScannerType.mobileScanner,
      );

      final Pop product = Pop(
        id: '2',
        name: 'Standard Pop',
        number: '2',
        category: 'Pop!',
        series: 'Test',
        value: 20,
        pricePaid: 0,
        quantity: 1,
        itemCondition: '',
        boxCondition: '',
        imageUrl: '',
        owner: 'Shared',
        isWishlist: false,
      );

      final result = const AtlasGrailGuardService().evaluate(
        session: session,
        product: product,
        collectorValueThreshold: 100.0,
      );

      expect(result.isRecommended, isFalse);
    },
  );
}
