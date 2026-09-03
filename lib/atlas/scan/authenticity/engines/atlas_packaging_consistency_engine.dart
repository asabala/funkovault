import '../models/atlas_authenticity_evidence.dart';
import '../models/atlas_inspection_reference.dart';
import '../models/atlas_visual_inspection.dart';

final class AtlasPackagingConsistencyEngine {
  const AtlasPackagingConsistencyEngine();

  static const String id = 'atlas.scan.authenticity.packaging-consistency';

  List<AtlasVisualEvidenceObservation> inspect({
    required String sessionId,
    required AtlasVisualInspection inspection,
    required DateTime observedAt,
  }) {
    final String copyrightText = inspection.copyrightText.trim();
    final bool hasMacroChecks =
        inspection.typographyConsistent != null ||
        inspection.borderConsistent != null;
    if (copyrightText.isEmpty && !hasMacroChecks) {
      return const <AtlasVisualEvidenceObservation>[];
    }

    final List<int> observedYears = RegExp(r'\b(?:19|20)\d{2}\b')
        .allMatches(copyrightText)
        .map((RegExpMatch match) => int.parse(match.group(0)!))
        .toSet()
        .toList(growable: false);

    final AtlasInspectionReferenceCriteria? reference =
        inspection.referenceCriteria;
    final Set<int> expectedYears = <int>{
      if (reference != null)
        for (final AtlasProductionRunReference run in reference.knownRuns)
          ...run.expectedCopyrightYears,
    };

    final bool copyrightMismatch =
        observedYears.isNotEmpty &&
        expectedYears.isNotEmpty &&
        !observedYears.any(expectedYears.contains);
    final bool macroMismatch =
        inspection.typographyConsistent == false ||
        inspection.borderConsistent == false ||
        copyrightMismatch;
    final bool criticalReferenceMismatch =
        copyrightMismatch &&
        reference != null &&
        _hasCompleteCopyrightReference(reference);

    return <AtlasVisualEvidenceObservation>[
      AtlasVisualEvidenceObservation(
        observationId: 'scanner5c-$sessionId-macro-packaging',
        sourceEngineId: id,
        area: AtlasInspectionArea.packagingCopyright,
        category: AtlasEvidenceCategory.macroPackaging,
        label: 'Macro packaging consistency',
        observedValue: copyrightText.isEmpty
            ? 'Collector visual checks recorded'
            : copyrightText,
        confidence: inspection.resolvedEvidenceConfidence,
        scanImageId: _packagingImageId(inspection),
        attributes: <String, Object?>{
          if (inspection.typographyConsistent != null)
            'typographyConsistent': inspection.typographyConsistent,
          if (inspection.borderConsistent != null)
            'borderConsistent': inspection.borderConsistent,
          if (observedYears.isNotEmpty) 'observedCopyrightYears': observedYears,
          if (expectedYears.isNotEmpty)
            'referenceCopyrightYears': expectedYears.toList(growable: false),
          if (copyrightMismatch) 'copyrightReferenceMismatch': true,
          if (macroMismatch) 'macroMismatch': true,
          if (criticalReferenceMismatch) 'criticalReferenceMismatch': true,
        },
        observedAt: observedAt,
      ),
    ];
  }

  static bool _hasCompleteCopyrightReference(
    AtlasInspectionReferenceCriteria reference,
  ) {
    if (reference.coverageLevel != AtlasReferenceCoverageLevel.comprehensive ||
        reference.completenessScore < 0.85 ||
        reference.knownRuns.isEmpty) {
      return false;
    }
    if (reference.knownRuns.any(
      (AtlasProductionRunReference run) => run.expectedCopyrightYears.isEmpty,
    )) {
      return false;
    }
    return reference.provenance.any(
          (AtlasReferenceProvenance source) => source.specialistVetted,
        ) ||
        reference.knownRuns.any(
          (AtlasProductionRunReference run) => run.provenance.specialistVetted,
        );
  }

  static String? _packagingImageId(AtlasVisualInspection inspection) {
    for (final image in inspection.images) {
      if (image.type.name == 'backBox' || image.type.name == 'frontBox') {
        return image.imageId;
      }
    }
    return null;
  }
}
