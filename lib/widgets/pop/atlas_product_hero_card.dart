import 'package:flutter/material.dart';

import '../../atlas/hero/models/atlas_hero_summary.dart';
import '../../models/pop.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../atlas/atlas_glass_card.dart';
import '../atlas/atlas_glass_panel.dart';
import '../atlas/components/atlas_chip.dart';
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
            child: _ProductImage(
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
          AtlasGlassPanel(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: AtlasColors.vaultGold,
                  size: 22,
                ),
                const SizedBox(width: AtlasSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Atlas says',
                        style: AtlasTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AtlasSpacing.xs),
                      Text(
                        heroSummary.summary,
                        style: AtlasTypography.bodySmall.copyWith(
                          color: AtlasColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
            _CompletionAction(
              prompt: completionPrompt,
              onPressed: onCompleteListing,
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
    return AtlasGlassPanel(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useVerticalLayout = constraints.maxWidth < 330;

          if (useVerticalLayout) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CurrentValueStat(
                  value: value,
                  trendPercent: trendPercent,
                  trendTimeframe: trendTimeframe,
                ),
                const SizedBox(height: AtlasSpacing.lg),
                _CollectorScoreStat(
                  score: score,
                  classification: classification,
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: _CurrentValueStat(
                  value: value,
                  trendPercent: trendPercent,
                  trendTimeframe: trendTimeframe,
                ),
              ),
              const SizedBox(width: AtlasSpacing.md),
              Expanded(
                flex: 4,
                child: _CollectorScoreStat(
                  score: score,
                  classification: classification,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CurrentValueStat extends StatelessWidget {
  const _CurrentValueStat({
    required this.value,
    required this.trendPercent,
    required this.trendTimeframe,
  });

  final double value;
  final double? trendPercent;
  final String trendTimeframe;

  @override
  Widget build(BuildContext context) {
    final hasValue = value > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CURRENT VALUE',
          style: AtlasTypography.bodySmall.copyWith(
            color: AtlasColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AtlasSpacing.sm),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AtlasSpacing.sm,
          runSpacing: AtlasSpacing.xs,
          children: [
            Text(
              hasValue
                  ? '\$${value.toStringAsFixed(2)}'
                  : 'Value needed',
              style: AtlasTypography.headingSmall.copyWith(
                color: AtlasColors.vaultGold,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (hasValue)
              _TrendLabel(
                trendPercent: trendPercent,
                timeframe: trendTimeframe,
              ),
          ],
        ),
      ],
    );
  }
}

class _TrendLabel extends StatelessWidget {
  const _TrendLabel({
    required this.trendPercent,
    required this.timeframe,
  });

  final double? trendPercent;
  final String timeframe;

  @override
  Widget build(BuildContext context) {
    final trend = trendPercent;

    if (trend == null) {
      return Text(
        '— No trend yet',
        style: AtlasTypography.bodySmall.copyWith(
          color: AtlasColors.textSecondary,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    final isPositive = trend > 0;
    final isNegative = trend < 0;

    final directionIcon = isPositive
        ? Icons.arrow_upward_rounded
        : isNegative
        ? Icons.arrow_downward_rounded
        : Icons.remove_rounded;

    final directionSymbol = isPositive
        ? '+'
        : '';

    final trendColor = isPositive
        ? Colors.greenAccent
        : isNegative
        ? Colors.redAccent
        : AtlasColors.textSecondary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          directionIcon,
          size: 16,
          color: trendColor,
        ),
        const SizedBox(width: 2),
        Text(
          '$directionSymbol${trend.toStringAsFixed(1)}% ($timeframe)',
          style: AtlasTypography.bodySmall.copyWith(
            color: trendColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _CollectorScoreStat extends StatelessWidget {
  const _CollectorScoreStat({
    required this.score,
    required this.classification,
  });

  final int score;
  final String classification;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'COLLECTOR SCORE',
          style: AtlasTypography.bodySmall.copyWith(
            color: AtlasColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AtlasSpacing.sm),
        Text(
          '$score / 100',
          style: AtlasTypography.headingSmall.copyWith(
            color: AtlasColors.vaultGold,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AtlasSpacing.xs),
        Text(
          classification,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AtlasTypography.bodySmall.copyWith(
            color: AtlasColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _CompletionAction extends StatelessWidget {
  const _CompletionAction({
    required this.prompt,
    required this.onPressed,
  });

  final _CompletionPrompt prompt;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AtlasSpacing.lg),
        child: AtlasGlassPanel(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.lightbulb_outline_rounded,
                color: AtlasColors.vaultGold,
              ),
              const SizedBox(width: AtlasSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complete Listing',
                      style: AtlasTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AtlasSpacing.xs),
                    Text(
                      '+ ${prompt.actionLabel}',
                      style: AtlasTypography.bodyMedium.copyWith(
                        color: AtlasColors.vaultGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AtlasSpacing.xs),
                    Text(
                      prompt.supportingText,
                      style: AtlasTypography.bodySmall.copyWith(
                        color: AtlasColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (onPressed != null)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: AtlasColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final cleanImageUrl = imageUrl.trim();

    return Container(
      width: 180,
      height: 220,
      decoration: BoxDecoration(
        color: AtlasColors.textSecondary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AtlasSpacing.lg),
        border: Border.all(
          color: AtlasColors.vaultGold.withValues(alpha: 0.28),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: cleanImageUrl.isEmpty
          ? const Icon(
        Icons.inventory_2_rounded,
        size: 72,
      )
          : Image.network(
        cleanImageUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }

          return const Center(
            child: SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.broken_image_rounded,
            size: 72,
          );
        },
      ),
    );
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