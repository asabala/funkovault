import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../atlas/atlas_glass_card.dart';
import '../atlas/components/atlas_section_header.dart';

class VaultBreakdownCard extends StatelessWidget {
  const VaultBreakdownCard({
    super.key,
    required this.ownedCount,
    required this.wishlistCount,
    required this.exclusiveCount,
    required this.variantCount,
    required this.stickerCount,
    required this.signedCount,
    required this.limitedCount,
    required this.needsValueCount,
    this.onTap,
  });

  final int ownedCount;
  final int wishlistCount;
  final int exclusiveCount;
  final int variantCount;
  final int stickerCount;
  final int signedCount;
  final int limitedCount;
  final int needsValueCount;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final List<_VaultBreakdownItem> items = <_VaultBreakdownItem>[
      _VaultBreakdownItem(
        label: 'Owned',
        value: ownedCount,
        icon: Icons.inventory_2_rounded,
      ),
      _VaultBreakdownItem(
        label: 'Wishlist',
        value: wishlistCount,
        icon: Icons.favorite_rounded,
      ),
      _VaultBreakdownItem(
        label: 'Exclusives',
        value: exclusiveCount,
        icon: Icons.workspace_premium_rounded,
      ),
      _VaultBreakdownItem(
        label: 'Variants',
        value: variantCount,
        icon: Icons.auto_awesome_rounded,
      ),
      _VaultBreakdownItem(
        label: 'Stickers',
        value: stickerCount,
        icon: Icons.local_offer_rounded,
      ),
      _VaultBreakdownItem(
        label: 'Signed',
        value: signedCount,
        icon: Icons.edit_rounded,
      ),
      _VaultBreakdownItem(
        label: 'Limited',
        value: limitedCount,
        icon: Icons.confirmation_number_rounded,
      ),
      _VaultBreakdownItem(
        label: 'Needs Value',
        value: needsValueCount,
        icon: Icons.attach_money_rounded,
      ),
    ];

    return AtlasGlassCard(
      accentColor: AtlasColors.vaultGold,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AtlasSectionHeader(
            title: 'Vault Breakdown',
            subtitle: 'Quick snapshot of what is inside your collection.',
            icon: Icons.dashboard_customize_rounded,
            accentColor: AtlasColors.vaultGold,
          ),
          const SizedBox(height: AtlasSpacing.lg),
          Wrap(
            spacing: AtlasSpacing.sm,
            runSpacing: AtlasSpacing.sm,
            children: items
                .map((_VaultBreakdownItem item) {
                  return _VaultBreakdownChip(item: item);
                })
                .toList(growable: false),
          ),
          if (onTap != null) ...[
            const SizedBox(height: AtlasSpacing.lg),
            Row(
              children: [
                const Icon(
                  Icons.visibility_rounded,
                  color: AtlasColors.vaultGold,
                  size: 18,
                ),
                const SizedBox(width: AtlasSpacing.sm),
                Expanded(
                  child: Text(
                    'Tap to review Entire Vault',
                    style: AtlasTypography.bodySmall.copyWith(
                      color: AtlasColors.vaultGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AtlasColors.vaultGold,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _VaultBreakdownChip extends StatelessWidget {
  const _VaultBreakdownChip({required this.item});

  final _VaultBreakdownItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(AtlasSpacing.md),
      decoration: BoxDecoration(
        color: AtlasColors.background.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AtlasColors.vaultGold.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: AtlasColors.vaultGold, size: 19),
          ),
          const SizedBox(width: AtlasSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.value.toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AtlasTypography.bodyMedium.copyWith(
                    color: AtlasColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AtlasTypography.bodySmall.copyWith(
                    color: AtlasColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VaultBreakdownItem {
  const _VaultBreakdownItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final int value;
  final IconData icon;
}
