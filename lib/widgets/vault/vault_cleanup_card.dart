import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';

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
        message: 'Check exclusives so stickers, retailers, and releases stay clean.',
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

    final activeItems = items
        .where(
          (item) => item.count > 0,
    )
        .toList()
      ..sort(
            (a, b) {
          final priorityCompare = _cleanupPriority(a.key).compareTo(
            _cleanupPriority(b.key),
          );

          if (priorityCompare != 0) {
            return priorityCompare;
          }

          return b.count.compareTo(a.count);
        },
      );

    final visibleItems = activeItems.take(3).toList();
    final hasCleanupItems = visibleItems.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AtlasSpacing.lg),
      decoration: BoxDecoration(
        color: AtlasColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AtlasColors.vaultGold.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.cleaning_services_rounded,
                color: AtlasColors.vaultGold,
              ),
              SizedBox(width: AtlasSpacing.sm),
              Expanded(
                child: Text(
                  'Vault Cleanup',
                  style: TextStyle(
                    color: AtlasColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AtlasSpacing.xs),
          Text(
            hasCleanupItems
                ? 'Atlas found a few areas that need attention.'
                : 'Your vault is looking clean right now.',
            style: const TextStyle(
              color: AtlasColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: AtlasSpacing.lg),
          if (hasCleanupItems)
            Column(
              children: visibleItems
                  .map(
                    (item) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: AtlasSpacing.sm,
                  ),
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
            const _VaultCleanupEmptyState(),
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
  const _VaultCleanupRow({
    required this.item,
    required this.onTap,
  });

  final _VaultCleanupItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isTappable = onTap != null;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AtlasSpacing.md),
        decoration: BoxDecoration(
          color: AtlasColors.background.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AtlasColors.vaultGold.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                item.icon,
                color: AtlasColors.vaultGold,
                size: 20,
              ),
            ),
            const SizedBox(width: AtlasSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: const TextStyle(
                      color: AtlasColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.message,
                    style: const TextStyle(
                      color: AtlasColors.textSecondary,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AtlasSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.count.toString(),
                  style: const TextStyle(
                    color: AtlasColors.vaultGold,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isTappable) ...[
                  const SizedBox(height: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AtlasColors.vaultGold,
                    size: 20,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VaultCleanupEmptyState extends StatelessWidget {
  const _VaultCleanupEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AtlasSpacing.md),
      decoration: BoxDecoration(
        color: AtlasColors.background.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.verified_rounded,
            color: AtlasColors.vaultGold,
          ),
          SizedBox(width: AtlasSpacing.md),
          Expanded(
            child: Text(
              'No cleanup items found. Atlas has a clean snapshot to work with.',
              style: TextStyle(
                color: AtlasColors.textSecondary,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
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