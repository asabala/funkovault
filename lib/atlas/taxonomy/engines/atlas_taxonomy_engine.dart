import '../../catalog/models/atlas_catalog_attribute_keys.dart';
import '../../catalog/models/atlas_catalog_product.dart';
import '../models/atlas_completion_scope.dart';
import '../models/atlas_taxonomy.dart';
import '../models/atlas_taxonomy_node.dart';

final class AtlasTaxonomyEngine {
  const AtlasTaxonomyEngine();

  AtlasTaxonomy resolve(
      AtlasCatalogProduct product,
      ) {
    final List<AtlasTaxonomyNode> nodes =
    <AtlasTaxonomyNode>[];

    final String releaseId =
    product.productId.value.trim();

    final String catalogNodeId =
    _nodeId(
      scope: AtlasCompletionScope.catalog,
      value: 'Atlas Catalog',
    );

    _addNode(
      nodes: nodes,
      scope: AtlasCompletionScope.catalog,
      value: 'Atlas Catalog',
      id: catalogNodeId,
      metadata: <String, Object?>{
        'categoryCode': product.categoryCode,
      },
    );

    final String? brand =
    _cleanText(
      product.brand,
    );

    final String? brandNodeId =
    _addNode(
      nodes: nodes,
      scope: AtlasCompletionScope.brand,
      value: brand,
      parentId: catalogNodeId,
    );

    final String? license =
    _attributeText(
      product,
      AtlasCatalogAttributeKeys.licenseName,
    );

    final String? licenseNodeId =
    _addNode(
      nodes: nodes,
      scope: AtlasCompletionScope.license,
      value: license,
      parentId: brandNodeId ?? catalogNodeId,
    );

    final String? franchise =
    _resolveFranchise(
      product,
      license: license,
    );

    final String? franchiseNodeId =
    _addNode(
      nodes: nodes,
      scope: AtlasCompletionScope.franchise,
      value: franchise,
      parentId:
      licenseNodeId ??
          brandNodeId ??
          catalogNodeId,
    );

    final List<String> mediumValues =
    _mediumValues(
      product,
    );

    for (final String medium
    in mediumValues) {
      _addNode(
        nodes: nodes,
        scope: AtlasCompletionScope.medium,
        value: medium,
        parentId:
        franchiseNodeId ??
            licenseNodeId ??
            catalogNodeId,
      );
    }

    final String? series =
    _cleanText(
      product.series,
    );

    final String? seriesNodeId =
    _addNode(
      nodes: nodes,
      scope: AtlasCompletionScope.series,
      value: series,
      parentId:
      franchiseNodeId ??
          licenseNodeId ??
          catalogNodeId,
    );

    final String? collection =
    _resolveCollection(
      product,
    );

    final String? collectionNodeId =
    _addNode(
      nodes: nodes,
      scope: AtlasCompletionScope.collection,
      value: collection,
      parentId:
      seriesNodeId ??
          franchiseNodeId ??
          catalogNodeId,
    );

    final String? wave =
    _attributeText(
      product,
      AtlasCatalogAttributeKeys.waveName,
    );

    final String? waveNodeId =
    _addNode(
      nodes: nodes,
      scope: AtlasCompletionScope.wave,
      value: wave,
      parentId:
      collectionNodeId ??
          seriesNodeId ??
          franchiseNodeId ??
          catalogNodeId,
    );

    final String? character =
    _cleanText(
      product.characterName,
    );

    final String? characterNodeId =
    _addNode(
      nodes: nodes,
      scope: AtlasCompletionScope.character,
      value: character,
      parentId:
      waveNodeId ??
          collectionNodeId ??
          seriesNodeId ??
          franchiseNodeId ??
          catalogNodeId,
    );

    final String? mold =
    _resolveMold(
      product,
    );

    final String? moldNodeId =
    _addNode(
      nodes: nodes,
      scope: AtlasCompletionScope.mold,
      value: mold,
      parentId:
      characterNodeId ??
          seriesNodeId ??
          franchiseNodeId ??
          catalogNodeId,
      metadata: <String, Object?>{
        if (_attributeText(
          product,
          AtlasCatalogAttributeKeys.model,
        ) !=
            null)
          'model': _attributeText(
            product,
            AtlasCatalogAttributeKeys.model,
          ),
        if (_attributeText(
          product,
          AtlasCatalogAttributeKeys.productionCode,
        ) !=
            null)
          'productionCode': _attributeText(
            product,
            AtlasCatalogAttributeKeys.productionCode,
          ),
      },
    );

    final String variantFamily =
    _resolveVariantFamily(
      product,
    );

    final String? variantFamilyNodeId =
    _addNode(
      nodes: nodes,
      scope:
      AtlasCompletionScope.variantFamily,
      value: variantFamily,
      parentId:
      moldNodeId ??
          characterNodeId ??
          seriesNodeId ??
          catalogNodeId,
      metadata: <String, Object?>{
        if (product.productNumber != null)
          'productNumber':
          product.productNumber,
      },
    );

    final String? retailer =
    _attributeText(
      product,
      AtlasCatalogAttributeKeys.retailer,
    );

    _addNode(
      nodes: nodes,
      scope: AtlasCompletionScope.retailer,
      value: retailer,
      parentId: variantFamilyNodeId,
    );

    final String? exclusive =
    _resolveExclusiveType(
      product,
    );

    _addNode(
      nodes: nodes,
      scope: AtlasCompletionScope.exclusive,
      value: exclusive,
      parentId: variantFamilyNodeId,
    );

    final String? convention =
    _attributeText(
      product,
      AtlasCatalogAttributeKeys.eventName,
    );

    _addNode(
      nodes: nodes,
      scope:
      AtlasCompletionScope.convention,
      value: convention,
      parentId: variantFamilyNodeId,
    );

    final String? sticker =
    _resolveSticker(
      product,
    );

    _addNode(
      nodes: nodes,
      scope: AtlasCompletionScope.sticker,
      value: sticker,
      parentId: variantFamilyNodeId,
    );

    final String releaseName =
    _resolveReleaseName(
      product,
    );

    _addNode(
      nodes: nodes,
      scope: AtlasCompletionScope.release,
      value: releaseName,
      id: releaseId.isEmpty
          ? null
          : releaseId,
      parentId:
      variantFamilyNodeId ??
          moldNodeId ??
          characterNodeId ??
          seriesNodeId ??
          catalogNodeId,
      metadata: <String, Object?>{
        'catalogProductId':
        product.productId.value,
        'displayName':
        product.displayName,
        'categoryCode':
        product.categoryCode,
        if (product.productNumber != null)
          'productNumber':
          product.productNumber,
        if (product.variantName != null)
          'variantName':
          product.variantName,
        if (product.barcodes.isNotEmpty)
          'barcodes':
          List<String>.unmodifiable(
            product.barcodes,
          ),
        if (_attributeText(
          product,
          AtlasCatalogAttributeKeys.releaseDate,
        ) !=
            null)
          'releaseDate': _attributeText(
            product,
            AtlasCatalogAttributeKeys.releaseDate,
          ),
        if (_attributeText(
          product,
          AtlasCatalogAttributeKeys.rarity,
        ) !=
            null)
          'rarity': _attributeText(
            product,
            AtlasCatalogAttributeKeys.rarity,
          ),
      },
    );

    return AtlasTaxonomy(
      nodes: nodes,
    );
  }

