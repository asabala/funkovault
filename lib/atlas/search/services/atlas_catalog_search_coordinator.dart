import 'package:funkovault2/atlas/catalog/converters/atlas_catalog_converter.dart';
import 'package:funkovault2/atlas/catalog/models/atlas_catalog_product.dart';
import 'package:funkovault2/atlas/catalog/services/atlas_catalog_service.dart';
import 'package:funkovault2/models/pop.dart';

final class AtlasCatalogSearchCoordinator {
  AtlasCatalogSearchCoordinator({AtlasCatalogService? catalogService})
    : _catalogService = catalogService ?? AtlasCatalogService.instance;

  final AtlasCatalogService _catalogService;

  Future<List<AtlasCatalogSearchCandidate>> search({
    required String query,
    required Map<String, List<Pop>> collections,
    int limit = 200,
  }) async {
    final String cleanedQuery = query.trim();

    if (cleanedQuery.isEmpty || limit <= 0) {
      return const <AtlasCatalogSearchCandidate>[];
    }

    final List<AtlasCatalogProduct> catalogProducts = await _catalogService
        .search(query: cleanedQuery, limit: limit);

    final List<_MutableSearchCandidate> candidates =
        <_MutableSearchCandidate>[];

    final Map<String, _MutableSearchCandidate> candidatesByCatalogId =
        <String, _MutableSearchCandidate>{};

    final Map<String, _MutableSearchCandidate> candidatesByCollectibleId =
        <String, _MutableSearchCandidate>{};

    final Map<String, _MutableSearchCandidate> candidatesByUpc =
        <String, _MutableSearchCandidate>{};

    final Map<String, _MutableSearchCandidate> vaultOnlyCandidatesByIdentity =
        <String, _MutableSearchCandidate>{};

    final DateTime conversionTimestamp = DateTime.now();

    for (int index = 0; index < catalogProducts.length; index++) {
      final AtlasCatalogProduct catalogProduct = catalogProducts[index];

      final String catalogId = _normalizeIdentifier(
        catalogProduct.productId.value,
      );

      if (catalogId.isEmpty || candidatesByCatalogId.containsKey(catalogId)) {
        continue;
      }

      final Pop catalogPop = AtlasCatalogConverter.toPop(
        catalogProduct,
        owner: 'Atlas Catalog',
        quantity: 1,
        timestamp: conversionTimestamp.add(Duration(microseconds: index)),
      );

      final _MutableSearchCandidate candidate = _MutableSearchCandidate(
        catalogProduct: catalogProduct,
        pop: catalogPop,
        isCatalogBacked: true,
      );

      candidates.add(candidate);

      candidatesByCatalogId[catalogId] = candidate;

      final String collectibleId = _normalizeIdentifier(
        catalogPop.sourceCollectibleId,
      );

      if (collectibleId.isNotEmpty) {
        candidatesByCollectibleId.putIfAbsent(collectibleId, () => candidate);
      }

      final String upc = _normalizeBarcode(catalogPop.sourceUpc);

      if (upc.isNotEmpty) {
        candidatesByUpc.putIfAbsent(upc, () => candidate);
      }
    }

    for (final MapEntry<String, List<Pop>> collectionEntry
        in collections.entries) {
      final String collectionName = collectionEntry.key.trim().isEmpty
          ? 'Vault'
          : collectionEntry.key.trim();

      for (final Pop vaultPop in collectionEntry.value) {
        if (!_matchesVaultQuery(
          pop: vaultPop,
          collectionName: collectionName,
          query: cleanedQuery,
        )) {
          continue;
        }

        final _MutableSearchCandidate? representedCatalogCandidate =
            _findCatalogCandidate(
              pop: vaultPop,
              candidatesByCatalogId: candidatesByCatalogId,
              candidatesByCollectibleId: candidatesByCollectibleId,
              candidatesByUpc: candidatesByUpc,
            );

        if (representedCatalogCandidate != null) {
          representedCatalogCandidate.collectionNames.add(collectionName);

          continue;
        }

        final String vaultIdentityKey = _vaultIdentityKey(vaultPop);

        final _MutableSearchCandidate? existingVaultCandidate =
            vaultOnlyCandidatesByIdentity[vaultIdentityKey];

        if (existingVaultCandidate != null) {
          existingVaultCandidate.collectionNames.add(collectionName);

          continue;
        }

        final _MutableSearchCandidate candidate = _MutableSearchCandidate(
          pop: vaultPop,
          isCatalogBacked: false,
          collectionNames: <String>{collectionName},
        );

        vaultOnlyCandidatesByIdentity[vaultIdentityKey] = candidate;

        candidates.add(candidate);
      }
    }

    return List<AtlasCatalogSearchCandidate>.unmodifiable(
      candidates.map((_MutableSearchCandidate candidate) {
        return candidate.freeze();
      }),
    );
  }

