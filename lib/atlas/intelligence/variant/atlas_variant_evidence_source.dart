// Identifies where Atlas obtained variant evidence.
//
// Keeping the source separate allows confidence policies to treat OCR,
// catalog data, user confirmation, and imported information differently.
enum AtlasVariantEvidenceSource {
  ocr(
    code: 'ocr',
    displayName: 'OCR',
  ),
  barcode(
    code: 'barcode',
    displayName: 'Barcode',
  ),
  catalog(
    code: 'catalog',
    displayName: 'Catalog',
  ),
  user(
    code: 'user',
    displayName: 'User',
  ),
  importer(
    code: 'importer',
    displayName: 'Importer',
  ),
  rule(
    code: 'rule',
    displayName: 'Rule',
  ),
  ai(
    code: 'ai',
    displayName: 'AI',
  ),
  unknown(
    code: 'unknown',
    displayName: 'Unknown',
  );

  const AtlasVariantEvidenceSource({
    required this.code,
    required this.displayName,
  });

  final String code;

  final String displayName;

  bool get isUserConfirmed {
    return this == AtlasVariantEvidenceSource.user;
  }

  bool get isAutomated {
    return switch (this) {
      AtlasVariantEvidenceSource.ocr ||
      AtlasVariantEvidenceSource.barcode ||
      AtlasVariantEvidenceSource.catalog ||
      AtlasVariantEvidenceSource.importer ||
      AtlasVariantEvidenceSource.rule ||
      AtlasVariantEvidenceSource.ai =>
      true,
      AtlasVariantEvidenceSource.user ||
      AtlasVariantEvidenceSource.unknown =>
      false,
    };
  }

  static AtlasVariantEvidenceSource fromCode(
      String? code,
      ) {
    final String normalizedCode =
        code?.trim().toLowerCase() ?? '';

    for (final AtlasVariantEvidenceSource source
    in AtlasVariantEvidenceSource.values) {
      if (source.code == normalizedCode) {
        return source;
      }
    }

    return AtlasVariantEvidenceSource.unknown;
  }
}