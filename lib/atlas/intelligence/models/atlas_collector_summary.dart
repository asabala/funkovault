import 'package:funkovault2/models/pop.dart';

final class AtlasCollectorSummary {
  const AtlasCollectorSummary({
    required this.productName,
    required this.productNumber,
    required this.variantLabel,
    required this.marketValue,
    required this.trendPercent,
    required this.ownedQuantity,
    required this.collectionName,
    required this.recommendation,
    required this.recommendationMessage,
  });

  final String productName;
  final String productNumber;
  final String variantLabel;

  final double? marketValue;
  final double? trendPercent;

  final int ownedQuantity;
  final String collectionName;

  final String recommendation;
  final String recommendationMessage;

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
      return 'Not enough history';
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
  }) {
    final int ownedQuantity = exactMatches.fold<int>(
      0,
          (int total, Pop pop) {
        return total + pop.quantity;
      },
    );

    final double? marketValue = _resolveMarketValue(
      product: product,
      exactMatches: exactMatches,
    );

    final double? trendPercent = _resolveTrendPercent(
      product: product,
      exactMatches: exactMatches,
    );

    final _CollectorRecommendation recommendation =
    _buildRecommendation(
      ownedQuantity: ownedQuantity,
      hasRelatedMatches: relatedMatches.isNotEmpty,
      hasMarketValue: marketValue != null && marketValue > 0,
    );

    return AtlasCollectorSummary(
      productName: product.name.trim().isEmpty
          ? 'Unknown Collectible'
          : product.name.trim(),
      productNumber: product.number.trim(),
      variantLabel: product.collectorLabel,
      marketValue: marketValue,
      trendPercent: trendPercent,
      ownedQuantity: ownedQuantity,
      collectionName: collectionName.trim().isEmpty
          ? 'Selected Collection'
          : collectionName.trim(),
      recommendation: recommendation.title,
      recommendationMessage: recommendation.message,
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
        .map(
          (entry) => entry.value,
    )
        .where(
          (double value) => value > 0,
    )
        .toList(
      growable: false,
    );

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
        .where(
          (entry) => entry.value > 0,
    )
        .toList();

    if (history.length < 2) {
      return null;
    }

    history.sort(
          (a, b) => a.recordedAt.compareTo(
        b.recordedAt,
      ),
    );

    final double previousValue =
        history[history.length - 2].value;

    final double currentValue =
        history.last.value;

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
      if (match.valueHistory.length >
          bestSource.valueHistory.length) {
        bestSource = match;
      }
    }

    return bestSource;
  }

  static _CollectorRecommendation _buildRecommendation({
    required int ownedQuantity,
    required bool hasRelatedMatches,
    required bool hasMarketValue,
  }) {
    if (ownedQuantity > 0) {
      return const _CollectorRecommendation(
        title: 'Already Owned',
        message:
        'This exact release is already saved in your selected Vault.',
      );
    }

    if (hasRelatedMatches) {
      return const _CollectorRecommendation(
        title: 'Review Variant',
        message:
        'Atlas found a related release. Confirm the sticker, finish, exclusive, and packaging details before adding it.',
      );
    }

    if (!hasMarketValue) {
      return const _CollectorRecommendation(
        title: 'Market Value Unavailable',
        message:
        'Atlas identified the product, but it does not yet have enough pricing evidence to evaluate the purchase.',
      );
    }

    return const _CollectorRecommendation(
      title: 'New to Vault',
      message:
      'This exact release was not found in your selected Vault. Review the market value and condition before buying.',
    );
  }
}

final class _CollectorRecommendation {
  const _CollectorRecommendation({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;
}