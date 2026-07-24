import 'funko_retailer.dart';
import 'funko_retailer_evidence_source.dart';

// Represents evidence supporting a detected retailer.
final class FunkoRetailerEvidence {
  const FunkoRetailerEvidence({
    required this.retailer,
    required this.confidence,
    required this.source,
    this.rawValue,
    this.normalizedValue,
    this.attributes = const <String, Object?>{},
  });

  final FunkoRetailer retailer;

  final double confidence;

  final FunkoRetailerEvidenceSource source;

  final String? rawValue;

  final String? normalizedValue;

  final Map<String, Object?> attributes;

  bool get isRecognized {
    return retailer != FunkoRetailer.unknown;
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