import '../../../models/pop.dart';
import '../models/atlas_catalog_attribute_keys.dart';
import '../models/atlas_catalog_product.dart';

// Converts canonical Atlas catalog products into Vault records.
//
// The catalog owns product identity and trusted product metadata.
// The Vault owns user-specific information such as:
//
// - owner
// - quantity
// - wishlist status
// - price paid
// - condition
// - date added
//
// Keeping this conversion in one place ensures that scanning, browsing,
// searching, importing, and future Atlas Intelligence workflows all create
// Vault records consistently.
abstract final class AtlasCatalogConverter {
  // Creates a new Vault [Pop] from an Atlas catalog product.
  //
  // User-owned information is supplied separately because it does not belong
  // to the canonical catalog product.
  static Pop toPop(
      AtlasCatalogProduct product, {
        String owner = 'Shared',
        bool isWishlist = false,
        int quantity = 1,
        double pricePaid = 0,
        String itemCondition = '',
        String boxCondition = '',
        DateTime? timestamp,
      }) {
    final DateTime resolvedTimestamp =
        timestamp ?? DateTime.now();

    final String now =
    resolvedTimestamp.toIso8601String();

    final String resolvedVariant =
    _catalogVariant(
      product,
    );

    return Pop(
      id: resolvedTimestamp
          .microsecondsSinceEpoch
          .toString(),
      name: product.displayName,
      number: product.productNumber ?? '',
      category: _categoryFrom(
        product,
      ),
      series: _seriesFrom(
        product,
      ),
      edition: resolvedVariant,
      variant: resolvedVariant,
      retailExclusive:
      _retailExclusiveFrom(
        product,
      ),
      eventSticker: _eventStickerFrom(
        product,
      ),
      limitedEdition:
      _limitedEditionFrom(
        product,
      ),
      signature: 'Unsigned',
      sourceCatalogId:
      product.productId.value,
      sourceCollectibleId:
      _sourceCollectibleIdFrom(
        product,
      ),
      sourceUpc: _upcFrom(
        product,
      ),
      productionStatus:
      _productionStatusFrom(
        product,
      ),
      releaseDate: _releaseDateFrom(
        product,
      ),
      gradingCompany: '',
      authenticityNumber: '',
      value: _estimatedValueFrom(
        product,
      ),
      pricePaid: pricePaid,
      quantity: quantity < 1
          ? 1
          : quantity,
      itemCondition: itemCondition,
      boxCondition: boxCondition,
      imageUrl: _imageUrlFrom(
        product,
      ),
      owner: owner.trim().isEmpty
          ? 'Shared'
          : owner.trim(),
      isWishlist: isWishlist,
      dateAdded: now,
      lastUpdated: now,
    );
  }

  // Applies trusted catalog metadata to an existing Vault record.
  //
  // This preserves user-owned information:
  //
  // - record ID
  // - owner
  // - quantity
  // - wishlist status
  // - price paid
  // - condition
  // - date added
  // - grading and authentication details
  //
  // Collector identity entered by the user is also preserved unless the
  // stored value is still a default value and the catalog contains a more
  // specific value.
  static Pop applyCatalogMetadata({
    required Pop existingPop,
    required AtlasCatalogProduct product,
    DateTime? timestamp,
  }) {
    final String catalogVariant =
    _catalogVariant(
      product,
    );

    final String resolvedVariant =
    _preferCatalogVariant(
      currentValue: existingPop.variant,
      catalogValue: catalogVariant,
    );

    final String resolvedEdition =
    _preferCatalogVariant(
      currentValue: existingPop.edition,
      catalogValue: catalogVariant,
    );

    final String resolvedRetailExclusive =
    _preferCatalogIdentity(
      currentValue:
      existingPop.retailExclusive,
      catalogValue:
      _retailExclusiveFrom(
        product,
      ),
      defaultValues: const <String>{
        '',
        'none',
        'no',
        'n/a',
        'na',
        'standard',
      },
    );

    final String resolvedEventSticker =
    _preferCatalogIdentity(
      currentValue:
      existingPop.eventSticker,
      catalogValue:
      _eventStickerFrom(
        product,
      ),
      defaultValues: const <String>{
        '',
        'none',
        'no',
        'n/a',
        'na',
        'standard',
      },
    );

    final double catalogValue =
    _estimatedValueFrom(
      product,
    );

    return existingPop.copyWith(
      name: product.displayName,
      number:
      product.productNumber ??
          existingPop.number,
      category: _preferCatalogText(
        catalogValue: _categoryFrom(
          product,
        ),
        existingValue:
        existingPop.category,
      ),
      series: _preferCatalogText(
        catalogValue: _seriesFrom(
          product,
        ),
        existingValue:
        existingPop.series,
      ),
      edition: resolvedEdition,
      variant: resolvedVariant,
      retailExclusive:
      resolvedRetailExclusive,
      eventSticker:
      resolvedEventSticker,
      limitedEdition:
      _preferCatalogIdentity(
        currentValue:
        existingPop.limitedEdition,
        catalogValue:
        _limitedEditionFrom(
          product,
        ),
        defaultValues: const <String>{
          '',
          'none',
          'no',
          'n/a',
          'na',
          'standard',
        },
      ),
      sourceCatalogId:
      product.productId.value,
      sourceCollectibleId:
      _sourceCollectibleIdFrom(
        product,
      ),
      sourceUpc: _upcFrom(
        product,
      ),
      productionStatus:
      _preferCatalogText(
        catalogValue:
        _productionStatusFrom(
          product,
        ),
        existingValue:
        existingPop.productionStatus,
      ),
      releaseDate:
      _preferCatalogText(
        catalogValue:
        _releaseDateFrom(
          product,
        ),
        existingValue:
        existingPop.releaseDate,
      ),
      imageUrl: _preferCatalogText(
        catalogValue: _imageUrlFrom(
          product,
        ),
        existingValue:
        existingPop.imageUrl,
      ),
      value: catalogValue > 0
          ? catalogValue
          : existingPop.value,
      lastUpdated:
      (timestamp ?? DateTime.now())
          .toIso8601String(),
    );
  }

