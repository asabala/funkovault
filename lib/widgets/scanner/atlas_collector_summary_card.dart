import 'package:flutter/material.dart';

import 'package:funkovault2/widgets/atlas/atlas_intelligence_feed.dart';
import 'package:funkovault2/atlas/intelligence/models/atlas_collector_summary.dart';
import 'package:funkovault2/theme/atlas_colors.dart';
import 'package:funkovault2/theme/atlas_spacing.dart';
import 'package:funkovault2/theme/atlas_typography.dart';
import 'package:funkovault2/widgets/atlas/atlas_glass_card.dart';
import 'package:funkovault2/widgets/atlas/atlas_glass_panel.dart';
import 'package:funkovault2/widgets/atlas/atlas_product_image.dart';
import 'package:funkovault2/widgets/identity/atlas_identity_badge.dart';

class AtlasCollectorSummaryCard extends StatelessWidget {
  const AtlasCollectorSummaryCard({
    required this.summary,
    required this.imageUrl,
    super.key,
  });

  final AtlasCollectorSummary summary;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      accentColor: AtlasColors.vaultGold,
      padding: const EdgeInsets.all(
        AtlasSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SummaryTopRow(
            summary: summary,
          ),
          const SizedBox(
            height: AtlasSpacing.sm,
          ),
          AtlasProductImage(
            imageUrl: imageUrl,
            height: 195,
          ),
          const SizedBox(
            height: AtlasSpacing.sm,
          ),
          _ProductIdentitySection(
            summary: summary,
          ),
          const SizedBox(
            height: AtlasSpacing.lg,
          ),
          _MarketValuePanel(
            summary: summary,
          ),
          const SizedBox(
            height: AtlasSpacing.md,
          ),
          _CollectionScopePanel(
            summary: summary,
          ),
          const SizedBox(
            height: AtlasSpacing.lg,
          ),

          AtlasIntelligenceFeed(
            recommendations: summary.recommendations,
            maxVisibleRecommendations: 3,
          ),
        ],
      ),
    );
  }
}

class _SummaryTopRow extends StatelessWidget {
  const _SummaryTopRow({
    required this.summary,
  });

  final AtlasCollectorSummary summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '🧠 Collector Summary',
            style: AtlasTypography.headingSmall,
          ),
        ),
        _StatusBadge(
          icon: summary.isOwned
              ? Icons.verified_rounded
              : Icons.add_box_outlined,
          label: summary.formattedOwnership,
          accentColor: summary.isOwned
              ? AtlasColors.success
              : AtlasColors.intelligenceBlue,
        ),
      ],
    );
  }
}

class _ProductIdentitySection extends StatelessWidget {
  const _ProductIdentitySection({
    required this.summary,
  });

  final AtlasCollectorSummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          summary.productName,
          style: AtlasTypography.headingLarge,
          textAlign: TextAlign.center,
        ),
        if (summary.productNumber.isNotEmpty) ...[
          const SizedBox(
            height: AtlasSpacing.xs,
          ),
          Text(
            '#${summary.productNumber}',
            style: AtlasTypography.headingSmall.copyWith(
              color: AtlasColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(
          height: AtlasSpacing.md,
        ),
        if (summary.hasIdentityBadges)
          Wrap(
            spacing: AtlasSpacing.sm,
            runSpacing: AtlasSpacing.sm,
            alignment: WrapAlignment.center,
            children: [
              for (final badge in summary.identityBadges)
                AtlasIdentityBadge(
                  badge: badge,
                ),
            ],
          )
        else
          _StatusBadge(
            icon: Icons.auto_awesome_rounded,
            label: summary.variantLabel.trim().isEmpty
                ? 'Common'
                : summary.variantLabel,
            accentColor: AtlasColors.vaultGold,
          ),
      ],
    );
  }
}

class _MarketValuePanel extends StatelessWidget {
  const _MarketValuePanel({
    required this.summary,
  });

