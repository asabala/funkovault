import 'package:flutter/material.dart';

import '../../atlas/scan/authenticity/models/atlas_authenticity_assessment.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../atlas/atlas_glass_card.dart';
import '../atlas/atlas_glass_panel.dart';
import '../atlas/components/atlas_section_header.dart';
import '../atlas/components/atlas_status_chip.dart';

class AtlasAuthenticityCard extends StatelessWidget {
  const AtlasAuthenticityCard({super.key, required this.assessment});

  final AtlasAuthenticityAssessment assessment;

  @override
  Widget build(BuildContext context) {
    final _ConcernPresentation concern = _concernPresentation(
      assessment.concernLevel,
    );

    return AtlasGlassCard(
      accentColor: concern.color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AtlasSectionHeader(
            title: '🧠 Inspection Assessment',
            subtitle: assessment.summary,
            icon: Icons.analytics_outlined,
            accentColor: concern.color,
            trailing: AtlasStatusChip(
              label: concern.label,
              icon: Icons.shield_outlined,
              accentColor: concern.color,
            ),
          ),
          const SizedBox(height: AtlasSpacing.md),
          Wrap(
            spacing: AtlasSpacing.sm,
            runSpacing: AtlasSpacing.sm,
            children: [
              _MetricPanel(
                label: '📷 Evidence',
                value: assessment.evidenceConfidence,
                color: AtlasColors.intelligenceBlue,
              ),
              _MetricPanel(
                label: '📚 Reference',
                value: assessment.referenceCoverage,
                color: AtlasColors.vaultGold,
              ),
              _MetricPanel(
                label: '🛡️ Concern',
                value: assessment.aggregatedConcernScore,
                color: concern.color,
              ),
            ],
          ),
          const SizedBox(height: AtlasSpacing.sm),
          Text(
            'Inspection coverage: ${(assessment.inspectionCoverage * 100).round().clamp(0, 100)}%',
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
          if (assessment.signals.isNotEmpty) ...[
            const SizedBox(height: AtlasSpacing.md),
            ...assessment.signals.map(
              (signal) => Padding(
                padding: const EdgeInsets.only(bottom: AtlasSpacing.sm),
                child: AtlasGlassPanel(
                  accentColor: signal.isWarning
                      ? AtlasColors.warning
                      : AtlasColors.intelligenceBlue,
                  child: Text(
                    '${signal.title}: ${signal.message}',
                    style: AtlasTypography.bodySmall,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: AtlasSpacing.sm),
          Text(
            'Atlas reports evidence and warning signals. This assessment is not a certification or a definitive authentic/fake verdict.',
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricPanel extends StatelessWidget {
  const _MetricPanel({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132,
      child: AtlasGlassPanel(
        accentColor: color,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AtlasTypography.bodySmall.copyWith(
                color: AtlasColors.textSecondary,
              ),
            ),
            const SizedBox(height: AtlasSpacing.xs),
            Text(
              '${(value * 100).round().clamp(0, 100)}%',
              style: AtlasTypography.metricSmall.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConcernPresentation {
  const _ConcernPresentation(this.label, this.color);

  final String label;
  final Color color;
}

_ConcernPresentation _concernPresentation(AtlasAuthenticityConcernLevel level) {
  return switch (level) {
    AtlasAuthenticityConcernLevel.noObviousConcerns =>
      const _ConcernPresentation('No obvious concerns', AtlasColors.success),
    AtlasAuthenticityConcernLevel.reviewRecommended =>
      const _ConcernPresentation('Review recommended', AtlasColors.warning),
    AtlasAuthenticityConcernLevel.significantInconsistencies =>
      const _ConcernPresentation(
        'Significant inconsistencies',
        AtlasColors.warning,
      ),
    AtlasAuthenticityConcernLevel.strongCounterfeitIndicators =>
      const _ConcernPresentation(
        'Strong warning indicators',
        AtlasColors.danger,
      ),
    AtlasAuthenticityConcernLevel.insufficientData =>
      const _ConcernPresentation(
        'Insufficient data',
        AtlasColors.textSecondary,
      ),
  };
}
