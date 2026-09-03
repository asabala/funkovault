// Describes the semantic meaning of OCR text recognized by Atlas.
//
// OCR engines should classify recognized text whenever possible so that
// downstream identity engines reason about structured knowledge instead of
// arbitrary strings.
enum OCRRecognitionType {
  unknown,

  // Core identity.
  productLine,
  brand,
  title,
  characterName,
  productNumber,
  series,

  // Variant information.
  sticker,
  exclusive,
  limitedEdition,
  chase,
  glow,
  metallic,
  flocked,
  diamond,
  blacklight,
  autograph,

  // Supporting information.
  certification,
  copyright,
  productionCode,
  manufacturer,
  language,
  date,
  website,
  barcodeText,
  qrText,
  miscellaneous,
}

extension OCRRecognitionTypeX on OCRRecognitionType {
  bool get isIdentity {
    return switch (this) {
      OCRRecognitionType.productLine ||
      OCRRecognitionType.brand ||
      OCRRecognitionType.title ||
      OCRRecognitionType.characterName ||
      OCRRecognitionType.productNumber ||
      OCRRecognitionType.series => true,
      _ => false,
    };
  }

  bool get isVariant {
    return switch (this) {
      OCRRecognitionType.sticker ||
      OCRRecognitionType.exclusive ||
      OCRRecognitionType.limitedEdition ||
      OCRRecognitionType.chase ||
      OCRRecognitionType.glow ||
      OCRRecognitionType.metallic ||
      OCRRecognitionType.flocked ||
      OCRRecognitionType.diamond ||
      OCRRecognitionType.blacklight ||
      OCRRecognitionType.autograph => true,
      _ => false,
    };
  }

  bool get displayPriority {
    return isIdentity || isVariant;
  }

  String get displayName {
    return switch (this) {
      OCRRecognitionType.unknown => 'Unknown',
      OCRRecognitionType.productLine => 'Product Line',
      OCRRecognitionType.brand => 'Brand',
      OCRRecognitionType.title => 'Title',
      OCRRecognitionType.characterName => 'Character Name',
      OCRRecognitionType.productNumber => 'Product Number',
      OCRRecognitionType.series => 'Series',
      OCRRecognitionType.sticker => 'Sticker',
      OCRRecognitionType.exclusive => 'Exclusive',
      OCRRecognitionType.limitedEdition => 'Limited Edition',
      OCRRecognitionType.chase => 'Chase',
      OCRRecognitionType.glow => 'Glow',
      OCRRecognitionType.metallic => 'Metallic',
      OCRRecognitionType.flocked => 'Flocked',
      OCRRecognitionType.diamond => 'Diamond',
      OCRRecognitionType.blacklight => 'Blacklight',
      OCRRecognitionType.autograph => 'Autograph',
      OCRRecognitionType.certification => 'Certification',
      OCRRecognitionType.copyright => 'Copyright',
      OCRRecognitionType.productionCode => 'Production Code',
      OCRRecognitionType.manufacturer => 'Manufacturer',
      OCRRecognitionType.language => 'Language',
      OCRRecognitionType.date => 'Date',
      OCRRecognitionType.website => 'Website',
      OCRRecognitionType.barcodeText => 'Barcode',
      OCRRecognitionType.qrText => 'QR Code',
      OCRRecognitionType.miscellaneous => 'Miscellaneous',
    };
  }
}
