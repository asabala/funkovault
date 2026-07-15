import 'package:flutter/material.dart';

import '../../../../models/pop.dart';
import '../../../../screens/pop/pop_details_screen.dart';
import '../../../../theme/atlas_colors.dart';
import '../../../../theme/atlas_spacing.dart';
import '../../../../theme/atlas_typography.dart';
import '../../atlas/atlas_glass_panel.dart';
import '../../../vault/utils/vault_display_utils.dart';
import '../../atlas/components/atlas_chip.dart';

class VaultPopTile extends StatelessWidget {
  const VaultPopTile({
    super.key,
    required this.pop,
    required this.showImage,
    this.onAddValue,
  });

  final Pop pop;
  final bool showImage;
  final VoidCallback? onAddValue;

  void _openDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PopDetailsScreen(
          pop: pop,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final numberLabel =
    pop.number.trim().isEmpty ? 'No #' : '#${pop.number}';

    final categoryLabel = pop.category.trim().isEmpty
        ? 'No category'
        : pop.category.trim();

    final seriesLabel =
    pop.series.trim().isEmpty ? 'No series' : pop.series.trim();

    final valueLabel = pop.value <= 0
        ? 'Value needed'
        : '\$${pop.value.toStringAsFixed(0)}';

    final addedLabel = formatVaultDateLabel(
      pop.dateAdded,
    );

    final updatedLabel = formatVaultDateLabel(
      pop.lastUpdated,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(
        AtlasSpacing.md,
      ),
      onTap: () => _openDetails(context),
      child: AtlasGlassPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showImage) ...[
              Center(
                child: VaultPopThumbnail(
                  imageUrl: pop.imageUrl,
                ),
              ),
              const SizedBox(
                height: AtlasSpacing.md,
              ),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!showImage) ...[
                  const Icon(
                    Icons.inventory_2_outlined,
                    color: AtlasColors.vaultGold,
                  ),
                  const SizedBox(
                    width: AtlasSpacing.md,
                  ),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        pop.name,
                        style:
                        AtlasTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: AtlasSpacing.xs,
                      ),
                      Text(
                        '$numberLabel • $categoryLabel',
                        style:
                        AtlasTypography.bodySmall.copyWith(
                          color:
                          AtlasColors.textSecondary,
                        ),
                      ),
                      const SizedBox(
                        height: AtlasSpacing.xs,
                      ),
                      Text(
                        seriesLabel,
                        style:
                        AtlasTypography.bodySmall.copyWith(
                          color:
                          AtlasColors.textSecondary,
                        ),
                      ),
                      const SizedBox(
                        height: AtlasSpacing.xs,
                      ),
                      VaultPopBadges(
                        pop: pop,
                      ),
                      const SizedBox(
                        height: AtlasSpacing.xs,
                      ),
                      Text(
                        'Added: $addedLabel • Updated: $updatedLabel',
                        style:
                        AtlasTypography.bodySmall.copyWith(
                          color:
                          AtlasColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: AtlasSpacing.md,
                ),
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.end,
                  children: [
                    Text(
                      valueLabel,
                      style:
                      AtlasTypography.bodySmall.copyWith(
                        color: pop.value <= 0
                            ? AtlasColors.textSecondary
                            : AtlasColors.vaultGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: AtlasSpacing.xs,
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AtlasColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
            if (pop.value <= 0 && onAddValue != null) ...[
              const SizedBox(
                height: AtlasSpacing.md,
              ),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onAddValue,
                  icon: const Icon(
                    Icons.attach_money_rounded,
                  ),
                  label: const Text(
                    'Add Value',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class VaultPopBadges extends StatelessWidget {
  const VaultPopBadges({
    super.key,
    required this.pop,
  });

  final Pop pop;

  @override
  Widget build(BuildContext context) {
    final badges = _buildBadges();

    if (badges.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: AtlasSpacing.xs,
      runSpacing: AtlasSpacing.xs,
      children: badges
          .map(
            (badge) => AtlasChip(
          label: badge,
          size: AtlasChipSize.compact,
        ),
      )
          .toList(),
    );
  }

  List<String> _buildBadges() {
    final badges = <String>[];

    if (pop.value <= 0) {
      badges.add('Needs Value');
    }

    if (pop.isWishlist) {
      badges.add('Wishlist');
    }

    if (hasMeaningfulVaultValue(pop.variant)) {
      badges.add(
        _cleanBadgeLabel(pop.variant),
      );
    }

    if (hasMeaningfulVaultValue(
      pop.retailExclusive,
    )) {
      badges.add('Exclusive');
    }

    if (hasMeaningfulVaultValue(
      pop.eventSticker,
    )) {
      badges.add('Sticker');
    }

    if (hasMeaningfulVaultValue(
      pop.limitedEdition,
    )) {
      badges.add('Limited');
    }

    if (hasMeaningfulVaultValue(
      pop.signature,
    )) {
      badges.add('Signed');
    }

    return badges;
  }

  String _cleanBadgeLabel(String value) {
    final cleaned = value.trim();

    if (cleaned.length <= 16) {
      return cleaned;
    }

    return '${cleaned.substring(0, 16)}...';
  }
}

class VaultPopThumbnail extends StatelessWidget {
  const VaultPopThumbnail({
    super.key,
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final cleanImageUrl = imageUrl.trim();

    return Container(
      width: 54,
      height: 68,
      decoration: BoxDecoration(
        color: AtlasColors.textSecondary.withValues(
          alpha: 0.06,
        ),
        borderRadius: BorderRadius.circular(
          AtlasSpacing.sm,
        ),
        border: Border.all(
          color: AtlasColors.vaultGold.withValues(
            alpha: 0.28,
          ),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: cleanImageUrl.isEmpty
          ? const Icon(
        Icons.inventory_2_rounded,
        size: 28,
      )
          : Image.network(
        cleanImageUrl,
        fit: BoxFit.contain,
        loadingBuilder: (
            context,
            child,
            loadingProgress,
            ) {
          if (loadingProgress == null) {
            return child;
          }

          return const Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (
            context,
            error,
            stackTrace,
            ) {
          return const Icon(
            Icons.broken_image_rounded,
            size: 28,
          );
        },
      ),
    );
  }
}