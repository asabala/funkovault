import 'package:flutter/material.dart';

import '../../atlas/hero/models/atlas_hero_summary.dart';
import '../../models/pop.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../atlas/atlas_glass_card.dart';
import '../atlas/components/atlas_action_row.dart';
import '../atlas/components/atlas_chip.dart';
import '../atlas/components/atlas_insight_panel.dart';
import '../atlas/components/atlas_metric_panel.dart';
import '../atlas/components/atlas_product_image.dart';
import 'pop_identity_badges.dart';

class AtlasProductHeroCard extends StatelessWidget {
  const AtlasProductHeroCard({
    super.key,
    required this.pop,
    required this.heroSummary,
    this.trendPercent,
    this.trendTimeframe = '30d',
    this.onCompleteListing,
  });

  final Pop pop;
  final AtlasHeroSummary heroSummary;

  /// Leave null until Atlas has real historical market data.
  final double? trendPercent;

  /// Examples: 7d, 30d, 90d, 1y.
  final String trendTimeframe;

  /// Opens the edit flow for the highest-priority missing detail.
  final VoidCallback? onCompleteListing;

  @override
  Widget build(BuildContext context) {
    final numberLabel = pop.number.trim().isEmpty
        ? 'No number'
        : '#${pop.number.trim()}';

    final seriesLabel = pop.series.trim();

    final completionPrompt = _buildCompletionPrompt(pop);

    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroTopRow(
            pop: pop,
          ),
          const SizedBox(height: AtlasSpacing.lg),
          Center(
            child: AtlasProductImage(
              imageUrl: pop.imageUrl,
            ),
          ),
          const SizedBox(height: AtlasSpacing.lg),
          Text(
            pop.name,
            style: AtlasTypography.headingLarge,
          ),
          const SizedBox(height: AtlasSpacing.xs),
          Text(
            seriesLabel.isEmpty
                ? numberLabel
                : '$numberLabel • $seriesLabel',
            style: AtlasTypography.bodyMedium.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
          const SizedBox(height: AtlasSpacing.lg),
          _HeroMarketStats(
            value: pop.value,
            score: heroSummary.normalizedScore,
            classification: heroSummary.classification,
            trendPercent: trendPercent,
            trendTimeframe: trendTimeframe,
          ),
          const SizedBox(height: AtlasSpacing.lg),
          AtlasInsightPanel(
            eyebrow: 'Atlas',
            title: 'Collector Insight',
            message: heroSummary.summary,
            symbol: '🧠',
            tone: AtlasInsightPanelTone.intelligence,
          ),
          const SizedBox(height: AtlasSpacing.lg),
          Text(
            'Release Identity',
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AtlasSpacing.sm),
          PopIdentityBadges(
            pop: pop,
            showStandardBadge: true,
          ),
          if (completionPrompt != null) ...[
            const SizedBox(height: AtlasSpacing.lg),
            AtlasActionRow(
              title: 'Complete Listing',
              description:
              '${completionPrompt.actionLabel}. ${completionPrompt.supportingText}',
              icon: Icons.lightbulb_outline_rounded,
              accentColor: AtlasColors.vaultGold,
              onTap: onCompleteListing,
            ),
          ],
        ],
      ),
    );
  }
}

class _HeroTopRow extends StatelessWidget {
  const _HeroTopRow({
    required this.pop,
  });

  final Pop pop;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Wrap(
            spacing: AtlasSpacing.sm,
            runSpacing: AtlasSpacing.sm,
            children: _buildPrimaryIdentityChips(pop),
          ),
        ),
        const SizedBox(width: AtlasSpacing.sm),
        AtlasChip(
          label: pop.isWishlist
              ? 'Wishlist'
              : 'Owned: ${pop.quantity}',
          icon: pop.isWishlist
              ? Icons.favorite_rounded
              : Icons.inventory_2_rounded,
        ),
      ],
    );
  }
}

class _HeroMarketStats extends StatelessWidget {
  const _HeroMarketStats({
    required this.value,
    required this.score,
    required this.classification,
    required this.trendPercent,
    required this.trendTimeframe,
  });

  final double value;
  final int score;
  final String classification;
  final double? trendPercent;
  final String trendTimeframe;

