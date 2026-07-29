import 'dart:async';
import 'dart:developer' as developer;

import '../models/product_upsert_result.dart';
import '../models/atlas_catalog_attribute_keys.dart';
import '../models/atlas_catalog_price.dart';
import '../models/atlas_catalog_product.dart';
import '../models/atlas_catalog_sync_result.dart';
import '../repository/atlas_catalog_sync_repository.dart';

typedef AtlasCatalogPriceResolver = AtlasCatalogPrice? Function(
    AtlasCatalogProduct product,
    );

class AtlasCatalogSyncService {
  const AtlasCatalogSyncService(this._repository);

  final AtlasCatalogSyncRepository _repository;

  Future<AtlasCatalogSyncResult> syncProducts({
    required Iterable<AtlasCatalogProduct> products,
    required String sourceType,
    String syncType = 'full',
    AtlasCatalogPriceResolver? priceResolver,
    Map<String, Object?> metadata = const <String, Object?>{},
  }) async {
    final DateTime startedAt = DateTime.now().toUtc();

    final List<AtlasCatalogProduct> catalogProducts = products.toList(
      growable: false,
    );

    final String normalizedSourceType = sourceType.trim();

    if (normalizedSourceType.isEmpty) {
      throw ArgumentError.value(
        sourceType,
        'sourceType',
        'Source type cannot be empty.',
      );
    }

    final String normalizedSyncType = syncType.trim();

    if (normalizedSyncType.isEmpty) {
      throw ArgumentError.value(
        syncType,
        'syncType',
        'Sync type cannot be empty.',
      );
    }

    final int syncRunId = await _repository.startSyncRun(
      sourceType: normalizedSourceType,
      syncType: normalizedSyncType,
      rowsReceived: catalogProducts.length,
      metadata: metadata,
    );

    int rowsProcessed = 0;
    int rowsInserted = 0;
    int rowsUpdated = 0;
    int rowsSkipped = 0;
    int rowsFailed = 0;

    String? firstFailureMessage;
    String? firstFailureProductId;
    String? firstFailureProductName;

    for (final AtlasCatalogProduct product in catalogProducts) {
      try {
        final String productSourceType = _sourceTypeFrom(
          product,
          fallbackSourceType: normalizedSourceType,
        );

        final String sourceProductId = _sourceProductIdFrom(product);

        if (sourceProductId.isEmpty) {
          rowsSkipped++;
          rowsProcessed++;
          continue;
        }


        final ProductUpsertResult upsertResult =
        await _upsertProductWithRetry(product);

        final int databaseProductId = upsertResult.productId;

        if (upsertResult.inserted) {
          rowsInserted++;
        } else {
          rowsUpdated++;
        }

        final AtlasCatalogPrice? price =
            priceResolver?.call(product) ??
                _priceFromProduct(
                  product,
                  sourceType: productSourceType,
                  sourceProductId: sourceProductId,
                );

        if (price != null && price.hasPrice) {
          await _repository.insertPriceSnapshot(
            databaseProductId: databaseProductId,
            price: price,
          );
        }

        rowsProcessed++;
      } catch (error, stackTrace) {
        rowsFailed++;
        rowsProcessed++;

        final String sourceProductId = _sourceProductIdFrom(product);
        final String failureMessage = _normalizedFailureMessage(error);

        firstFailureMessage ??= failureMessage;
        firstFailureProductId ??= sourceProductId.isEmpty
            ? product.productId.value
            : sourceProductId;
        firstFailureProductName ??= product.displayName;

        if (rowsFailed == 1) {
          developer.log(
            'Atlas catalog product sync failed.\n'
                'Product ID: $firstFailureProductId\n'
                'Product Name: $firstFailureProductName\n'
                'Error: $firstFailureMessage',
            name: 'AtlasCatalogSyncService',
            error: error,
            stackTrace: stackTrace,
          );
        }
      }
    }

    final String? errorMessage = rowsFailed > 0
        ? _buildSyncErrorMessage(
      rowsFailed: rowsFailed,
      firstFailureMessage: firstFailureMessage,
      firstFailureProductId: firstFailureProductId,
      firstFailureProductName: firstFailureProductName,
    )
        : null;

    final Map<String, Object?> completionMetadata = <String, Object?>{
      ...metadata,
      'priceResolverUsed': priceResolver != null,
      'firstFailureProductId': ?firstFailureProductId,
      'firstFailureProductName': ?firstFailureProductName,
      'firstFailureMessage': ?firstFailureMessage,
    };

    await _repository.completeSyncRun(
      syncRunId: syncRunId,
      rowsProcessed: rowsProcessed,
      rowsInserted: rowsInserted,
      rowsUpdated: rowsUpdated,
      rowsSkipped: rowsSkipped,
      rowsFailed: rowsFailed,
      errorMessage: errorMessage,
      metadata: completionMetadata,
    );

    final DateTime finishedAt = DateTime.now().toUtc();

    return AtlasCatalogSyncResult(
      syncRunId: syncRunId,
      sourceType: normalizedSourceType,
      rowsReceived: catalogProducts.length,
      rowsProcessed: rowsProcessed,
      rowsInserted: rowsInserted,
      rowsUpdated: rowsUpdated,
      rowsSkipped: rowsSkipped,
      rowsFailed: rowsFailed,
      startedAt: startedAt,
      finishedAt: finishedAt,
      errorMessage: errorMessage,
    );
  }

