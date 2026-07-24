import 'atlas_variant_type.dart';

// Converts raw variant text into canonical Atlas variant types.
//
// Retailer names, convention names, sticker wording, and distribution
// markers are intentionally handled by separate intelligence layers.
final class AtlasVariantNormalizer {
  const AtlasVariantNormalizer();
  Map<AtlasVariantType, List<String>> get aliases {
    return Map<AtlasVariantType, List<String>>.unmodifiable(
      _aliases.map(
            (key, value) => MapEntry(
          key,
          List<String>.unmodifiable(value),
        ),
      ),
    );
  }
  AtlasVariantType normalize(
      String? value,
      ) {
    final String normalized = normalizeText(value);

    if (normalized.isEmpty) {
      return AtlasVariantType.unknown;
    }

    for (final MapEntry<AtlasVariantType, List<String>> entry
    in _aliases.entries) {
      if (entry.value.contains(normalized)) {
        return entry.key;
      }
    }

    return AtlasVariantType.unknown;
  }

  bool isKnownVariant(
      String? value,
      ) {
    return normalize(value) !=
        AtlasVariantType.unknown;
  }

  String normalizeText(
      String? value,
      ) {
    return value
        ?.trim()
        .toLowerCase()
        .replaceAll('&', ' and ')
        .replaceAll('-', ' ')
        .replaceAll('_', ' ')
        .replaceAll(
      RegExp(r'[^a-z0-9\s]'),
      ' ',
    )
        .replaceAll(
      RegExp(r'\s+'),
      ' ',
    )
        .trim() ??
        '';
  }

  static const Map<AtlasVariantType, List<String>>
  _aliases = {
    AtlasVariantType.common: [
      'common',
      'standard',
      'regular',
      'standard edition',
    ],
    AtlasVariantType.chase: [
      'chase',
      'chase variant',
    ],
    AtlasVariantType.blacklight: [
      'blacklight',
      'black light',
      'blacklight edition',
      'black light edition',
    ],
    AtlasVariantType.glow: [
      'glow',
      'gitd',
      'glow in the dark',
      'glow in dark',
      'glows in the dark',
      'glowing',
    ],
    AtlasVariantType.metallic: [
      'metallic',
      'metallic finish',
      'metallic edition',
    ],
    AtlasVariantType.chrome: [
      'chrome',
      'gold chrome',
      'silver chrome',
      'colored chrome',
      'colour chrome',
    ],
    AtlasVariantType.diamond: [
      'diamond',
      'diamond collection',
      'diamond edition',
    ],
    AtlasVariantType.glitter: [
      'glitter',
      'glitter finish',
      'glitter edition',
    ],
    AtlasVariantType.flocked: [
      'flocked',
      'flock',
      'fuzzy',
    ],
    AtlasVariantType.scented: [
      'scented',
      'scented edition',
      'scented exclusive',
    ],
    AtlasVariantType.dieCast: [
      'die cast',
      'diecast',
      'die cast edition',
      'diecast edition',
    ],
    AtlasVariantType.translucent: [
      'translucent',
      'clear',
      'transparent',
    ],
    AtlasVariantType.woodDeco: [
      'wood deco',
      'wooden deco',
      'wood finish',
    ],
    AtlasVariantType.patina: [
      'patina',
      'patina finish',
    ],
    AtlasVariantType.sepia: [
      'sepia',
      'sepia tone',
    ],
    AtlasVariantType.grayscale: [
      'grayscale',
      'greyscale',
      'black and white',
      'monochrome',
    ],
    AtlasVariantType.signed: [
      'signed',
      'autographed',
      'autograph',
      'auto',
    ],
    AtlasVariantType.limitedEdition: [
      'limited edition',
      'limited',
      'le',
    ],
    AtlasVariantType.numbered: [
      'numbered',
      'numbered piece',
      'piece count',
      'pcs',
    ],
    AtlasVariantType.artistProof: [
      'artist proof',
      'ap',
    ],
    AtlasVariantType.prototype: [
      'prototype',
      'proto',
    ],
    AtlasVariantType.error: [
      'error',
      'error variant',
      'misprint',
      'factory error',
    ],
    AtlasVariantType.nft: [
      'nft',
      'digital pop',
      'digital collectible',
    ],
    AtlasVariantType.soda: [
      'soda',
      'funko soda',
    ],
    AtlasVariantType.jumbo: [
      'jumbo',
      'jumbo sized',
    ],
    AtlasVariantType.superSized: [
      'super sized',
      'supersized',
      'super size',
    ],
    AtlasVariantType.mini: [
      'mini',
      'miniature',
    ],
    AtlasVariantType.pocket: [
      'pocket',
      'pocket pop',
    ],
    AtlasVariantType.keychain: [
      'keychain',
      'key chain',
      'keyring',
    ],
  };
}