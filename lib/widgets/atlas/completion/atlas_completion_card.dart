import 'package:flutter/material.dart';

import 'package:funkovault2/atlas/completion/models/atlas_completion_item.dart';
import 'package:funkovault2/atlas/completion/models/atlas_completion_result.dart';
import 'package:funkovault2/theme/atlas_colors.dart';
import 'package:funkovault2/theme/atlas_spacing.dart';
import 'package:funkovault2/theme/atlas_symbols.dart';
import 'package:funkovault2/theme/atlas_typography.dart';
import 'package:funkovault2/widgets/atlas/atlas_glass_card.dart';
import '../components/atlas_insight_panel.dart';
import '../components/atlas_progress_bar.dart';
import '../components/atlas_section_header.dart';
import '../components/atlas_status_chip.dart';


class AtlasCompletionCard extends StatelessWidget {
  const AtlasCompletionCard({
    super.key,
    required this.result,
    this.title = 'Collector Progress',
    this.maxVisibleItemsPerSection = 3,
    this.showItemBreakdown = true,
    this.onTap,
  });

  final AtlasCompletionResult result;

  final String title;

  final int maxVisibleItemsPerSection;

  final bool showItemBreakdown;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      accentColor: _accentColor,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AtlasSectionHeader(
            title: title,
            subtitle: result.milestoneMessage,
            symbol: result.isComplete
                ? AtlasSymbols.achievement
                : AtlasSymbols.completion,
            accentColor: _accentColor,
            badge: AtlasStatusChip(
              label: result.formattedCompletion,
              accentColor: _accentColor,
              size: AtlasStatusChipSize.compact,
            ),
          ),
          const SizedBox(
            height: AtlasSpacing.lg,
          ),
          _CompletionProgress(
            result: result,
          ),
          if (result.isNotEmpty) ...[
            const SizedBox(
              height: AtlasSpacing.lg,
            ),
            AtlasInsightPanel(
              eyebrow: result.isComplete
                  ? 'Milestone'
                  : 'Next Goal',
              title: result.nextGoalLabel,
              message: result.isComplete
                  ? 'Every release in this catalog group is owned.'
                  : result.milestoneMessage,
              symbol: result.isComplete
                  ? AtlasSymbols.achievement
                  : AtlasSymbols.recommendation,
              tone: result.isComplete
                  ? AtlasInsightPanelTone.success
                  : AtlasInsightPanelTone.recommendation,
            ),
          ],
          if (showItemBreakdown &&
              result.isNotEmpty) ...[
            const SizedBox(
              height: AtlasSpacing.lg,
            ),
            const Divider(
              color: AtlasColors.divider,
              height: 1,
            ),
            const SizedBox(
              height: AtlasSpacing.lg,
            ),
            _CompletionBreakdown(
              result: result,
              maxVisibleItemsPerSection:
              maxVisibleItemsPerSection,
            ),
          ],
        ],
      ),
    );
  }

  Color get _accentColor {
    if (result.isComplete) {
      return AtlasColors.success;
    }

    if (result.completionPercent >= 75) {
      return AtlasColors.vaultGold;
    }

    return AtlasColors.intelligenceBlue;
  }
}

class _CompletionProgress extends StatelessWidget {
  const _CompletionProgress({
    required this.result,
  });

  final AtlasCompletionResult result;

  @override
  Widget build(BuildContext context) {
    final Color progressColor = result.isComplete
        ? AtlasColors.success
        : result.completionPercent >= 75
        ? AtlasColors.vaultGold
        : AtlasColors.intelligenceBlue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          result.formattedCompletion,
          style: AtlasTypography.headingLarge.copyWith(
            color: progressColor,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(
          height: AtlasSpacing.xs,
        ),
        Text(
          result.formattedReleaseProgress,
          style: AtlasTypography.headingSmall.copyWith(
            color: AtlasColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: AtlasSpacing.md,
        ),
        AtlasProgressBar(
          value: result.completionRatio,
          accentColor: progressColor,
          height: 10,
        ),
        const SizedBox(
          height: AtlasSpacing.md,
        ),
        Wrap(
          spacing: AtlasSpacing.sm,
          runSpacing: AtlasSpacing.sm,
          children: [
            AtlasStatusChip(
              label: '${result.ownedReleaseCount} Owned',
              symbol: AtlasSymbols.owned,
              accentColor: AtlasColors.success,
              size: AtlasStatusChipSize.compact,
            ),
            AtlasStatusChip(
              label: '${result.wishlistReleaseCount} Wishlist',
              symbol: AtlasSymbols.wishlist,
              accentColor: AtlasColors.warning,
              size: AtlasStatusChipSize.compact,
            ),
            AtlasStatusChip(
              label: '${result.missingReleaseCount} Missing',
              symbol: AtlasSymbols.missing,
              accentColor: AtlasColors.textSecondary,
              size: AtlasStatusChipSize.compact,
            ),
          ],
        ),
      ],
    );
  }
}

