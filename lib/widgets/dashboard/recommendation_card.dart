import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';
import '../../theme/atlas_icons.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../vault/atlas_priority_chip.dart';
import '../atlas/atlas_section_card.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.title,
    required this.message,
    required this.confidenceScore,
    required this.confidenceMessage,
    required this.severity,
    required this.why,
  });

  final String title;
  final String message;
  final double confidenceScore;
  final String confidenceMessage;
  final String severity;
  final String why;

  @override
  Widget build(BuildContext context) {
    return AtlasSectionCard(
      title: 'Atlas Recommendation',
      icon: AtlasIcons.decision,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AtlasPriorityChip(severity: severity),

          const SizedBox(height: AtlasSpacing.md),

          Text(title, style: AtlasTypography.headingSmall),

          const SizedBox(height: AtlasSpacing.sm),

          Text(message, style: AtlasTypography.bodyMedium),

          const SizedBox(height: AtlasSpacing.md),

          Text(
            'Confidence: ${confidenceScore.toStringAsFixed(0)}%',
            style: AtlasTypography.label.copyWith(
              color: AtlasColors.intelligenceBlue,
            ),
          ),

          const SizedBox(height: AtlasSpacing.sm),

          Text(confidenceMessage, style: AtlasTypography.bodySmall),

          const SizedBox(height: AtlasSpacing.md),

          Text(
            'Why Atlas selected this:',
            style: AtlasTypography.label.copyWith(color: AtlasColors.vaultGold),
          ),

          const SizedBox(height: AtlasSpacing.sm),

          Text(why, style: AtlasTypography.bodySmall),
        ],
      ),
    );
  }
}
