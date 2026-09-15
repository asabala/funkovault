import '../../identity/product/atlas_product_id.dart';

// Canonical product record stored in the Atlas catalog.
//
// This model describes the product itself. User-owned collection details,
// purchase information, condition, quantity, and personal notes belong in
// the Vault layer rather than the catalog.
final class AtlasCatalogProduct {
  AtlasCatalogProduct({
    required this.productId,
    required String displayName,
    required String categoryCode,
    String? brand,
    String? productLine,
    String? series,
    String? characterName,
    String? productNumber,
    String? variantName,
    Iterable<String> barcodes = const <String>[],
    Map<String, Object?> attributes = const <String, Object?>{},
  }) : displayName = _requireText(displayName, 'displayName'),
       categoryCode = _normalizeCode(categoryCode),
       brand = _normalizeOptionalText(brand),
       productLine = _normalizeOptionalText(productLine),
       series = _normalizeOptionalText(series),
       characterName = _normalizeOptionalText(characterName),
       productNumber = _normalizeOptionalText(productNumber),
       variantName = _normalizeOptionalText(variantName),
       barcodes = List.unmodifiable(_normalizeBarcodes(barcodes)),
       attributes = Map.unmodifiable(Map<String, Object?>.from(attributes));

  final AtlasProductId productId;

  final String displayName;

  final String categoryCode;

  final String? brand;

  final String? productLine;

  final String? series;

  final String? characterName;

  final String? productNumber;

  final String? variantName;

  final List<String> barcodes;

  final Map<String, Object?> attributes;

  bool get hasBarcode {
    return barcodes.isNotEmpty;
  }

  bool get hasVariant {
    return variantName != null;
  }

  bool get hasProductNumber {
    return productNumber != null;
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

  bool matchesBarcode(String value) {
    final String normalized = _normalizeBarcode(value);

    return normalized.isNotEmpty && barcodes.contains(normalized);
  }

  static String _requireText(String value, String parameterName) {
    final String normalized = value.trim();

    if (normalized.isEmpty) {
      throw ArgumentError.value(
        value,
        parameterName,
        '$parameterName cannot be empty.',
      );
    }

    return normalized;
  }

  static String _normalizeCode(String value) {
    final String normalized = value.trim().toUpperCase();

    if (normalized.isEmpty) {
      throw ArgumentError.value(
        value,
        'categoryCode',
        'Category code cannot be empty.',
      );
    }

    return normalized;
  }

  static String? _normalizeOptionalText(String? value) {
    final String normalized = value?.trim() ?? '';

    if (normalized.isEmpty) {
      return null;
    }

    return normalized;
  }

  static List<String> _normalizeBarcodes(Iterable<String> values) {
    final Set<String> normalized = <String>{};

    for (final String value in values) {
      final String barcode = _normalizeBarcode(value);

      if (barcode.isNotEmpty) {
        normalized.add(barcode);
      }
    }

    return normalized.toList(growable: false);
  }

  static String _normalizeBarcode(String value) {
    return value.replaceAll(RegExp(r'[^0-9A-Za-z]'), '');
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AtlasCatalogProduct && other.productId == productId;
  }

  @override
  int get hashCode {
    return productId.hashCode;
  }

  @override
  String toString() {
    return '$displayName (${productId.value})';
  }
}
