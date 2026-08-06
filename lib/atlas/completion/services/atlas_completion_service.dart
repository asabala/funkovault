import 'package:funkovault2/atlas/catalog/models/atlas_catalog_product.dart';
import 'package:funkovault2/atlas/catalog/services/atlas_catalog_service.dart';
import 'package:funkovault2/atlas/completion/engine/atlas_completion_engine.dart';
import 'package:funkovault2/atlas/completion/models/atlas_completion_query.dart';
import 'package:funkovault2/atlas/completion/models/atlas_completion_result.dart';
import 'package:funkovault2/atlas/taxonomy/models/atlas_completion_scope.dart';
import 'package:funkovault2/atlas/taxonomy/models/atlas_taxonomy.dart';
import 'package:funkovault2/atlas/taxonomy/models/atlas_taxonomy_node.dart';
import 'package:funkovault2/atlas/taxonomy/services/atlas_taxonomy_service.dart';
import 'package:funkovault2/models/pop.dart';

final class AtlasCompletionService {
  AtlasCompletionService({
    AtlasCatalogService? catalogService,
    AtlasCompletionEngine? completionEngine,
    AtlasTaxonomyService? taxonomyService,
  })  : _catalogService =
      catalogService ?? AtlasCatalogService.instance,
        _completionEngine =
            completionEngine ?? AtlasCompletionEngine(),
        _taxonomyService =
            taxonomyService ?? AtlasTaxonomyService.instance;

  static final AtlasCompletionService instance =
  AtlasCompletionService();

  final AtlasCatalogService _catalogService;
  final AtlasCompletionEngine _completionEngine;
  final AtlasTaxonomyService _taxonomyService;

  /// Calculates completion for the selected product's variant family.
  ///
  /// Example:
  ///
  /// Ted DiBiase #41
  /// - Common
  /// - Chase
  /// - Exclusive
  /// - Other catalog releases sharing the same family
  Future<AtlasCompletionResult> evaluateVariantFamily({
    required AtlasCatalogProduct selectedProduct,
    required List<Pop> collectionPops,
    Set<String> ownedWishlistIdentityKeys =
    const <String>{},
    String collectionName = 'All Atlas Collections',
    bool includeWishlist = true,
    bool includeInactiveCatalogItems = false,
    int searchLimit = 250,
  }) async {
    final AtlasTaxonomy selectedTaxonomy =
    _taxonomyService.resolve(
      selectedProduct,
    );

    final AtlasTaxonomyNode? variantFamilyNode =
    selectedTaxonomy.nodeForScope(
      AtlasCompletionScope.variantFamily,
    );

    if (variantFamilyNode == null) {
      return _evaluateExactRelease(
        selectedProduct: selectedProduct,
        selectedTaxonomy: selectedTaxonomy,
        collectionPops: collectionPops,
        ownedWishlistIdentityKeys:
        ownedWishlistIdentityKeys,
        collectionName: collectionName,
        includeWishlist: includeWishlist,
        includeInactiveCatalogItems:
        includeInactiveCatalogItems,
      );
    }

    final List<AtlasCatalogProduct> candidates =
    await _findVariantFamilyCandidates(
      selectedProduct: selectedProduct,
      searchLimit: searchLimit,
    );

    final AtlasCompletionQuery query =
    AtlasCompletionQuery(
      filters: <AtlasCompletionFilter>[
        AtlasCompletionFilter(
          scope: AtlasCompletionScope.variantFamily,
          nodeId: variantFamilyNode.id,
          displayName: variantFamilyNode.name,
        ),
      ],
      primaryScope:
      AtlasCompletionScope.variantFamily,
      includeWishlist: includeWishlist,
      includeInactiveCatalogItems:
      includeInactiveCatalogItems,
    );

    return _completionEngine.evaluate(
      query: query,
      catalogProducts: candidates,
      collectionPops: collectionPops,
      ownedWishlistIdentityKeys:
      ownedWishlistIdentityKeys,
      collectionName: collectionName,
    );
  }

