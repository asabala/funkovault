import '../models/atlas_authenticity_evidence.dart';
import '../models/atlas_visual_inspection.dart';
import 'atlas_autograph_coa_inspection_engine.dart';
import 'atlas_packaging_consistency_engine.dart';
import 'atlas_production_stamp_inspection_engine.dart';
import 'atlas_sticker_variant_inspection_engine.dart';

final class AtlasHighSignalInspectionPipeline {
  const AtlasHighSignalInspectionPipeline({
    this.stickerVariantEngine = const AtlasStickerVariantInspectionEngine(),
    this.productionStampEngine = const AtlasProductionStampInspectionEngine(),
    this.packagingConsistencyEngine = const AtlasPackagingConsistencyEngine(),
    this.autographCoaEngine = const AtlasAutographCoaInspectionEngine(),
  });

  final AtlasStickerVariantInspectionEngine stickerVariantEngine;
  final AtlasProductionStampInspectionEngine productionStampEngine;
  final AtlasPackagingConsistencyEngine packagingConsistencyEngine;
  final AtlasAutographCoaInspectionEngine autographCoaEngine;

  static const Set<String> managedSourceEngineIds = <String>{
    AtlasStickerVariantInspectionEngine.id,
    AtlasProductionStampInspectionEngine.id,
    AtlasPackagingConsistencyEngine.id,
    AtlasAutographCoaInspectionEngine.id,
  };

  AtlasVisualInspection enrich({
    required String sessionId,
    required AtlasVisualInspection inspection,
    String? expectedResolvedVariant,
    DateTime? observedAt,
  }) {
    final DateTime timestamp = (observedAt ?? DateTime.now()).toUtc();

    final List<AtlasVisualEvidenceObservation> preserved = inspection
        .observations
        .where(
          (AtlasVisualEvidenceObservation observation) =>
              !managedSourceEngineIds.contains(observation.sourceEngineId),
        )
        .toList(growable: false);

    final List<AtlasVisualEvidenceObservation> generated =
        <AtlasVisualEvidenceObservation>[
          ...stickerVariantEngine.inspect(
            sessionId: sessionId,
            inspection: inspection,
            expectedResolvedVariant: expectedResolvedVariant,
            observedAt: timestamp,
          ),
          ...productionStampEngine.inspect(
            sessionId: sessionId,
            inspection: inspection,
            observedAt: timestamp,
          ),
          ...packagingConsistencyEngine.inspect(
            sessionId: sessionId,
            inspection: inspection,
            observedAt: timestamp,
          ),
          ...autographCoaEngine.inspect(
            sessionId: sessionId,
            inspection: inspection,
            observedAt: timestamp,
          ),
        ];

    return AtlasVisualInspection(
      stickerText: inspection.stickerText,
      productionStampText: inspection.productionStampText,
      copyrightText: inspection.copyrightText,
      signature: inspection.signature,
      authenticationProvider: inspection.authenticationProvider,
      authenticityNumber: inspection.authenticityNumber,
      typographyConsistent: inspection.typographyConsistent,
      borderConsistent: inspection.borderConsistent,
      stickerPrintClear: inspection.stickerPrintClear,
      stickerCutEven: inspection.stickerCutEven,
      hasAutograph: inspection.hasAutograph,
      hasCoa: inspection.hasCoa,
      notes: inspection.notes,
      referenceCriteria: inspection.referenceCriteria,
      evidenceConfidence: inspection.evidenceConfidence,
      observations: <AtlasVisualEvidenceObservation>[
        ...preserved,
        ...generated,
      ],
      images: inspection.images,
    );
  }
}
