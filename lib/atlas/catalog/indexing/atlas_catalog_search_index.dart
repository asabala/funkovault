import '../models/atlas_catalog_product.dart';

// Lightweight search index for Atlas catalog products.
//
// This index normalizes searchable text and allows repositories to perform
// consistent text searches without duplicating normalization logic.
final class AtlasCatalogSearchIndex {
  AtlasCatalogSearchIndex({required Iterable<AtlasCatalogProduct> products})
    : _products = List.unmodifiable(products);

  final List<AtlasCatalogProduct> _products;

  List<AtlasCatalogProduct> search({
    String? query,
    String? categoryCode,
    String? brand,
    String? productLine,
    String? series,
    String? characterName,
    String? productNumber,
    String? variantName,
    int limit = 25,
  }) {
    final String normalizedQuery = _normalize(query);

    final List<AtlasCatalogProduct> results = <AtlasCatalogProduct>[];

    for (final AtlasCatalogProduct product in _products) {
      if (!_matches(
        product: product,
        query: normalizedQuery,
        categoryCode: categoryCode,
        brand: brand,
        productLine: productLine,
        series: series,
        characterName: characterName,
        productNumber: productNumber,
        variantName: variantName,
      )) {
        continue;
      }

      results.add(product);

      if (results.length >= limit) {
        break;
      }
    }

    return List<AtlasCatalogProduct>.unmodifiable(results);
  }

  bool _matches({
    required AtlasCatalogProduct product,
    required String query,
    String? categoryCode,
    String? brand,
    String? productLine,
    String? series,
    String? characterName,
    String? productNumber,
    String? variantName,
  }) {
    if (categoryCode != null &&
        product.categoryCode != categoryCode.toUpperCase()) {
      return false;
    }

    if (brand != null && product.brand != brand) {
      return false;
    }

    if (productLine != null && product.productLine != productLine) {
      return false;
    }

    if (series != null && product.series != series) {
      return false;
    }

    if (characterName != null && product.characterName != characterName) {
      return false;
    }

    if (productNumber != null && product.productNumber != productNumber) {
      return false;
    }

    if (variantName != null && product.variantName != variantName) {
      return false;
    }

    if (query.isEmpty) {
      return true;
    }

    return _normalize(product.displayName).contains(query) ||
        _normalize(product.series).contains(query) ||
        _normalize(product.characterName).contains(query) ||
        _normalize(product.productNumber).contains(query);
  }

  String _normalize(String? value) {
    return value?.trim().toLowerCase() ?? '';
  }
}
