import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/atlas_catalog_attribute_keys.dart';
import '../models/atlas_catalog_price.dart';
import '../models/atlas_catalog_product.dart';
import 'atlas_catalog_sync_repository.dart';

final class SupabaseAtlasCatalogSyncRepository
    implements AtlasCatalogSyncRepository {
  SupabaseAtlasCatalogSyncRepository({
    SupabaseClient? client,
  }) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const String _productsTable = 'products';
  static const String _productPricesTable = 'product_prices';
  static const String _syncRunsTable = 'catalog_sync_runs';

  @override
  Future<int> startSyncRun({
    required String sourceType,
    required String syncType,
    required int rowsReceived,
    Map<String, Object?> metadata = const <String, Object?>{},
  }) async {
    final Map<String, dynamic> response = await _client
        .from(_syncRunsTable)
        .insert(
      <String, Object?>{
        'source_type': sourceType.trim(),
        'sync_type': syncType.trim(),
        'status': 'running',
        'rows_received': rowsReceived,
        'rows_processed': 0,
        'rows_inserted': 0,
        'rows_updated': 0,
        'rows_skipped': 0,
        'rows_failed': 0,
        if (metadata.isNotEmpty)
          'metadata': _toJsonSafeMap(metadata),
      },
    )
        .select('id')
        .single();

    return _readDatabaseId(
      response,
      context: 'catalog sync run',
    );
  }

  @override
  Future<bool> productExists({
    required String sourceType,
    required String sourceProductId,
  }) async {
    final String normalizedSourceType = sourceType.trim();
    final String normalizedSourceProductId = sourceProductId.trim();

    if (normalizedSourceType.isEmpty ||
        normalizedSourceProductId.isEmpty) {
      return false;
    }

    final List<Map<String, dynamic>> response = await _client
        .from(_productsTable)
        .select('id')
        .eq(
      'source_type',
      normalizedSourceType,
    )
        .eq(
      'source_product_id',
      normalizedSourceProductId,
    )
        .limit(1);

    return response.isNotEmpty;
  }

  @override
  Future<int> upsertProduct(
      AtlasCatalogProduct product,
      ) async {
    final String sourceType = _sourceTypeFrom(product);
    final String sourceProductId = _sourceProductIdFrom(product);

    if (sourceType.isEmpty) {
      throw StateError(
        'Catalog product ${product.productId.value} does not contain '
            'a source type.',
      );
    }

    if (sourceProductId.isEmpty) {
      throw StateError(
        'Catalog product ${product.productId.value} does not contain '
            'a source product ID.',
      );
    }

    final DateTime now = DateTime.now().toUtc();

    final Map<String, dynamic> response = await _client
        .from(_productsTable)
        .upsert(
      _productPayload(
        product: product,
        sourceType: sourceType,
        sourceProductId: sourceProductId,
        syncedAt: now,
      ),
      onConflict: 'source_type,source_product_id',
    )
        .select('id')
        .single();

    return _readDatabaseId(
      response,
      context: 'catalog product',
    );
  }

  @override
  Future<void> insertPriceSnapshot({
    required int databaseProductId,
    required AtlasCatalogPrice price,
  }) async {
    if (databaseProductId <= 0) {
      throw ArgumentError.value(
        databaseProductId,
        'databaseProductId',
        'Database product ID must be greater than zero.',
      );
    }

    if (!price.hasPrice) {
      return;
    }

    final DateTime? sourceModifiedAt =
    price.sourceModifiedAt?.toUtc();

    if (sourceModifiedAt != null) {
      final bool alreadyExists = await _priceSnapshotExists(
        databaseProductId: databaseProductId,
        sourceType: price.sourceType,
        sourceModifiedAt: sourceModifiedAt,
      );

      if (alreadyExists) {
        return;
      }
    }

    try {
      await _client.from(_productPricesTable).insert(
        <String, Object?>{
          'product_id': databaseProductId,
          'source_type': price.sourceType.trim(),
          'source_product_id': _nullableText(
            price.sourceProductId,
          ),
          'low_price': _positivePriceOrNull(
            price.lowPrice,
          ),
          'mid_price': _positivePriceOrNull(
            price.midPrice,
          ),
          'high_price': _positivePriceOrNull(
            price.highPrice,
          ),
          'market_price': _positivePriceOrNull(
            price.marketPrice,
          ),
          'direct_low_price': _positivePriceOrNull(
            price.directLowPrice,
          ),
          'currency_code': _currencyCodeFrom(price),
          if (sourceModifiedAt != null)
            'source_modified_at':
            sourceModifiedAt.toIso8601String(),
          'captured_at':
          (price.capturedAt ?? DateTime.now())
              .toUtc()
              .toIso8601String(),
        },
      );
    } on PostgrestException catch (error) {
      // A repeated catalog file can attempt to insert the same source
      // snapshot more than once. The database unique index remains the
      // final protection against that race.
      if (error.code == '23505') {
        return;
      }

      rethrow;
    }
  }

  @override
  Future<void> completeSyncRun({
    required int syncRunId,
    required int rowsProcessed,
    required int rowsInserted,
    required int rowsUpdated,
    required int rowsSkipped,
    required int rowsFailed,
    String? errorMessage,
    Map<String, Object?> metadata = const <String, Object?>{},
  }) async {
    if (syncRunId <= 0) {
      throw ArgumentError.value(
        syncRunId,
        'syncRunId',
        'Sync run ID must be greater than zero.',
      );
    }

    final String? normalizedErrorMessage =
    _nullableText(errorMessage);

    final bool completedWithErrors =
        rowsFailed > 0 || normalizedErrorMessage != null;

    await _client
        .from(_syncRunsTable)
        .update(
      <String, Object?>{
        'status': completedWithErrors
            ? 'completed_with_errors'
            : 'completed',
        'finished_at':
        DateTime.now().toUtc().toIso8601String(),
        'rows_processed': rowsProcessed,
        'rows_inserted': rowsInserted,
        'rows_updated': rowsUpdated,
        'rows_skipped': rowsSkipped,
        'rows_failed': rowsFailed,
        'error_message': normalizedErrorMessage,
        if (metadata.isNotEmpty)
          'metadata': _toJsonSafeMap(metadata),
      },
    )
        .eq(
      'id',
      syncRunId,
    );
  }

  Future<bool> _priceSnapshotExists({
    required int databaseProductId,
    required String sourceType,
    required DateTime sourceModifiedAt,
  }) async {
    final List<Map<String, dynamic>> response = await _client
        .from(_productPricesTable)
        .select('id')
        .eq(
      'product_id',
      databaseProductId,
    )
        .eq(
      'source_type',
      sourceType.trim(),
    )
        .eq(
      'source_modified_at',
      sourceModifiedAt.toIso8601String(),
    )
        .limit(1);

    return response.isNotEmpty;
  }

  Map<String, Object?> _productPayload({
    required AtlasCatalogProduct product,
    required String sourceType,
    required String sourceProductId,
    required DateTime syncedAt,
  }) {
    final String? barcode = product.barcodes.isEmpty
        ? null
        : product.barcodes.first;

    final String? imageUrl = _textAttribute(
      product,
      AtlasCatalogAttributeKeys.imageUrl,
    );

    final String? sourceUrl = _textAttribute(
      product,
      AtlasCatalogAttributeKeys.sourceUrl,
    );

    final String? licenseName = _textAttribute(
      product,
      AtlasCatalogAttributeKeys.licenseName,
    );

    final String? retailer = _textAttribute(
      product,
      AtlasCatalogAttributeKeys.retailer,
    );

    return <String, Object?>{
      'title': product.displayName,
      'barcode': barcode,
      'funko_number': product.productNumber,
      'category': product.categoryCode,
      'franchise':
      licenseName ??
          product.brand ??
          product.productLine,
      'exclusive_name': retailer,
      'variant_name': product.variantName,
      'image_url': imageUrl,
      'release_year': _releaseYearFrom(product),
      'status': 'active',
      'source': sourceType,
      'updated_at': syncedAt.toIso8601String(),
      'catalog_status': 'active',
      'source_type': sourceType,
      'source_product_id': sourceProductId,
      'source_category_id': _textAttribute(
        product,
        AtlasCatalogAttributeKeys.sourceCategoryId,
      ),
      'source_group_id': _textAttribute(
        product,
        AtlasCatalogAttributeKeys.sourceGroupId,
      ),
      'source_url': sourceUrl,
      'source_modified_at': _sourceModifiedAtFrom(product),
      'clean_name': _cleanName(product.displayName),
      'description': _textAttribute(
        product,
        AtlasCatalogAttributeKeys.description,
      ),
      'rarity': _textAttribute(
        product,
        AtlasCatalogAttributeKeys.rarity,
      ),
      'model_number': _textAttribute(
        product,
        AtlasCatalogAttributeKeys.model,
      ),
      'gtin': _textAttribute(
        product,
        AtlasCatalogAttributeKeys.gtin,
      ),
      'upc':
      _textAttribute(
        product,
        AtlasCatalogAttributeKeys.upc,
      ) ??
          barcode,
      'printing': _textAttribute(
        product,
        AtlasCatalogAttributeKeys.printing,
      ),
      'series_name': product.series ?? product.productLine,
      'treatment': _textAttribute(
        product,
        AtlasCatalogAttributeKeys.treatment,
      ),
      'subtype_name': _textAttribute(
        product,
        AtlasCatalogAttributeKeys.subTypeName,
      ),
      'data_source': sourceType,
      'finish': _textAttribute(
        product,
        AtlasCatalogAttributeKeys.finish,
      ),
      'sticker_type': _textAttribute(
        product,
        AtlasCatalogAttributeKeys.stickerType,
      ),
      'retailer': retailer,
      'event_name': _textAttribute(
        product,
        AtlasCatalogAttributeKeys.eventName,
      ),
      'packaging_type': _textAttribute(
        product,
        AtlasCatalogAttributeKeys.packagingType,
      ),
      'box_version': _textAttribute(
        product,
        AtlasCatalogAttributeKeys.boxVersion,
      ),
      'production_code': _textAttribute(
        product,
        AtlasCatalogAttributeKeys.productionCode,
      ),
      'size': _textAttribute(
        product,
        AtlasCatalogAttributeKeys.size,
      ),
      'license_name': licenseName,
      'character_name': product.characterName,
      'wave_name': _textAttribute(
        product,
        AtlasCatalogAttributeKeys.waveName,
      ),
      'catalog_last_synced_at': syncedAt.toIso8601String(),
      'source_payload': _sourcePayloadFrom(product),
    };
  }

  String _sourceTypeFrom(
      AtlasCatalogProduct product,
      ) {
    return _textAttribute(
      product,
      AtlasCatalogAttributeKeys.source,
    ) ??
        'tcgcsv';
  }

  String _sourceProductIdFrom(
      AtlasCatalogProduct product,
      ) {
    return _textAttribute(
      product,
      AtlasCatalogAttributeKeys.sourceProductId,
    ) ??
        product.productId.value;
  }

  String? _sourceModifiedAtFrom(
      AtlasCatalogProduct product,
      ) {
    final String? rawModifiedOn = _textAttribute(
      product,
      AtlasCatalogAttributeKeys.modifiedOn,
    );

    if (rawModifiedOn == null) {
      return null;
    }

    final DateTime? parsedDate = DateTime.tryParse(
      rawModifiedOn,
    );

    if (parsedDate == null) {
      return null;
    }

    return parsedDate.toUtc().toIso8601String();
  }

  int? _releaseYearFrom(
      AtlasCatalogProduct product,
      ) {
    final String? releaseDate = _textAttribute(
      product,
      AtlasCatalogAttributeKeys.releaseDate,
    );

    if (releaseDate == null) {
      return null;
    }

    final DateTime? parsedDate = DateTime.tryParse(
      releaseDate,
    );

    if (parsedDate != null) {
      return parsedDate.year;
    }

    final RegExpMatch? yearMatch = RegExp(
      r'\b(19|20)\d{2}\b',
    ).firstMatch(releaseDate);

    if (yearMatch == null) {
      return null;
    }

    return int.tryParse(
      yearMatch.group(0) ?? '',
    );
  }

  Map<String, Object?> _sourcePayloadFrom(
      AtlasCatalogProduct product,
      ) {
    return _toJsonSafeMap(
      <String, Object?>{
        'atlasProductId': product.productId.value,
        'displayName': product.displayName,
        'categoryCode': product.categoryCode,
        'brand': product.brand,
        'productLine': product.productLine,
        'series': product.series,
        'characterName': product.characterName,
        'productNumber': product.productNumber,
        'variantName': product.variantName,
        'barcodes': product.barcodes,
        'attributes': product.attributes,
      },
    );
  }

  String? _textAttribute(
      AtlasCatalogProduct product,
      String key,
      ) {
    final Object? value = product.attributes[key];

    if (value == null) {
      return null;
    }

    final String normalized = value.toString().trim();

    if (normalized.isEmpty) {
      return null;
    }

    return normalized;
  }

  int _readDatabaseId(
      Map<String, dynamic> row, {
        required String context,
      }) {
    final Object? value = row['id'];

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    final int? parsed = int.tryParse(
      value?.toString() ?? '',
    );

    if (parsed != null) {
      return parsed;
    }

    throw StateError(
      'Supabase did not return a valid ID for the $context.',
    );
  }

  String _currencyCodeFrom(
      AtlasCatalogPrice price,
      ) {
    final String normalized =
    price.currencyCode.trim().toUpperCase();

    return normalized.isEmpty ? 'USD' : normalized;
  }

  double? _positivePriceOrNull(
      double? value,
      ) {
    if (value == null || value <= 0) {
      return null;
    }

    return value;
  }

  String _cleanName(
      String value,
      ) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(
      RegExp(r'[^a-z0-9]+'),
      ' ',
    )
        .replaceAll(
      RegExp(r'\s+'),
      ' ',
    )
        .trim();
  }

  String? _nullableText(
      String? value,
      ) {
    final String normalized = value?.trim() ?? '';

    return normalized.isEmpty ? null : normalized;
  }

  Map<String, Object?> _toJsonSafeMap(
      Map<String, Object?> values,
      ) {
    return values.map(
          (
          String key,
          Object? value,
          ) {
        return MapEntry<String, Object?>(
          key,
          _toJsonSafeValue(value),
        );
      },
    );
  }

  Object? _toJsonSafeValue(
      Object? value,
      ) {
    if (value == null ||
        value is String ||
        value is num ||
        value is bool) {
      return value;
    }

    if (value is DateTime) {
      return value.toUtc().toIso8601String();
    }

    if (value is Map) {
      return value.map(
            (
            Object? key,
            Object? nestedValue,
            ) {
          return MapEntry<String, Object?>(
            key.toString(),
            _toJsonSafeValue(nestedValue),
          );
        },
      );
    }

    if (value is Iterable) {
      return value
          .map<Object?>(
        _toJsonSafeValue,
      )
          .toList(
        growable: false,
      );
    }

    return value.toString();
  }
}