// Semantic region of a collectible where recognition evidence was found.
//
// RecognitionRegion describes the meaning of an area rather than its pixel
// coordinates. OCR, vision, logo, sticker, autograph, and future recognition
// engines can use the same region vocabulary.
enum RecognitionRegion {
  unknown,

  // Broad collectible surfaces.
  front,
  rear,
  leftSide,
  rightSide,
  top,
  bottom,

  // Product identity regions.
  productLine,
  brand,
  logo,
  title,
  characterName,
  productNumber,

  // Variant and authenticity regions.
  sticker,
  autograph,
  editionMarking,
  exclusiveMarking,
  limitedEditionMarking,
  certification,

  // Machine-readable regions.
  barcode,
  qrCode,

  // Visual regions.
  frontArtwork,
  window,
  productImage,
  backgroundArtwork,
}

// Shared helpers for recognition-region interpretation.
extension RecognitionRegionX on RecognitionRegion {
  bool get isUnknown {
    return this == RecognitionRegion.unknown;
  }

  bool get isSurface {
    return switch (this) {
      RecognitionRegion.front ||
      RecognitionRegion.rear ||
      RecognitionRegion.leftSide ||
      RecognitionRegion.rightSide ||
      RecognitionRegion.top ||
      RecognitionRegion.bottom => true,
      _ => false,
    };
  }

  bool get isIdentityRegion {
    return switch (this) {
      RecognitionRegion.productLine ||
      RecognitionRegion.brand ||
      RecognitionRegion.logo ||
      RecognitionRegion.title ||
      RecognitionRegion.characterName ||
      RecognitionRegion.productNumber => true,
      _ => false,
    };
  }

  bool get isVariantRegion {
    return switch (this) {
      RecognitionRegion.sticker ||
      RecognitionRegion.autograph ||
      RecognitionRegion.editionMarking ||
      RecognitionRegion.exclusiveMarking ||
      RecognitionRegion.limitedEditionMarking ||
      RecognitionRegion.certification => true,
      _ => false,
    };
  }

  bool get isMachineReadableRegion {
    return this == RecognitionRegion.barcode ||
        this == RecognitionRegion.qrCode;
  }

  bool get isVisualRegion {
    return switch (this) {
      RecognitionRegion.frontArtwork ||
      RecognitionRegion.window ||
      RecognitionRegion.productImage ||
      RecognitionRegion.backgroundArtwork => true,
      _ => false,
    };
  }

  String get displayName {
    return switch (this) {
      RecognitionRegion.unknown => 'Unknown',
      RecognitionRegion.front => 'Front',
      RecognitionRegion.rear => 'Rear',
      RecognitionRegion.leftSide => 'Left Side',
      RecognitionRegion.rightSide => 'Right Side',
      RecognitionRegion.top => 'Top',
      RecognitionRegion.bottom => 'Bottom',
      RecognitionRegion.productLine => 'Product Line',
      RecognitionRegion.brand => 'Brand',
      RecognitionRegion.logo => 'Logo',
      RecognitionRegion.title => 'Title',
      RecognitionRegion.characterName => 'Character Name',
      RecognitionRegion.productNumber => 'Product Number',
      RecognitionRegion.sticker => 'Sticker',
      RecognitionRegion.autograph => 'Autograph',
      RecognitionRegion.editionMarking => 'Edition Marking',
      RecognitionRegion.exclusiveMarking => 'Exclusive Marking',
      RecognitionRegion.limitedEditionMarking => 'Limited Edition Marking',
      RecognitionRegion.certification => 'Certification',
      RecognitionRegion.barcode => 'Barcode',
      RecognitionRegion.qrCode => 'QR Code',
      RecognitionRegion.frontArtwork => 'Front Artwork',
      RecognitionRegion.window => 'Window',
      RecognitionRegion.productImage => 'Product Image',
      RecognitionRegion.backgroundArtwork => 'Background Artwork',
    };
  }
}
