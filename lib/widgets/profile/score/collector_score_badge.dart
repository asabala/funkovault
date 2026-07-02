import 'package:flutter/material.dart';

import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';
import '../../../theme/atlas_typography.dart';

class CollectorScoreBadge extends StatelessWidget {
  const CollectorScoreBadge({
    required this.score,
    required this.title,
    super.key,
  });

  final int score;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AtlasSpacing.md),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AtlasColors.vaultGold.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        children: [
          Text(
            '$score',
            style: AtlasTypography.headingLarge.copyWith(
              color: AtlasColors.vaultGold,
            ),
          ),
          const SizedBox(height: AtlasSpacing.xs),
          Text(
            'Collector Score',
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
          const SizedBox(height: AtlasSpacing.sm),
          Text(
            title,
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.vaultGold,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}