  static String _categoryFrom(
      AtlasCatalogProduct product,
      ) {
    final String? genre =
    _textAttribute(
      product,
      AtlasCatalogAttributeKeys.genre,
    );

    if (genre != null) {
      return genre;
    }

    final String? subTypeName =
    _textAttribute(
      product,
      AtlasCatalogAttributeKeys.subTypeName,
    );

    if (subTypeName != null) {
      return subTypeName;
    }

    return product.categoryCode;
  }

  static String _seriesFrom(
      AtlasCatalogProduct product,
      ) {
    final String? series =
    product.series?.trim();

    if (series != null &&
        series.isNotEmpty) {
      return series;
    }

    final String? productLine =
    product.productLine?.trim();

    if (productLine != null &&
        productLine.isNotEmpty) {
      return productLine;
    }

    return '';
  }

  static String _catalogVariant(
      AtlasCatalogProduct product,
      ) {
    final List<String> variantParts =
    <String>[];

    void addVariantPart(
        String? value,
        ) {
      final String cleaned =
          value?.trim() ?? '';

      if (cleaned.isEmpty) {
        return;
      }

      final String normalized =
      cleaned.toLowerCase();

      final bool alreadyAdded =
      variantParts.any(
            (String existing) {
          return existing.toLowerCase() ==
              normalized;
        },
      );

      if (!alreadyAdded) {
        variantParts.add(
          cleaned,
        );
      }
    }

    addVariantPart(
      product.variantName,
    );

    addVariantPart(
      _textAttribute(
        product,
        AtlasCatalogAttributeKeys.treatment,
      ),
    );

    final String? rarity =
    _textAttribute(
      product,
      AtlasCatalogAttributeKeys.rarity,
    );

    if (rarity != null) {
      final String normalizedRarity =
      rarity.toLowerCase();

      if (normalizedRarity.contains(
        'chase',
      )) {
        addVariantPart(
          'Chase',
        );
      }
    }

    if (variantParts.isEmpty) {
      return 'Common';
    }

    return variantParts.join(
      ' • ',
    );
  }

  static String _retailExclusiveFrom(
      AtlasCatalogProduct product,
      ) {
    final String? retailer =
    _textAttribute(
      product,
      AtlasCatalogAttributeKeys.retailer,
    );

    if (retailer != null) {
      return retailer;
    }

    final String? printing =
    _textAttribute(
      product,
      AtlasCatalogAttributeKeys.printing,
    );

    if (printing != null) {
      return printing;
    }

    return 'None';
  }

  static String _eventStickerFrom(
      AtlasCatalogProduct product,
      ) {
    final String? eventName =
    _textAttribute(
      product,
      AtlasCatalogAttributeKeys.eventName,
    );

    if (eventName != null) {
      return eventName;
    }

    final String? stickerType =
    _textAttribute(
      product,
      AtlasCatalogAttributeKeys.stickerType,
    );

    if (stickerType != null) {
      return stickerType;
    }

    return 'None';
  }

