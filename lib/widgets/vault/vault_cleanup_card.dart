import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../atlas/atlas_glass_card.dart';
import '../atlas/components/atlas_action_row.dart';
import '../atlas/components/atlas_empty_state.dart';
import '../atlas/components/atlas_section_header.dart';
import '../atlas/components/atlas_status_chip.dart';

class VaultCleanupCard extends StatelessWidget {
  const VaultCleanupCard({
    super.key,
    required this.needsValueCount,
    required this.duplicateGroupCount,
    required this.wishlistCount,
    required this.variantCount,
    required this.exclusiveCount,
    required this.signedCount,
    required this.limitedCount,
    required this.stickerCount,
    this.onReviewVault,
    this.onCleanupItemTap,
  });

  final int needsValueCount;
  final int duplicateGroupCount;
  final int wishlistCount;
  final int variantCount;
  final int exclusiveCount;
  final int signedCount;
  final int limitedCount;
  final int stickerCount;
  final VoidCallback? onReviewVault;
  final ValueChanged<String>? onCleanupItemTap;

  @override
  Widget build(BuildContext context) {
    final items = [
      _VaultCleanupItem(
        key: 'needsValue',
        label: 'Needs Value',
        count: needsValueCount,
        icon: Icons.attach_money_rounded,
        message: 'Add missing values so Atlas can calculate your vault better.',
      ),
      _VaultCleanupItem(
        key: 'duplicates',
        label: 'Possible Duplicates',
        count: duplicateGroupCount,
        icon: Icons.content_copy_rounded,
        message:
            'Review possible duplicate or variant groups before making changes.',
      ),
      _VaultCleanupItem(
        key: 'wishlist',
        label: 'Wishlist Items',
        count: wishlistCount,
        icon: Icons.favorite_rounded,
        message: 'Review wishlist items and decide what belongs in the vault.',
      ),
      _VaultCleanupItem(
        key: 'variants',
        label: 'Variants',
        count: variantCount,
        icon: Icons.auto_awesome_rounded,
        message:
            'Confirm variants so common, chase, glow, and special editions stay accurate.',
      ),
      _VaultCleanupItem(
        key: 'exclusives',
        label: 'Exclusives',
        count: exclusiveCount,
        icon: Icons.workspace_premium_rounded,
        message:
            'Check exclusives so stickers, retailers, and releases stay clean.',
      ),
      _VaultCleanupItem(
        key: 'signed',
        label: 'Signed',
        count: signedCount,
        icon: Icons.edit_rounded,
        message: 'Review signed Pops and keep signature details accurate.',
      ),
      _VaultCleanupItem(
        key: 'limited',
        label: 'Limited',
        count: limitedCount,
        icon: Icons.confirmation_number_rounded,
        message: 'Verify limited editions and numbered pieces.',
      ),
      _VaultCleanupItem(
        key: 'stickers',
        label: 'Stickers',
        count: stickerCount,
        icon: Icons.local_offer_rounded,
        message:
            'Confirm sticker details so variants and exclusives are easier to track.',
      ),
    ];

    final activeItems = items.where((item) => item.count > 0).toList()
      ..sort((a, b) {
        final priorityCompare = _cleanupPriority(
          a.key,
        ).compareTo(_cleanupPriority(b.key));

        if (priorityCompare != 0) {
          return priorityCompare;
        }

        return b.count.compareTo(a.count);
      });

    final visibleItems = activeItems.take(3).toList();
    final hasCleanupItems = visibleItems.isNotEmpty;

    return AtlasGlassCard(
      accentColor: AtlasColors.vaultGold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AtlasSectionHeader(
            title: 'Vault Cleanup',
            subtitle: hasCleanupItems
                ? 'Atlas found a few areas that need attention.'
                : 'Your vault is looking clean right now.',
            icon: Icons.cleaning_services_rounded,
            accentColor: AtlasColors.vaultGold,
          ),
          const SizedBox(height: AtlasSpacing.lg),
          if (hasCleanupItems)
            Column(
              children: visibleItems
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: AtlasSpacing.sm),
                      child: _VaultCleanupRow(
                        item: item,
                        onTap: onCleanupItemTap == null
                            ? null
                            : () => onCleanupItemTap!(item.key),
                      ),
                    ),
                  )
                  .toList(),
            )
          else
            const AtlasEmptyState(
              eyebrow: 'Vault Cleanup',
              title: 'Vault Looking Clean',
              message:
                  'No cleanup items found. Atlas has a clean snapshot to work with.',
              icon: Icons.verified_rounded,
              compact: true,
            ),
          if (onReviewVault != null) ...[
            const SizedBox(height: AtlasSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onReviewVault,
                icon: const Icon(Icons.visibility_rounded),
                label: const Text('Review Entire Vault'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

int _cleanupPriority(String key) {
  switch (key) {
    case 'needsValue':
      return 1;
    case 'duplicates':
      return 2;
    case 'variants':
      return 3;
    case 'stickers':
      return 4;
    case 'exclusives':
      return 5;
    case 'signed':
      return 6;
    case 'limited':
      return 7;
    case 'wishlist':
      return 8;
    default:
      return 99;
  }
}

class _VaultCleanupRow extends StatelessWidget {
  const _VaultCleanupRow({required this.item, required this.onTap});

  final _VaultCleanupItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AtlasActionRow(
      title: item.label,
      description: item.message,
      icon: item.icon,
      accentColor: AtlasColors.vaultGold,
      badge: AtlasStatusChip(
        label: item.count.toString(),
        accentColor: AtlasColors.vaultGold,
        size: AtlasStatusChipSize.compact,
      ),
      onTap: onTap,
    );
  }
}

class _VaultCleanupItem {
  const _VaultCleanupItem({
    required this.key,
    required this.label,
    required this.count,
    required this.icon,
    required this.message,
  });

  final String key;
  final String label;
  final int count;
  final IconData icon;
  final String message;
}