  String? _addNode({
    required List<AtlasTaxonomyNode> nodes,
    required AtlasCompletionScope scope,
    required String? value,
    String? id,
    String? parentId,
    Map<String, Object?> metadata =
    const <String, Object?>{},
  }) {
    final String? cleanedValue =
    _cleanText(
      value,
    );

    if (cleanedValue == null) {
      return null;
    }

    final String resolvedId =
        _cleanText(
          id,
        ) ??
            _nodeId(
              scope: scope,
              value: cleanedValue,
            );

    nodes.add(
      AtlasTaxonomyNode(
        scope: scope,
        id: resolvedId,
        name: cleanedValue,
        parentId: _cleanText(
          parentId,
        ),
        metadata:
        Map<String, Object?>.unmodifiable(
          metadata,
        ),
      ),
    );

    return resolvedId;
  }

  String? _resolveFranchise(
      AtlasCatalogProduct product, {
        required String? license,
      }) {
    final String? productLine =
    _cleanText(
      product.productLine,
    );

    if (productLine == null) {
      return license;
    }

    if (_sameText(
      productLine,
      product.brand,
    )) {
      return license;
    }

    return productLine;
  }

  List<String> _mediumValues(
      AtlasCatalogProduct product,
      ) {
    final Set<String> values =
    <String>{};

    final String? genre =
    _attributeText(
      product,
      AtlasCatalogAttributeKeys.genre,
    );

    final String? subType =
    _attributeText(
      product,
      AtlasCatalogAttributeKeys.subTypeName,
    );

    if (genre != null) {
      values.add(
        genre,
      );
    }

    if (subType != null &&
        !_containsNormalized(
          values,
          subType,
        )) {
      values.add(
        subType,
      );
    }

    return values.toList(
      growable: false,
    );
  }

  String? _resolveCollection(
      AtlasCatalogProduct product,
      ) {
    final String? printing =
    _attributeText(
      product,
      AtlasCatalogAttributeKeys.printing,
    );

    if (printing != null &&
        !_looksLikeRetailer(
          printing,
        )) {
      return printing;
    }

    return null;
  }

  String? _resolveMold(
      AtlasCatalogProduct product,
      ) {
    final String? model =
    _attributeText(
      product,
      AtlasCatalogAttributeKeys.model,
    );

    if (model != null) {
      return model;
    }

    final String? character =
    _cleanText(
      product.characterName,
    );

    final String? number =
    _cleanText(
      product.productNumber,
    );

    if (character != null &&
        number != null) {
      return '$character #$number';
    }

    if (number != null) {
      return '#$number';
    }

    return null;
  }

