import 'package:flutter/material.dart';

import '../../atlas/scan/authenticity/models/atlas_authenticity_assessment.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../atlas/atlas_glass_card.dart';
import '../atlas/components/atlas_section_header.dart';
import '../atlas/components/atlas_status_chip.dart';

class AtlasAuthenticityCard extends StatelessWidget {
  const AtlasAuthenticityCard({super.key, required this.assessment});

  final AtlasAuthenticityAssessment assessment;

  @override
  Widget build(BuildContext context) {
    final presentation = _presentation(assessment.status);
    return AtlasGlassCard(
      accentColor: presentation.color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AtlasSectionHeader(
            title: '${presentation.emoji} Authenticity Intelligence',
            subtitle: assessment.summary,
            icon: Icons.verified_user_outlined,
            accentColor: presentation.color,
            trailing: AtlasStatusChip(
              label: presentation.label,
              icon: Icons.shield_outlined,
              accentColor: presentation.color,
            ),
          ),
          const SizedBox(height: AtlasSpacing.md),
          Wrap(
            spacing: AtlasSpacing.sm,
            runSpacing: AtlasSpacing.sm,
            children: [
              AtlasStatusChip(
                label: '${assessment.confidenceScore}% confidence',
                icon: Icons.speed_rounded,
                accentColor: presentation.color,
              ),
              AtlasStatusChip(
                label: '${assessment.evidenceCoverage}% coverage',
                icon: Icons.fact_check_outlined,
                accentColor: AtlasColors.intelligenceBlue,
              ),
            ],
          ),
          if (assessment.signals.isNotEmpty) ...[
            const SizedBox(height: AtlasSpacing.md),
            ...assessment.signals.map(
              (signal) => Padding(
                padding: const EdgeInsets.only(bottom: AtlasSpacing.sm),
                child: Text('• ${signal.title}: ${signal.message}'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static ({String emoji, String label, Color color}) _presentation(
    AtlasAuthenticityStatus status,
  ) => switch (status) {
    AtlasAuthenticityStatus.strongEvidence => (
      emoji: '🛡️',
      label: 'Strong Evidence',
      color: AtlasColors.success,
    ),
    AtlasAuthenticityStatus.developingEvidence => (
      emoji: '🟡',
      label: 'Developing',
      color: AtlasColors.intelligenceBlue,
    ),
    AtlasAuthenticityStatus.reviewRecommended => (
      emoji: '⚠️',
      label: 'Review',
      color: AtlasColors.warning,
    ),
    AtlasAuthenticityStatus.insufficientEvidence => (
      emoji: '🔎',
      label: 'Insufficient',
      color: AtlasColors.textSecondary,
    ),
  };
}
