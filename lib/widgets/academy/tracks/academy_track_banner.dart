import 'package:flutter/material.dart';

import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';
import '../../../theme/atlas_typography.dart';
import '../../atlas/atlas_glass_card.dart';

class AcademyTrackBanner extends StatelessWidget {
  const AcademyTrackBanner({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  final String emoji;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final String cleanedTitle = title.trim();
    final String cleanedSubtitle = subtitle.trim();

    return AtlasGlassCard(
      accentColor: AtlasColors.vaultGold,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AtlasColors.vaultGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              emoji.trim().isEmpty ? '🎓' : emoji.trim(),
              style: const TextStyle(fontSize: 28),
            ),
          ),
          const SizedBox(width: AtlasSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cleanedTitle.isEmpty ? 'Academy Track' : cleanedTitle,
                  style: AtlasTypography.headingSmall.copyWith(
                    color: AtlasColors.vaultGold,
                  ),
                ),
                const SizedBox(height: AtlasSpacing.xs),
                Text(
                  cleanedSubtitle.isEmpty
                      ? 'More Academy track details are coming soon.'
                      : cleanedSubtitle,
                  style: AtlasTypography.bodySmall.copyWith(
                    color: AtlasColors.textSecondary,
                    height: 1.4,
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
