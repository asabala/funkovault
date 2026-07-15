class Pop {
  final String id;

  final String name;
  final String number;

  final String category;
  final String series;

  final String edition;
  final String variant;
  final String retailExclusive;
  final String eventSticker;
  final String limitedEdition;
  final String signature;

  /// External catalog identity.
  ///
  /// For HobbyDB imports:
  /// sourceCatalogId = HDBID
  /// sourceCollectibleId = HDBC Number
  /// sourceUpc = UPC
  final String sourceCatalogId;
  final String sourceCollectibleId;
  final String sourceUpc;

  /// Additional source metadata that helps Atlas preserve and explain
  /// imported collectible releases.
  final String productionStatus;
  final String releaseDate;
  final String gradingCompany;
  final String authenticityNumber;

  final double value;
  final double pricePaid;

  final int quantity;

  final String itemCondition;
  final String boxCondition;

  final String imageUrl;

  final String owner;

  final bool isWishlist;

  final String dateAdded;
  final String lastUpdated;

  const Pop({
    required this.id,
    required this.name,
    required this.number,
    required this.category,
    required this.series,
    this.edition = 'Common',
    this.variant = 'Common',
    this.retailExclusive = 'None',
    this.eventSticker = 'None',
    this.limitedEdition = 'None',
    this.signature = 'Unsigned',
    this.sourceCatalogId = '',
    this.sourceCollectibleId = '',
    this.sourceUpc = '',
    this.productionStatus = '',
    this.releaseDate = '',
    this.gradingCompany = '',
    this.authenticityNumber = '',
    required this.value,
    required this.pricePaid,
    required this.quantity,
    required this.itemCondition,
    required this.boxCondition,
    required this.imageUrl,
    required this.owner,
    required this.isWishlist,
    this.dateAdded = '',
    this.lastUpdated = '',
  });

  factory Pop.fromJson(
      Map<String, dynamic> json,
      ) {
    final legacyEdition = json['edition'] ?? 'Common';

    return Pop(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      number: json['number'] ?? '',
      category: json['category'] ?? '',
      series: json['series'] ?? '',
      edition: legacyEdition,
      variant: json['variant'] ?? legacyEdition,
      retailExclusive: json['retailExclusive'] ?? 'None',
      eventSticker: json['eventSticker'] ?? 'None',
      limitedEdition: json['limitedEdition'] ?? 'None',
      signature: json['signature'] ?? 'Unsigned',
      sourceCatalogId: json['sourceCatalogId'] ?? '',
      sourceCollectibleId: json['sourceCollectibleId'] ?? '',
      sourceUpc: json['sourceUpc'] ?? '',
      productionStatus: json['productionStatus'] ?? '',
      releaseDate: json['releaseDate'] ?? '',
      gradingCompany: json['gradingCompany'] ?? '',
      authenticityNumber: json['authenticityNumber'] ?? '',
      value: (json['value'] ?? 0).toDouble(),
      pricePaid: (json['pricePaid'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      itemCondition: json['itemCondition'] ?? '',
      boxCondition: json['boxCondition'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      owner: json['owner'] ?? 'Shared',
      isWishlist: json['isWishlist'] ?? false,
      dateAdded: json['dateAdded'] ?? '',
      lastUpdated: json['lastUpdated'] ?? '',
    );
  }

  /// Identifies the collectible release itself.
  ///
  /// A source catalog ID takes priority because HobbyDB assigns different
  /// HDBID values to separate releases, including Common versus Chase and
  /// releases that differ only by sticker or catalog entry.
  String get collectibleIdentityKey {
    final catalogId = normalizeIdentityText(
      sourceCatalogId,
    );

    if (catalogId.isNotEmpty) {
      return 'catalog|$catalogId';
    }

    final normalizedName = normalizeIdentityText(name);
    final normalizedNumber = normalizeIdentityText(number);

    if (normalizedName.isEmpty || normalizedNumber.isEmpty) {
      return '';
    }

    return [
      'manual',
      normalizedName,
      normalizedNumber,
      normalizeIdentityText(category),
      normalizeIdentityText(series),
      normalizeVariantIdentity(edition),
      normalizeVariantIdentity(variant),
      normalizeOptionalIdentity(retailExclusive),
      normalizeOptionalIdentity(eventSticker),
      normalizeOptionalIdentity(limitedEdition),
      normalizeSignatureIdentity(signature),
    ].join('|');
  }

  /// Identifies one stored record in a collection.
  ///
  /// Owner and wishlist status remain separate so different collectors and
  /// owned/wishlist records are never merged together.
  String get collectionRecordKey {
    final collectibleKey = collectibleIdentityKey;

    if (collectibleKey.isEmpty) {
      return '';
    }

    return [
      collectibleKey,
      normalizeIdentityText(owner),
      isWishlist ? 'wishlist' : 'owned',
    ].join('|');
  }

  String get csvImportKey => collectionRecordKey;

  String get duplicateKey => collectionRecordKey;

  String get collectorIdentity => collectibleIdentityKey;

  String get collectorLabel {
    final parts = <String>[
      variant,
      retailExclusive,
      eventSticker,
      limitedEdition,
      signature,
    ].where(hasMeaningfulIdentityLabel);

    if (parts.isEmpty) {
      return 'Common';
    }

    return parts.join(' • ');
  }

  Pop copyWith({
    String? id,
    String? name,
    String? number,
    String? category,
    String? series,
    String? edition,
    String? variant,
    String? retailExclusive,
    String? eventSticker,
    String? limitedEdition,
    String? signature,
    String? sourceCatalogId,
    String? sourceCollectibleId,
    String? sourceUpc,
    String? productionStatus,
    String? releaseDate,
    String? gradingCompany,
    String? authenticityNumber,
    double? value,
    double? pricePaid,
    int? quantity,
    String? itemCondition,
    String? boxCondition,
    String? imageUrl,
    String? owner,
    bool? isWishlist,
    String? dateAdded,
    String? lastUpdated,
  }) {
    return Pop(
      id: id ?? this.id,
      name: name ?? this.name,
      number: number ?? this.number,
      category: category ?? this.category,
      series: series ?? this.series,
      edition: edition ?? this.edition,
      variant: variant ?? this.variant,
      retailExclusive: retailExclusive ?? this.retailExclusive,
      eventSticker: eventSticker ?? this.eventSticker,
      limitedEdition: limitedEdition ?? this.limitedEdition,
      signature: signature ?? this.signature,
      sourceCatalogId: sourceCatalogId ?? this.sourceCatalogId,
      sourceCollectibleId:
      sourceCollectibleId ?? this.sourceCollectibleId,
      sourceUpc: sourceUpc ?? this.sourceUpc,
      productionStatus: productionStatus ?? this.productionStatus,
      releaseDate: releaseDate ?? this.releaseDate,
      gradingCompany: gradingCompany ?? this.gradingCompany,
      authenticityNumber:
      authenticityNumber ?? this.authenticityNumber,
      value: value ?? this.value,
      pricePaid: pricePaid ?? this.pricePaid,
      quantity: quantity ?? this.quantity,
      itemCondition: itemCondition ?? this.itemCondition,
      boxCondition: boxCondition ?? this.boxCondition,
      imageUrl: imageUrl ?? this.imageUrl,
      owner: owner ?? this.owner,
      isWishlist: isWishlist ?? this.isWishlist,
      dateAdded: dateAdded ?? this.dateAdded,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'number': number,
      'category': category,
      'series': series,
      'edition': edition,
      'variant': variant,
      'retailExclusive': retailExclusive,
      'eventSticker': eventSticker,
      'limitedEdition': limitedEdition,
      'signature': signature,
      'sourceCatalogId': sourceCatalogId,
      'sourceCollectibleId': sourceCollectibleId,
      'sourceUpc': sourceUpc,
      'productionStatus': productionStatus,
      'releaseDate': releaseDate,
      'gradingCompany': gradingCompany,
      'authenticityNumber': authenticityNumber,
      'value': value,
      'pricePaid': pricePaid,
      'quantity': quantity,
      'itemCondition': itemCondition,
      'boxCondition': boxCondition,
      'imageUrl': imageUrl,
      'owner': owner,
      'isWishlist': isWishlist,
      'dateAdded': dateAdded,
      'lastUpdated': lastUpdated,
    };
  }

  static String normalizeIdentityText(String value) {
    return value.trim().toLowerCase();
  }

  static String normalizeVariantIdentity(String value) {
    final cleaned = normalizeIdentityText(value);

    if (cleaned.isEmpty ||
        cleaned == 'none' ||
        cleaned == 'no' ||
        cleaned == 'n/a' ||
        cleaned == 'na' ||
        cleaned == 'common' ||
        cleaned == 'standard') {
      return 'common';
    }

    return cleaned;
  }

  static String normalizeOptionalIdentity(String value) {
    final cleaned = normalizeIdentityText(value);

    if (cleaned.isEmpty ||
        cleaned == 'none' ||
        cleaned == 'no' ||
        cleaned == 'n/a' ||
        cleaned == 'na') {
      return 'none';
    }

    return cleaned;
  }

  static String normalizeSignatureIdentity(String value) {
    final cleaned = normalizeIdentityText(value);

    if (cleaned.isEmpty ||
        cleaned == 'none' ||
        cleaned == 'no' ||
        cleaned == 'n/a' ||
        cleaned == 'na' ||
        cleaned == 'unsigned') {
      return 'unsigned';
    }

    return cleaned;
  }

  static bool hasMeaningfulIdentityLabel(String value) {
    final cleaned = normalizeIdentityText(value);

    return cleaned.isNotEmpty &&
        cleaned != 'none' &&
        cleaned != 'no' &&
        cleaned != 'n/a' &&
        cleaned != 'na' &&
        cleaned != 'unsigned' &&
        cleaned != 'common' &&
        cleaned != 'standard';
  }
}