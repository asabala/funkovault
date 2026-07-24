import '../identity/atlas_identity_analysis.dart';
import '../identity/atlas_identity_detector.dart';
import '../identity/atlas_identity_lookup.dart';
import '../identity/atlas_identity_phrase.dart';
import 'atlas_variant_detection_result.dart';
import 'atlas_variant_evidence.dart';
import 'atlas_variant_evidence_source.dart';
import 'atlas_variant_type.dart';

// Detects variants and contributes them to the shared identity analysis.
final class AtlasVariantDetector
    implements AtlasIdentityDetector {
  const AtlasVariantDetector({
    required this.lookup,
  });

  final AtlasIdentityLookup lookup;

  @override
  AtlasIdentityAnalysis detect({
    required List<AtlasIdentityPhrase> phrases,
    required AtlasIdentityAnalysis analysis,
  }) {
    final Map<AtlasVariantType, AtlasVariantEvidence> evidence =
    <AtlasVariantType, AtlasVariantEvidence>{};

    for (final AtlasIdentityPhrase phrase in phrases) {
      final AtlasVariantType? variant = lookup.variant(
        phrase.normalizedText,
      );

      if (variant == null || !variant.isSpecial) {
        continue;
      }

      evidence.putIfAbsent(
        variant,
            () => AtlasVariantEvidence(
          type: variant,
          confidence: 1.0,
          source: AtlasVariantEvidenceSource.rule,
          rawValue: phrase.text,
          normalizedValue: phrase.normalizedText,
        ),
      );
    }

    return analysis.copyWith(
      variantResult: AtlasVariantDetectionResult(
        evidence: List<AtlasVariantEvidence>.unmodifiable(
          evidence.values,
        ),
      ),
    );
  }
}