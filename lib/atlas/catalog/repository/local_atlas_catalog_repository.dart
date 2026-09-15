import 'package:flutter/foundation.dart';
import 'package:funkovault2/atlas/catalog/indexing/atlas_catalog_index.dart';
import 'package:funkovault2/atlas/catalog/loaders/atlas_catalog_loader.dart';
import 'package:funkovault2/atlas/catalog/models/atlas_catalog_product.dart';
import 'package:funkovault2/atlas/catalog/repository/atlas_catalog_repository.dart';
import 'package:funkovault2/atlas/identity/product/atlas_product_id.dart';

final class LocalAtlasCatalogRepository implements AtlasCatalogRepository {
  Future<AtlasCatalogIndex>? _indexFuture;

  Future<AtlasCatalogIndex> _getIndex() {
    return _indexFuture ??= _loadIndex();
  }

  Future<AtlasCatalogIndex> _loadIndex() async {
    debugPrint('ATLAS CATALOG: Starting catalog load...');

    final Stopwatch stopwatch = Stopwatch()..start();

    final List<AtlasCatalogProduct> products =
        await AtlasCatalogLoader.loadPopVinylCatalog();

    final int productsWithBarcodes = products
        .where((AtlasCatalogProduct product) => product.barcodes.isNotEmpty)
        .length;

    final int totalBarcodes = products.fold<int>(0, (
      int total,
      AtlasCatalogProduct product,
    ) {
      return total + product.barcodes.length;
    });

    final AtlasCatalogIndex index = AtlasCatalogIndex(products: products);

    stopwatch.stop();

    debugPrint('ATLAS CATALOG: Loaded ${products.length} products.');

    debugPrint('ATLAS CATALOG: $productsWithBarcodes products have barcodes.');

    debugPrint('ATLAS CATALOG: $totalBarcodes total barcode entries.');

    debugPrint(
      'ATLAS CATALOG: Index contains '
      '${index.byBarcode.length} unique barcode keys.',
    );

    debugPrint(
      'ATLAS CATALOG: Catalog load completed in '
      '${stopwatch.elapsedMilliseconds} ms.',
    );

    return index;
  }

  @override
  Future<AtlasCatalogProduct?> findByProductId(AtlasProductId productId) async {
    final AtlasCatalogIndex index = await _getIndex();

    return index.findByAtlasProductId(productId);
  }

  @override
  Future<List<AtlasCatalogProduct>> findByBarcode(String barcode) async {
    final AtlasCatalogIndex index = await _getIndex();

    final String normalizedBarcode = _normalizeBarcode(barcode);

    debugPrint('ATLAS BARCODE: Raw value "$barcode".');

    debugPrint(
      'ATLAS BARCODE: Searching for '
      '"$normalizedBarcode".',
    );

    if (normalizedBarcode.isEmpty) {
      debugPrint('ATLAS BARCODE: Search value was empty.');

      return const <AtlasCatalogProduct>[];
    }

    final Set<String> candidateBarcodes = _barcodeCandidates(normalizedBarcode);

    debugPrint(
      'ATLAS BARCODE: Candidate values '
      '${candidateBarcodes.join(', ')}.',
    );

    final List<AtlasCatalogProduct> matches = <AtlasCatalogProduct>[];

    final Set<String> matchedProductIds = <String>{};

    for (final String candidate in candidateBarcodes) {
      final List<AtlasCatalogProduct> candidateMatches = index.findByBarcode(
        candidate,
      );

      debugPrint(
        'ATLAS BARCODE: Candidate "$candidate" '
        'returned ${candidateMatches.length} match(es).',
      );

      for (final AtlasCatalogProduct product in candidateMatches) {
        if (matchedProductIds.add(product.productId.value)) {
          matches.add(product);
        }
      }
    }

    if (matches.isNotEmpty) {
      for (final AtlasCatalogProduct product in matches) {
        debugPrint(
          'ATLAS BARCODE MATCH: '
          '${product.displayName} '
          '${product.barcodes}.',
        );
      }

      return List<AtlasCatalogProduct>.unmodifiable(matches);
    }

    debugPrint(
      'ATLAS BARCODE: Indexed lookup returned '
      'no matches. Running direct catalog check.',
    );

    for (final AtlasCatalogProduct product in index.products) {
      final bool matchesCandidate = candidateBarcodes.any(
        product.matchesBarcode,
      );

      if (!matchesCandidate) {
        continue;
      }

      if (matchedProductIds.add(product.productId.value)) {
        matches.add(product);
      }
    }

    debugPrint(
      'ATLAS BARCODE: Direct catalog check returned '
      '${matches.length} match(es).',
    );

    if (matches.isNotEmpty) {
      for (final AtlasCatalogProduct product in matches) {
        debugPrint(
          'ATLAS BARCODE DIRECT MATCH: '
          '${product.displayName} '
          '${product.barcodes}.',
        );
      }
    }

    return List<AtlasCatalogProduct>.unmodifiable(matches);
  }

