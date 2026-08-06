enum AtlasCompletionScope {
  /// The entire active Atlas catalog.
  catalog,

  /// The product manufacturer or platform brand.
  ///
  /// Examples:
  /// Funko, Loungefly, LEGO, Mattel.
  brand,

  /// The intellectual-property owner or licensed universe.
  ///
  /// Examples:
  /// Marvel, DC, Disney, Pokémon.
  license,

  /// A recognizable property within a broader license.
  ///
  /// Examples:
  /// Spider-Man, Batman, Star Wars, One Piece.
  franchise,

  /// The content format or source medium.
  ///
  /// Examples:
  /// Movie, television, animation, anime, comic, video game.
  medium,

  /// An official product series or catalog grouping.
  ///
  /// Examples:
  /// Spider-Man: No Way Home, Retro Toys, Pop! Animation.
  series,

  /// A named official or curated product collection.
  ///
  /// Examples:
  /// Black Light, Art Series, Marvel Collector Corps.
  collection,

  /// A chronological or manufacturer-defined release wave.
  wave,

  /// A character, person, creature, vehicle, or primary subject.
  character,

  /// Products sharing the same underlying sculpt, pose, or physical mold.
  mold,

  /// Related releases that represent the same core collectible identity
  /// but differ through finish, sticker, retailer, chase, or treatment.
  variantFamily,

  /// A retailer, distributor, or sales-channel grouping.
  ///
  /// Examples:
  /// Target, Funko Shop, BoxLunch, Books-A-Million.
  retailer,

  /// An exclusive release classification.
  ///
  /// Examples:
  /// Retail exclusive, shared exclusive, convention exclusive.
  exclusive,

  /// A convention or event release grouping.
  ///
  /// Examples:
  /// SDCC, NYCC, WonderCon, Summer Convention.
  convention,

  /// A specific sticker classification attached to a release.
  ///
  /// Examples:
  /// Shared, convention, retailer, special edition.
  sticker,

  /// One exact catalog release.
  ///
  /// This is the smallest official completion unit and should represent
  /// a distinct catalog product rather than an owned quantity.
  release,
}

extension AtlasCompletionScopeMetadata
on AtlasCompletionScope {
  String get key {
    return switch (this) {
      AtlasCompletionScope.catalog => 'catalog',
      AtlasCompletionScope.brand => 'brand',
      AtlasCompletionScope.license => 'license',
      AtlasCompletionScope.franchise => 'franchise',
      AtlasCompletionScope.medium => 'medium',
      AtlasCompletionScope.series => 'series',
      AtlasCompletionScope.collection => 'collection',
      AtlasCompletionScope.wave => 'wave',
      AtlasCompletionScope.character => 'character',
      AtlasCompletionScope.mold => 'mold',
      AtlasCompletionScope.variantFamily =>
      'variant_family',
      AtlasCompletionScope.retailer => 'retailer',
      AtlasCompletionScope.exclusive => 'exclusive',
      AtlasCompletionScope.convention => 'convention',
      AtlasCompletionScope.sticker => 'sticker',
      AtlasCompletionScope.release => 'release',
    };
  }

  String get displayLabel {
    return switch (this) {
      AtlasCompletionScope.catalog => 'Catalog',
      AtlasCompletionScope.brand => 'Brand',
      AtlasCompletionScope.license => 'License',
      AtlasCompletionScope.franchise => 'Franchise',
      AtlasCompletionScope.medium => 'Medium',
      AtlasCompletionScope.series => 'Series',
      AtlasCompletionScope.collection => 'Collection',
      AtlasCompletionScope.wave => 'Wave',
      AtlasCompletionScope.character => 'Character',
      AtlasCompletionScope.mold => 'Mold',
      AtlasCompletionScope.variantFamily =>
      'Variant Family',
      AtlasCompletionScope.retailer => 'Retailer',
      AtlasCompletionScope.exclusive =>
      'Exclusive Type',
      AtlasCompletionScope.convention =>
      'Convention',
      AtlasCompletionScope.sticker => 'Sticker',
      AtlasCompletionScope.release => 'Release',
    };
  }

  int get hierarchyOrder {
    return switch (this) {
      AtlasCompletionScope.catalog => 0,
      AtlasCompletionScope.brand => 10,
      AtlasCompletionScope.license => 20,
      AtlasCompletionScope.franchise => 30,
      AtlasCompletionScope.medium => 40,
      AtlasCompletionScope.series => 50,
      AtlasCompletionScope.collection => 60,
      AtlasCompletionScope.wave => 70,
      AtlasCompletionScope.character => 80,
      AtlasCompletionScope.mold => 90,
      AtlasCompletionScope.variantFamily => 100,
      AtlasCompletionScope.retailer => 110,
      AtlasCompletionScope.exclusive => 120,
      AtlasCompletionScope.convention => 130,
      AtlasCompletionScope.sticker => 140,
      AtlasCompletionScope.release => 150,
    };
  }

  bool get isBroadScope {
    return switch (this) {
      AtlasCompletionScope.catalog ||
      AtlasCompletionScope.brand ||
      AtlasCompletionScope.license ||
      AtlasCompletionScope.franchise ||
      AtlasCompletionScope.medium => true,
      _ => false,
    };
  }

  bool get isReleaseIdentityScope {
    return switch (this) {
      AtlasCompletionScope.mold ||
      AtlasCompletionScope.variantFamily ||
      AtlasCompletionScope.release => true,
      _ => false,
    };
  }

  bool get isDistributionScope {
    return switch (this) {
      AtlasCompletionScope.retailer ||
      AtlasCompletionScope.exclusive ||
      AtlasCompletionScope.convention ||
      AtlasCompletionScope.sticker => true,
      _ => false,
    };
  }

  static AtlasCompletionScope? fromKey(
      String value,
      ) {
    final String normalized = value
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

    for (final AtlasCompletionScope scope
    in AtlasCompletionScope.values) {
      if (scope.key == normalized) {
        return scope;
      }
    }

    return null;
  }
}