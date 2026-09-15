import '../../identity/product/atlas_product_id.dart';
import 'atlas_catalog_product.dart';

// Represents a possible catalog match for a scanned item.
//
// Multiple matches may exist while Atlas is evaluating evidence. The
// ProductResolutionEngine can later choose the highest-confidence match
// or require user review.
final class CatalogMatch {
  CatalogMatch({
    required this.product,
    required this.confidence,
    this.matchReason,
    this.requiresReview = false,
    Map<String, Object?> attributes = const <String, Object?>{},
  }) : attributes = Map.unmodifiable(Map<String, Object?>.from(attributes));

  final AtlasCatalogProduct product;

  final double confidence;

  final String? matchReason;

  final bool requiresReview;

  final Map<String, Object?> attributes;

  AtlasProductId get productId {
    return product.productId;
  }

  bool get isHighConfidence {
    return confidence >= 0.95;
  }

  bool get isMediumConfidence {
    return confidence >= 0.80 && confidence < 0.95;
  }

  bool get isLowConfidence {
    return confidence < 0.80;
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
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CatalogMatch && other.productId == productId;
  }

  @override
  int get hashCode {
    return productId.hashCode;
  }

  @override
  String toString() {
    return '${product.displayName} (${(confidence * 100).toStringAsFixed(1)}%)';
  }
}
