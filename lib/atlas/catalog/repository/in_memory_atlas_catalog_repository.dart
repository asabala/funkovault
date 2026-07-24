import '../../identity/product/atlas_product_id.dart';
import '../indexing/atlas_catalog_index.dart';
import '../indexing/atlas_catalog_search_index.dart';
import '../models/atlas_catalog_product.dart';
import 'atlas_catalog_repository.dart';

// Simple in-memory catalog used for development, testing, and early
// pipeline validation.
final class InMemoryAtlasCatalogRepository
    implements AtlasCatalogRepository {
  InMemoryAtlasCatalogRepository({
    Iterable<AtlasCatalogProduct> products =
    const <AtlasCatalogProduct>[],
  })  : _index = AtlasCatalogIndex(
    products: products,
  ),
        _searchIndex =
        AtlasCatalogSearchIndex(
          products: products,
        );

  final AtlasCatalogIndex _index;

  final AtlasCatalogSearchIndex
  _searchIndex;

  @override
  Future<AtlasCatalogProduct?> findByProductId(
      AtlasProductId productId,
      ) async {
    return _index.findByProductId(
      productId.value,
    );
  }

  @override
  Future<List<AtlasCatalogProduct>> findByBarcode(
      String barcode,
      ) async {
    return _index.findByBarcode(
      barcode,
    );
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
    return _searchIndex.search(
      query: query,
      categoryCode: categoryCode,
      brand: brand,
      productLine: productLine,
      series: series,
      characterName: characterName,
      productNumber: productNumber,
      variantName: variantName,
      limit: limit,
    );
  }
}