class _CompletionBreakdown
    extends StatelessWidget {
  const _CompletionBreakdown({
    required this.result,
    required this.maxVisibleItemsPerSection,
  });

  final AtlasCompletionResult result;

  final int maxVisibleItemsPerSection;

  @override
  Widget build(BuildContext context) {
    final int safeLimit =
    maxVisibleItemsPerSection < 1
        ? 1
        : maxVisibleItemsPerSection;

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        if (result.ownedItems.isNotEmpty)
          _CompletionSection(
            title: 'Owned',
            emoji: AtlasSymbols.owned,
            color: AtlasColors.success,
            items: result.ownedItems,
            maxVisibleItems: safeLimit,
          ),
        if (result.ownedItems.isNotEmpty &&
            (
                result.wishlistItems.isNotEmpty ||
                    result.missingItems.isNotEmpty
            ))
          const SizedBox(
            height: AtlasSpacing.lg,
          ),
        if (result.wishlistItems.isNotEmpty)
          _CompletionSection(
            title: 'Wishlist',
            emoji: AtlasSymbols.wishlist,
            color: AtlasColors.warning,
            items: result.wishlistItems,
            maxVisibleItems: safeLimit,
          ),
        if (result.wishlistItems.isNotEmpty &&
            result.missingItems.isNotEmpty)
          const SizedBox(
            height: AtlasSpacing.lg,
          ),
        if (result.missingItems.isNotEmpty)
          _CompletionSection(
            title: 'Missing',
            emoji: AtlasSymbols.missing,
            color: AtlasColors.textSecondary,
            items: result.missingItems,
            maxVisibleItems: safeLimit,
          ),
      ],
    );
  }
}

class _CompletionSection extends StatelessWidget {
  const _CompletionSection({
    required this.title,
    required this.emoji,
    required this.color,
    required this.items,
    required this.maxVisibleItems,
  });

  final String title;
  final String emoji;
  final Color color;
  final List<AtlasCompletionItem> items;
  final int maxVisibleItems;

  @override
  Widget build(BuildContext context) {
    final List<AtlasCompletionItem> visibleItems =
    items
        .take(
      maxVisibleItems,
    )
        .toList(
      growable: false,
    );

    final int remainingCount =
        items.length - visibleItems.length;

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              emoji,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
            const SizedBox(
              width: AtlasSpacing.sm,
            ),
            Expanded(
              child: Text(
                title,
                style: AtlasTypography
                    .headingSmall
                    .copyWith(
                  color: color,
                ),
              ),
            ),
            Text(
              '${items.length}',
              style: AtlasTypography.bodySmall
                  .copyWith(
                color:
                AtlasColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: AtlasSpacing.sm,
        ),
        for (final AtlasCompletionItem item
        in visibleItems)
          Padding(
            padding: const EdgeInsets.only(
              bottom: AtlasSpacing.sm,
            ),
            child: _CompletionReleaseRow(
              item: item,
              emoji: emoji,
              color: color,
            ),
          ),
        if (remainingCount > 0)
          Text(
            '+$remainingCount more release'
                '${remainingCount == 1 ? '' : 's'}',
            style: AtlasTypography.bodySmall
                .copyWith(
              color:
              AtlasColors.intelligenceBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}

class _CompletionReleaseRow extends StatelessWidget {
  const _CompletionReleaseRow({
    required this.item,
    required this.emoji,
    required this.color,
  });

  final AtlasCompletionItem item;
  final String emoji;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final String subtitle =
    _releaseSubtitle(
      item,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AtlasSpacing.md,
        vertical: AtlasSpacing.sm,
      ),
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(
          14,
        ),
        color: AtlasColors.surface
            .withValues(
          alpha: 0.55,
        ),
        border: Border.all(
          color: color.withValues(
            alpha: 0.20,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: const TextStyle(
              fontSize: 17,
            ),
          ),
          const SizedBox(
            width: AtlasSpacing.sm,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  item.displayName,
                  maxLines: 2,
                  overflow:
                  TextOverflow.ellipsis,
                  style: AtlasTypography
                      .bodyMedium
                      .copyWith(
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(
                    height: AtlasSpacing.xs,
                  ),
                  Text(
                    subtitle,
                    style: AtlasTypography
                        .bodySmall
                        .copyWith(
                      color: AtlasColors
                          .textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (item.isOwned &&
              item.ownedQuantity > 1) ...[
            const SizedBox(
              width: AtlasSpacing.sm,
            ),
            Text(
              'x${item.ownedQuantity}',
              style: AtlasTypography.bodySmall
                  .copyWith(
                color: AtlasColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _releaseSubtitle(
      AtlasCompletionItem item,
      ) {
    final List<String> parts =
    <String>[];

    final String number =
        item.productNumber?.trim() ?? '';

    final String variant =
        item.variantName?.trim() ?? '';

    if (number.isNotEmpty) {
      parts.add(
        '#$number',
      );
    }

    if (variant.isNotEmpty &&
        variant.toLowerCase() !=
            'common') {
      parts.add(
        variant,
      );
    }

    return parts.join(
      ' • ',
    );
  }
}