  static String _sourceCollectibleIdFrom(
      AtlasCatalogProduct product,
      ) {
    return _textAttribute(
      product,
      AtlasCatalogAttributeKeys.sourceProductId,
    ) ??
        '';
  }

  static String _upcFrom(
      AtlasCatalogProduct product,
      ) {
    final String? explicitUpc =
    _textAttribute(
      product,
      AtlasCatalogAttributeKeys.upc,
    );

    if (explicitUpc != null) {
      return explicitUpc;
    }

    if (product.barcodes.isNotEmpty) {
      return product.barcodes.first;
    }

    return '';
  }

  static String _imageUrlFrom(
      AtlasCatalogProduct product,
      ) {
    return _textAttribute(
      product,
      AtlasCatalogAttributeKeys.imageUrl,
    ) ??
        '';
  }

  static String _productionStatusFrom(
      AtlasCatalogProduct product,
      ) {
    return _textAttribute(
      product,
      AtlasCatalogAttributeKeys.productionStatus,
    ) ??
        '';
  }

  static String _releaseDateFrom(
      AtlasCatalogProduct product,
      ) {
    return _textAttribute(
      product,
      AtlasCatalogAttributeKeys.releaseDate,
    ) ??
        '';
  }

  static String _limitedEditionFrom(
      AtlasCatalogProduct product,
      ) {
    final String? rarity =
    _textAttribute(
      product,
      AtlasCatalogAttributeKeys.rarity,
    );

    if (rarity == null) {
      return 'None';
    }

    final String normalized =
    rarity.toLowerCase();

    if (normalized.contains(
      'limited',
    ) ||
        normalized.contains(
          'exclusive',
        ) ||
        normalized.contains(
          'numbered',
        )) {
      return rarity;
    }

    return 'None';
  }

  // Uses the best available TCGCSV price as the initial estimated value.
  //
  // Priority:
  // 1. Market price
  // 2. Mid price
  // 3. Low price
  // 4. Direct low price
  //
  // High price is intentionally excluded because it may overstate the
  // collectible's current estimated value.
  static double _estimatedValueFrom(
      AtlasCatalogProduct product,
      ) {
    const List<String> priceKeys =
    <String>[
      AtlasCatalogAttributeKeys.marketPrice,
      AtlasCatalogAttributeKeys.midPrice,
      AtlasCatalogAttributeKeys.lowPrice,
      AtlasCatalogAttributeKeys.directLowPrice,
    ];

    for (final String key
    in priceKeys) {
      final double? value =
      _doubleAttribute(
        product,
        key,
      );

      if (value != null &&
          value > 0) {
        return value;
      }
    }

    return 0;
  }

  static String _preferCatalogText({
    required String catalogValue,
    required String existingValue,
  }) {
    final String cleanedCatalogValue =
    catalogValue.trim();

    if (cleanedCatalogValue.isNotEmpty) {
      return cleanedCatalogValue;
    }

    return existingValue;
  }

  static String _preferCatalogVariant({
    required String currentValue,
    required String catalogValue,
  }) {
    return _preferCatalogIdentity(
      currentValue: currentValue,
      catalogValue: catalogValue,
      defaultValues: const <String>{
        '',
        'none',
        'no',
        'n/a',
        'na',
        'common',
        'standard',
      },
    );
  }

  static String _preferCatalogIdentity({
    required String currentValue,
    required String catalogValue,
    required Set<String> defaultValues,
  }) {
    final String normalizedCurrent =
    currentValue
        .trim()
        .toLowerCase();

    final String cleanedCatalogValue =
    catalogValue.trim();

    if (cleanedCatalogValue.isEmpty) {
      return currentValue;
    }

    if (defaultValues.contains(
      normalizedCurrent,
    )) {
      return cleanedCatalogValue;
    }

    return currentValue;
  }

  static String? _textAttribute(
      AtlasCatalogProduct product,
      String key,
      ) {
    final Object? value =
    product.attributes[key];

    if (value == null) {
      return null;
    }

    final String normalized =
    value.toString().trim();

    if (normalized.isEmpty) {
      return null;
    }

    return normalized;
  }

  static double? _doubleAttribute(
      AtlasCatalogProduct product,
      String key,
      ) {
    final Object? value =
    product.attributes[key];

    if (value is num) {
      return value.toDouble();
    }

    if (value == null) {
      return null;
    }

    final String normalized =
    value
        .toString()
        .replaceAll(
      RegExp(r'[^0-9.\-]'),
      '',
    )
        .trim();

    if (normalized.isEmpty) {
      return null;
    }

    return double.tryParse(
      normalized,
    );
  }
}