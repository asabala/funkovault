import 'package:funkovault2/atlas/collection/models/atlas_collector_state.dart';
import 'package:funkovault2/atlas/intelligence/models/atlas_collector_recommendation.dart';
import 'package:funkovault2/models/pop.dart';

class AtlasCollectorRecommendationEngine {
  const AtlasCollectorRecommendationEngine();

  /// Backward-compatible primary recommendation.
  AtlasCollectorRecommendation build({
    required Pop product,
    required AtlasCollectorState collectorState,
    required double? marketValue,
    required double? trendPercent,
  }) {
    return buildAll(
      product: product,
      collectorState: collectorState,
      marketValue: marketValue,
      trendPercent: trendPercent,
    ).first;
  }

  /// Produces every relevant recommendation, ordered by priority.
  List<AtlasCollectorRecommendation> buildAll({
    required Pop product,
    required AtlasCollectorState collectorState,
    required double? marketValue,
    required double? trendPercent,
  }) {
    final List<AtlasCollectorRecommendation> recommendations =
    <AtlasCollectorRecommendation>[];

    _addOwnershipRecommendation(
      recommendations: recommendations,
      collectorState: collectorState,
      trendPercent: trendPercent,
    );

    _addVariantRecommendation(
      recommendations: recommendations,
      collectorState: collectorState,
    );

    _addMarketRecommendation(
      recommendations: recommendations,
      marketValue: marketValue,
      trendPercent: trendPercent,
    );

    _addWishlistRecommendation(
      recommendations: recommendations,
      collectorState: collectorState,
    );

    _addIdentityRecommendation(
      recommendations: recommendations,
      product: product,
      collectorState: collectorState,
    );

    if (recommendations.isEmpty) {
      recommendations.add(
        const AtlasCollectorRecommendation(
          type: AtlasCollectorRecommendationType.newToVault,
          category:
          AtlasCollectorRecommendationCategory.collection,
          severity:
          AtlasCollectorRecommendationSeverity.informational,
          title: '🆕 New to Vault',
          message:
          'This exact release was not found in your selected Vault. Review its market value and condition before buying.',
          priority: 50,
        ),
      );
    }

    final Map<String, AtlasCollectorRecommendation> recommendationsByKey =
    <String, AtlasCollectorRecommendation>{};

    for (final AtlasCollectorRecommendation recommendation
    in recommendations) {
      final String key =
          '${recommendation.type.name}|${recommendation.title.trim().toLowerCase()}';

      final AtlasCollectorRecommendation? existing =
      recommendationsByKey[key];

      if (existing == null ||
          recommendation.priority < existing.priority) {
        recommendationsByKey[key] = recommendation;
      }
    }

    final List<AtlasCollectorRecommendation> sortedRecommendations =
    recommendationsByKey.values.toList(
      growable: false,
    );

    sortedRecommendations.sort(
          (
          AtlasCollectorRecommendation first,
          AtlasCollectorRecommendation second,
          ) {
        final int priorityComparison =
        first.priority.compareTo(
          second.priority,
        );

        if (priorityComparison != 0) {
          return priorityComparison;
        }

        return first.title.compareTo(
          second.title,
        );
      },
    );

    return List<AtlasCollectorRecommendation>.unmodifiable(
      sortedRecommendations,
    );
  }

  void _addOwnershipRecommendation({
    required List<AtlasCollectorRecommendation> recommendations,
    required AtlasCollectorState collectorState,
    required double? trendPercent,
  }) {
    if (!collectorState.isOwned) {
      return;
    }

    final List<String> details = <String>[
      collectorState.ownedQuantity == 1
          ? 'You currently own 1 copy.'
          : 'You currently own ${collectorState.ownedQuantity} copies.',
    ];

    if (collectorState.isWishlisted) {
      details.add(
        'This release is also on your Wishlist.',
      );
    }

    if (_isTrendingUp(trendPercent)) {
      details.add(
        'The recorded value is trending upward.',
      );
    }

    recommendations.add(
      AtlasCollectorRecommendation(
        type: AtlasCollectorRecommendationType.alreadyOwned,
        category:
        AtlasCollectorRecommendationCategory.ownership,
        severity:
        AtlasCollectorRecommendationSeverity.informational,
        title: '✅ Already Owned',
        message:
        'This exact release is already saved in your selected Vault. Only buy another for an additional copy, trade inventory, or condition upgrade.',
        priority: 10,
        details: List<String>.unmodifiable(
          details,
        ),
      ),
    );
  }

  void _addVariantRecommendation({
    required List<AtlasCollectorRecommendation> recommendations,
    required AtlasCollectorState collectorState,
  }) {
    if (collectorState.isOwned ||
        !collectorState.hasRelatedMatches) {
      return;
    }

    recommendations.add(
      const AtlasCollectorRecommendation(
        type: AtlasCollectorRecommendationType.reviewVariant,
        category:
        AtlasCollectorRecommendationCategory.variant,
        severity:
        AtlasCollectorRecommendationSeverity.caution,
        title: '⚠️ Review Variant',
        message:
        'Atlas found a related release. Confirm that this is not a different sticker, finish, exclusive, signature, or package version.',
        priority: 15,
        details: <String>[
          'Compare the variant and finish.',
          'Compare retailer and convention stickers.',
          'Confirm limited-edition and signature details.',
          'Review the packaging and box version.',
        ],
      ),
    );
  }

