import '../atlas/market/models/value_history_entry.dart';
import '../atlas/timeline/models/atlas_timeline_event.dart';

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

  // External catalog identity.
  //
  // For HobbyDB imports:
  // sourceCatalogId = HDBID
  // sourceCollectibleId = HDBC Number
  // sourceUpc = UPC
  final String sourceCatalogId;
  final String sourceCollectibleId;
  final String sourceUpc;

  // Additional source metadata that helps Atlas preserve and explain
  // imported collectible releases.
  final String productionStatus;
  final String releaseDate;
  final String gradingCompany;
  final String authenticityNumber;

  // Physical release identity metadata.
  //
  // These fields describe meaningful release or packaging differences.
  // They do not describe the collector's individual copy condition.
  final String finish;
  final String size;
  final String packagingType;
  final String boxVersion;
  final String copyrightYear;
  final String productionCode;
  final String stickerType;
  final String authenticationProvider;

  final double value;
  final double pricePaid;

  // Chronological estimated-value records for this collectible.
  //
  // Legacy Pops may begin with a single synthesized history entry based on
  // their existing [value] and last known update date.
  final List<ValueHistoryEntry> valueHistory;

  // Chronological collector and market events for this collectible.
  final List<AtlasTimelineEvent> timeline;

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
    this.finish = 'Standard',
    this.size = 'Standard 4 Inch',
    this.packagingType = 'Single',
    this.boxVersion = '',
    this.copyrightYear = '',
    this.productionCode = '',
    this.stickerType = '',
    this.authenticationProvider = '',
    required this.value,
    required this.pricePaid,
    this.valueHistory = const [],
    this.timeline = const [],
    required this.quantity,
    required this.itemCondition,
    required this.boxCondition,
    required this.imageUrl,
    required this.owner,
    required this.isWishlist,
    this.dateAdded = '',
    this.lastUpdated = '',
  });

  factory Pop.fromJson(Map<String, dynamic> json) {
    final parsedId = json['id']?.toString() ?? '';
    final legacyEdition = json['edition'] ?? 'Common';

    final parsedValue = _readDouble(json['value']);
    final parsedDateAdded = json['dateAdded']?.toString() ?? '';
    final parsedLastUpdated = json['lastUpdated']?.toString() ?? '';

    final parsedValueHistory = _readValueHistory(
      json['valueHistory'],
      currentValue: parsedValue,
      dateAdded: parsedDateAdded,
      lastUpdated: parsedLastUpdated,
    );

    final parsedTimeline = _readTimeline(
      json['timeline'],
      popId: parsedId,
      dateAdded: parsedDateAdded,
    );

    return Pop(
      id: parsedId,
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
      finish: json['finish'] ?? 'Standard',
      size: json['size'] ?? 'Standard 4 Inch',
      packagingType: json['packagingType'] ?? 'Single',
      boxVersion: json['boxVersion'] ?? '',
      copyrightYear: json['copyrightYear'] ?? '',
      productionCode: json['productionCode'] ?? '',
      stickerType: json['stickerType'] ?? '',
      authenticationProvider: json['authenticationProvider'] ?? '',
      value: parsedValue,
      pricePaid: _readDouble(json['pricePaid']),
      valueHistory: parsedValueHistory,
      timeline: parsedTimeline,
      quantity: _readInt(json['quantity'], fallback: 1),
      itemCondition: json['itemCondition'] ?? '',
      boxCondition: json['boxCondition'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      owner: json['owner'] ?? 'Shared',
      isWishlist: json['isWishlist'] ?? false,
      dateAdded: parsedDateAdded,
      lastUpdated: parsedLastUpdated,
    );
  }

  /// Identifies the exact collectible release itself for CONFIRMED duplicates.
  ///
  /// No single external identifier is trusted by itself.
  ///
  /// Catalog IDs and UPCs are strong identity evidence, but Funko releases may
  /// reuse UPCs or third-party catalogs may group multiple physical variants
  /// under one record. Release-defining attributes are therefore always included.
  String get collectibleIdentityKey {
    final catalogId = normalizeIdentityText(sourceCatalogId);
    final collectibleId = normalizeIdentityText(sourceCollectibleId);
    final upc = normalizeIdentityText(sourceUpc);

    final normalizedName = normalizeIdentityText(name);
    final normalizedNumber = normalizeIdentityText(number);
    final normalizedCategory = normalizeIdentityText(category);
    final normalizedSeries = normalizeIdentityText(series);

    final identityAnchor = _buildIdentityAnchor(
      catalogId: catalogId,
      collectibleId: collectibleId,
      upc: upc,
      normalizedName: normalizedName,
      normalizedNumber: normalizedNumber,
      normalizedCategory: normalizedCategory,
      normalizedSeries: normalizedSeries,
    );

    if (identityAnchor.isEmpty) {
      return '';
    }

    return <String>[
      'release',
      identityAnchor,
      ..._releaseIdentityParts,
    ].join('|');
  }

  /// Broad identity key used to group POSSIBLE duplicates for review.
  ///
  /// This intentionally ignores release-defining differences such as Chase,
  /// stickers, finishes, signatures, box versions, and production codes.
  ///
  /// Examples:
  ///
  /// Same UPC but Common vs Chase:
  ///   grouped for review, not confirmed as duplicates.
  ///
  /// Same number and series with slightly different names:
  ///   grouped for review.
  ///
  /// Same number in different Funko lines:
  ///   not grouped together.
  String get similarityReviewKey {
    final upc = normalizeIdentityText(sourceUpc);

    if (upc.isNotEmpty) {
      return 'upc_review|$upc';
    }

    final collectibleId = normalizeIdentityText(sourceCollectibleId);

    if (collectibleId.isNotEmpty) {
      return 'collectible_review|$collectibleId';
    }

    final catalogId = normalizeIdentityText(sourceCatalogId);

    if (catalogId.isNotEmpty) {
      return 'catalog_review|$catalogId';
    }

    final normalizedNumber = normalizeIdentityText(number);
    final normalizedCategory = normalizeIdentityText(category);
    final normalizedSeries = normalizeIdentityText(series);
    final normalizedName = normalizeIdentityText(name);

    if (normalizedNumber.isEmpty) {
      return '';
    }

    // Preferred manual review identity:
    // Number + Funko line/category + series.
    //
    // Name is intentionally omitted here so entries such as:
    // "Spider-Man" and "Spider Man"
    // can still be reviewed together.
    if (normalizedCategory.isNotEmpty && normalizedSeries.isNotEmpty) {
      return <String>[
        'line_review',
        normalizedNumber,
        normalizedCategory,
        normalizedSeries,
      ].join('|');
    }

    // When series is missing, retain the name to avoid grouping every #01
    // in a broad category together.
    if (normalizedCategory.isNotEmpty && normalizedName.isNotEmpty) {
      return <String>[
        'category_review',
        normalizedNumber,
        normalizedCategory,
        normalizedName,
      ].join('|');
    }

    // Last-resort review key. This is deliberately conservative.
    if (normalizedSeries.isNotEmpty && normalizedName.isNotEmpty) {
      return <String>[
        'series_review',
        normalizedNumber,
        normalizedSeries,
        normalizedName,
      ].join('|');
    }

    return '';
  }

  /// Builds the strongest available core identity anchor.
  ///
  /// The anchor identifies the probable catalog object. Physical release
  /// attributes are appended separately through [_releaseIdentityParts].
  String _buildIdentityAnchor({
    required String catalogId,
    required String collectibleId,
    required String upc,
    required String normalizedName,
    required String normalizedNumber,
    required String normalizedCategory,
    required String normalizedSeries,
  }) {
    if (collectibleId.isNotEmpty) {
      return 'collectible|$collectibleId';
    }

    if (catalogId.isNotEmpty) {
      return 'catalog|$catalogId';
    }

    if (upc.isNotEmpty) {
      return 'upc|$upc';
    }

    if (normalizedNumber.isEmpty) {
      return '';
    }

    // Number alone is never enough because every Funko line can restart at #01.
    if (normalizedCategory.isEmpty && normalizedSeries.isEmpty) {
      return '';
    }

    return <String>[
      'manual',
      normalizedName,
      normalizedNumber,
      normalizedCategory,
      normalizedSeries,
    ].join('|');
  }

  /// Release-defining attributes used by exact duplicate detection.
  ///
  /// Any meaningful difference here represents either:
  ///
  /// - another variant,
  /// - another sticker release,
  /// - another package format,
  /// - another box version,
  /// - another production run,
  /// - or another authenticated collectible.
  List<String> get _releaseIdentityParts {
    return <String>[
      normalizeVariantIdentity(edition),
      normalizeVariantIdentity(variant),
      normalizeVariantIdentity(finish),
      normalizeOptionalIdentity(retailExclusive),
      normalizeOptionalIdentity(eventSticker),
      normalizeOptionalIdentity(stickerType),
      normalizeOptionalIdentity(limitedEdition),
      normalizeSignatureIdentity(signature),
      normalizeOptionalIdentity(authenticationProvider),
      normalizeOptionalIdentity(gradingCompany),
      normalizeOptionalIdentity(authenticityNumber),
      normalizeOptionalIdentity(size),
      normalizeOptionalIdentity(packagingType),
      normalizeOptionalIdentity(boxVersion),
      normalizeOptionalIdentity(copyrightYear),
      normalizeOptionalIdentity(productionCode),
    ];
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
    String? finish,
    String? size,
    String? packagingType,
    String? boxVersion,
    String? copyrightYear,
    String? productionCode,
    String? stickerType,
    String? authenticationProvider,
    double? value,
    double? pricePaid,
    List<ValueHistoryEntry>? valueHistory,
    List<AtlasTimelineEvent>? timeline,
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
      sourceCollectibleId: sourceCollectibleId ?? this.sourceCollectibleId,
      sourceUpc: sourceUpc ?? this.sourceUpc,
      productionStatus: productionStatus ?? this.productionStatus,
      releaseDate: releaseDate ?? this.releaseDate,
      gradingCompany: gradingCompany ?? this.gradingCompany,
      authenticityNumber: authenticityNumber ?? this.authenticityNumber,
      finish: finish ?? this.finish,
      size: size ?? this.size,
      packagingType: packagingType ?? this.packagingType,
      boxVersion: boxVersion ?? this.boxVersion,
      copyrightYear: copyrightYear ?? this.copyrightYear,
      productionCode: productionCode ?? this.productionCode,
      stickerType: stickerType ?? this.stickerType,
      authenticationProvider:
          authenticationProvider ?? this.authenticationProvider,
      value: value ?? this.value,
      pricePaid: pricePaid ?? this.pricePaid,
      valueHistory: valueHistory ?? this.valueHistory,
      timeline: timeline ?? this.timeline,
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
      'finish': finish,
      'size': size,
      'packagingType': packagingType,
      'boxVersion': boxVersion,
      'copyrightYear': copyrightYear,
      'productionCode': productionCode,
      'stickerType': stickerType,
      'authenticationProvider': authenticationProvider,
      'value': value,
      'pricePaid': pricePaid,
      'valueHistory': valueHistory
          .map((entry) => entry.toJson())
          .toList(growable: false),
      'timeline': timeline
          .map((event) => event.toJson())
          .toList(growable: false),
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

  static double _readDouble(dynamic rawValue) {
    if (rawValue is num) {
      return rawValue.toDouble();
    }

    return double.tryParse(rawValue?.toString().trim() ?? '') ?? 0;
  }

  static int _readInt(dynamic rawValue, {required int fallback}) {
    if (rawValue is int) {
      return rawValue;
    }

    if (rawValue is num) {
      return rawValue.toInt();
    }

    return int.tryParse(rawValue?.toString().trim() ?? '') ?? fallback;
  }

  static List<ValueHistoryEntry> _readValueHistory(
    dynamic rawHistory, {
    required double currentValue,
    required String dateAdded,
    required String lastUpdated,
  }) {
    final entries = <ValueHistoryEntry>[];

    if (rawHistory is List) {
      for (final rawEntry in rawHistory) {
        if (rawEntry is! Map) {
          continue;
        }

        final entry = ValueHistoryEntry.fromJson(
          Map<String, dynamic>.from(rawEntry),
        );

        if (entry.value <= 0) {
          continue;
        }

        entries.add(entry);
      }
    }

    if (entries.isNotEmpty) {
      entries.sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

      return List<ValueHistoryEntry>.unmodifiable(entries);
    }

    if (currentValue <= 0) {
      return const [];
    }

    final recordedAt =
        DateTime.tryParse(lastUpdated) ??
        DateTime.tryParse(dateAdded) ??
        DateTime.fromMillisecondsSinceEpoch(0);

    return List<ValueHistoryEntry>.unmodifiable(<ValueHistoryEntry>[
      ValueHistoryEntry(
        value: currentValue,
        recordedAt: recordedAt,
        source: ValueHistoryEntry.legacyValueSource,
      ),
    ]);
  }

  static List<AtlasTimelineEvent> _readTimeline(
    dynamic rawTimeline, {
    required String popId,
    required String dateAdded,
  }) {
    final events = <AtlasTimelineEvent>[];

    if (rawTimeline is List) {
      for (final rawEvent in rawTimeline) {
        if (rawEvent is! Map) {
          continue;
        }

        final event = AtlasTimelineEvent.fromJson(
          Map<String, dynamic>.from(rawEvent),
        );

        events.add(event);
      }
    }

    if (events.isNotEmpty) {
      events.sort((a, b) => a.occurredAt.compareTo(b.occurredAt));

      return List<AtlasTimelineEvent>.unmodifiable(events);
    }

    final addedAt = DateTime.tryParse(dateAdded);

    if (popId.isEmpty || addedAt == null) {
      return const [];
    }

    return List<AtlasTimelineEvent>.unmodifiable(<AtlasTimelineEvent>[
      AtlasTimelineEvent(
        id: 'legacy-added-$popId',
        popId: popId,
        type: AtlasTimelineEventType.addedToVault,
        occurredAt: addedAt,
        title: 'Added to Vault',
        createdBy: AtlasTimelineEvent.systemCreatedBy,
        createdAt: addedAt,
      ),
    ]);
  }

  // Cleans strings by lowercasing and stripping non-alphanumeric characters.
  // Converts "Spider-Man #01!" -> "spiderman01"
  static String normalizeIdentityText(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  static String normalizeVariantIdentity(String value) {
    final cleaned = normalizeIdentityText(value);

    if (cleaned.isEmpty ||
        cleaned == 'none' ||
        cleaned == 'no' ||
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
        cleaned != 'na' &&
        cleaned != 'unsigned' &&
        cleaned != 'common' &&
        cleaned != 'standard';
  }
}
