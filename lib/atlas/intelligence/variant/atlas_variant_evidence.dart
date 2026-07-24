import 'atlas_variant_evidence_source.dart';
import 'atlas_variant_type.dart';

// Immutable evidence describing a possible product variant.
//
// Evidence may originate from OCR, catalog records, importers, barcode
// resolution, user confirmation, rules, or future Atlas AI analysis.
final class AtlasVariantEvidence {
  AtlasVariantEvidence({
    required this.type,
    required this.confidence,
    required this.source,
    this.rawValue,
    this.normalizedValue,
    Map<String, Object?> attributes =
    const <String, Object?>{},
  })  : assert(
  confidence >= 0.0 &&
      confidence <= 1.0,
  'confidence must be between 0.0 and 1.0',
  ),
        attributes = Map<String, Object?>.unmodifiable(
          attributes,
        );

  final AtlasVariantType type;

  final double confidence;

  final AtlasVariantEvidenceSource source;

  final String? rawValue;

  final String? normalizedValue;

  final Map<String, Object?> attributes;

  bool get isRecognized {
    return type != AtlasVariantType.unknown;
  }

  bool get affectsIdentity {
    return isRecognized &&
        type.affectsIdentity;
  }

  bool get isUserConfirmed {
    return source.isUserConfirmed;
  }

  bool get isHighConfidence {
    return confidence >= 0.85;
  }

  bool get isModerateConfidence {
    return confidence >= 0.60 &&
        confidence < 0.85;
  }

  bool get isLowConfidence {
    return confidence < 0.60;
  }

  T? attribute<T>(
      String key,
      ) {
    final Object? value = attributes[key];

    if (value is T) {
      return value;
    }

    return null;
  }

  bool hasAttribute(
      String key,
      ) {
    return attributes.containsKey(key);
  }
}