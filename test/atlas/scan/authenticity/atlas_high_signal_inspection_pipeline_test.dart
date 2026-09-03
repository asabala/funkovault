import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/atlas/scan/authenticity/engines/atlas_autograph_coa_inspection_engine.dart';
import 'package:funkovault2/atlas/scan/authenticity/engines/atlas_high_signal_inspection_pipeline.dart';
import 'package:funkovault2/atlas/scan/authenticity/engines/atlas_packaging_consistency_engine.dart';
import 'package:funkovault2/atlas/scan/authenticity/engines/atlas_production_stamp_inspection_engine.dart';
import 'package:funkovault2/atlas/scan/authenticity/engines/atlas_sticker_variant_inspection_engine.dart';
import 'package:funkovault2/atlas/scan/authenticity/models/atlas_authenticity_evidence.dart';
import 'package:funkovault2/atlas/scan/authenticity/models/atlas_inspection_reference.dart';
import 'package:funkovault2/atlas/scan/authenticity/models/atlas_visual_inspection.dart';

void main() {
  final DateTime observedAt = DateTime.utc(2026, 9, 3, 17);

  AtlasReferenceProvenance vettedSource() => AtlasReferenceProvenance(
    sourceType: AtlasReferenceSourceType.verifiedCollectorArchive,
    sourceIdentifier: 'scanner-5c-test-reference',
    lastVerifiedAt: DateTime.utc(2026, 9, 1),
    specialistVetted: true,
  );

  AtlasInspectionReferenceCriteria comprehensiveReference({
    Iterable<String> variants = const <String>[],
    Iterable<AtlasProductionRunReference> runs =
        const <AtlasProductionRunReference>[],
  }) => AtlasInspectionReferenceCriteria(
    productId: 'test-product',
    coverageLevel: AtlasReferenceCoverageLevel.comprehensive,
    completenessScore: 0.95,
    legitimateVariantTypes: variants,
    knownRuns: runs,
    provenance: <AtlasReferenceProvenance>[vettedSource()],
  );

  test('missing inspection evidence generates no specialized observations', () {
    final result = const AtlasHighSignalInspectionPipeline().enrich(
      sessionId: 'session-1',
      inspection: AtlasVisualInspection(),
      observedAt: observedAt,
    );

    expect(result.observations, isEmpty);
  });

  test('unclassified sticker text stays observational', () {
    final observations = const AtlasStickerVariantInspectionEngine().inspect(
      sessionId: 'session-2',
      inspection: AtlasVisualInspection(
        stickerText: 'unrecognized sticker wording xyz',
      ),
      observedAt: observedAt,
    );

    expect(observations, hasLength(1));
    expect(observations.single.category, AtlasEvidenceCategory.variantSticker);
    expect(
      observations.single.attributes['criticalReferenceMismatch'],
      isNot(true),
    );
  });

  test(
    'sticker print or cut warning is emitted as a structured visual mismatch',
    () {
      final observations = const AtlasStickerVariantInspectionEngine().inspect(
        sessionId: 'session-visual-sticker',
        inspection: AtlasVisualInspection(
          stickerText: 'Special Edition',
          stickerPrintClear: false,
        ),
        observedAt: observedAt,
      );

      expect(observations, hasLength(1));
      expect(observations.single.attributes['visualMismatch'], isTrue);
      expect(
        observations.single.attributes['criticalReferenceMismatch'],
        isNot(true),
      );
    },
  );

  test('weak reference cannot create critical sticker contradiction', () {
    final weakReference = AtlasInspectionReferenceCriteria(
      productId: 'test-product',
      coverageLevel: AtlasReferenceCoverageLevel.partial,
      completenessScore: 0.60,
      legitimateVariantTypes: const <String>['Common'],
    );

    final observations = const AtlasStickerVariantInspectionEngine().inspect(
      sessionId: 'session-3',
      inspection: AtlasVisualInspection(
        stickerText: 'Chase',
        referenceCriteria: weakReference,
      ),
      observedAt: observedAt,
    );

    expect(observations, hasLength(1));
    expect(
      observations.single.attributes['criticalReferenceMismatch'],
      isNot(true),
    );
  });

  test(
    'vetted comprehensive reference can mark high-signal sticker mismatch',
    () {
      final observations = const AtlasStickerVariantInspectionEngine().inspect(
        sessionId: 'session-4',
        inspection: AtlasVisualInspection(
          stickerText: 'Chase',
          referenceCriteria: comprehensiveReference(
            variants: const <String>['Common'],
          ),
        ),
        observedAt: observedAt,
      );

      expect(observations, hasLength(1));
      expect(observations.single.attributes['referenceMismatch'], isTrue);
      expect(
        observations.single.attributes['criticalReferenceMismatch'],
        isTrue,
      );
    },
  );

  test(
    'production stamp engine emits structured factory and date evidence',
    () {
      final observations = const AtlasProductionStampInspectionEngine().inspect(
        sessionId: 'session-5',
        inspection: AtlasVisualInspection(productionStampText: 'JJL 240815'),
        observedAt: observedAt,
      );

      expect(observations, hasLength(1));
      expect(observations.single.attributes['recognizedFormat'], isTrue);
      expect(observations.single.attributes['factoryPrefix'], 'JJL');
      expect(
        observations.single.attributes['parsedDate'],
        DateTime.utc(2024, 8, 15),
      );
    },
  );

  test(
    'unsupported production stamp is recorded without contradiction metadata',
    () {
      final observations = const AtlasProductionStampInspectionEngine().inspect(
        sessionId: 'session-6',
        inspection: AtlasVisualInspection(productionStampText: 'UNKNOWN 1234'),
        observedAt: observedAt,
      );

      expect(observations, hasLength(1));
      expect(observations.single.attributes['recognizedFormat'], isFalse);
      expect(
        observations.single.attributes.containsKey('factoryPrefix'),
        isFalse,
      );
      expect(observations.single.attributes.containsKey('parsedDate'), isFalse);
    },
  );

  test(
    'macro packaging warning is structured without pretending certainty',
    () {
      final observations = const AtlasPackagingConsistencyEngine().inspect(
        sessionId: 'session-7',
        inspection: AtlasVisualInspection(
          copyrightText: '2024 Funko',
          typographyConsistent: false,
        ),
        observedAt: observedAt,
      );

      expect(observations, hasLength(1));
      expect(observations.single.attributes['macroMismatch'], isTrue);
      expect(
        observations.single.attributes['criticalReferenceMismatch'],
        isNot(true),
      );
    },
  );

  test('complete vetted copyright reference can mark major contradiction', () {
    final run = AtlasProductionRunReference(
      runIdentifier: 'run-2024',
      expectedCopyrightYears: const <int>[2024],
      provenance: vettedSource(),
    );

    final observations = const AtlasPackagingConsistencyEngine().inspect(
      sessionId: 'session-8',
      inspection: AtlasVisualInspection(
        copyrightText: 'Copyright 2015',
        referenceCriteria: comprehensiveReference(
          runs: <AtlasProductionRunReference>[run],
        ),
      ),
      observedAt: observedAt,
    );

    expect(
      observations.single.attributes['copyrightReferenceMismatch'],
      isTrue,
    );
    expect(observations.single.attributes['criticalReferenceMismatch'], isTrue);
  });

  test('autograph without COA remains observation only', () {
    final observations = const AtlasAutographCoaInspectionEngine().inspect(
      sessionId: 'session-9',
      inspection: AtlasVisualInspection(
        signature: 'Jane Doe',
        hasAutograph: true,
        hasCoa: false,
      ),
      observedAt: observedAt,
    );

    expect(observations, hasLength(2));
    expect(
      observations.every(
        (AtlasVisualEvidenceObservation observation) =>
            observation.attributes['criticalReferenceMismatch'] != true,
      ),
      isTrue,
    );
    expect(
      observations.every(
        (AtlasVisualEvidenceObservation observation) =>
            observation.attributes['providerVerified'] == false,
      ),
      isTrue,
    );
  });

  test(
    'pipeline replaces its own prior observations and preserves external ones',
    () {
      final external = AtlasVisualEvidenceObservation(
        observationId: 'external-observation',
        sourceEngineId: 'future.external-engine',
        area: AtlasInspectionArea.frontBox,
        category: AtlasEvidenceCategory.macroPackaging,
        label: 'External observation',
        observedValue: 'Recorded',
        confidence: 0.90,
        observedAt: observedAt,
      );

      final pipeline = const AtlasHighSignalInspectionPipeline();
      final first = pipeline.enrich(
        sessionId: 'session-10',
        inspection: AtlasVisualInspection(
          stickerText: 'Chase',
          productionStampText: 'FAC 240815',
          observations: <AtlasVisualEvidenceObservation>[external],
        ),
        observedAt: observedAt,
      );
      final second = pipeline.enrich(
        sessionId: 'session-10',
        inspection: first,
        observedAt: observedAt,
      );

      expect(
        second.observations.where(
          (observation) => observation.observationId == 'external-observation',
        ),
        hasLength(1),
      );
      expect(
        second.observations.where(
          (observation) =>
              observation.sourceEngineId ==
              AtlasStickerVariantInspectionEngine.id,
        ),
        hasLength(1),
      );
      expect(
        second.observations.where(
          (observation) =>
              observation.sourceEngineId ==
              AtlasProductionStampInspectionEngine.id,
        ),
        hasLength(1),
      );
    },
  );
}
