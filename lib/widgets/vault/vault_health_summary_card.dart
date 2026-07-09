import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';

class VaultHealthSummaryCard extends StatelessWidget {
  const VaultHealthSummaryCard({
    super.key,
    required this.healthScore,
    required this.priority,
    required this.needsValueCount,
    required this.duplicateGroupCount,
    this.onTap,
  });

  final double healthScore;
  final String priority;
  final int needsValueCount;
  final int duplicateGroupCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final roundedHealth = healthScore.round();

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
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
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AtlasColors.vaultGold.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.health_and_safety_rounded,
                color: AtlasColors.vaultGold,
              ),
            ),
            const SizedBox(width: AtlasSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vault Health',
                    style: TextStyle(
                      color: AtlasColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AtlasSpacing.xs),
                  Text(
                    '$roundedHealth% • $priority Priority',
                    style: const TextStyle(
                      color: AtlasColors.vaultGold,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Needs Value: $needsValueCount • Duplicates: $duplicateGroupCount',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AtlasColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AtlasSpacing.sm),
            const Icon(
              Icons.chevron_right_rounded,
              color: AtlasColors.vaultGold,
            ),
          ],
        ),
      ),
    );
  }
}