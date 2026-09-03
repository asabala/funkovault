import '../../../intelligence/identity/atlas_identity_analysis_engine.dart';
import '../models/atlas_authenticity_evidence.dart';
import '../models/atlas_inspection_reference.dart';
import '../models/atlas_visual_inspection.dart';

final class AtlasStickerVariantInspectionEngine {
  const AtlasStickerVariantInspectionEngine();

  static const String id = 'atlas.scan.authenticity.sticker-variant';

  List<AtlasVisualEvidenceObservation> inspect({
    required String sessionId,
    required AtlasVisualInspection inspection,
    String? expectedResolvedVariant,
    required DateTime observedAt,
  }) {
    final String stickerText = inspection.stickerText.trim();
    if (stickerText.isEmpty) {
      return const <AtlasVisualEvidenceObservation>[];
    }

    final analysis = AtlasIdentityAnalysisEngine.create().analyze(stickerText);
    final Set<String> detected = <String>{
      ...analysis.stickerResult.stickers.map((value) => value.displayName),
      ...analysis.variantResult.variants.map((value) => value.displayName),
    }..removeWhere((String value) => value.trim().isEmpty);

    final AtlasInspectionReferenceCriteria? reference =
        inspection.referenceCriteria;
    final bool hasReferenceVariants =
        reference != null && reference.legitimateVariantTypes.isNotEmpty;
    final bool referenceMismatch =
        hasReferenceVariants &&
        detected.isNotEmpty &&
        !_hasAnySemanticMatch(detected, reference.legitimateVariantTypes);
    final bool criticalReferenceMismatch =
        referenceMismatch && _hasHighConfidenceVettedReference(reference);
    final bool visualMismatch =
        inspection.stickerPrintClear == false ||
        inspection.stickerCutEven == false;

    final String expected = expectedResolvedVariant?.trim() ?? '';
    final bool resolvedVariantMismatch =
        expected.isNotEmpty &&
        detected.isNotEmpty &&
        !_hasAnySemanticMatch(detected, <String>[expected]);

    return <AtlasVisualEvidenceObservation>[
      AtlasVisualEvidenceObservation(
        observationId: 'scanner5c-$sessionId-sticker-variant',
        sourceEngineId: id,
        area: AtlasInspectionArea.windowSticker,
        category: AtlasEvidenceCategory.variantSticker,
        label: detected.isEmpty
            ? 'Sticker text recorded'
            : 'Sticker / variant classification',
        observedValue: stickerText,
        confidence: inspection.resolvedEvidenceConfidence,
        scanImageId: _imageIdForArea(
          inspection,
          AtlasInspectionArea.windowSticker,
        ),
        attributes: <String, Object?>{
          'classified': detected.isNotEmpty,
          'detectedLabels': detected.toList(growable: false),
          if (expected.isNotEmpty) 'expectedResolvedVariant': expected,
          if (resolvedVariantMismatch) 'resolvedVariantMismatch': true,
          if (inspection.stickerPrintClear != null)
            'stickerPrintClear': inspection.stickerPrintClear,
          if (inspection.stickerCutEven != null)
            'stickerCutEven': inspection.stickerCutEven,
          if (visualMismatch) 'visualMismatch': true,
          if (hasReferenceVariants)
            'referenceVariantFamilies': reference.legitimateVariantTypes,
          if (referenceMismatch) 'referenceMismatch': true,
          if (criticalReferenceMismatch) 'criticalReferenceMismatch': true,
        },
        observedAt: observedAt,
      ),
    ];
  }

  static bool _hasAnySemanticMatch(
    Iterable<String> observed,
    Iterable<String> expected,
  ) {
    for (final String left in observed) {
      final String normalizedLeft = _normalize(left);
      if (normalizedLeft.isEmpty) continue;
      for (final String right in expected) {
        final String normalizedRight = _normalize(right);
        if (normalizedRight.isEmpty) continue;
        if (normalizedLeft == normalizedRight ||
            normalizedLeft.contains(normalizedRight) ||
            normalizedRight.contains(normalizedLeft)) {
          return true;
        }
      }
    }
    return false;
  }

  static bool _hasHighConfidenceVettedReference(
    AtlasInspectionReferenceCriteria reference,
  ) {
    if (reference.coverageLevel != AtlasReferenceCoverageLevel.comprehensive ||
        reference.completenessScore < 0.85) {
      return false;
    }
    return reference.provenance.any(
          (AtlasReferenceProvenance source) => source.specialistVetted,
        ) ||
        reference.knownRuns.any(
          (AtlasProductionRunReference run) => run.provenance.specialistVetted,
        );
  }

  static String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  static String? _imageIdForArea(
    AtlasVisualInspection inspection,
    AtlasInspectionArea area,
  ) {
    for (final image in inspection.images) {
      final bool matches = switch (area) {
        AtlasInspectionArea.windowSticker => image.type.name == 'sticker',
        _ => false,
      };
      if (matches) return image.imageId;
    }
    return null;
  }
}