  void _addMarketRecommendation({
    required List<AtlasCollectorRecommendation> recommendations,
    required double? marketValue,
    required double? trendPercent,
  }) {
    final bool hasMarketValue =
        marketValue != null &&
            marketValue.isFinite &&
            marketValue > 0;

    if (!hasMarketValue) {
      recommendations.add(
        const AtlasCollectorRecommendation(
          type:
          AtlasCollectorRecommendationType.marketValueUnavailable,
          category:
          AtlasCollectorRecommendationCategory.market,
          severity:
          AtlasCollectorRecommendationSeverity.caution,
          title: '💰 Market Value Unavailable',
          message:
          'Atlas does not yet have enough pricing evidence to evaluate this purchase confidently.',
          priority: 40,
          details: <String>[
            'Review recent completed sales.',
            'Confirm the exact sticker and variant.',
            'Consider item and box condition.',
          ],
        ),
      );

      return;
    }

    if (_isTrendingUp(trendPercent)) {
      recommendations.add(
        AtlasCollectorRecommendation(
          type: AtlasCollectorRecommendationType.newToVault,
          category:
          AtlasCollectorRecommendationCategory.market,
          severity:
          AtlasCollectorRecommendationSeverity.positive,
          title: '📈 Market Trending Up',
          message:
          'The recorded value is rising. Confirm the price and condition before the market moves further.',
          priority: 30,
          details: <String>[
            'Current recorded value: \$${marketValue.toStringAsFixed(2)}.',
            'Trend: +${trendPercent!.toStringAsFixed(1)}%.',
          ],
        ),
      );

      return;
    }

    if (_isTrendingDown(trendPercent)) {
      recommendations.add(
        AtlasCollectorRecommendation(
          type: AtlasCollectorRecommendationType.newToVault,
          category:
          AtlasCollectorRecommendationCategory.market,
          severity:
          AtlasCollectorRecommendationSeverity.caution,
          title: '📉 Market Trending Down',
          message:
          'The recorded value is declining. Waiting may produce a better buying opportunity.',
          priority: 35,
          details: <String>[
            'Current recorded value: \$${marketValue.toStringAsFixed(2)}.',
            'Trend: ${trendPercent!.toStringAsFixed(1)}%.',
          ],
        ),
      );
    }
  }

  void _addWishlistRecommendation({
    required List<AtlasCollectorRecommendation> recommendations,
    required AtlasCollectorState collectorState,
  }) {
    if (collectorState.isOwned ||
        !collectorState.isWishlisted) {
      return;
    }

    recommendations.add(
      const AtlasCollectorRecommendation(
        type: AtlasCollectorRecommendationType.newToVault,
        category:
        AtlasCollectorRecommendationCategory.wishlist,
        severity:
        AtlasCollectorRecommendationSeverity.positive,
        title: '❤️ Wishlist Opportunity',
        message:
        'This release is on your Wishlist and is not currently owned. Review the price and condition before adding it to your Vault.',
        priority: 20,
      ),
    );
  }

  void _addIdentityRecommendation({
    required List<AtlasCollectorRecommendation> recommendations,
    required Pop product,
    required AtlasCollectorState collectorState,
  }) {
    if (collectorState.isOwned ||
        collectorState.hasRelatedMatches ||
        collectorState.isWishlisted) {
      return;
    }

    final String collectorLabel =
    product.collectorLabel.trim();

    final bool hasSpecialIdentity =
        collectorLabel.isNotEmpty &&
            collectorLabel.toLowerCase() != 'common';

    recommendations.add(
      AtlasCollectorRecommendation(
        type: AtlasCollectorRecommendationType.newToVault,
        category:
        AtlasCollectorRecommendationCategory.identity,
        severity:
        AtlasCollectorRecommendationSeverity.positive,
        title: hasSpecialIdentity
            ? '⭐ New Special Release'
            : '🆕 New to Vault',
        message: hasSpecialIdentity
            ? 'This exact release is not currently in your Vault. Confirm its special identity and condition before buying.'
            : 'This exact release was not found in your selected Vault. Review the market value and condition before buying.',
        priority: 25,
        details: hasSpecialIdentity
            ? <String>[
          'Identity: $collectorLabel',
        ]
            : const <String>[],
      ),
    );
  }

  bool _isTrendingUp(
      double? trendPercent,
      ) {
    return trendPercent != null &&
        trendPercent.isFinite &&
        trendPercent > 0;
  }

  bool _isTrendingDown(
      double? trendPercent,
      ) {
    return trendPercent != null &&
        trendPercent.isFinite &&
        trendPercent < 0;
  }
}