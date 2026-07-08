import 'package:flutter/material.dart';

import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';
import '../../../theme/atlas_typography.dart';
import '../../atlas/atlas_glass_card.dart';
import '../../atlas/atlas_glass_panel.dart';

class AcademyLearningPathCard extends StatelessWidget {
  const AcademyLearningPathCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.lessonCount,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final int lessonCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: AtlasGlassPanel(
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AtlasSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AtlasColors.intelligenceBlue.withValues(
                      alpha: 0.14,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.route_outlined,
                    color: AtlasColors.intelligenceBlue,
                  ),
                ),
                const SizedBox(width: AtlasSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AtlasTypography.headingSmall,
                      ),
                      const SizedBox(height: AtlasSpacing.xs),
                      Text(
                        subtitle,
                        style: AtlasTypography.bodySmall.copyWith(
                          color: AtlasColors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: AtlasSpacing.sm),
                      Text(
                        '$lessonCount lesson${lessonCount == 1 ? '' : 's'} available',
                        style: AtlasTypography.label.copyWith(
                          color: AtlasColors.vaultGold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AtlasSpacing.sm),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AtlasColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}