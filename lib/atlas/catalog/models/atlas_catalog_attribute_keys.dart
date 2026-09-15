abstract final class AtlasCatalogAttributeKeys {
  // Source identity and provider metadata.
  static const String source = 'source';
  static const String sourceProductId = 'sourceProductId';
  static const String sourceCategoryId = 'sourceCategoryId';
  static const String sourceGroupId = 'sourceGroupId';
  static const String sourceUrl = 'sourceUrl';
  static const String modifiedOn = 'modifiedOn';
  static const String cleanName = 'cleanName';

  // General product metadata.
  static const String imageUrl = 'imageUrl';
  static const String imageCount = 'imageCount';
  static const String description = 'description';
  static const String genre = 'genre';
  static const String rarity = 'rarity';
  static const String model = 'model';
  static const String gtin = 'gtin';
  static const String upc = 'upc';

  // Product classification and treatment.
  static const String printing = 'printing';
  static const String treatment = 'treatment';
  static const String subTypeName = 'subTypeName';

  // Funko and collectible identity metadata.
  static const String finish = 'finish';
  static const String stickerType = 'stickerType';
  static const String retailer = 'retailer';
  static const String eventName = 'eventName';
  static const String packagingType = 'packagingType';
  static const String boxVersion = 'boxVersion';
  static const String productionCode = 'productionCode';
  static const String size = 'size';
  static const String licenseName = 'licenseName';
  static const String waveName = 'waveName';

  // Product lifecycle metadata.
  static const String productionStatus = 'productionStatus';
  static const String releaseDate = 'releaseDate';

  // Pricing metadata.
  static const String lowPrice = 'lowPrice';
  static const String midPrice = 'midPrice';
  static const String highPrice = 'highPrice';
  static const String marketPrice = 'marketPrice';
  static const String directLowPrice = 'directLowPrice';

  static const List<String> priceKeys = <String>[
    marketPrice,
    midPrice,
    lowPrice,
    directLowPrice,
    highPrice,
  ];

  static const List<String> sourceKeys = <String>[
    source,
    sourceProductId,
    sourceCategoryId,
    sourceGroupId,
    sourceUrl,
    modifiedOn,
  ];

  static const List<String> identityKeys = <String>[
    finish,
    stickerType,
    retailer,
    eventName,
    packagingType,
    boxVersion,
    productionCode,
    size,
    licenseName,
    waveName,
    rarity,
    printing,
    treatment,
    subTypeName,
  ];
}
