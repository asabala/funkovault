import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/atlas/identity/product/atlas_product_id.dart';
import 'package:funkovault2/atlas/scan/authenticity/models/atlas_authenticity_evidence.dart';
import 'package:funkovault2/atlas/scan/authenticity/models/atlas_visual_inspection.dart';
import 'package:funkovault2/atlas/scan/contributions/visual_inspection_contribution.dart';
import 'package:funkovault2/atlas/scan/models/scan_session.dart';
import 'package:funkovault2/atlas/scan/results/scan_variant_status.dart';
import 'package:funkovault2/atlas/scan/variant/atlas_variant_confirmation_service.dart';
import 'package:funkovault2/atlas/scan/variant/atlas_variant_resolution_bridge.dart';
import 'package:funkovault2/atlas/scan/workflow/scan_intent.dart';
import 'package:funkovault2/atlas/scan/workflow/scan_performance_mode.dart';
import 'package:funkovault2/atlas/scan/models/scanner_type.dart';

void main() {
  const AtlasVariantResolutionBridge bridge = AtlasVariantResolutionBridge();

  group('AtlasVariantResolutionBridge', () {
    test('missing visual inspection preserves existing resolution', () {
      final ScanSession session = _session().copyWith(
        variantResolution: const ScanVariantResolution(
          status: ScanVariantStatus.exactMatch,
          confirmedTraits: <String>['Chase'],
          confidence: 0.95,
        ),
      );

      expect(bridge.resolve(session), same(session.variantResolution));
    });

    test('unclassified sticker evidence does not manufacture a result', () {
      final ScanSession session = _withStickerObservation(
        _session(),
        attributes: const <String, Object?>{
          'classified': false,
          'detectedLabels': <String>[],
        },
      );

      expect(bridge.resolve(session), isNull);
    });

    test('matching observed and resolved variant becomes likely match', () {
      final ScanSession session = _withStickerObservation(
        _session(),
        attributes: const <String, Object?>{
          'classified': true,
          'detectedLabels': <String>['Chase'],
          'expectedResolvedVariant': 'Chase',
        },
      );

      final ScanVariantResolution resolution = bridge.resolve(session)!;

      expect(resolution.status, ScanVariantStatus.likelyMatch);
      expect(resolution.requiresConfirmation, isFalse);
      expect(resolution.confirmedTraits, contains('Chase'));
      expect(resolution.candidateProductIds, <String>['ATLAS-FNK-000001']);
    });

    test('resolved variant mismatch requires visual confirmation', () {
      final ScanSession session = _withStickerObservation(
        _session(),
        attributes: const <String, Object?>{
          'classified': true,
          'detectedLabels': <String>['Chase'],
          'expectedResolvedVariant': 'Common',
          'resolvedVariantMismatch': true,
        },
      );

      final ScanVariantResolution resolution = bridge.resolve(session)!;

      expect(resolution.status, ScanVariantStatus.visualConfirmationRequired);
      expect(resolution.requiresConfirmation, isTrue);
      expect(resolution.unconfirmedTraits, contains('Chase'));
      expect(
        resolution.unconfirmedTraits,
        contains('Resolved variant: Common'),
      );
    });

    test(
      'reference mismatch requires confirmation without changing identity',
      () {
        final ScanSession session = _withStickerObservation(
          _session(),
          attributes: const <String, Object?>{
            'classified': true,
            'detectedLabels': <String>['Special Edition'],
            'expectedResolvedVariant': 'Special Edition',
            'referenceMismatch': true,
            'criticalReferenceMismatch': true,
          },
        );

        final ScanVariantResolution resolution = bridge.resolve(session)!;

        expect(resolution.requiresConfirmation, isTrue);
        expect(session.atlasProductId?.value, 'ATLAS-FNK-000001');
      },
    );

    test(
      'classified evidence with no resolved variant requests confirmation',
      () {
        final ScanSession session = _withStickerObservation(
          _session(),
          attributes: const <String, Object?>{
            'classified': true,
            'detectedLabels': <String>['Glow in the Dark'],
          },
        );

        expect(
          bridge.resolve(session)!.status,
          ScanVariantStatus.visualConfirmationRequired,
        );
      },
    );
  });

  group('AtlasVariantConfirmationService', () {
    test('collector confirmation marks reviewed variant exact', () {
      final ScanSession session = _session().copyWith(
        variantResolution: const ScanVariantResolution(
          status: ScanVariantStatus.visualConfirmationRequired,
          candidateProductIds: <String>['ATLAS-FNK-000001'],
          confirmedTraits: <String>['Funko'],
          unconfirmedTraits: <String>['Chase'],
          confidence: 0.84,
        ),
      );

      final ScanSession confirmed = const AtlasVariantConfirmationService()
          .confirmResolvedVariant(session);

      expect(confirmed.variantResolution!.status, ScanVariantStatus.exactMatch);
      expect(confirmed.requiresVariantConfirmation, isFalse);
      expect(confirmed.variantResolution!.unconfirmedTraits, isEmpty);
      expect(confirmed.variantResolution!.confirmedTraits, contains('Chase'));
      expect(confirmed.atlasProductId?.value, 'ATLAS-FNK-000001');
    });

    test('non-review resolution is unchanged', () {
      final ScanSession session = _session().copyWith(
        variantResolution: const ScanVariantResolution(
          status: ScanVariantStatus.likelyMatch,
          confirmedTraits: <String>['Chase'],
        ),
      );

      final ScanSession result = const AtlasVariantConfirmationService()
          .confirmResolvedVariant(session);

      expect(result, same(session));
    });
  });
}

ScanSession _session() {
  return ScanSession(
    sessionId: 'session-5d',
    startedAt: DateTime.utc(2026, 9, 3),
    intent: ScanIntent.identifyProduct,
    performanceMode: ScanPerformanceMode.fullAnalysis,
    scannerType: ScannerType.mobileScanner,
    atlasProductId: AtlasProductId.funko(numericId: 1),
  );
}

ScanSession _withStickerObservation(
  ScanSession session, {
  required Map<String, Object?> attributes,
}) {
  final AtlasVisualInspection inspection = AtlasVisualInspection(
    stickerText: 'test',
    evidenceConfidence: 0.88,
    observations: <AtlasVisualEvidenceObservation>[
      AtlasVisualEvidenceObservation(
        observationId: 'sticker-5d',
        sourceEngineId: 'atlas.scan.authenticity.sticker-variant',
        area: AtlasInspectionArea.windowSticker,
        category: AtlasEvidenceCategory.variantSticker,
        label: 'Sticker / variant classification',
        observedValue: 'test',
        confidence: 0.88,
        attributes: attributes,
        observedAt: DateTime.utc(2026, 9, 3),
      ),
    ],
  );

  return session.addContribution(
    VisualInspectionContribution(
      contributionId: 'visual-session-5d',
      sourceEngineId: 'atlas.visual-inspection',
      createdAt: DateTime.utc(2026, 9, 3),
      inspection: inspection,
      confidence: 0.88,
    ),
  );
}
