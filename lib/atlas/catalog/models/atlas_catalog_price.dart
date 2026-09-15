final class AtlasCatalogPrice {
  const AtlasCatalogPrice({
    required this.sourceType,
    required this.sourceProductId,
    this.lowPrice,
    this.midPrice,
    this.highPrice,
    this.marketPrice,
    this.directLowPrice,
    this.currencyCode = 'USD',
    this.sourceModifiedAt,
    this.capturedAt,
  });

  final String sourceType;
  final String sourceProductId;

  final double? lowPrice;
  final double? midPrice;
  final double? highPrice;
  final double? marketPrice;
  final double? directLowPrice;

  final String currencyCode;

  final DateTime? sourceModifiedAt;
  final DateTime? capturedAt;

  bool get hasPrice {
    return <double?>[
      lowPrice,
      midPrice,
      highPrice,
      marketPrice,
      directLowPrice,
    ].any((double? value) => value != null && value > 0);
  }

  double? get preferredValue {
    final List<double?> candidates = <double?>[
      marketPrice,
      midPrice,
      lowPrice,
      directLowPrice,
    ];

    for (final double? value in candidates) {
      if (value != null && value > 0) {
        return value;
      }
    }

    return null;
  }
}
