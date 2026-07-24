// Identifies where retailer evidence originated.
enum FunkoRetailerEvidenceSource {
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

  const FunkoRetailerEvidenceSource({
    required this.code,
  });

  final String code;

  bool get isUserConfirmed {
    return this == FunkoRetailerEvidenceSource.user;
  }

  bool get isAutomated {
    return switch (this) {
      FunkoRetailerEvidenceSource.ocr ||
      FunkoRetailerEvidenceSource.barcode ||
      FunkoRetailerEvidenceSource.catalog ||
      FunkoRetailerEvidenceSource.importer ||
      FunkoRetailerEvidenceSource.rule ||
      FunkoRetailerEvidenceSource.ai =>
      true,
      _ => false,
    };
  }

  static FunkoRetailerEvidenceSource fromCode(
      String? code,
      ) {
    final String normalizedCode =
        code?.trim().toLowerCase() ?? '';

    for (final FunkoRetailerEvidenceSource source
    in FunkoRetailerEvidenceSource.values) {
      if (source.code == normalizedCode) {
        return source;
      }
    }

    return FunkoRetailerEvidenceSource.unknown;
  }
}