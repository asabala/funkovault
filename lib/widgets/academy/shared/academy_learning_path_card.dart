import 'package:flutter/material.dart';

import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';
import '../../../theme/atlas_typography.dart';
import '../../atlas/atlas_glass_card.dart';
import '../../atlas/components/atlas_status_chip.dart';

class AcademyLearningPathCard extends StatelessWidget {
  const AcademyLearningPathCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.lessonCount,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final int lessonCount;
  final VoidCallback? onTap;

  bool get _isAvailable {
    return onTap != null;
  }

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      onTap: onTap,
      accentColor: _isAvailable
          ? AtlasColors.intelligenceBlue
          : AtlasColors.textSecondary,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AtlasColors.intelligenceBlue.withValues(
                alpha: _isAvailable ? 0.14 : 0.06,
              ),
              borderRadius: BorderRadius.circular(
                16,
              ),
            ),
            child: Icon(
              Icons.route_outlined,
              color: _isAvailable
                  ? AtlasColors.intelligenceBlue
                  : AtlasColors.textSecondary,
            ),
          ),
          const SizedBox(
            width: AtlasSpacing.md,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                  AtlasTypography.headingSmall.copyWith(
                    color: _isAvailable
                        ? AtlasColors.textPrimary
                        : AtlasColors.textSecondary,
                  ),
                ),
                const SizedBox(
                  height: AtlasSpacing.xs,
                ),
                Text(
                  subtitle,
                  style:
                  AtlasTypography.bodySmall.copyWith(
                    color:
                    AtlasColors.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(
                  height: AtlasSpacing.sm,
                ),
                AtlasStatusChip(
                  label: lessonCount == 0
                      ? 'Lessons Coming Soon'
                      : '$lessonCount '
                      '${lessonCount == 1 ? 'Lesson' : 'Lessons'}',
                  icon: lessonCount == 0
                      ? Icons.schedule_rounded
                      : Icons.menu_book_outlined,
                  accentColor: lessonCount == 0
                      ? AtlasColors.textSecondary
                      : AtlasColors.vaultGold,
                  size:
                  AtlasStatusChipSize.compact,
                ),
              ],
            ),
          ),
          const SizedBox(
            width: AtlasSpacing.sm,
          ),
          Icon(
            _isAvailable
                ? Icons.chevron_right_rounded
                : Icons.lock_clock_outlined,
            size: 20,
            color: AtlasColors.textSecondary,
          ),
        ],
      ),
    );
  }
}