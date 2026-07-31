import '../../catalog/models/atlas_catalog_product.dart';
import '../../identity/product/atlas_product_id.dart';

/// Immutable scanner-owned snapshot of a resolved Atlas product.
///
/// The scanner stores this snapshot instead of depending directly on the
/// catalog repository or database model. This allows the result screen and
/// downstream intelligence engines to use the resolved product without
/// performing another catalog lookup.
final class ResolvedProductSnapshot {
  ResolvedProductSnapshot({
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
  })  : displayName = _requireText(
    displayName,
    'displayName',
  ),
        categoryCode = _normalizeCode(categoryCode),
        brand = _normalizeOptionalText(brand),
        productLine = _normalizeOptionalText(productLine),
        series = _normalizeOptionalText(series),
        characterName = _normalizeOptionalText(characterName),
        productNumber = _normalizeOptionalText(productNumber),
        variantName = _normalizeOptionalText(variantName),
        barcodes = List<String>.unmodifiable(
          _normalizeBarcodes(barcodes),
        ),
        attributes = Map<String, Object?>.unmodifiable(
          Map<String, Object?>.from(attributes),
        );

  factory ResolvedProductSnapshot.fromCatalogProduct(
      AtlasCatalogProduct product,
      ) {
    return ResolvedProductSnapshot(
      productId: product.productId,
      displayName: product.displayName,
      categoryCode: product.categoryCode,
      brand: product.brand,
      productLine: product.productLine,
      series: product.series,
      characterName: product.characterName,
      productNumber: product.productNumber,
      variantName: product.variantName,
      barcodes: product.barcodes,
      attributes: product.attributes,
    );
  }

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

  bool get hasBarcode => barcodes.isNotEmpty;

  bool get hasVariant => variantName != null;

  bool get hasProductNumber => productNumber != null;

  String? get primaryBarcode {
    if (barcodes.isEmpty) {
      return null;
    }

    return barcodes.first;
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

    return normalized.isNotEmpty &&
        barcodes.contains(normalized);
  }

  AtlasCatalogProduct toCatalogProduct() {
    return AtlasCatalogProduct(
      productId: productId,
      displayName: displayName,
      categoryCode: categoryCode,
      brand: brand,
      productLine: productLine,
      series: series,
      characterName: characterName,
      productNumber: productNumber,
      variantName: variantName,
      barcodes: barcodes,
      attributes: attributes,
    );
  }

  static String _requireText(
      String value,
      String parameterName,
      ) {
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

  static List<String> _normalizeBarcodes(
      Iterable<String> values,
      ) {
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
    return value.replaceAll(
      RegExp(r'[^0-9A-Za-z]'),
      '',
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ResolvedProductSnapshot &&
            other.productId == productId;
  }

  @override
  int get hashCode => productId.hashCode;

  @override
  String toString() {
    return '$displayName (${productId.value})';
  }
}