  static _MutableSearchCandidate? _findCatalogCandidate({
    required Pop pop,
    required Map<String, _MutableSearchCandidate> candidatesByCatalogId,
    required Map<String, _MutableSearchCandidate> candidatesByCollectibleId,
    required Map<String, _MutableSearchCandidate> candidatesByUpc,
  }) {
    final String catalogId = _normalizeIdentifier(pop.sourceCatalogId);

    if (catalogId.isNotEmpty) {
      final _MutableSearchCandidate? catalogCandidate =
          candidatesByCatalogId[catalogId];

      if (catalogCandidate != null) {
        return catalogCandidate;
      }
    }

    final String collectibleId = _normalizeIdentifier(pop.sourceCollectibleId);

    if (collectibleId.isNotEmpty) {
      final _MutableSearchCandidate? collectibleCandidate =
          candidatesByCollectibleId[collectibleId];

      if (collectibleCandidate != null) {
        return collectibleCandidate;
      }
    }

    final String upc = _normalizeBarcode(pop.sourceUpc);

    if (upc.isNotEmpty) {
      return candidatesByUpc[upc];
    }

    return null;
  }

  static bool _matchesVaultQuery({
    required Pop pop,
    required String collectionName,
    required String query,
  }) {
    final String normalizedQuery = _normalizeSearchText(query);

    if (normalizedQuery.isEmpty) {
      return false;
    }

    final String searchableText = _normalizeSearchText(
      <String>[
        pop.name,
        pop.number,
        pop.category,
        pop.series,
        pop.edition,
        pop.variant,
        pop.retailExclusive,
        pop.eventSticker,
        pop.limitedEdition,
        pop.signature,
        pop.owner,
        pop.sourceUpc,
        pop.sourceCatalogId,
        pop.sourceCollectibleId,
        pop.collectorLabel,
        collectionName,
        pop.isWishlist ? 'wishlist' : 'owned',
      ].join(' '),
    );

    return searchableText.contains(normalizedQuery);
  }

  static String _vaultIdentityKey(Pop pop) {
    final String catalogId = _normalizeIdentifier(pop.sourceCatalogId);

    if (catalogId.isNotEmpty) {
      return 'catalog:$catalogId';
    }

    final String collectibleId = _normalizeIdentifier(pop.sourceCollectibleId);

    if (collectibleId.isNotEmpty) {
      return 'collectible:$collectibleId';
    }

    final String upc = _normalizeBarcode(pop.sourceUpc);

    if (upc.isNotEmpty) {
      return 'upc:$upc';
    }

    return <String>[
      'release',
      _normalizeSearchText(pop.name),
      _normalizeSearchText(pop.number),
      _normalizeSearchText(pop.variant),
      _normalizeSearchText(pop.edition),
      _normalizeSearchText(pop.retailExclusive),
      _normalizeSearchText(pop.eventSticker),
      _normalizeSearchText(pop.limitedEdition),
      _normalizeSearchText(pop.signature),
    ].join('|');
  }

  static String _normalizeIdentifier(String value) {
    return value.trim().toLowerCase();
  }

  static String _normalizeBarcode(String value) {
    return value.replaceAll(RegExp(r'[^0-9A-Za-z]'), '');
  }

  static String _normalizeSearchText(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

final class AtlasCatalogSearchCandidate {
  const AtlasCatalogSearchCandidate({
    required this.pop,
    required this.isCatalogBacked,
    required this.collectionNames,
    this.catalogProduct,
  });

  final AtlasCatalogProduct? catalogProduct;
  final Pop pop;
  final bool isCatalogBacked;
  final List<String> collectionNames;

  bool get hasVaultLocations {
    return collectionNames.isNotEmpty;
  }

  bool get isVaultOnly {
    return !isCatalogBacked;
  }

  String get productId {
    return catalogProduct?.productId.value ?? pop.sourceCatalogId;
  }

  String get displayName {
    return pop.name;
  }

  String get sourceLabel {
    if (isCatalogBacked && collectionNames.isEmpty) {
      return 'Atlas Catalog';
    }

    if (isCatalogBacked) {
      return 'Atlas Catalog • ${collectionNames.join(', ')}';
    }

    if (collectionNames.isNotEmpty) {
      return collectionNames.join(', ');
    }

    return 'Vault';
  }
}

final class _MutableSearchCandidate {
  _MutableSearchCandidate({
    required this.pop,
    required this.isCatalogBacked,
    this.catalogProduct,
    Set<String>? collectionNames,
  }) : collectionNames = collectionNames ?? <String>{};

  final AtlasCatalogProduct? catalogProduct;
  final Pop pop;
  final bool isCatalogBacked;
  final Set<String> collectionNames;

  AtlasCatalogSearchCandidate freeze() {
    final List<String> sortedCollectionNames = collectionNames.toList(
      growable: false,
    )..sort();

    return AtlasCatalogSearchCandidate(
      catalogProduct: catalogProduct,
      pop: pop,
      isCatalogBacked: isCatalogBacked,
      collectionNames: List<String>.unmodifiable(sortedCollectionNames),
    );
  }
}
