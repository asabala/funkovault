import 'package:funkovault2/atlas/collection/models/atlas_collector_state.dart';
import 'package:funkovault2/atlas/identity/pop/pop_identity_engine.dart';
import 'package:funkovault2/atlas/identity/pop/pop_identity_rule.dart';
import 'package:funkovault2/atlas/intelligence/engines/atlas_collector_recommendation_engine.dart';
import 'package:funkovault2/atlas/intelligence/models/atlas_collector_recommendation.dart';
import 'package:funkovault2/models/pop.dart';

final class AtlasCollectorSummary {
  const AtlasCollectorSummary({
    required this.productName,
    required this.productNumber,
    required this.variantLabel,
    required this.identityBadges,
    required this.marketValue,
    required this.trendPercent,
    required this.ownedQuantity,
    required this.collectionName,
    required this.recommendation,
    required this.recommendations,
  });

  final String productName;
  final String productNumber;
  final String variantLabel;

  final List<PopIdentityBadgeData> identityBadges;

  final double? marketValue;
  final double? trendPercent;

  final int ownedQuantity;
  final String collectionName;

  final AtlasCollectorRecommendation recommendation;
  final List<AtlasCollectorRecommendation> recommendations;

  bool get hasRecommendations {
    return recommendations.isNotEmpty;
  }

  int get recommendationCount {
    return recommendations.length;
  }

  AtlasCollectorRecommendationType get recommendationType {
    return recommendation.type;
  }

  String get recommendationTitle {
    return recommendation.title;
  }

  String get recommendationMessage {
    return recommendation.message;
  }

  bool get hasIdentityBadges {
    return identityBadges.isNotEmpty;
  }

  bool get hasMarketValue {
    return marketValue != null && marketValue! > 0;
  }

  bool get hasTrend {
    return trendPercent != null && trendPercent!.isFinite;
  }

  bool get isOwned {
    return ownedQuantity > 0;
  }

  String get formattedMarketValue {
    if (!hasMarketValue) {
      return 'Not available';
    }

    return '\$${marketValue!.toStringAsFixed(2)}';
  }

  String get formattedTrend {
    final double? trend = trendPercent;

    if (trend == null || !trend.isFinite) {
      return 'No trend data yet';
    }

    final String direction;

    if (trend > 0) {
      direction = '▲';
    } else if (trend < 0) {
      direction = '▼';
    } else {
      direction = '—';
    }

    final String sign = trend > 0 ? '+' : '';

    return '$direction $sign${trend.toStringAsFixed(1)}%';
  }

  String get trendDescription {
    final double? trend = trendPercent;

    if (trend == null || !trend.isFinite) {
      return 'Market history will appear when more values are recorded.';
    }

    if (trend > 0) {
      return 'Value is trending upward.';
    }

    if (trend < 0) {
      return 'Value is trending downward.';
    }

    return 'Value is currently stable.';
  }

  String get formattedOwnership {
    if (ownedQuantity <= 0) {
      return 'Not owned';
    }

    if (ownedQuantity == 1) {
      return '1 copy';
    }

    return '$ownedQuantity copies';
  }

  factory AtlasCollectorSummary.build({
    required Pop product,
    required List<Pop> exactMatches,
    required List<Pop> relatedMatches,
    required String collectionName,
    bool isWishlisted = false,
  }) {
    final AtlasCollectorState collectorState = AtlasCollectorState(
      ownedMatches: exactMatches,
      wishlistMatches: const <Pop>[],
      relatedMatches: relatedMatches,
      isOwnedWishlisted: isWishlisted,
    );

    return AtlasCollectorSummary.buildFromState(
      product: product,
      collectorState: collectorState,
      collectionName: collectionName,
    );
  }

  factory AtlasCollectorSummary.buildFromState({
    required Pop product,
    required AtlasCollectorState collectorState,
    required String collectionName,
  }) {
    const PopIdentityEngine identityEngine = PopIdentityEngine();

    const AtlasCollectorRecommendationEngine recommendationEngine =
        AtlasCollectorRecommendationEngine();

    final List<PopIdentityBadgeData> identityBadges = identityEngine
        .buildBadges(product);

    final double? marketValue = _resolveMarketValue(
      product: product,
      exactMatches: collectorState.ownedMatches,
    );

    final double? trendPercent = _resolveTrendPercent(
      product: product,
      exactMatches: collectorState.ownedMatches,
    );

    final List<AtlasCollectorRecommendation> recommendations =
        recommendationEngine.buildAll(
          product: product,
          collectorState: collectorState,
          marketValue: marketValue,
          trendPercent: trendPercent,
        );

    final AtlasCollectorRecommendation recommendation = recommendations.first;

    return AtlasCollectorSummary(
      productName: product.name.trim().isEmpty
          ? 'Unknown Collectible'
          : product.name.trim(),
      productNumber: product.number.trim(),
      variantLabel: product.collectorLabel,
      identityBadges: List<PopIdentityBadgeData>.unmodifiable(identityBadges),
      marketValue: marketValue,
      trendPercent: trendPercent,
      ownedQuantity: collectorState.ownedQuantity,
      collectionName: collectionName.trim().isEmpty
          ? 'Selected Collection'
          : collectionName.trim(),
      recommendation: recommendation,
      recommendations: recommendations,
    );
  }

  static double? _resolveMarketValue({
    required Pop product,
    required List<Pop> exactMatches,
  }) {
    if (product.value > 0) {
      return product.value;
    }

    for (final Pop match in exactMatches) {
      if (match.value > 0) {
        return match.value;
      }
    }

    final List<double> historyValues = product.valueHistory
        .map((entry) => entry.value)
        .where((double value) => value > 0)
        .toList(growable: false);

    if (historyValues.isEmpty) {
      return null;
    }

    return historyValues.last;
  }

  static double? _resolveTrendPercent({
    required Pop product,
    required List<Pop> exactMatches,
  }) {
    final Pop trendSource = _bestTrendSource(
      product: product,
      exactMatches: exactMatches,
    );

    final history = trendSource.valueHistory
        .where((entry) => entry.value > 0)
        .toList();

    if (history.length < 2) {
      return null;
    }

    history.sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

    final double previousValue = history[history.length - 2].value;

    final double currentValue = history.last.value;

    if (previousValue <= 0) {
      return null;
    }

    return ((currentValue - previousValue) / previousValue) * 100;
  }

  static Pop _bestTrendSource({
    required Pop product,
    required List<Pop> exactMatches,
  }) {
    Pop bestSource = product;

    for (final Pop match in exactMatches) {
      if (match.valueHistory.length > bestSource.valueHistory.length) {
        bestSource = match;
      }
    }

    return bestSource;
  }
}
