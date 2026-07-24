import 'funko_sticker_type.dart';

// Converts sticker wording into canonical Atlas sticker types.
//
// This class recognizes the meaning of a sticker only.
// It intentionally ignores retailer and convention identity,
// which are detected by separate intelligence modules.
final class FunkoStickerNormalizer {
  const FunkoStickerNormalizer();
  Map<FunkoStickerType, List<String>> get aliases {
    return Map<FunkoStickerType, List<String>>.unmodifiable(
      _aliases.map(
            (key, value) => MapEntry(
          key,
          List<String>.unmodifiable(value),
        ),
      ),
    );
  }
  FunkoStickerType normalize(
      String? value,
      ) {
    final String normalized =
    normalizeText(value);

    if (normalized.isEmpty) {
      return FunkoStickerType.unknown;
    }

    for (final MapEntry<FunkoStickerType, List<String>>
    entry in _aliases.entries) {
      if (entry.value.contains(normalized)) {
        return entry.key;
      }
    }

    return FunkoStickerType.unknown;
  }

  bool isKnownSticker(
      String? value,
      ) {
    return normalize(value) !=
        FunkoStickerType.unknown;
  }

  String normalizeText(
      String? value,
      ) {
    return value
        ?.trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[áàâä]'), 'a')
        .replaceAll(RegExp(r'[íìîï]'), 'i')
        .replaceAll(RegExp(r'[óòôö]'), 'o')
        .replaceAll(RegExp(r'[úùûü]'), 'u')
        .replaceAll('ñ', 'n')
        .replaceAll('ç', 'c')
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

  static const Map<FunkoStickerType, List<String>>
  _aliases =
  <FunkoStickerType, List<String>>{
    FunkoStickerType.retailerExclusive: <String>[
      'exclusive',
      'retailer exclusive',
    ],

    FunkoStickerType.officialConvention: <String>[
      'official convention',
      'convention exclusive',
      'official convention exclusive',
    ],

    FunkoStickerType.sharedConvention: <String>[
      'shared exclusive',
      'shared convention',
      'shared convention exclusive',
    ],

    FunkoStickerType.specialEdition: <String>[
      'special edition',
    ],

    FunkoStickerType.specialtySeries: <String>[
      'specialty series',
    ],

    FunkoStickerType.subscriptionBox: <String>[
      'subscription box',
    ],

    FunkoStickerType.employeeExclusive: <String>[
      'employee exclusive',
      'funko employee',
    ],

    FunkoStickerType.prototype: <String>[
      'prototype',
      'proto',
    ],

    FunkoStickerType.sample: <String>[
      'sample',
    ],
  };
}