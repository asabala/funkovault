import '../models/atlas_catalog_price.dart';
import '../models/atlas_catalog_product.dart';
import '../models/product_upsert_result.dart';

abstract interface class AtlasCatalogSyncRepository {
  Future<int> startSyncRun({
    required String sourceType,
    required String syncType,
    required int rowsReceived,
    Map<String, Object?> metadata =
    const <String, Object?>{},
  });

  Future<ProductUpsertResult> upsertProduct(
      AtlasCatalogProduct product,
      );

  Future<void> insertPriceSnapshot({
    required int databaseProductId,
    required AtlasCatalogPrice price,
  });

  Future<void> completeSyncRun({
    required int syncRunId,
    required int rowsProcessed,
    required int rowsInserted,
    required int rowsUpdated,
    required int rowsSkipped,
    required int rowsFailed,
    String? errorMessage,
    Map<String, Object?> metadata =
    const <String, Object?>{},
  });
}