  String _resolveVariantFamily(
      AtlasCatalogProduct product,
      ) {
    final String? character =
    _cleanText(
      product.characterName,
    );

    final String? number =
    _cleanText(
      product.productNumber,
    );

    if (character != null &&
        number != null) {
      return '$character #$number';
    }

    if (number != null) {
      return '${product.displayName} #$number';
    }

    return product.displayName;
  }

  String? _resolveExclusiveType(
      AtlasCatalogProduct product,
      ) {
    final String? retailer =
    _attributeText(
      product,
      AtlasCatalogAttributeKeys.retailer,
    );

    final String? eventName =
    _attributeText(
      product,
      AtlasCatalogAttributeKeys.eventName,
    );

    final String? rarity =
    _attributeText(
      product,
      AtlasCatalogAttributeKeys.rarity,
    );

    final String? printing =
    _attributeText(
      product,
      AtlasCatalogAttributeKeys.printing,
    );

    if (eventName != null) {
      return 'Convention Exclusive';
    }

    if (retailer != null) {
      return 'Retailer Exclusive';
    }

    if (_containsWord(
      rarity,
      'exclusive',
    )) {
      return rarity;
    }

    if (_containsWord(
      printing,
      'exclusive',
    )) {
      return printing;
    }

    return null;
  }

  String? _resolveSticker(
      AtlasCatalogProduct product,
      ) {
    final String? stickerType =
    _attributeText(
      product,
      AtlasCatalogAttributeKeys.stickerType,
    );

    if (stickerType != null) {
      return stickerType;
    }

    final String? printing =
    _attributeText(
      product,
      AtlasCatalogAttributeKeys.printing,
    );

    if (printing != null &&
        _looksLikeSticker(
          printing,
        )) {
      return printing;
    }

    return null;
  }

  String _resolveReleaseName(
      AtlasCatalogProduct product,
      ) {
    final List<String> parts =
    <String>[
      product.displayName,
    ];

    final String? number =
    _cleanText(
      product.productNumber,
    );

    final String? variant =
    _cleanText(
      product.variantName,
    );

    final String? treatment =
    _attributeText(
      product,
      AtlasCatalogAttributeKeys.treatment,
    );

    if (number != null &&
        !product.displayName.contains(
          '#$number',
        )) {
      parts.add(
        '#$number',
      );
    }

    if (variant != null &&
        !_containsNormalized(
          parts,
          variant,
        )) {
      parts.add(
        variant,
      );
    }

    if (treatment != null &&
        !_containsNormalized(
          parts,
          treatment,
        )) {
      parts.add(
        treatment,
      );
    }

    return parts.join(
      ' • ',
    );
  }

  String? _attributeText(
      AtlasCatalogProduct product,
      String key,
      ) {
    final Object? value =
    product.attributes[key];

    return _cleanText(
      value?.toString(),
    );
  }

  String _nodeId({
    required AtlasCompletionScope scope,
    required String value,
  }) {
    final String slug = value
        .trim()
        .toLowerCase()
        .replaceAll(
      RegExp(r'[^a-z0-9]+'),
      '_',
    )
        .replaceAll(
      RegExp(r'_+'),
      '_',
    )
        .replaceAll(
      RegExp(r'^_|_$'),
      '',
    );

    return '${scope.key}:$slug';
  }

  String? _cleanText(
      String? value,
      ) {
    final String cleaned =
        value?.trim() ?? '';

    if (cleaned.isEmpty) {
      return null;
    }

    return cleaned;
  }

  bool _sameText(
      String? first,
      String? second,
      ) {
    final String firstValue =
        first?.trim().toLowerCase() ?? '';

    final String secondValue =
        second?.trim().toLowerCase() ?? '';

    return firstValue.isNotEmpty &&
        firstValue == secondValue;
  }

  bool _containsNormalized(
      Iterable<String> values,
      String candidate,
      ) {
    final String normalizedCandidate =
    candidate.trim().toLowerCase();

    return values.any(
          (String value) {
        return value
            .trim()
            .toLowerCase() ==
            normalizedCandidate;
      },
    );
  }

  bool _containsWord(
      String? value,
      String word,
      ) {
    final String normalized =
        value?.trim().toLowerCase() ?? '';

    return normalized.contains(
      word.toLowerCase(),
    );
  }

  bool _looksLikeRetailer(
      String value,
      ) {
    final String normalized =
    value.toLowerCase();

    const List<String> retailerTerms =
    <String>[
      'target',
      'walmart',
      'amazon',
      'boxlunch',
      'hot topic',
      'gamestop',
      'funko shop',
      'books-a-million',
      'books a million',
      'entertainment earth',
      'exclusive',
    ];

    return retailerTerms.any(
      normalized.contains,
    );
  }

  bool _looksLikeSticker(
      String value,
      ) {
    final String normalized =
    value.toLowerCase();

    const List<String> stickerTerms =
    <String>[
      'sticker',
      'shared',
      'convention',
      'special edition',
      'exclusive',
    ];

    return stickerTerms.any(
      normalized.contains,
    );
  }
}