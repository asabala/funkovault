abstract final class FunkoIdentityKeys {
  // General identity
  static const String category = 'funko.identity.category';
  static const String maker = 'funko.identity.maker';

  // Core anchors
  static const String line = 'funko.identity.line';
  static const String name = 'funko.identity.name';
  static const String boxNumber = 'funko.identity.box_number';
  static const String upc = 'funko.identity.upc';
  static const String productionCode = 'funko.identity.production_code';
  static const String series = 'funko.identity.series';

  // Finish modifiers
  static const String finishGlow = 'funko.identity.finish.glow';
  static const String finishMetallic = 'funko.identity.finish.metallic';
  static const String finishFlocked = 'funko.identity.finish.flocked';
  static const String finishDiamond = 'funko.identity.finish.diamond';
  static const String finishGlitter = 'funko.identity.finish.glitter';
  static const String finishChrome = 'funko.identity.finish.chrome';
  static const String finishTranslucent = 'funko.identity.finish.translucent';
  static const String finishBloodSplatter =
      'funko.identity.finish.blood_splatter';
  static const String finishPatina = 'funko.identity.finish.patina';
  static const String finishBronze = 'funko.identity.finish.bronze';
  static const String finishWoodDeco = 'funko.identity.finish.wood_deco';

  // Form and scale modifiers
  static const String scale = 'funko.identity.form.scale';
  static const String build = 'funko.identity.form.build';
  static const String sculpt = 'funko.identity.form.sculpt';
  static const String pose = 'funko.identity.form.pose';
  static const String productForm = 'funko.identity.form.product_form';
  static const String factoryError = 'funko.identity.form.factory_error';

  // Release context
  static const String stickerClass = 'funko.identity.release.sticker_class';
  static const String stickerName = 'funko.identity.release.sticker_name';
  static const String retailer = 'funko.identity.release.retailer';
  static const String region = 'funko.identity.release.region';
  static const String distribution = 'funko.identity.release.distribution';
  static const String productionGeneration =
      'funko.identity.release.production_generation';

  // Factory scarcity
  static const String limitedEdition = 'funko.identity.release.limited_edition';
  static const String pieceCount = 'funko.identity.release.piece_count';
  static const String numberedPiece = 'funko.identity.release.numbered_piece';

  // Temporal context
  static const String releaseYear = 'funko.identity.release.release_year';

  static const Set<String> coreAnchorKeys = <String>{
    line,
    name,
    boxNumber,
    upc,
    productionCode,
  };

  static const Set<String> finishModifierKeys = <String>{
    finishGlow,
    finishMetallic,
    finishFlocked,
    finishDiamond,
    finishGlitter,
    finishChrome,
    finishTranslucent,
    finishBloodSplatter,
    finishPatina,
    finishBronze,
    finishWoodDeco,
  };

  static const Set<String> formModifierKeys = <String>{
    scale,
    build,
    sculpt,
    pose,
    productForm,
    factoryError,
  };

  static const Set<String> releaseContextKeys = <String>{
    stickerClass,
    stickerName,
    retailer,
    region,
    distribution,
    productionGeneration,
    limitedEdition,
    pieceCount,
    numberedPiece,
    releaseYear,
  };

  static const Set<String> contextualKeys = <String>{category, maker, series};

  static bool isCoreAnchor(String key) {
    return coreAnchorKeys.contains(key);
  }

  static bool isFinishModifier(String key) {
    return finishModifierKeys.contains(key);
  }

  static bool isFormModifier(String key) {
    return formModifierKeys.contains(key);
  }

  static bool isVariantModifier(String key) {
    return isFinishModifier(key) || isFormModifier(key);
  }

  static bool isReleaseContext(String key) {
    return releaseContextKeys.contains(key);
  }

  static bool isContextual(String key) {
    return contextualKeys.contains(key);
  }

  static bool isIdentityDefining(String key) {
    return isCoreAnchor(key) || isVariantModifier(key) || isReleaseContext(key);
  }
}
