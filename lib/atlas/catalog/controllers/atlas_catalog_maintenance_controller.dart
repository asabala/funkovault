import '../models/atlas_catalog_sync_result.dart';
import '../repository/atlas_catalog_sync_repository.dart';
import '../repository/supabase_atlas_catalog_sync_repository.dart';
import '../services/atlas_catalog_bootstrap_service.dart';
import '../services/atlas_catalog_sync_service.dart';

final class AtlasCatalogMaintenanceController {
  AtlasCatalogMaintenanceController({
    AtlasCatalogSyncRepository? repository,
  }) : _repository =
      repository ?? SupabaseAtlasCatalogSyncRepository();

  final AtlasCatalogSyncRepository _repository;

  Future<AtlasCatalogSyncResult> syncCatalog() async {
    final AtlasCatalogSyncService syncService =
    AtlasCatalogSyncService(_repository);

    final AtlasCatalogBootstrapService bootstrapService =
    AtlasCatalogBootstrapService(
      syncService: syncService,
    );

    return bootstrapService.syncBundledPopVinylCatalog();
  }
}