// Describes the direction of a collectible's recent market movement.
enum MarketTrendDirection { rising, falling, stable, unknown }

// Identifies the confidence Atlas has in a market value estimate.
enum MarketValueConfidence { low, medium, high, verified, unknown }

// Immutable pricing snapshot returned for a collectible.
//
// This represents a value at a specific point in time. It should not
// be stored as permanent product identity data because prices change.
class MarketValueSnapshot {
  const MarketValueSnapshot({
    required this.currencyCode,
    required this.lastUpdated,
    this.estimatedValue,
    this.retailPrice,
    this.recentSaleLow,
    this.recentSaleHigh,
    this.lastSalePrice,
    this.trendPercentage,
    this.trendDirection = MarketTrendDirection.unknown,
    this.confidence = MarketValueConfidence.unknown,
    this.recentSalesCount = 0,
    this.sourceNames = const [],
  });

  final String currencyCode;

  final double? estimatedValue;

  final double? retailPrice;

  final double? recentSaleLow;

  final double? recentSaleHigh;

  final double? lastSalePrice;

  final double? trendPercentage;

  final MarketTrendDirection trendDirection;

  final MarketValueConfidence confidence;

  final int recentSalesCount;

  final DateTime lastUpdated;

  final List<String> sourceNames;

  bool get hasEstimatedValue => estimatedValue != null;

  bool get hasRetailPrice => retailPrice != null;

  bool get hasRecentRange {
    return recentSaleLow != null && recentSaleHigh != null;
  }

  bool get hasLastSale => lastSalePrice != null;

  bool get hasTrend => trendPercentage != null;

  bool get hasMarketEvidence {
    return hasEstimatedValue ||
        hasRecentRange ||
        hasLastSale ||
        recentSalesCount > 0;
  }

  bool get isStale {
    return DateTime.now().difference(lastUpdated).inDays > 30;
  }

  MarketValueSnapshot copyWith({
    String? currencyCode,
    double? estimatedValue,
    double? retailPrice,
    double? recentSaleLow,
    double? recentSaleHigh,
    double? lastSalePrice,
    double? trendPercentage,
    MarketTrendDirection? trendDirection,
    MarketValueConfidence? confidence,
    int? recentSalesCount,
    DateTime? lastUpdated,
    List<String>? sourceNames,
  }) {
    return MarketValueSnapshot(
      currencyCode: currencyCode ?? this.currencyCode,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      retailPrice: retailPrice ?? this.retailPrice,
      recentSaleLow: recentSaleLow ?? this.recentSaleLow,
      recentSaleHigh: recentSaleHigh ?? this.recentSaleHigh,
      lastSalePrice: lastSalePrice ?? this.lastSalePrice,
      trendPercentage: trendPercentage ?? this.trendPercentage,
      trendDirection: trendDirection ?? this.trendDirection,
      confidence: confidence ?? this.confidence,
      recentSalesCount: recentSalesCount ?? this.recentSalesCount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      sourceNames: sourceNames ?? this.sourceNames,
    );
  }
}
