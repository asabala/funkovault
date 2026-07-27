import 'package:funkovault2/atlas/catalog/models/atlas_catalog_product.dart';
import 'package:funkovault2/atlas/catalog/repository/atlas_catalog_repository.dart';
import 'package:funkovault2/atlas/catalog/repository/local_atlas_catalog_repository.dart';
import 'package:funkovault2/atlas/identity/product/atlas_product_id.dart';

/// Central read-only access point for the Atlas product catalog.
///
/// Screens, engines, and workflows should depend on this service rather than
/// creating repository implementations directly.
///
/// The repository can later be replaced with a Supabase, cloud, cached, or
/// combined implementation without changing catalog consumers.
final class AtlasCatalogService {
  AtlasCatalogService({
    AtlasCatalogRepository? repository,
  }) : _repository =
      repository ?? LocalAtlasCatalogRepository();

  /// Shared catalog service used throughout Atlas.
  static final AtlasCatalogService instance =
  AtlasCatalogService();

  final AtlasCatalogRepository _repository;

  /// Finds one catalog product using its Atlas-owned product ID.
  Future<AtlasCatalogProduct?> findByProductId(
      AtlasProductId productId,
      ) {
    return _repository.findByProductId(
      productId,
    );
  }

  /// Finds all catalog products associated with a barcode.
  ///
  /// A list is returned because more than one catalog record may
  /// legitimately share or reference the same barcode.
  Future<List<AtlasCatalogProduct>> findByBarcode(
      String barcode,
      ) {
    return _repository.findByBarcode(
      barcode,
    );
  }

  /// Searches the catalog using a general query and optional filters.
  ///
  /// The general query may match several product fields. Specific filters
  /// are handled by the active repository implementation.
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
  }) {
    return _repository.search(
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