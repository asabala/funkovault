import '../loaders/atlas_catalog_loader.dart';
import '../models/atlas_catalog_product.dart';
import '../models/atlas_catalog_sync_result.dart';
import 'atlas_catalog_sync_service.dart';

/// Coordinates loading and synchronizing the bundled Atlas catalog.
///
/// This service intentionally sits between the catalog loader and the catalog
/// sync service:
///
/// - [AtlasCatalogLoader] reads and maps the bundled catalog asset.
/// - [AtlasCatalogSyncService] persists canonical products and price history.
/// - [AtlasCatalogBootstrapService] coordinates those two operations.
///
/// Catalog synchronization should be triggered intentionally rather than during
/// ordinary catalog searches or barcode scans.
final class AtlasCatalogBootstrapService {
  const AtlasCatalogBootstrapService({required this.syncService});

  final AtlasCatalogSyncService syncService;

  /// Loads the bundled Pop Vinyl catalog and synchronizes it with Supabase.
  Future<AtlasCatalogSyncResult> syncBundledPopVinylCatalog() async {
    final List<AtlasCatalogProduct> products =
        await AtlasCatalogLoader.loadPopVinylCatalog();

    return syncService.syncProducts(sourceType: 'tcgcsv', products: products);
  }
}
