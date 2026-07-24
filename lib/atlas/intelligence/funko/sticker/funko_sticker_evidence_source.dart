// Identifies where sticker evidence originated.
enum FunkoStickerEvidenceSource {
  ocr(
    code: 'ocr',
  ),
  barcode(
    code: 'barcode',
  ),
  catalog(
    code: 'catalog',
  ),
  user(
    code: 'user',
  ),
  importer(
    code: 'importer',
  ),
  rule(
    code: 'rule',
  ),
  ai(
    code: 'ai',
  ),
  unknown(
    code: 'unknown',
  );

  const FunkoStickerEvidenceSource({
    required this.code,
  });

  final String code;

  bool get isUserConfirmed {
    return this == FunkoStickerEvidenceSource.user;
  }

  bool get isAutomated {
    return switch (this) {
      FunkoStickerEvidenceSource.ocr ||
      FunkoStickerEvidenceSource.barcode ||
      FunkoStickerEvidenceSource.catalog ||
      FunkoStickerEvidenceSource.importer ||
      FunkoStickerEvidenceSource.rule ||
      FunkoStickerEvidenceSource.ai =>
      true,
      _ => false,
    };
  }

  static FunkoStickerEvidenceSource fromCode(
      String? code,
      ) {
    final String normalized =
        code?.trim().toLowerCase() ?? '';

    for (final source
    in FunkoStickerEvidenceSource.values) {
      if (source.code == normalized) {
        return source;
      }
    }

    return FunkoStickerEvidenceSource.unknown;
  }
}