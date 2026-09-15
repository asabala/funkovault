import 'package:flutter/material.dart';

import 'package:funkovault2/atlas/intelligence/models/atlas_collector_recommendation.dart';
import 'package:funkovault2/theme/atlas_colors.dart';
import 'package:funkovault2/theme/atlas_spacing.dart';
import 'package:funkovault2/theme/atlas_typography.dart';
import 'package:funkovault2/widgets/atlas/atlas_glass_panel.dart';

class AtlasIntelligenceFeed extends StatelessWidget {
  const AtlasIntelligenceFeed({
    required this.recommendations,
    this.title = '🧠 Atlas Intelligence',
    this.maxVisibleRecommendations,
    this.showPriority = false,
    super.key,
  });

  final List<AtlasCollectorRecommendation> recommendations;
  final String title;
  final int? maxVisibleRecommendations;
  final bool showPriority;

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<AtlasCollectorRecommendation> sortedRecommendations =
        List<AtlasCollectorRecommendation>.from(recommendations)..sort((
          AtlasCollectorRecommendation first,
          AtlasCollectorRecommendation second,
        ) {
          final int priorityComparison = first.priority.compareTo(
            second.priority,
          );

          if (priorityComparison != 0) {
            return priorityComparison;
          }

          return first.title.compareTo(second.title);
        });

    final int visibleCount = maxVisibleRecommendations == null
        ? sortedRecommendations.length
        : maxVisibleRecommendations!.clamp(0, sortedRecommendations.length);

    final List<AtlasCollectorRecommendation> visibleRecommendations =
        sortedRecommendations.take(visibleCount).toList(growable: false);

    return AtlasGlassPanel(
      accentColor: AtlasColors.intelligenceBlue,
      padding: const EdgeInsets.all(AtlasSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FeedHeader(title: title, count: recommendations.length),
          const SizedBox(height: AtlasSpacing.md),
          for (
            int index = 0;
            index < visibleRecommendations.length;
            index++
          ) ...[
            _RecommendationFeedItem(
              recommendation: visibleRecommendations[index],
              showPriority: showPriority,
            ),
            if (index < visibleRecommendations.length - 1)
              const Divider(height: AtlasSpacing.xl),
          ],
          if (visibleRecommendations.length < recommendations.length) ...[
            const SizedBox(height: AtlasSpacing.sm),
            Text(
              '${recommendations.length - visibleRecommendations.length} additional '
              '${recommendations.length - visibleRecommendations.length == 1 ? 'insight' : 'insights'} available',
              style: AtlasTypography.bodySmall.copyWith(
                color: AtlasColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _FeedHeader extends StatelessWidget {
  const _FeedHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AtlasTypography.headingSmall)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AtlasColors.intelligenceBlue.withValues(alpha: 0.35),
            ),
            color: AtlasColors.intelligenceBlue.withValues(alpha: 0.10),
          ),
          child: Text(
            '$count',
            style: AtlasTypography.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AtlasColors.intelligenceBlue,
            ),
          ),
        ),
      ],
    );
  }
}

class _RecommendationFeedItem extends StatelessWidget {
  const _RecommendationFeedItem({
    required this.recommendation,
    required this.showPriority,
  });

  final AtlasCollectorRecommendation recommendation;
  final bool showPriority;

  @override
  Widget build(BuildContext context) {
    final Color accentColor = _accentColorForSeverity(recommendation.severity);

    final IconData icon = _iconForType(recommendation.type);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accentColor.withValues(alpha: 0.14),
            border: Border.all(color: accentColor.withValues(alpha: 0.35)),
          ),
          child: Icon(icon, color: accentColor, size: 22),
        ),
        const SizedBox(width: AtlasSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recommendation.categoryLabel.toUpperCase(),
                style: AtlasTypography.bodySmall.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: AtlasSpacing.xs),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      recommendation.title,
                      style: AtlasTypography.headingSmall.copyWith(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (showPriority)
                    _PriorityBadge(
                      priority: recommendation.priority,
                      accentColor: accentColor,
                    ),
                ],
              ),
              const SizedBox(height: AtlasSpacing.xs),
              Text(recommendation.message, style: AtlasTypography.bodyMedium),
              if (recommendation.hasDetails) ...[
                const SizedBox(height: AtlasSpacing.sm),
                for (final String detail in recommendation.details)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AtlasSpacing.xs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '•',
                          style: AtlasTypography.bodyMedium.copyWith(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: AtlasSpacing.sm),
                        Expanded(
                          child: Text(detail, style: AtlasTypography.bodySmall),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Color _accentColorForSeverity(AtlasCollectorRecommendationSeverity severity) {
    switch (severity) {
      case AtlasCollectorRecommendationSeverity.informational:
        return AtlasColors.intelligenceBlue;

      case AtlasCollectorRecommendationSeverity.positive:
        return AtlasColors.success;

      case AtlasCollectorRecommendationSeverity.caution:
        return AtlasColors.warning;

      case AtlasCollectorRecommendationSeverity.warning:
        return AtlasColors.warning;

      case AtlasCollectorRecommendationSeverity.critical:
        return AtlasColors.danger;
    }
  }

  IconData _iconForType(AtlasCollectorRecommendationType type) {
    switch (type) {
      case AtlasCollectorRecommendationType.alreadyOwned:
        return Icons.inventory_2_rounded;

      case AtlasCollectorRecommendationType.reviewVariant:
        return Icons.manage_search_rounded;

      case AtlasCollectorRecommendationType.marketValueUnavailable:
        return Icons.query_stats_rounded;

      case AtlasCollectorRecommendationType.newToVault:
        return Icons.auto_awesome_rounded;
    }
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority, required this.accentColor});

  final int priority;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: AtlasSpacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: accentColor.withValues(alpha: 0.10),
        border: Border.all(color: accentColor.withValues(alpha: 0.30)),
      ),
      child: Text(
        'P$priority',
        style: AtlasTypography.bodySmall.copyWith(
          color: accentColor,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}
