// Canonical physical and identity-relevant variant classifications.
//
// Retailers, conventions, stickers, distribution channels, and piece counts
// are modeled separately by their own intelligence layers.
enum AtlasVariantType {
  common(
    code: 'common',
    displayName: 'Common',
  ),
  chase(
    code: 'chase',
    displayName: 'Chase',
  ),
  blacklight(
    code: 'blacklight',
    displayName: 'Black Light',
  ),
  glow(
    code: 'glow',
    displayName: 'Glow in the Dark',
  ),
  metallic(
    code: 'metallic',
    displayName: 'Metallic',
  ),
  chrome(
    code: 'chrome',
    displayName: 'Chrome',
  ),
  diamond(
    code: 'diamond',
    displayName: 'Diamond',
  ),
  glitter(
    code: 'glitter',
    displayName: 'Glitter',
  ),
  flocked(
    code: 'flocked',
    displayName: 'Flocked',
  ),
  scented(
    code: 'scented',
    displayName: 'Scented',
  ),
  dieCast(
    code: 'die-cast',
    displayName: 'Die-Cast',
  ),
  translucent(
    code: 'translucent',
    displayName: 'Translucent',
  ),
  woodDeco(
    code: 'wood-deco',
    displayName: 'Wood Deco',
  ),
  patina(
    code: 'patina',
    displayName: 'Patina',
  ),
  sepia(
    code: 'sepia',
    displayName: 'Sepia',
  ),
  grayscale(
    code: 'grayscale',
    displayName: 'Grayscale',
  ),
  signed(
    code: 'signed',
    displayName: 'Signed',
  ),
  limitedEdition(
    code: 'limited-edition',
    displayName: 'Limited Edition',
  ),
  numbered(
    code: 'numbered',
    displayName: 'Numbered Piece',
  ),
  artistProof(
    code: 'artist-proof',
    displayName: 'Artist Proof',
  ),
  prototype(
    code: 'prototype',
    displayName: 'Prototype',
  ),
  error(
    code: 'error',
    displayName: 'Error Variant',
  ),
  nft(
    code: 'nft',
    displayName: 'NFT',
  ),
  soda(
    code: 'soda',
    displayName: 'Soda',
  ),
  jumbo(
    code: 'jumbo',
    displayName: 'Jumbo',
  ),
  superSized(
    code: 'super-sized',
    displayName: 'Super Sized',
  ),
  mini(
    code: 'mini',
    displayName: 'Mini',
  ),
  pocket(
    code: 'pocket',
    displayName: 'Pocket',
  ),
  keychain(
    code: 'keychain',
    displayName: 'Keychain',
  ),
  unknown(
    code: 'unknown',
    displayName: 'Unknown Variant',
  );

  const AtlasVariantType({
    required this.code,
    required this.displayName,
  });

  final String code;

  final String displayName;

  bool get isStandard {
    return this == AtlasVariantType.common;
  }

  bool get isSpecial {
    return this != AtlasVariantType.common &&
        this != AtlasVariantType.unknown;
  }

  bool get affectsIdentity {
    return this != AtlasVariantType.unknown;
  }

  bool get isTreatment {
    return switch (this) {
      AtlasVariantType.blacklight ||
      AtlasVariantType.glow ||
      AtlasVariantType.metallic ||
      AtlasVariantType.chrome ||
      AtlasVariantType.diamond ||
      AtlasVariantType.glitter ||
      AtlasVariantType.flocked ||
      AtlasVariantType.scented ||
      AtlasVariantType.dieCast ||
      AtlasVariantType.translucent ||
      AtlasVariantType.woodDeco ||
      AtlasVariantType.patina ||
      AtlasVariantType.sepia ||
      AtlasVariantType.grayscale =>
      true,
      _ => false,
    };
  }

  bool get isEdition {
    return switch (this) {
      AtlasVariantType.limitedEdition ||
      AtlasVariantType.numbered ||
      AtlasVariantType.artistProof ||
      AtlasVariantType.prototype ||
      AtlasVariantType.error ||
      AtlasVariantType.nft =>
      true,
      _ => false,
    };
  }

  bool get isFormat {
    return switch (this) {
      AtlasVariantType.soda ||
      AtlasVariantType.jumbo ||
      AtlasVariantType.superSized ||
      AtlasVariantType.mini ||
      AtlasVariantType.pocket ||
      AtlasVariantType.keychain =>
      true,
      _ => false,
    };
  }

  static AtlasVariantType fromCode(
      String? code,
      ) {
    final String normalizedCode =
        code?.trim().toLowerCase() ?? '';

    for (final AtlasVariantType type
    in AtlasVariantType.values) {
      if (type.code == normalizedCode) {
        return type;
      }
    }

    return AtlasVariantType.unknown;
  }
}