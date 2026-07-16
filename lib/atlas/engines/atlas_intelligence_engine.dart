import '../../models/activity.dart';
import '../../models/pop.dart';
import 'atlas_confidence_engine.dart';
import 'pop_activity_summary_engine.dart';

class AtlasIntelligenceReport {
  const AtlasIntelligenceReport({
    required this.primaryFocusTitle,
    required this.primaryFocusMessage,
    required this.confidenceScore,
    required this.confidenceMessage,
  });

  final String primaryFocusTitle;
  final String primaryFocusMessage;
  final double confidenceScore;
  final String confidenceMessage;
}

class AtlasIntelligenceEngine {
  const AtlasIntelligenceEngine();

  AtlasIntelligenceReport analyze({
    required List<Pop> pops,
    required int duplicateCount,
    required int missingValueCount,
  }) {
    const confidenceEngine = AtlasConfidenceEngine();

    final confidence = confidenceEngine.calculate(pops);

    if (duplicateCount > 0) {
      return AtlasIntelligenceReport(
        primaryFocusTitle: 'Review Duplicates',
        primaryFocusMessage:
        'Atlas found $duplicateCount possible duplicate group${duplicateCount == 1 ? '' : 's'}.',
        confidenceScore: confidence.score,
        confidenceMessage: confidence.message,
      );
    }

    if (missingValueCount > 0) {
      return AtlasIntelligenceReport(
        primaryFocusTitle: 'Complete Missing Values',
        primaryFocusMessage:
        '$missingValueCount Pop${missingValueCount == 1 ? '' : 's'} need estimated values.',
        confidenceScore: confidence.score,
        confidenceMessage: confidence.message,
      );
    }

    return AtlasIntelligenceReport(
      primaryFocusTitle: 'Vault Looks Strong',
      primaryFocusMessage:
      'Atlas found no critical issues that need attention right now.',
      confidenceScore: confidence.score,
      confidenceMessage: confidence.message,
    );
  }

  PopActivitySummary analyzePopActivity({
    required Pop pop,
    required List<Activity> activities,
  }) {
    const activitySummaryEngine = PopActivitySummaryEngine();

    return activitySummaryEngine.build(
      popId: pop.id,
      popName: pop.name,
      popNumber: pop.number,
      activities: activities,
    );
  }
}