  @override
  Future<List<AtlasCatalogProduct>> search({
    String? query,
    String? categoryCode,
    String? brand,
    String? productLine,
    String? series,
    String? characterName,
    String? productNumber,
    String? variantName,
    int limit = 25,
  }) async {
    if (limit <= 0) {
      return const <AtlasCatalogProduct>[];
    }

    final AtlasCatalogIndex index = await _getIndex();

    final String normalizedQuery = _normalizeText(query);

    final String normalizedCategoryCode = _normalizeText(categoryCode);

    final String normalizedBrand = _normalizeText(brand);

    final String normalizedProductLine = _normalizeText(productLine);

    final String normalizedSeries = _normalizeText(series);

    final String normalizedCharacterName = _normalizeText(characterName);

    final String normalizedProductNumber = _normalizeText(productNumber);

    final String normalizedVariantName = _normalizeText(variantName);

    final List<AtlasCatalogProduct> matches = <AtlasCatalogProduct>[];

    for (final AtlasCatalogProduct product in index.products) {
      if (!_matchesOptionalField(
        value: product.categoryCode,
        filter: normalizedCategoryCode,
      )) {
        continue;
      }

      if (!_matchesOptionalField(
        value: product.brand,
        filter: normalizedBrand,
      )) {
        continue;
      }

      if (!_matchesOptionalField(
        value: product.productLine,
        filter: normalizedProductLine,
      )) {
        continue;
      }

      if (!_matchesOptionalField(
        value: product.series,
        filter: normalizedSeries,
      )) {
        continue;
      }

      if (!_matchesOptionalField(
        value: product.characterName,
        filter: normalizedCharacterName,
      )) {
        continue;
      }

      if (!_matchesOptionalField(
        value: product.productNumber,
        filter: normalizedProductNumber,
      )) {
        continue;
      }

      if (!_matchesOptionalField(
        value: product.variantName,
        filter: normalizedVariantName,
      )) {
        continue;
      }

      if (!_matchesQuery(product: product, query: normalizedQuery)) {
        continue;
      }

      matches.add(product);

      if (matches.length >= limit) {
        break;
      }
    }

    return List<AtlasCatalogProduct>.unmodifiable(matches);
  }

  static bool _matchesQuery({
    required AtlasCatalogProduct product,
    required String query,
  }) {
    if (query.isEmpty) {
      return true;
    }

    final Iterable<String?> searchableValues = <String?>[
      product.productId.value,
      product.displayName,
      product.categoryCode,
      product.brand,
      product.productLine,
      product.series,
      product.characterName,
      product.productNumber,
      product.variantName,
      ...product.barcodes,
    ];

    for (final String? value in searchableValues) {
      if (_normalizeText(value).contains(query)) {
        return true;
      }
    }

    return false;
  }

  static bool _matchesOptionalField({
    required String? value,
    required String filter,
  }) {
    if (filter.isEmpty) {
      return true;
    }

    return _normalizeText(value) == filter;
  }

  static Set<String> _barcodeCandidates(String barcode) {
    final Set<String> candidates = <String>{barcode};

    if (barcode.length == 13 && barcode.startsWith('0')) {
      candidates.add(barcode.substring(1));
    }

    if (barcode.length == 12) {
      candidates.add('0$barcode');
    }

    return candidates;
  }

  static String _normalizeBarcode(String value) {
    return value.replaceAll(RegExp(r'[^0-9A-Za-z]'), '');
  }

  static String _normalizeText(String? value) {
    return value?.trim().toLowerCase() ?? '';
  }
}
