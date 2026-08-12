import 'package:flutter/material.dart';

import '../../../academy/models/academy_category.dart';
import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';
import '../../../theme/atlas_typography.dart';
import '../../atlas/atlas_glass_card.dart';
import '../../atlas/components/atlas_status_chip.dart';

class AcademyCategoryCard extends StatelessWidget {
  const AcademyCategoryCard({
    required this.category,
    this.onTap,
    super.key,
  });

  final AcademyCategory category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final int lessonCount =
        category.lessonIds.length;

    final bool hasLessons =
        lessonCount > 0;

    return AtlasGlassCard(
      onTap: onTap,
      accentColor: hasLessons
          ? AtlasColors.vaultGold
          : AtlasColors.textSecondary,
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AtlasColors.vaultGold
                  .withValues(
                alpha: hasLessons
                    ? 0.12
                    : 0.06,
              ),
              borderRadius:
              BorderRadius.circular(
                18,
              ),
              border: Border.all(
                color: AtlasColors.vaultGold
                    .withValues(
                  alpha: hasLessons
                      ? 0.28
                      : 0.12,
                ),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              category.icon,
              style: const TextStyle(
                fontSize: 26,
              ),
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
                  category.title,
                  style:
                  AtlasTypography.headingSmall,
                ),
                const SizedBox(
                  height: AtlasSpacing.xs,
                ),
                Text(
                  category.subtitle,
                  style:
                  AtlasTypography.bodySmall
                      .copyWith(
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
            onTap == null
                ? Icons.lock_clock_outlined
                : Icons.chevron_right_rounded,
            color:
            AtlasColors.textSecondary,
          ),
        ],
      ),
    );
  }
}