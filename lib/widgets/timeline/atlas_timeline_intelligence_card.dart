import 'package:flutter/material.dart';

import '../../atlas/engines/timeline/models/atlas_timeline_intelligence_report.dart';
import '../../atlas/engines/timeline/models/timeline_insight.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../atlas/atlas_glass_card.dart';
import '../atlas/atlas_glass_panel.dart';
import '../atlas/components/atlas_section_header.dart';

class AtlasTimelineIntelligenceCard extends StatelessWidget {
  const AtlasTimelineIntelligenceCard({super.key, required this.report});

  final AtlasTimelineIntelligenceReport report;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AtlasSectionHeader(
            title: 'Atlas Intelligence',
            subtitle: 'Ownership, value, milestones, and timeline observations',
            icon: Icons.auto_awesome_rounded,
          ),
          const SizedBox(height: AtlasSpacing.lg),
          _AtlasSummaryPanel(report: report),
          const SizedBox(height: AtlasSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ScorePanel(
                  label: 'Timeline Health',
                  score: report.health.healthScore,
                  icon: Icons.monitor_heart_outlined,
                ),
              ),
              const SizedBox(width: AtlasSpacing.sm),
              Expanded(
                child: _ScorePanel(
                  label: 'Confidence',
                  score: report.health.confidenceScore,
                  icon: Icons.verified_outlined,
                ),
              ),
            ],
          ),
          if (report.insights.isNotEmpty) ...[
            const SizedBox(height: AtlasSpacing.lg),
            Text('Insights', style: AtlasTypography.headingSmall),
            const SizedBox(height: AtlasSpacing.sm),
            ...report.insights
                .take(3)
                .map(
                  (insight) => Padding(
                    padding: const EdgeInsets.only(bottom: AtlasSpacing.sm),
                    child: _InsightPanel(insight: insight),
                  ),
                ),
          ],
          if (report.milestones.isNotEmpty) ...[
            const SizedBox(height: AtlasSpacing.md),
            Text('Milestones', style: AtlasTypography.headingSmall),
            const SizedBox(height: AtlasSpacing.sm),
            Wrap(
              spacing: AtlasSpacing.sm,
              runSpacing: AtlasSpacing.sm,
              children: report.milestones
                  .take(3)
                  .map((milestone) => _MilestoneBadge(title: milestone.title))
                  .toList(growable: false),
            ),
          ],
          if (report.health.recommendations.isNotEmpty) ...[
            const SizedBox(height: AtlasSpacing.lg),
            Text('Recommended Next Steps', style: AtlasTypography.headingSmall),
            const SizedBox(height: AtlasSpacing.sm),
            AtlasGlassPanel(
              child: Column(
                children: report.health.recommendations
                    .take(3)
                    .map(
                      (recommendation) =>
                          _RecommendationRow(recommendation: recommendation),
                    )
                    .toList(growable: false),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AtlasSummaryPanel extends StatelessWidget {
  const _AtlasSummaryPanel({required this.report});

  final AtlasTimelineIntelligenceReport report;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassPanel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.psychology_alt_outlined,
            color: AtlasColors.vaultGold,
          ),
          const SizedBox(width: AtlasSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Atlas Summary',
                  style: AtlasTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AtlasSpacing.xs),
                Text(
                  _buildSummary(),
                  style: AtlasTypography.bodySmall.copyWith(
                    color: AtlasColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _buildSummary() {
    if (!report.hasMeaningfulIntelligence) {
      return 'Add more timeline and value history to unlock deeper collector intelligence.';
    }

    final parts = <String>[];

    if (report.hasOwnershipHistory) {
      parts.add('Owned for ${report.ownership.durationLabel.toLowerCase()}');
    }

    if (report.hasValueHistory) {
      if (report.value.hasIncreased) {
        parts.add('recorded value is trending upward');
      } else if (report.value.hasDecreased) {
        parts.add('recorded value has declined');
      } else {
        parts.add('recorded value is currently stable');
      }
    }

    if (parts.isEmpty) {
      return 'Atlas is building intelligence from this collectible’s recorded history.';
    }

    final summary = parts.join(' and ');

    return '${summary[0].toUpperCase()}${summary.substring(1)}.';
  }
}

class _ScorePanel extends StatelessWidget {
  const _ScorePanel({
    required this.label,
    required this.score,
    required this.icon,
  });

  final String label;
  final double score;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final roundedScore = score.round();

    return AtlasGlassPanel(
      child: Column(
        children: [
          Icon(icon, color: AtlasColors.vaultGold),
          const SizedBox(height: AtlasSpacing.sm),
          Text(
            '$roundedScore%',
            textAlign: TextAlign.center,
            style: AtlasTypography.headingSmall.copyWith(
              color: AtlasColors.vaultGold,
            ),
          ),
          const SizedBox(height: AtlasSpacing.xs),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightPanel extends StatelessWidget {
  const _InsightPanel({required this.insight});

  final TimelineInsight insight;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassPanel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_priorityIcon(insight.priority), color: AtlasColors.vaultGold),
          const SizedBox(width: AtlasSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: AtlasTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AtlasSpacing.xs),
                Text(
                  insight.description,
                  style: AtlasTypography.bodySmall.copyWith(
                    color: AtlasColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _priorityIcon(TimelineInsightPriority priority) {
    switch (priority) {
      case TimelineInsightPriority.low:
        return Icons.lightbulb_outline_rounded;
      case TimelineInsightPriority.medium:
        return Icons.insights_outlined;
      case TimelineInsightPriority.high:
        return Icons.priority_high_rounded;
      case TimelineInsightPriority.critical:
        return Icons.warning_amber_rounded;
    }
  }
}

class _MilestoneBadge extends StatelessWidget {
  const _MilestoneBadge({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AtlasSpacing.md,
        vertical: AtlasSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AtlasColors.vaultGold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AtlasColors.vaultGold.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.emoji_events_outlined,
            size: 18,
            color: AtlasColors.vaultGold,
          ),
          const SizedBox(width: AtlasSpacing.xs),
          Text(
            title,
            style: AtlasTypography.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationRow extends StatelessWidget {
  const _RecommendationRow({required this.recommendation});

  final String recommendation;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AtlasSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.arrow_forward_rounded,
            size: 18,
            color: AtlasColors.vaultGold,
          ),
          const SizedBox(width: AtlasSpacing.sm),
          Expanded(
            child: Text(
              recommendation,
              style: AtlasTypography.bodySmall.copyWith(
                color: AtlasColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
