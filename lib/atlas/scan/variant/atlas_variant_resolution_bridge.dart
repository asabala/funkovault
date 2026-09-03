import '../authenticity/models/atlas_authenticity_evidence.dart';
import '../models/scan_session.dart';
import '../results/scan_variant_status.dart';

// Converts Scanner 5 sticker/variant observations into the existing
// [ScanVariantResolution] model without changing canonical product identity.
//
// The bridge is intentionally conservative:
// - missing or unclassified visual evidence does not create a variant result;
// - visual evidence can request confirmation but never rewrites the resolved
//   catalog product;
// - a visual match is considered likely, not exact, until a collector or a
//   stronger identity workflow confirms the physical release.

final class AtlasVariantResolutionBridge {
  const AtlasVariantResolutionBridge();

  ScanVariantResolution? resolve(ScanSession session) {
    final inspection = session.visualInspectionContribution?.inspection;
    if (inspection == null) {
      return session.variantResolution;
    }

    AtlasVisualEvidenceObservation? stickerObservation;
    for (final AtlasVisualEvidenceObservation observation
        in inspection.observations.reversed) {
      if (observation.category == AtlasEvidenceCategory.variantSticker) {
        stickerObservation = observation;
        break;
      }
    }

    if (stickerObservation == null) {
      return session.variantResolution;
    }

    final List<String> detectedLabels = _stringList(
      stickerObservation.attributes['detectedLabels'],
    );
    final bool classified =
        stickerObservation.attributes['classified'] == true &&
        detectedLabels.isNotEmpty;

    // Unreadable, unknown, or otherwise unclassified evidence is observation
    // only. It must not downgrade or manufacture a variant conclusion.
    if (!classified) {
      return session.variantResolution;
    }

    final String expectedVariant = _stringValue(
      stickerObservation.attributes['expectedResolvedVariant'],
    );
    final bool resolvedVariantMismatch =
        stickerObservation.attributes['resolvedVariantMismatch'] == true;
    final bool referenceMismatch =
        stickerObservation.attributes['referenceMismatch'] == true;
    final bool criticalReferenceMismatch =
        stickerObservation.attributes['criticalReferenceMismatch'] == true;
    final double confidence = _normalizeConfidence(
      stickerObservation.confidence,
    );

    final List<String> candidateProductIds = <String>[
      if (session.atlasProductId?.value.trim().isNotEmpty == true)
        session.atlasProductId!.value.trim(),
    ];

    if (resolvedVariantMismatch ||
        referenceMismatch ||
        criticalReferenceMismatch ||
        expectedVariant.isEmpty) {
      return ScanVariantResolution(
        status: ScanVariantStatus.visualConfirmationRequired,
        candidateProductIds: candidateProductIds,
        confirmedTraits: const <String>[],
        unconfirmedTraits: _deduplicate(<String>[
          ...detectedLabels,
          if (expectedVariant.isNotEmpty) 'Resolved variant: $expectedVariant',
        ]),
        confidence: confidence,
      );
    }

    return ScanVariantResolution(
      status: ScanVariantStatus.likelyMatch,
      candidateProductIds: candidateProductIds,
      confirmedTraits: _deduplicate(<String>[
        expectedVariant,
        ...detectedLabels,
      ]),
      unconfirmedTraits: const <String>[],
      confidence: confidence,
    );
  }

  static List<String> _stringList(Object? value) {
    if (value is! Iterable) return const <String>[];
    return value
        .map((Object? item) => item?.toString().trim() ?? '')
        .where((String item) => item.isNotEmpty)
        .toList(growable: false);
  }

  static String _stringValue(Object? value) => value?.toString().trim() ?? '';

  static double _normalizeConfidence(double value) {
    if (!value.isFinite) return 0.0;
    return value.clamp(0.0, 1.0).toDouble();
  }

  static List<String> _deduplicate(Iterable<String> values) {
    final Map<String, String> normalized = <String, String>{};
    for (final String value in values) {
      final String trimmed = value.trim();
      if (trimmed.isEmpty) continue;
      normalized.putIfAbsent(trimmed.toLowerCase(), () => trimmed);
    }
    return List<String>.unmodifiable(normalized.values);
  }
}
