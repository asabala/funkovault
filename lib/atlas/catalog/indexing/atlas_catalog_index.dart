import '../models/atlas_catalog_product.dart';

// Immutable lookup indexes for Atlas catalog products.
//
// These indexes allow repository implementations to perform fast lookups
// without repeatedly scanning the entire catalog.
final class AtlasCatalogIndex {
  AtlasCatalogIndex({
    required Iterable<AtlasCatalogProduct> products,
  })  : products = List.unmodifiable(products),
        byProductId = Map.unmodifiable(
          {
            for (final product in products)
              product.productId.value: product,
          },
        ),
        byBarcode = Map.unmodifiable(
          _buildBarcodeIndex(products),
        );

  final List<AtlasCatalogProduct> products;

  final Map<String, AtlasCatalogProduct> byProductId;

  final Map<String, List<AtlasCatalogProduct>> byBarcode;

  AtlasCatalogProduct? findByProductId(
      String productId,
      ) {
    return byProductId[productId];
  }

  List<AtlasCatalogProduct> findByBarcode(
      String barcode,
      ) {
    return byBarcode[barcode] ??
        const <AtlasCatalogProduct>[];
  }

  static Map<String, List<AtlasCatalogProduct>>
  _buildBarcodeIndex(
      Iterable<AtlasCatalogProduct> products,
      ) {
    final Map<String, List<AtlasCatalogProduct>>
    index = {};

    for (final product in products) {
      for (final barcode in product.barcodes) {
        index.putIfAbsent(
          barcode,
              () => <AtlasCatalogProduct>[],
        );

        index[barcode]!.add(product);
      }
    }

    return index.map(
          (key, value) => MapEntry(
        key,
        List.unmodifiable(value),
      ),
    );
  }
}