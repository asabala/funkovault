import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';
import '../../theme/atlas_icons.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../atlas/atlas_glass_card.dart';

class AtlasPulseCard extends StatelessWidget {
  const AtlasPulseCard({
    required this.greeting,
    required this.dateLabel,
    required this.timeLabel,
    required this.summary,
    required this.status,
    super.key,
  });

  final String greeting;
  final String dateLabel;
  final String timeLabel;
  final String summary;
  final String status;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(AtlasIcons.intelligence, color: AtlasColors.vaultGold),
              const SizedBox(width: AtlasSpacing.sm),
              Text('Atlas Pulse', style: AtlasTypography.headingSmall),
            ],
          ),
          const SizedBox(height: AtlasSpacing.lg),
          Text(greeting, style: AtlasTypography.headingLarge),
          const SizedBox(height: AtlasSpacing.xs),
          Text(
            '$dateLabel • $timeLabel',
            style: AtlasTypography.bodyMedium.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
          const SizedBox(height: AtlasSpacing.lg),
          Text(
            status,
            style: AtlasTypography.bodyMedium.copyWith(
              color: AtlasColors.vaultGold,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AtlasSpacing.sm),
          Text(
            summary,
            style: AtlasTypography.bodyMedium.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
