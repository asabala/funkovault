import 'package:funkovault2/atlas/catalog/models/atlas_catalog_product.dart';
import 'package:funkovault2/atlas/collector/models/atlas_resolved_product.dart';
import 'package:funkovault2/atlas/collector/services/atlas_collector_resolver.dart';
import 'package:funkovault2/atlas/completion/models/atlas_completion_item.dart';
import 'package:funkovault2/atlas/completion/models/atlas_completion_query.dart';
import 'package:funkovault2/atlas/completion/models/atlas_completion_result.dart';
import 'package:funkovault2/atlas/taxonomy/models/atlas_taxonomy.dart';
import 'package:funkovault2/models/pop.dart';

final class AtlasCompletionEngine {
  AtlasCompletionEngine({
    AtlasCollectorResolver? collectorResolver,
  }) : _collectorResolver =
      collectorResolver ??
          AtlasCollectorResolver.instance;

  final AtlasCollectorResolver _collectorResolver;

  AtlasCompletionResult evaluate({
    required AtlasCompletionQuery query,
    required Iterable<AtlasCatalogProduct> catalogProducts,
    required List<Pop> collectionPops,
    Set<String> ownedWishlistIdentityKeys =
    const <String>{},
    String collectionName = 'All Atlas Collections',
  }) {
    final List<AtlasCatalogProduct> normalizedProducts =
    _normalizeCatalogProducts(
      catalogProducts,
    );

    if (normalizedProducts.isEmpty) {
      return AtlasCompletionResult(
        query: query,
        items: const <AtlasCompletionItem>[],
      );
    }

    final List<AtlasResolvedProduct> resolvedProducts =
    _collectorResolver.resolveAll(
      catalogProducts: normalizedProducts,
      collectionPops: collectionPops,
      ownedWishlistIdentityKeys:
      ownedWishlistIdentityKeys,
      collectionName: collectionName,
      source: 'Atlas Completion Engine',
    );

    final List<AtlasCompletionItem> completionItems =
    <AtlasCompletionItem>[];

    for (final AtlasResolvedProduct resolvedProduct
    in resolvedProducts) {
      if (!_matchesQuery(
        taxonomy: resolvedProduct.taxonomy,
        query: query,
      )) {
        continue;
      }

      if (!query.includeInactiveCatalogItems &&
          _isInactiveCatalogProduct(
            resolvedProduct.catalogPop,
          )) {
        continue;
      }

      final bool includeWishlistState =
          query.includeWishlist &&
              resolvedProduct.collectorState.isWishlisted;

      completionItems.add(
        AtlasCompletionItem.build(
          catalogProduct:
          resolvedProduct.catalogProduct,
          taxonomy:
          resolvedProduct.taxonomy,
          ownedMatches:
          resolvedProduct.collectorState.ownedMatches,
          wishlistMatches:
          query.includeWishlist
              ? resolvedProduct
              .collectorState
              .wishlistMatches
              : const <Pop>[],
          isWishlistOverlayActive:
          includeWishlistState &&
              resolvedProduct.collectorState
                  .isOwnedWishlisted,
          releaseWeight: _releaseWeightFor(
            resolvedProduct,
          ),
        ),
      );
    }

    completionItems.sort(
          (
          AtlasCompletionItem first,
          AtlasCompletionItem second,
          ) {
        final int stateComparison =
        _stateOrder(
          first.state,
        ).compareTo(
          _stateOrder(
            second.state,
          ),
        );

        if (stateComparison != 0) {
          return stateComparison;
        }

        final int nameComparison =
        first.displayName
            .toLowerCase()
            .compareTo(
          second.displayName.toLowerCase(),
        );

        if (nameComparison != 0) {
          return nameComparison;
        }

        final int numberComparison =
        (first.productNumber ?? '')
            .compareTo(
          second.productNumber ?? '',
        );

        if (numberComparison != 0) {
          return numberComparison;
        }

        return first.productId.compareTo(
          second.productId,
        );
      },
    );

    return AtlasCompletionResult(
      query: query,
      items: completionItems,
    );
  }

  bool _matchesQuery({
    required AtlasTaxonomy taxonomy,
    required AtlasCompletionQuery query,
  }) {
    if (query.isEmpty) {
      return true;
    }

    for (final AtlasCompletionFilter filter
    in query.filters) {
      if (!taxonomy.containsNode(
        scope: filter.scope,
        id: filter.nodeId,
      )) {
        return false;
      }
    }

    return true;
  }

  List<AtlasCatalogProduct> _normalizeCatalogProducts(
      Iterable<AtlasCatalogProduct> products,
      ) {
    final Map<String, AtlasCatalogProduct> productsById =
    <String, AtlasCatalogProduct>{};

    int fallbackIndex = 0;

    for (final AtlasCatalogProduct product in products) {
      final String productId =
      product.productId.value.trim();

      final String key;

      if (productId.isNotEmpty) {
        key = productId.toLowerCase();
      } else {
        key = _fallbackProductKey(
          product: product,
          index: fallbackIndex,
        );
      }

      productsById.putIfAbsent(
        key,
            () => product,
      );

      fallbackIndex++;
    }

    return List<AtlasCatalogProduct>.unmodifiable(
      productsById.values,
    );
  }

  String _fallbackProductKey({
    required AtlasCatalogProduct product,
    required int index,
  }) {
    final String normalizedName =
    _normalizeText(
      product.displayName,
    );

    final String normalizedNumber =
    _normalizeText(
      product.productNumber ?? '',
    );

    final String normalizedVariant =
    _normalizeText(
      product.variantName ?? '',
    );

    final String barcodeKey =
    product.barcodes
        .map(_normalizeBarcode)
        .where(
          (String value) => value.isNotEmpty,
    )
        .join('|');

    return <String>[
      'fallback',
      normalizedName,
      normalizedNumber,
      normalizedVariant,
      barcodeKey,
      '$index',
    ].join(':');
  }

  bool _isInactiveCatalogProduct(
      Pop product,
      ) {
    final String normalizedStatus =
    product.productionStatus
        .trim()
        .toLowerCase();

    if (normalizedStatus.isEmpty) {
      return false;
    }

    const Set<String> inactiveStatuses =
    <String>{
      'cancelled',
      'canceled',
      'prototype',
      'concept',
      'unreleased',
      'inactive',
    };

    return inactiveStatuses.contains(
      normalizedStatus,
    );
  }

  double _releaseWeightFor(
      AtlasResolvedProduct resolvedProduct,
      ) {
    final Object? rarity =
    resolvedProduct
        .catalogProduct
        .attributes['rarity'];

    final String normalizedRarity =
        rarity
            ?.toString()
            .trim()
            .toLowerCase() ??
            '';

    if (normalizedRarity.contains(
      'chase',
    )) {
      return 2;
    }

    if (normalizedRarity.contains(
      'limited',
    ) ||
        normalizedRarity.contains(
          'numbered',
        )) {
      return 1.5;
    }

    return 1;
  }

  int _stateOrder(
      AtlasCompletionItemState state,
      ) {
    return switch (state) {
      AtlasCompletionItemState.owned => 0,
      AtlasCompletionItemState.wishlisted => 1,
      AtlasCompletionItemState.missing => 2,
    };
  }

  String _normalizeText(
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

  String _normalizeBarcode(
      String value,
      ) {
    return value.replaceAll(
      RegExp(r'[^0-9A-Za-z]'),
      '',
    );
  }
}