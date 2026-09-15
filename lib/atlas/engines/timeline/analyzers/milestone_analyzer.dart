import '../models/ownership_analysis.dart';
import '../models/timeline_milestone.dart';
import '../models/value_analysis.dart';

class MilestoneAnalyzer {
  const MilestoneAnalyzer();

  List<TimelineMilestone> analyze({
    required OwnershipAnalysis ownership,
    required ValueAnalysis value,
    DateTime? now,
  }) {
    final generatedAt = now ?? DateTime.now();
    final milestones = <TimelineMilestone>[];

    if (ownership.ownedSince != null) {
      if (ownership.yearsOwned >= 1) {
        milestones.add(
          TimelineMilestone(
            id: 'owned-1-year',
            type: TimelineMilestoneType.anniversary,
            title: 'Owned One Year',
            description:
                'You have owned this collectible for at least one year.',
            achievedAt: generatedAt,
          ),
        );
      }

      if (ownership.yearsOwned >= 5) {
        milestones.add(
          TimelineMilestone(
            id: 'owned-5-years',
            type: TimelineMilestoneType.anniversary,
            title: 'Five-Year Collector',
            description:
                'This collectible has been part of your collection for over five years.',
            achievedAt: generatedAt,
          ),
        );
      }
    }

    if (value.hasValueHistory && value.hasIncreased) {
      milestones.add(
        TimelineMilestone(
          id: 'value-growth',
          type: TimelineMilestoneType.value,
          title: 'Value Increased',
          description:
              'This collectible has increased in value since it was first recorded.',
          achievedAt: generatedAt,
        ),
      );
    }

    if (value.percentageChange >= 100) {
      milestones.add(
        TimelineMilestone(
          id: 'value-doubled',
          type: TimelineMilestoneType.value,
          title: 'Value Doubled',
          description: 'The recorded value has increased by at least 100%.',
          achievedAt: generatedAt,
        ),
      );
    }

    return List<TimelineMilestone>.unmodifiable(milestones);
  }
}
