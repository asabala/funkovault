import '../../identity/product/atlas_product_id.dart';
import '../models/atlas_catalog_product.dart';

// Defines the read-only contract for accessing the Atlas product catalog.
//
// Implementations may use local storage, Supabase, an external provider,
// cached data, or a combination of sources without changing the engines that
// consume this interface.
abstract interface class AtlasCatalogRepository {
  Future<AtlasCatalogProduct?> findByProductId(
      AtlasProductId productId,
      );

  Future<List<AtlasCatalogProduct>> findByBarcode(
      String barcode,
      );

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
  });
}