import 'package:funkovault2/atlas/catalog/models/atlas_catalog_product.dart';
import 'package:funkovault2/atlas/identity/product/atlas_product_id.dart';

final class AtlasCatalogIndex {
  AtlasCatalogIndex({
    required Iterable<AtlasCatalogProduct> products,
  }) {
    final List<AtlasCatalogProduct> productList =
    List<AtlasCatalogProduct>.unmodifiable(
      products,
    );

    final Map<String, AtlasCatalogProduct> productsById =
    <String, AtlasCatalogProduct>{};

    final Map<String, List<AtlasCatalogProduct>> productsByBarcode =
    <String, List<AtlasCatalogProduct>>{};

    final Map<String, List<AtlasCatalogProduct>>
    productsByProductNumber =
    <String, List<AtlasCatalogProduct>>{};

    final Map<String, List<AtlasCatalogProduct>>
    productsByDisplayName =
    <String, List<AtlasCatalogProduct>>{};

    final Map<String, List<AtlasCatalogProduct>> productsBySeries =
    <String, List<AtlasCatalogProduct>>{};

    for (final AtlasCatalogProduct product in productList) {
      final String productId = product.productId.value;

      if (productsById.containsKey(productId)) {
        throw StateError(
          'Duplicate Atlas product ID detected: $productId.',
        );
      }

      productsById[productId] = product;

      for (final String barcode in product.barcodes) {
        _addToGroupedIndex(
          index: productsByBarcode,
          key: _normalizeBarcode(barcode),
          product: product,
        );
      }

      final String? productNumber = product.productNumber;

      if (productNumber != null) {
        _addToGroupedIndex(
          index: productsByProductNumber,
          key: _normalizeText(productNumber),
          product: product,
        );
      }

      _addToGroupedIndex(
        index: productsByDisplayName,
        key: _normalizeText(product.displayName),
        product: product,
      );

      final String? series = product.series;

      if (series != null) {
        _addToGroupedIndex(
          index: productsBySeries,
          key: _normalizeText(series),
          product: product,
        );
      }
    }

    this.products = productList;

    byProductId = Map<String, AtlasCatalogProduct>.unmodifiable(
      productsById,
    );

    byBarcode = _freezeGroupedIndex(
      productsByBarcode,
    );

    byProductNumber = _freezeGroupedIndex(
      productsByProductNumber,
    );

    byDisplayName = _freezeGroupedIndex(
      productsByDisplayName,
    );

    bySeries = _freezeGroupedIndex(
      productsBySeries,
    );
  }

  late final List<AtlasCatalogProduct> products;

  late final Map<String, AtlasCatalogProduct> byProductId;

  late final Map<String, List<AtlasCatalogProduct>> byBarcode;

  late final Map<String, List<AtlasCatalogProduct>>
  byProductNumber;

  late final Map<String, List<AtlasCatalogProduct>>
  byDisplayName;

  late final Map<String, List<AtlasCatalogProduct>> bySeries;

  int get productCount {
    return products.length;
  }

  bool containsProductId(
      String productId,
      ) {
    return byProductId.containsKey(
      productId.trim(),
    );
  }

  AtlasCatalogProduct? findByProductId(
      String productId,
      ) {
    return byProductId[productId.trim()];
  }

  AtlasCatalogProduct? findByAtlasProductId(
      AtlasProductId productId,
      ) {
    return byProductId[productId.value];
  }

  List<AtlasCatalogProduct> findByBarcode(
      String barcode,
      ) {
    final String normalizedBarcode =
    _normalizeBarcode(barcode);

    if (normalizedBarcode.isEmpty) {
      return const <AtlasCatalogProduct>[];
    }

    return byBarcode[normalizedBarcode] ??
        const <AtlasCatalogProduct>[];
  }

  List<AtlasCatalogProduct> findByProductNumber(
      String productNumber,
      ) {
    final String normalizedProductNumber =
    _normalizeText(productNumber);

    if (normalizedProductNumber.isEmpty) {
      return const <AtlasCatalogProduct>[];
    }

    return byProductNumber[normalizedProductNumber] ??
        const <AtlasCatalogProduct>[];
  }

  List<AtlasCatalogProduct> findByDisplayName(
      String displayName,
      ) {
    final String normalizedDisplayName =
    _normalizeText(displayName);

    if (normalizedDisplayName.isEmpty) {
      return const <AtlasCatalogProduct>[];
    }

    return byDisplayName[normalizedDisplayName] ??
        const <AtlasCatalogProduct>[];
  }

  List<AtlasCatalogProduct> findBySeries(
      String series,
      ) {
    final String normalizedSeries =
    _normalizeText(series);

    if (normalizedSeries.isEmpty) {
      return const <AtlasCatalogProduct>[];
    }

    return bySeries[normalizedSeries] ??
        const <AtlasCatalogProduct>[];
  }

  static void _addToGroupedIndex({
    required Map<String, List<AtlasCatalogProduct>> index,
    required String key,
    required AtlasCatalogProduct product,
  }) {
    if (key.isEmpty) {
      return;
    }

    index
        .putIfAbsent(
      key,
          () => <AtlasCatalogProduct>[],
    )
        .add(product);
  }

  static Map<String, List<AtlasCatalogProduct>>
  _freezeGroupedIndex(
      Map<String, List<AtlasCatalogProduct>> index,
      ) {
    return Map<String, List<AtlasCatalogProduct>>.unmodifiable(
      index.map(
            (
            String key,
            List<AtlasCatalogProduct> products,
            ) {
          return MapEntry<String, List<AtlasCatalogProduct>>(
            key,
            List<AtlasCatalogProduct>.unmodifiable(
              products,
            ),
          );
        },
      ),
    );
  }

  static String _normalizeText(
      String value,
      ) {
    return value.trim().toLowerCase();
  }

  static String _normalizeBarcode(
      String value,
      ) {
    return value.replaceAll(
      RegExp(r'[^0-9A-Za-z]'),
      '',
    );
  }
}