import 'package:flutter/material.dart';

import '../../atlas/recommendations/models/atlas_recommendation.dart';
import '../../atlas/recommendations/models/atlas_recommendation_summary.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../atlas/atlas_expandable_section.dart';
import '../atlas/atlas_glass_panel.dart';
import 'atlas_recommendation_tile.dart';

/// Reusable presentation for completed Atlas recommendation intelligence.
///
/// The recommendation engine remains responsible for recommendation creation,
/// priority, sorting, deduplication, descriptions, reasons, and action labels.
class AtlasRecommendationsCard extends StatelessWidget {
  const AtlasRecommendationsCard({
    super.key,
    required this.summary,
    this.maxRecommendations = 5,
    this.onRecommendationAction,
    this.onViewAll,
    this.showEmptyState = true,
    this.initiallyExpanded = false,
  });

  final AtlasRecommendationSummary summary;

  /// Maximum number rendered by the compact card.
  final int maxRecommendations;

  /// Parent-owned action handling for navigation or record editing.
  final ValueChanged<AtlasRecommendation>? onRecommendationAction;

  /// Optional callback for a full recommendations screen or sheet.
  final VoidCallback? onViewAll;

  final bool showEmptyState;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    if (!summary.hasRecommendations && !showEmptyState) {
      return const SizedBox.shrink();
    }

    final visibleRecommendations = summary.recommendations
        .take(maxRecommendations)
        .toList(growable: false);

    return AtlasExpandableSection(
      title: 'Atlas Recommendations',
      subtitle: _buildRecommendationSubtitle(summary),
      icon: Icons.recommend_outlined,
      initiallyExpanded: initiallyExpanded,
      badge: AtlasExpandableBadge(
        label: '${summary.count} ${summary.count == 1 ? 'Action' : 'Actions'}',
        icon: Icons.lightbulb_outline,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!summary.hasRecommendations)
            const _RecommendationEmptyState()
          else ...[
            if (summary.primaryRecommendation != null) ...[
              _PrimaryRecommendationPanel(
                recommendation: summary.primaryRecommendation!,
              ),
              const SizedBox(height: AtlasSpacing.md),
            ],

            ...visibleRecommendations.map(
                  (recommendation) => Padding(
                padding: const EdgeInsets.only(
                  bottom: AtlasSpacing.sm,
                ),
                child: AtlasRecommendationTile(
                  recommendation: recommendation,
                  onAction: onRecommendationAction,
                  showAction:
                  onRecommendationAction != null,
                ),
              ),
            ),

            if (summary.count >
                visibleRecommendations.length ||
                onViewAll != null) ...[
              const SizedBox(height: AtlasSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onViewAll,
                  icon: const Icon(
                    Icons.list_alt_rounded,
                    size: 18,
                  ),
                  label: Text(
                    summary.count >
                        visibleRecommendations.length
                        ? 'View All ${summary.count}'
                        : 'View All Recommendations',
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

String _buildRecommendationSubtitle(
    AtlasRecommendationSummary summary,
    ) {
  if (!summary.hasRecommendations) {
    return 'No immediate improvements recommended';
  }

  final primary = summary.primaryRecommendation;

  if (primary == null) {
    return '${summary.count} recommendations available';
  }

  return primary.title;
}

class _PrimaryRecommendationPanel extends StatelessWidget {
  const _PrimaryRecommendationPanel({required this.recommendation});

  final AtlasRecommendation recommendation;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassPanel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AtlasColors.vaultGold.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AtlasColors.vaultGold,
            ),
          ),
          const SizedBox(width: AtlasSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommended Next Step',
                  style: AtlasTypography.bodySmall.copyWith(
                    color: AtlasColors.vaultGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AtlasSpacing.xs),
                Text(
                  recommendation.title,
                  style: AtlasTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AtlasSpacing.xs),
                Text(
                  recommendation.reason,
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

class _RecommendationEmptyState extends StatelessWidget {
  const _RecommendationEmptyState();

  @override
  Widget build(BuildContext context) {
    return AtlasGlassPanel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.task_alt_rounded, color: AtlasColors.vaultGold),
          const SizedBox(width: AtlasSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile looks complete',
                  style: AtlasTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AtlasSpacing.xs),
                Text(
                  'Atlas did not identify any immediate collectible record improvements.',
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
