import '../models/atlas_catalog_sync_result.dart';
import '../repository/atlas_catalog_sync_repository.dart';
import '../repository/supabase_atlas_catalog_sync_repository.dart';
import '../services/atlas_catalog_bootstrap_service.dart';
import '../services/atlas_catalog_sync_service.dart';

final class AtlasCatalogMaintenanceController {
  AtlasCatalogMaintenanceController({this.repository});

  final AtlasCatalogSyncRepository? repository;

  Future<AtlasCatalogSyncResult> syncCatalog() async {
    final AtlasCatalogSyncRepository syncRepository =
        repository ?? SupabaseAtlasCatalogSyncRepository();

    final AtlasCatalogSyncService syncService = AtlasCatalogSyncService(
      syncRepository,
    );

    final AtlasCatalogBootstrapService bootstrapService =
        AtlasCatalogBootstrapService(syncService: syncService);

    return bootstrapService.syncBundledPopVinylCatalog();
  }
}
