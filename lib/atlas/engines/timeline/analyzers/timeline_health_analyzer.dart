import '../models/timeline_health.dart';

class TimelineHealthAnalyzer {
  const TimelineHealthAnalyzer();

  TimelineHealth analyze({
    required int timelineEventCount,
    required int valueEventCount,
    required bool hasOwnershipDate,
    required bool hasPurchaseInformation,
    required bool hasCollectorNotes,
  }) {
    final missingInformation = <String>[];
    final recommendations = <String>[];

    var healthScore = 100.0;
    var confidenceScore = 100.0;

    if (!hasOwnershipDate) {
      missingInformation.add('Ownership date');
      recommendations.add('Add an ownership date.');
      healthScore -= 20;
      confidenceScore -= 20;
    }

    if (!hasPurchaseInformation) {
      missingInformation.add('Purchase information');
      recommendations.add(
        'Record where and when this collectible was purchased.',
      );
      healthScore -= 15;
      confidenceScore -= 10;
    }

    if (valueEventCount == 0) {
      missingInformation.add('Value history');
      recommendations.add(
        'Record the first estimated value.',
      );
      healthScore -= 25;
      confidenceScore -= 20;
    }

    if (!hasCollectorNotes) {
      recommendations.add(
        'Add a collector note or memory.',
      );
      healthScore -= 5;
    }

    if (timelineEventCount == 0) {
      missingInformation.add('Timeline events');
      recommendations.add(
        'Begin recording Timeline events.',
      );
      healthScore -= 35;
      confidenceScore -= 25;
    }

    healthScore = healthScore.clamp(0.0, 100.0);
    confidenceScore = confidenceScore.clamp(0.0, 100.0);

    return TimelineHealth(
      timelineEventCount: timelineEventCount,
      valueEventCount: valueEventCount,
      healthScore: healthScore,
      confidenceScore: confidenceScore,
      missingInformation:
      List<String>.unmodifiable(missingInformation),
      recommendations:
      List<String>.unmodifiable(recommendations),
    );
  }
}