import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/atlas/scan/authenticity/atlas_authenticity_engine.dart';
import 'package:funkovault2/atlas/scan/authenticity/atlas_visual_inspection_service.dart';
import 'package:funkovault2/atlas/scan/authenticity/models/atlas_authenticity_assessment.dart';
import 'package:funkovault2/atlas/scan/authenticity/models/atlas_authenticity_evidence.dart';
import 'package:funkovault2/atlas/scan/authenticity/models/atlas_inspection_reference.dart';
import 'package:funkovault2/atlas/scan/authenticity/models/atlas_visual_inspection.dart';
import 'package:funkovault2/atlas/scan/contributions/authenticity_contribution.dart';
import 'package:funkovault2/atlas/scan/contributions/visual_inspection_contribution.dart';
import 'package:funkovault2/atlas/scan/models/scan_session.dart';
import 'package:funkovault2/atlas/scan/models/scanner_type.dart';
import 'package:funkovault2/atlas/scan/workflow/scan_intent.dart';
import 'package:funkovault2/atlas/scan/workflow/scan_performance_mode.dart';

void main() {
  ScanSession session() => ScanSession(
    sessionId: 'scan-1',
    startedAt: DateTime.utc(2026),
    intent: ScanIntent.identifyProduct,
    performanceMode: ScanPerformanceMode.fullAnalysis,
    scannerType: ScannerType.mobileScanner,
  );

  AtlasInspectionReferenceCriteria comprehensiveReference() {
    return AtlasInspectionReferenceCriteria(
      productId: 'ATLAS-FNK-001855',
      upc: '889698750000',
      coverageLevel: AtlasReferenceCoverageLevel.comprehensive,
      completenessScore: 0.95,
      legitimateVariantTypes: const <String>['Common', 'Chase'],
      knownRuns: <AtlasProductionRunReference>[
        AtlasProductionRunReference(
          runIdentifier: '2024-first-run',
          knownFactoryPrefixes: const <String>['JJL', 'FAC'],
          earliestKnownDate: DateTime.utc(2024, 1, 1),
          latestKnownDate: DateTime.utc(2024, 6, 30),
          expectedCopyrightYears: const <int>[2024],
          verifiedStickerFamilies: const <String>['Chase'],
          provenance: AtlasReferenceProvenance(
            sourceType: AtlasReferenceSourceType.verifiedCollectorArchive,
            sourceIdentifier: 'test-reference',
            lastVerifiedAt: DateTime.utc(2026, 9, 1),
            specialistVetted: true,
          ),
        ),
      ],
    );
  }

  test('absence of evidence remains explicitly unassessed', () async {
    final result = await const AtlasVisualInspectionService().inspect(
      session: session(),
      inspection: AtlasVisualInspection(
        referenceCriteria: comprehensiveReference(),
      ),
    );

    final assessment = result.authenticityContribution!.assessment;
    expect(assessment.status, AtlasAuthenticityStatus.insufficientEvidence);
    expect(
      assessment.concernLevel,
      AtlasAuthenticityConcernLevel.insufficientData,
    );
    expect(assessment.aggregatedConcernScore, 0.0);
    expect(
      assessment.uninspectedAreas.length,
      AtlasInspectionArea.values.length,
    );
  });

  test(
    'low evidence confidence is insufficient data, not suspicious',
    () async {
      final result = await const AtlasVisualInspectionService().inspect(
        session: session(),
        inspection: AtlasVisualInspection(
          stickerText: 'Chase',
          evidenceConfidence: 0.20,
          referenceCriteria: comprehensiveReference(),
        ),
      );

      final assessment = result.authenticityContribution!.assessment;
      expect(
        assessment.concernLevel,
        AtlasAuthenticityConcernLevel.insufficientData,
      );
      expect(assessment.aggregatedConcernScore, 0.0);
    },
  );

  test(
    'limited reference coverage is insufficient data, not counterfeit',
    () async {
      final limitedReference = AtlasInspectionReferenceCriteria(
        productId: 'ATLAS-FNK-000001',
        coverageLevel: AtlasReferenceCoverageLevel.limited,
        completenessScore: 0.25,
      );

      final result = await const AtlasVisualInspectionService().inspect(
        session: session(),
        inspection: AtlasVisualInspection(
          stickerText: 'Unknown Convention Sticker',
          evidenceConfidence: 0.95,
          referenceCriteria: limitedReference,
        ),
      );

      final assessment = result.authenticityContribution!.assessment;
      expect(
        assessment.concernLevel,
        AtlasAuthenticityConcernLevel.insufficientData,
      );
      expect(assessment.aggregatedConcernScore, 0.0);
    },
  );

  test('warning signals recommend review and never claim fake', () async {
    final result = await const AtlasVisualInspectionService().inspect(
      session: session(),
      inspection: AtlasVisualInspection(
        stickerText: 'Convention Exclusive',
        typographyConsistent: false,
        borderConsistent: true,
        stickerPrintClear: false,
        stickerCutEven: true,
        evidenceConfidence: 0.90,
        referenceCriteria: comprehensiveReference(),
      ),
    );

    final assessment = result.authenticityContribution!.assessment;
    expect(assessment.requiresReview, isTrue);
    expect(assessment.summary.toLowerCase(), isNot(contains('fake')));
  });

  test('correlated packaging advisories are category capped', () async {
    final observations = List<AtlasVisualEvidenceObservation>.generate(
      12,
      (int index) => AtlasVisualEvidenceObservation(
        observationId: 'packaging-$index',
        sourceEngineId: 'test.packaging',
        area: AtlasInspectionArea.packagingCopyright,
        category: AtlasEvidenceCategory.macroPackaging,
        label: 'Macro packaging check',
        observedValue: 'Layout offset',
        confidence: 0.95,
        attributes: const <String, Object?>{'macroMismatch': true},
      ),
    );

    final result = await const AtlasVisualInspectionService().inspect(
      session: session(),
      inspection: AtlasVisualInspection(
        observations: observations,
        evidenceConfidence: 0.95,
        referenceCriteria: comprehensiveReference(),
      ),
    );

    final assessment = result.authenticityContribution!.assessment;
    expect(assessment.aggregatedConcernScore, lessThanOrEqualTo(0.35));
    expect(
      assessment.concernLevel,
      isNot(AtlasAuthenticityConcernLevel.strongCounterfeitIndicators),
    );
  });

  test(
    'one critical category cannot produce strongest concern state',
    () async {
      final observation = AtlasVisualEvidenceObservation(
        observationId: 'bad-stamp',
        sourceEngineId: 'test.stamp',
        area: AtlasInspectionArea.bottomStamp,
        category: AtlasEvidenceCategory.productionStamp,
        label: 'Production stamp',
        observedValue: 'DRM 200101',
        confidence: 0.98,
        attributes: <String, Object?>{
          'factoryPrefix': 'DRM',
          'parsedDate': DateTime.utc(2020, 1, 1),
        },
      );

      final result = await const AtlasVisualInspectionService().inspect(
        session: session(),
        inspection: AtlasVisualInspection(
          observations: <AtlasVisualEvidenceObservation>[observation],
          referenceCriteria: comprehensiveReference(),
        ),
      );

      expect(
        result.authenticityContribution!.assessment.concernLevel,
        isNot(AtlasAuthenticityConcernLevel.strongCounterfeitIndicators),
      );
    },
  );

  test(
    'two independent critical categories can produce strong indicators',
    () async {
      final observations = <AtlasVisualEvidenceObservation>[
        AtlasVisualEvidenceObservation(
          observationId: 'bad-stamp',
          sourceEngineId: 'test.stamp',
          area: AtlasInspectionArea.bottomStamp,
          category: AtlasEvidenceCategory.productionStamp,
          label: 'Production stamp',
          observedValue: 'DRM 200101',
          confidence: 0.98,
          attributes: <String, Object?>{
            'factoryPrefix': 'DRM',
            'parsedDate': DateTime.utc(2020, 1, 1),
          },
        ),
        AtlasVisualEvidenceObservation(
          observationId: 'critical-sticker',
          sourceEngineId: 'test.sticker',
          area: AtlasInspectionArea.windowSticker,
          category: AtlasEvidenceCategory.variantSticker,
          label: 'Sticker reference comparison',
          observedValue: 'Reference contradiction',
          confidence: 0.98,
          attributes: const <String, Object?>{
            'criticalReferenceMismatch': true,
          },
        ),
      ];

      final result = await const AtlasVisualInspectionService().inspect(
        session: session(),
        inspection: AtlasVisualInspection(
          observations: observations,
          referenceCriteria: comprehensiveReference(),
        ),
      );

      final assessment = result.authenticityContribution!.assessment;
      expect(
        assessment.concernLevel,
        AtlasAuthenticityConcernLevel.strongCounterfeitIndicators,
      );
      expect(assessment.aggregatedConcernScore, greaterThanOrEqualTo(0.65));
      expect(assessment.summary.toLowerCase(), contains('not a definitive'));
    },
  );

  test('reinspection replaces typed contributions immutably', () async {
    const service = AtlasVisualInspectionService(
      authenticityEngine: AtlasAuthenticityEngine(),
    );

    final original = session();
    final first = await service.inspect(
      session: original,
      inspection: AtlasVisualInspection(
        stickerText: 'Special Edition',
        referenceCriteria: comprehensiveReference(),
      ),
    );
    final second = await service.inspect(
      session: first,
      inspection: AtlasVisualInspection(
        stickerText: 'Chase',
        productionStampText: 'JJL 240815',
        evidenceConfidence: 0.90,
        referenceCriteria: comprehensiveReference(),
      ),
    );

    expect(original.contributionCount, 0);
    expect(
      second.contributions.ofType<VisualInspectionContribution>(),
      hasLength(1),
    );
    expect(
      second.contributions.ofType<AuthenticityContribution>(),
      hasLength(1),
    );
  });
}
