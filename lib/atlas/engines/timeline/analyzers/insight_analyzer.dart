import '../models/ownership_analysis.dart';
import '../models/timeline_health.dart';
import '../models/timeline_insight.dart';
import '../models/value_analysis.dart';

class InsightAnalyzer {
  const InsightAnalyzer();

  List<TimelineInsight> analyze({
    required OwnershipAnalysis ownership,
    required ValueAnalysis value,
    required TimelineHealth health,
    DateTime? now,
  }) {
    final generatedAt = now ?? DateTime.now();
    final insights = <TimelineInsight>[];

    if (!health.isHealthy) {
      insights.add(
        TimelineInsight(
          id: 'timeline-health',
          title: 'Timeline Needs Attention',
          description:
              'Adding more timeline events and value history will improve future intelligence.',
          priority: TimelineInsightPriority.high,
          category: TimelineInsightCategory.health,
          createdAt: generatedAt,
        ),
      );
    }

    if (ownership.isRecentlyAdded) {
      insights.add(
        TimelineInsight(
          id: 'recently-added',
          title: 'Recently Added',
          description:
              'This collectible was recently added to your collection.',
          priority: TimelineInsightPriority.low,
          category: TimelineInsightCategory.ownership,
          createdAt: generatedAt,
        ),
      );
    }

    if (ownership.yearsOwned >= 5) {
      insights.add(
        TimelineInsight(
          id: 'long-term-ownership',
          title: 'Long-Term Collectible',
          description:
              'You have owned this collectible for more than five years.',
          priority: TimelineInsightPriority.medium,
          category: TimelineInsightCategory.ownership,
          createdAt: generatedAt,
        ),
      );
    }

    if (value.hasValueHistory && value.hasIncreased) {
      insights.add(
        TimelineInsight(
          id: 'value-up',
          title: 'Value Trending Up',
          description: 'Historical value records show positive growth.',
          priority: TimelineInsightPriority.medium,
          category: TimelineInsightCategory.value,
          createdAt: generatedAt,
        ),
      );
    }

    if (value.hasValueHistory && value.percentageChange >= 100) {
      insights.add(
        TimelineInsight(
          id: 'value-doubled',
          title: 'Exceptional Growth',
          description: 'The recorded value has increased by more than 100%.',
          priority: TimelineInsightPriority.high,
          category: TimelineInsightCategory.value,
          createdAt: generatedAt,
        ),
      );
    }

    if (value.hasValueHistory && value.hasDecreased) {
      insights.add(
        TimelineInsight(
          id: 'value-down',
          title: 'Value Has Declined',
          description: 'Recent value history indicates a decrease in value.',
          priority: TimelineInsightPriority.medium,
          category: TimelineInsightCategory.value,
          createdAt: generatedAt,
        ),
      );
    }

    return List<TimelineInsight>.unmodifiable(insights);
  }
}