  final AtlasCollectorSummary summary;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassPanel(
      accentColor: AtlasColors.vaultGold,
      padding: const EdgeInsets.all(
        AtlasSpacing.lg,
      ),
      child: Column(
        children: [
          Text(
            '💰 ESTIMATED MARKET VALUE',
            style: AtlasTypography.label.copyWith(
              color: AtlasColors.vaultGold,
              letterSpacing: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: AtlasSpacing.sm,
          ),
          Text(
            summary.formattedMarketValue,
            style: AtlasTypography.metricLarge.copyWith(
              color: summary.hasMarketValue
                  ? AtlasColors.textPrimary
                  : AtlasColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: AtlasSpacing.sm,
          ),
          _TrendSection(
            summary: summary,
          ),
        ],
      ),
    );
  }
}

class _TrendSection extends StatelessWidget {
  const _TrendSection({
    required this.summary,
  });

  final AtlasCollectorSummary summary;

  @override
  Widget build(BuildContext context) {
    final double? trend = summary.trendPercent;

    final IconData icon;
    final Color accentColor;
    final String heading;

    if (trend == null || !trend.isFinite) {
      icon = Icons.horizontal_rule_rounded;
      accentColor = AtlasColors.textSecondary;
      heading = '📊 No Market Trend Yet';
    } else if (trend > 0) {
      icon = Icons.trending_up_rounded;
      accentColor = AtlasColors.success;
      heading = '📈 Trending Up';
    } else if (trend < 0) {
      icon = Icons.trending_down_rounded;
      accentColor = AtlasColors.danger;
      heading = '📉 Trending Down';
    } else {
      icon = Icons.trending_flat_rounded;
      accentColor = AtlasColors.textSecondary;
      heading = '➖ Market Stable';
    }

    return Column(
      children: [
        _StatusBadge(
          icon: icon,
          label: summary.formattedTrend,
          accentColor: accentColor,
        ),
        const SizedBox(
          height: AtlasSpacing.sm,
        ),
        Text(
          heading,
          style: AtlasTypography.bodySmall.copyWith(
            color: accentColor,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: AtlasSpacing.xs,
        ),
        Text(
          summary.trendDescription,
          style: AtlasTypography.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _CollectionScopePanel extends StatelessWidget {
  const _CollectionScopePanel({
    required this.summary,
  });

  final AtlasCollectorSummary summary;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassPanel(
      accentColor: summary.isOwned
          ? AtlasColors.success
          : AtlasColors.intelligenceBlue,
      padding: const EdgeInsets.all(
        AtlasSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📦 YOUR COLLECTION',
            style: AtlasTypography.label.copyWith(
              color: summary.isOwned
                  ? AtlasColors.success
                  : AtlasColors.intelligenceBlue,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(
            height: AtlasSpacing.md,
          ),
          Wrap(
            spacing: AtlasSpacing.sm,
            runSpacing: AtlasSpacing.sm,
            children: [
              _StatusBadge(
                icon: summary.isOwned
                    ? Icons.verified_rounded
                    : Icons.inventory_2_outlined,
                label: summary.isOwned
                    ? 'Owned: ${summary.formattedOwnership}'
                    : 'Not owned',
                accentColor: summary.isOwned
                    ? AtlasColors.success
                    : AtlasColors.textSecondary,
              ),
              _StatusBadge(
                icon: Icons.collections_bookmark_outlined,
                label: 'In collection: ${summary.collectionName}',
                accentColor: AtlasColors.intelligenceBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.icon,
    required this.label,
    required this.accentColor,
  });

  final IconData icon;
  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AtlasSpacing.md,
        vertical: AtlasSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: accentColor.withValues(
          alpha: 0.12,
        ),
        borderRadius: BorderRadius.circular(
          999,
        ),
        border: Border.all(
          color: accentColor.withValues(
            alpha: 0.32,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 17,
            color: accentColor,
          ),
          const SizedBox(
            width: AtlasSpacing.sm,
          ),
          Flexible(
            child: Text(
              label,
              style: AtlasTypography.bodySmall.copyWith(
                color: AtlasColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}