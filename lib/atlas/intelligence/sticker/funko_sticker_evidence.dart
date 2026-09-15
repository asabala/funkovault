import 'funko_sticker_evidence_source.dart';
import 'funko_sticker_type.dart';

// Represents evidence supporting a detected sticker type.
final class FunkoStickerEvidence {
  const FunkoStickerEvidence({
    required this.sticker,
    required this.confidence,
    required this.source,
    this.rawValue,
    this.normalizedValue,
    this.attributes = const <String, Object?>{},
  });

  final FunkoStickerType sticker;

  final double confidence;

  final FunkoStickerEvidenceSource source;

  final String? rawValue;

  final String? normalizedValue;

  final Map<String, Object?> attributes;

  bool get isRecognized {
    return sticker != FunkoStickerType.unknown;
  }

  bool get isUserConfirmed {
    return source.isUserConfirmed;
  }

  bool get isHighConfidence {
    return confidence >= 0.85;
  }

  bool get isModerateConfidence {
    return confidence >= 0.60 && confidence < 0.85;
  }

  bool get isLowConfidence {
    return confidence < 0.60;
  }

  T? attribute<T>(String key) {
    final Object? value = attributes[key];

    if (value is T) {
      return value;
    }

    return null;
  }

  bool hasAttribute(String key) {
    return attributes.containsKey(key);
  }
}
