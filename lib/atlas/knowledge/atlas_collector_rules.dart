class AtlasCollectorRules {
  const AtlasCollectorRules._();

  static const Set<String> rareVariants = {
    'Chase',
    'Glow',
    'Blacklight',
    'Diamond',
    'Flocked',
    'Metallic',
    'Chrome',
    'Glitter',
    'Prototype',
    'NFT Redemption',
    'Error Variant',
  };

  static const Set<String> conventionStickers = {
    'SDCC',
    'NYCC',
    'ECCC',
    'WonderCon',
    'C2E2',
    'Fundays',
  };

  static const Set<String> authenticationTypes = {
    'Beckett Authenticated',
    'JSA Authenticated',
    'PSA Authenticated',
  };

  static bool isRareVariant(String variant) {
    return rareVariants.contains(variant);
  }

  static bool isConventionSticker(String sticker) {
    return conventionStickers.contains(sticker);
  }

  static bool isAuthenticated(String signature) {
    return authenticationTypes.contains(signature);
  }

  static bool isLimitedEdition(String limitedEdition) {
    return limitedEdition != 'None';
  }

  static bool isExclusive(String retailExclusive) {
    return retailExclusive != 'None';
  }
}