  /// Calculates completion for any taxonomy node already resolved by Atlas.
  ///
  /// This supports future experiences such as:
  ///
  /// - Character completion
  /// - Series completion
  /// - Franchise completion
  /// - Retailer-exclusive completion
  /// - Convention completion
  Future<AtlasCompletionResult> evaluateScope({
    required AtlasCatalogProduct selectedProduct,
    required AtlasCompletionScope scope,
    required List<Pop> collectionPops,
    Set<String> ownedWishlistIdentityKeys =
    const <String>{},
    String collectionName = 'All Atlas Collections',
    bool includeWishlist = true,
    bool includeInactiveCatalogItems = false,
    int searchLimit = 500,
  }) async {
    final AtlasTaxonomy selectedTaxonomy =
    _taxonomyService.resolve(
      selectedProduct,
    );

    final AtlasTaxonomyNode? targetNode =
    selectedTaxonomy.nodeForScope(
      scope,
    );

    if (targetNode == null) {
      return AtlasCompletionResult(
        query: AtlasCompletionQuery(
          filters: const <AtlasCompletionFilter>[],
          primaryScope: scope,
          includeWishlist: includeWishlist,
          includeInactiveCatalogItems:
          includeInactiveCatalogItems,
        ),
        items: const [],
      );
    }

    final List<AtlasCatalogProduct> candidates =
    await _findScopeCandidates(
      selectedProduct: selectedProduct,
      scope: scope,
      searchLimit: searchLimit,
    );

    final AtlasCompletionQuery query =
    AtlasCompletionQuery(
      filters: <AtlasCompletionFilter>[
        AtlasCompletionFilter(
          scope: scope,
          nodeId: targetNode.id,
          displayName: targetNode.name,
        ),
      ],
      primaryScope: scope,
      includeWishlist: includeWishlist,
      includeInactiveCatalogItems:
      includeInactiveCatalogItems,
    );

    return _completionEngine.evaluate(
      query: query,
      catalogProducts: candidates,
      collectionPops: collectionPops,
      ownedWishlistIdentityKeys:
      ownedWishlistIdentityKeys,
      collectionName: collectionName,
    );
  }

  Future<List<AtlasCatalogProduct>>
  _findVariantFamilyCandidates({
    required AtlasCatalogProduct selectedProduct,
    required int searchLimit,
  }) async {
    final String? characterName =
    _cleanText(
      selectedProduct.characterName,
    );

    final String? productNumber =
    _cleanText(
      selectedProduct.productNumber,
    );

    final List<AtlasCatalogProduct> products;

    if (characterName != null ||
        productNumber != null) {
      products = await _catalogService.search(
        characterName: characterName,
        productNumber: productNumber,
        limit: searchLimit,
      );
    } else {
      products = await _catalogService.search(
        query: selectedProduct.displayName,
        limit: searchLimit,
      );
    }

    return _includeSelectedProduct(
      selectedProduct: selectedProduct,
      products: products,
    );
  }

  Future<List<AtlasCatalogProduct>>
  _findScopeCandidates({
    required AtlasCatalogProduct selectedProduct,
    required AtlasCompletionScope scope,
    required int searchLimit,
  }) async {
    final List<AtlasCatalogProduct> products =
    switch (scope) {
      AtlasCompletionScope.brand =>
      await _catalogService.search(
        brand: _cleanText(
          selectedProduct.brand,
        ),
        limit: searchLimit,
      ),

      AtlasCompletionScope.franchise =>
      await _catalogService.search(
        productLine: _cleanText(
          selectedProduct.productLine,
        ),
        limit: searchLimit,
      ),

      AtlasCompletionScope.series =>
      await _catalogService.search(
        series: _cleanText(
          selectedProduct.series,
        ),
        limit: searchLimit,
      ),

      AtlasCompletionScope.character =>
      await _catalogService.search(
        characterName: _cleanText(
          selectedProduct.characterName,
        ),
        limit: searchLimit,
      ),

      AtlasCompletionScope.variantFamily =>
      await _catalogService.search(
        characterName: _cleanText(
          selectedProduct.characterName,
        ),
        productNumber: _cleanText(
          selectedProduct.productNumber,
        ),
        limit: searchLimit,
      ),

      AtlasCompletionScope.release =>
      <AtlasCatalogProduct>[
        selectedProduct,
      ],

      _ => await _catalogService.search(
        query: _bestGeneralQuery(
          selectedProduct,
        ),
        limit: searchLimit,
      ),
    };

    return _includeSelectedProduct(
      selectedProduct: selectedProduct,
      products: products,
    );
  }

