// Canonical sticker classifications used by Atlas.
//
// These represent the meaning of a sticker, not the specific retailer
// or convention. Retailers and conventions are modeled separately.
enum FunkoStickerType {
  none(code: 'none', displayName: 'None'),

  retailerExclusive(
    code: 'retailer-exclusive',
    displayName: 'Retailer Exclusive',
  ),

  officialConvention(
    code: 'official-convention',
    displayName: 'Official Convention',
  ),

  sharedConvention(code: 'shared-convention', displayName: 'Shared Convention'),

  specialEdition(code: 'special-edition', displayName: 'Special Edition'),

  specialtySeries(code: 'specialty-series', displayName: 'Specialty Series'),

  subscriptionBox(code: 'subscription-box', displayName: 'Subscription Box'),

  employeeExclusive(
    code: 'employee-exclusive',
    displayName: 'Employee Exclusive',
  ),

  prototype(code: 'prototype', displayName: 'Prototype'),

  sample(code: 'sample', displayName: 'Sample'),

  unknown(code: 'unknown', displayName: 'Unknown');

  const FunkoStickerType({required this.code, required this.displayName});

  final String code;

  final String displayName;

  bool get affectsIdentity {
    return this != FunkoStickerType.none && this != FunkoStickerType.unknown;
  }

  bool get isConvention {
    return this == FunkoStickerType.officialConvention ||
        this == FunkoStickerType.sharedConvention;
  }

  bool get isRetail {
    return this == FunkoStickerType.retailerExclusive;
  }

  bool get isSpecialRelease {
    return switch (this) {
      FunkoStickerType.specialEdition ||
      FunkoStickerType.specialtySeries ||
      FunkoStickerType.subscriptionBox ||
      FunkoStickerType.employeeExclusive ||
      FunkoStickerType.prototype ||
      FunkoStickerType.sample => true,
      _ => false,
    };
  }

  static FunkoStickerType fromCode(String? code) {
    final String normalized = code?.trim().toLowerCase() ?? '';

    for (final FunkoStickerType value in FunkoStickerType.values) {
      if (value.code == normalized) {
        return value;
      }
    }

    return FunkoStickerType.unknown;
  }
}