  @override
  Widget build(BuildContext context) {
    final bool hasValue = value > 0;

    return LayoutBuilder(
      builder: (
          BuildContext context,
          BoxConstraints constraints,
          ) {
        final bool useVerticalLayout =
            constraints.maxWidth < 330;

        final AtlasMetricPanel valuePanel =
        AtlasMetricPanel(
          label: 'Current Value',
          value: hasValue
              ? '\$${value.toStringAsFixed(2)}'
              : 'Value needed',
          supportingText: _trendLabel(
            trendPercent: trendPercent,
            timeframe: trendTimeframe,
          ),
          icon: Icons.attach_money_rounded,
        );

        final AtlasMetricPanel scorePanel =
        AtlasMetricPanel(
          label: 'Collector Score',
          value: '$score / 100',
          supportingText: classification,
          icon: Icons.insights_rounded,
        );

        if (useVerticalLayout) {
          return Column(
            children: [
              valuePanel,
              const SizedBox(
                height: AtlasSpacing.md,
              ),
              scorePanel,
            ],
          );
        }

        return Row(
          crossAxisAlignment:
          CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: valuePanel,
            ),
            const SizedBox(
              width: AtlasSpacing.md,
            ),
            Expanded(
              child: scorePanel,
            ),
          ],
        );
      },
    );
  }

  String _trendLabel({
    required double? trendPercent,
    required String timeframe,
  }) {
    final double? trend = trendPercent;

    if (trend == null) {
      return 'No trend yet';
    }

    final String direction =
    trend > 0 ? '+' : '';

    return '$direction${trend.toStringAsFixed(1)}% ($timeframe)';
  }
}

List<Widget> _buildPrimaryIdentityChips(Pop pop) {
  final chips = <Widget>[];

  void addChip(String value, IconData icon) {
    final cleaned = value.trim();

    if (_isMeaningfulIdentityValue(cleaned)) {
      chips.add(
        AtlasChip(
          label: cleaned,
          icon: icon,
        ),
      );
    }
  }

  addChip(pop.variant, Icons.auto_awesome_rounded);
  addChip(pop.retailExclusive, Icons.storefront_outlined);
  addChip(pop.eventSticker, Icons.local_activity_outlined);
  addChip(pop.limitedEdition, Icons.numbers_rounded);

  if (_isMeaningfulSignature(pop.signature)) {
    chips.add(
      AtlasChip(
        label: pop.signature.trim(),
        icon: Icons.draw_outlined,
      ),
    );
  }

  if (chips.isEmpty) {
    chips.add(
      const AtlasChip(
        label: 'Standard Release',
        icon: Icons.inventory_2_outlined,
      ),
    );
  }

  return chips.take(3).toList();
}

bool _isMeaningfulIdentityValue(String value) {
  final normalized = value.trim().toLowerCase();

  if (normalized.isEmpty) {
    return false;
  }

  return normalized != 'none' &&
      normalized != 'common' &&
      normalized != 'standard' &&
      normalized != 'unsigned' &&
      normalized != 'not entered';
}

bool _isMeaningfulSignature(String value) {
  final normalized = value.trim().toLowerCase();

  return normalized.isNotEmpty &&
      normalized != 'none' &&
      normalized != 'unsigned' &&
      normalized != 'not entered';
}

_CompletionPrompt? _buildCompletionPrompt(Pop pop) {
  if (_isMissingDetail(pop.boxCondition)) {
    return const _CompletionPrompt(
      actionLabel: 'Add Box Condition',
      supportingText: 'Unlock a more accurate valuation.',
    );
  }

  if (_isMissingDetail(pop.itemCondition)) {
    return const _CompletionPrompt(
      actionLabel: 'Add Item Condition',
      supportingText: 'Improve valuation and collection accuracy.',
    );
  }

  if (pop.pricePaid <= 0) {
    return const _CompletionPrompt(
      actionLabel: 'Add Purchase Price',
      supportingText: 'Track profit, loss, and collection performance.',
    );
  }

  return null;
}

bool _isMissingDetail(String value) {
  final normalized = value.trim().toLowerCase();

  return normalized.isEmpty ||
      normalized == 'none' ||
      normalized == 'not entered' ||
      normalized == 'unknown';
}

class _CompletionPrompt {
  const _CompletionPrompt({
    required this.actionLabel,
    required this.supportingText,
  });

  final String actionLabel;
  final String supportingText;
}