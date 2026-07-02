import 'package:flutter/material.dart';

import '../../../atlas/models/atlas_achievement.dart';
import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';
import '../../../theme/atlas_typography.dart';
import '../../atlas/atlas_glass_card.dart';

class AchievementPreviewCard extends StatelessWidget {
  const AchievementPreviewCard({
    required this.achievements,
    super.key,
  });

  final List<AtlasAchievement> achievements;

  @override
  Widget build(BuildContext context) {
    final unlocked = achievements.where((item) => item.unlocked).toList();

    final latest = unlocked.isEmpty ? null : unlocked.last;

    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Latest Achievement',
            style: AtlasTypography.headingSmall,
          ),
          const SizedBox(height: AtlasSpacing.md),
          if (latest == null)
            Text(
              'No achievements unlocked yet. Add your first collectible to begin your Atlas journey.',
              style: AtlasTypography.bodyMedium.copyWith(
                color: AtlasColors.textSecondary,
              ),
            )
          else
            Row(
              children: [
                Text(
                  latest.icon,
                  style: const TextStyle(fontSize: 36),
                ),
                const SizedBox(width: AtlasSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        latest.title,
                        style: AtlasTypography.headingSmall.copyWith(
                          color: AtlasColors.vaultGold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        latest.description,
                        style: AtlasTypography.bodyMedium.copyWith(
                          color: AtlasColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}