  AtlasCompletionResult _evaluateExactRelease({
    required AtlasCatalogProduct selectedProduct,
    required AtlasTaxonomy selectedTaxonomy,
    required List<Pop> collectionPops,
    required Set<String> ownedWishlistIdentityKeys,
    required String collectionName,
    required bool includeWishlist,
    required bool includeInactiveCatalogItems,
  }) {
    final AtlasTaxonomyNode? releaseNode =
    selectedTaxonomy.nodeForScope(
      AtlasCompletionScope.release,
    );

    final List<AtlasCompletionFilter> filters =
    releaseNode == null
        ? const <AtlasCompletionFilter>[]
        : <AtlasCompletionFilter>[
      AtlasCompletionFilter(
        scope: AtlasCompletionScope.release,
        nodeId: releaseNode.id,
        displayName: releaseNode.name,
      ),
    ];

    final AtlasCompletionQuery query =
    AtlasCompletionQuery(
      filters: filters,
      primaryScope: AtlasCompletionScope.release,
      includeWishlist: includeWishlist,
      includeInactiveCatalogItems:
      includeInactiveCatalogItems,
    );

    return _completionEngine.evaluate(
      query: query,
      catalogProducts: <AtlasCatalogProduct>[
        selectedProduct,
      ],
      collectionPops: collectionPops,
      ownedWishlistIdentityKeys:
      ownedWishlistIdentityKeys,
      collectionName: collectionName,
    );
  }

  List<AtlasCatalogProduct> _includeSelectedProduct({
    required AtlasCatalogProduct selectedProduct,
    required Iterable<AtlasCatalogProduct> products,
  }) {
    final Map<String, AtlasCatalogProduct> productsById =
    <String, AtlasCatalogProduct>{};

    void addProduct(
        AtlasCatalogProduct product,
        ) {
      final String productId =
      product.productId.value.trim();

      final String key = productId.isEmpty
          ? _fallbackProductKey(
        product,
      )
          : productId.toLowerCase();

      productsById.putIfAbsent(
        key,
            () => product,
      );
    }

    addProduct(
      selectedProduct,
    );

    for (final AtlasCatalogProduct product
    in products) {
      addProduct(
        product,
      );
    }

    return List<AtlasCatalogProduct>.unmodifiable(
      productsById.values,
    );
  }

  String _bestGeneralQuery(
      AtlasCatalogProduct product,
      ) {
    return _cleanText(
      product.characterName,
    ) ??
        _cleanText(
          product.series,
        ) ??
        _cleanText(
          product.productLine,
        ) ??
        product.displayName;
  }

  String _fallbackProductKey(
      AtlasCatalogProduct product,
      ) {
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

    final String normalizedBarcodes =
    product.barcodes
        .map(
      _normalizeBarcode,
    )
        .where(
          (
          String barcode,
          ) {
        return barcode.isNotEmpty;
      },
    )
        .join(
      '|',
    );

    return <String>[
      'fallback',
      normalizedName,
      normalizedNumber,
      normalizedVariant,
      normalizedBarcodes,
    ].join(
      ':',
    );
  }

  String? _cleanText(
      String? value,
      ) {
    final String cleaned =
        value?.trim() ?? '';

    return cleaned.isEmpty
        ? null
        : cleaned;
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