  Future<ProductUpsertResult> _upsertProductWithRetry(
      AtlasCatalogProduct product,
      ) async {
    const int maximumAttempts = 3;

    for (int attempt = 1; attempt <= maximumAttempts; attempt++) {
      try {
        return await _repository.upsertProduct(product);
      } catch (error, stackTrace) {
        final bool shouldRetry = _isTransientConnectionError(error);
        final bool hasAnotherAttempt = attempt < maximumAttempts;

        if (!shouldRetry || !hasAnotherAttempt) {
          Error.throwWithStackTrace(error, stackTrace);
        }

        final Duration retryDelay = Duration(
          milliseconds: 500 * attempt,
        );

        developer.log(
          'Transient catalog upsert failure. Retrying product.\n'
              'Product ID: ${_sourceProductIdFrom(product)}\n'
              'Product Name: ${product.displayName}\n'
              'Failed attempt: $attempt of $maximumAttempts\n'
              'Next attempt: ${attempt + 1} of $maximumAttempts\n'
              'Retry delay: ${retryDelay.inMilliseconds} ms\n'
              'Error: ${_normalizedFailureMessage(error)}',
          name: 'AtlasCatalogSyncService',
          error: error,
          stackTrace: stackTrace,
        );

        await Future<void>.delayed(retryDelay);
      }
    }

    throw StateError(
      'Catalog product upsert stopped without returning a result.',
    );
  }

  bool _isTransientConnectionError(Object error) {
    final String message = error.toString().toLowerCase();

    return message.contains('clientexception') ||
        message.contains('software caused connection abort') ||
        message.contains('connection abort') ||
        message.contains('connection reset') ||
        message.contains('connection closed') ||
        message.contains('connection terminated') ||
        message.contains('broken pipe') ||
        message.contains('socketexception') ||
        message.contains('failed host lookup') ||
        message.contains('network is unreachable') ||
        message.contains('timed out') ||
        message.contains('timeout') ||
        message.contains('statuscode: 502') ||
        message.contains('statuscode: 503') ||
        message.contains('statuscode: 504');
  }

  String _sourceTypeFrom(
      AtlasCatalogProduct product, {
        required String fallbackSourceType,
      }) {
    return _textAttribute(
      product,
      AtlasCatalogAttributeKeys.source,
    ) ??
        fallbackSourceType;
  }

  String _sourceProductIdFrom(
      AtlasCatalogProduct product,
      ) {
    return _textAttribute(
      product,
      AtlasCatalogAttributeKeys.sourceProductId,
    ) ??
        product.productId.value.trim();
  }

  AtlasCatalogPrice? _priceFromProduct(
      AtlasCatalogProduct product, {
        required String sourceType,
        required String sourceProductId,
      }) {
    final double? lowPrice = _doubleAttribute(
      product,
      AtlasCatalogAttributeKeys.lowPrice,
    );

    final double? midPrice = _doubleAttribute(
      product,
      AtlasCatalogAttributeKeys.midPrice,
    );

    final double? highPrice = _doubleAttribute(
      product,
      AtlasCatalogAttributeKeys.highPrice,
    );

    final double? marketPrice = _doubleAttribute(
      product,
      AtlasCatalogAttributeKeys.marketPrice,
    );

    final double? directLowPrice = _doubleAttribute(
      product,
      AtlasCatalogAttributeKeys.directLowPrice,
    );

    final bool hasAnyPrice = <double?>[
      lowPrice,
      midPrice,
      highPrice,
      marketPrice,
      directLowPrice,
    ].any(
          (double? value) => value != null && value > 0,
    );

    if (!hasAnyPrice) {
      return null;
    }

    return AtlasCatalogPrice(
      sourceType: sourceType,
      sourceProductId: sourceProductId,
      lowPrice: lowPrice,
      midPrice: midPrice,
      highPrice: highPrice,
      marketPrice: marketPrice,
      directLowPrice: directLowPrice,
      sourceModifiedAt: _sourceModifiedAtFrom(product),
      capturedAt: DateTime.now().toUtc(),
    );
  }

  DateTime? _sourceModifiedAtFrom(
      AtlasCatalogProduct product,
      ) {
    final String? value = _textAttribute(
      product,
      AtlasCatalogAttributeKeys.modifiedOn,
    );

    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value)?.toUtc();
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

    return normalized.isEmpty ? null : normalized;
  }

  double? _doubleAttribute(
      AtlasCatalogProduct product,
      String key,
      ) {
    final Object? value = product.attributes[key];

    if (value == null) {
      return null;
    }

    if (value is num) {
      final double parsed = value.toDouble();

      return parsed > 0 ? parsed : null;
    }

    final String normalized = value
        .toString()
        .replaceAll(r'$', '')
        .replaceAll(',', '')
        .trim();

    final double? parsed = double.tryParse(normalized);

    if (parsed == null || parsed <= 0) {
      return null;
    }

    return parsed;
  }

  String _normalizedFailureMessage(Object error) {
    final String message = error.toString().trim();

    if (message.isEmpty) {
      return 'Unknown catalog synchronization error.';
    }

    const int maximumLength = 1000;

    if (message.length <= maximumLength) {
      return message;
    }

    return '${message.substring(0, maximumLength)}...';
  }

  String _buildSyncErrorMessage({
    required int rowsFailed,
    required String? firstFailureMessage,
    required String? firstFailureProductId,
    required String? firstFailureProductName,
  }) {
    final StringBuffer message = StringBuffer(
      '$rowsFailed catalog row${rowsFailed == 1 ? '' : 's'} '
          'failed during sync.',
    );

    if (firstFailureProductId != null) {
      message.write(
        ' First failed product ID: $firstFailureProductId.',
      );
    }

    if (firstFailureProductName != null) {
      message.write(
        ' Product: $firstFailureProductName.',
      );
    }

    if (firstFailureMessage != null) {
      message.write(
        ' Error: $firstFailureMessage',
      );
    }

    return message.toString();
  }
}