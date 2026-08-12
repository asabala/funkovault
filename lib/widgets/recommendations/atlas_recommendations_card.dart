import 'package:flutter/material.dart';

import '../../atlas/recommendations/models/atlas_recommendation.dart';
import '../../atlas/recommendations/models/atlas_recommendation_summary.dart';
import '../../theme/atlas_spacing.dart';
import '../atlas/atlas_expandable_section.dart';
import '../atlas/components/atlas_empty_state.dart';
import '../atlas/components/atlas_insight_panel.dart';
import 'atlas_recommendation_tile.dart';

/// Reusable presentation for completed Atlas recommendation intelligence.
///
/// The recommendation engine remains responsible for recommendation creation,
/// priority, sorting, deduplication, descriptions, reasons, and action labels.
///
/// Presentation is intentionally composed from shared ADS components so this
/// card stays focused on orchestration rather than owning one-off UI.
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

    final List<AtlasRecommendation> visibleRecommendations =
    summary.recommendations
        .take(maxRecommendations)
        .toList(
      growable: false,
    );

    final AtlasRecommendation? primaryRecommendation =
        summary.primaryRecommendation;

    return AtlasExpandableSection(
      title: 'Atlas Recommendations',
      subtitle: _buildRecommendationSubtitle(
        summary,
      ),
      icon: Icons.recommend_outlined,
      initiallyExpanded: initiallyExpanded,
      badge: AtlasExpandableBadge(
        label:
        '${summary.count} '
            '${summary.count == 1 ? 'Action' : 'Actions'}',
        icon: Icons.lightbulb_outline,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!summary.hasRecommendations)
            const AtlasEmptyState(
              eyebrow: 'Recommendations',
              title: 'Profile looks complete',
              message:
              'Atlas did not identify any immediate collectible record improvements.',
              icon: Icons.task_alt_rounded,
              tone: AtlasEmptyStateTone.recommendation,
              compact: true,
            )
          else ...[
            if (primaryRecommendation != null) ...[
              AtlasInsightPanel(
                eyebrow: 'Recommended Next Step',
                title: primaryRecommendation.title,
                message: primaryRecommendation.reason,
                icon: Icons.auto_awesome_rounded,
                tone: AtlasInsightPanelTone.recommendation,
              ),
              const SizedBox(
                height: AtlasSpacing.md,
              ),
            ],

            ...visibleRecommendations.map(
                  (
                  AtlasRecommendation recommendation,
                  ) {
                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: AtlasSpacing.sm,
                  ),
                  child: AtlasRecommendationTile(
                    recommendation: recommendation,
                    onAction: onRecommendationAction,
                    showAction:
                    onRecommendationAction != null,
                  ),
                );
              },
            ),

            if (summary.count >
                visibleRecommendations.length ||
                onViewAll != null) ...[
              const SizedBox(
                height: AtlasSpacing.sm,
              ),
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

  final AtlasRecommendation? primary =
      summary.primaryRecommendation;

  if (primary == null) {
    return '${summary.count} recommendations available';
  }

  return primary.title;
}