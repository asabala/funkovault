import '../../identity/product/atlas_product_id.dart';

// Represents the canonical product selected by Atlas after identity
// resolution.
//
// ProductResolution is intentionally lightweight. It describes the outcome
// of product resolution rather than exposing database or catalog details.
final class ProductResolution {
  ProductResolution({
    required this.productId,
    required this.displayName,
    required this.matchConfidence,
    this.requiresReview = false,
    Map<String, Object?> attributes =
    const <String, Object?>{},
  }) : attributes = Map<String, Object?>.unmodifiable(
    attributes,
  );

  // Canonical Atlas product identifier.
  final AtlasProductId productId;

  // Human-readable product name.
  final String displayName;

  // Confidence assigned by the product-resolution engine.
  final double matchConfidence;

  // Indicates that a human should verify this match.
  final bool requiresReview;

  // Extensible metadata.
  final Map<String, Object?> attributes;

  bool get isHighConfidence {
    return matchConfidence >= 0.95;
  }

  bool get isMediumConfidence {
    return matchConfidence >= 0.80 &&
        matchConfidence < 0.95;
  }

  bool get isLowConfidence {
    return matchConfidence < 0.80;
  }

  bool get hasAttributes {
    return attributes.isNotEmpty;
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

  @override
  String toString() {
    return 'ProductResolution('
        'productId: ${productId.value}, '
        'displayName: $displayName, '
        'confidence: $matchConfidence, '
        'requiresReview: $requiresReview'
        ')';
  }
}