import 'package:flutter/material.dart';

import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';
import '../../../theme/atlas_typography.dart';
import '../../atlas/atlas_glass_card.dart';

class CollectorScoreCard extends StatelessWidget {
  const CollectorScoreCard({
    required this.score,
    required this.title,
    super.key,
  });

  final int score;
  final String title;

  @override
  Widget build(BuildContext context) {
    const maxScore = 1000;

    final progress = (score / maxScore).clamp(0.0, 1.0);

    final nextRankPoints = (maxScore - score).clamp(0, maxScore);

    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Collector Score',
            style: AtlasTypography.headingSmall,
          ),

          const SizedBox(height: AtlasSpacing.lg),

          Center(
            child: Text(
              '$score',
              style: AtlasTypography.headingLarge.copyWith(
                color: AtlasColors.vaultGold,
                fontSize: 42,
              ),
            ),
          ),

          const SizedBox(height: AtlasSpacing.sm),

          Center(
            child: Text(
              title,
              style: AtlasTypography.bodyMedium.copyWith(
                color: AtlasColors.vaultGold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: AtlasSpacing.lg),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation(
                AtlasColors.vaultGold,
              ),
            ),
          ),

          const SizedBox(height: AtlasSpacing.sm),

          Text(
            '$nextRankPoints points until Vault Legend',
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}