import '../../timeline/models/atlas_timeline_event.dart';
import '../../market/models/value_history_entry.dart';
import 'analyzers/insight_analyzer.dart';
import 'analyzers/milestone_analyzer.dart';
import 'analyzers/ownership_analyzer.dart';
import 'analyzers/timeline_health_analyzer.dart';
import 'analyzers/value_analyzer.dart';
import 'models/atlas_timeline_intelligence_report.dart';

class AtlasTimelineIntelligenceEngine {
  const AtlasTimelineIntelligenceEngine({
    this.ownershipAnalyzer = const OwnershipAnalyzer(),
    this.valueAnalyzer = const ValueAnalyzer(),
    this.healthAnalyzer = const TimelineHealthAnalyzer(),
    this.milestoneAnalyzer = const MilestoneAnalyzer(),
    this.insightAnalyzer = const InsightAnalyzer(),
  });

  final OwnershipAnalyzer ownershipAnalyzer;
  final ValueAnalyzer valueAnalyzer;
  final TimelineHealthAnalyzer healthAnalyzer;
  final MilestoneAnalyzer milestoneAnalyzer;
  final InsightAnalyzer insightAnalyzer;

  AtlasTimelineIntelligenceReport analyze({
    required List<AtlasTimelineEvent> timeline,
    required List<ValueHistoryEntry> valueHistory,
    required double currentValue,
    DateTime? now,
  }) {
    final generatedAt = now ?? DateTime.now();

    final ownership = ownershipAnalyzer.analyze(
      timeline: timeline,
      now: generatedAt,
    );

    final value = valueAnalyzer.analyze(
      currentValue: currentValue,
      valueHistory: valueHistory,
    );

    final health = healthAnalyzer.analyze(
      timelineEventCount: timeline.length,
      valueEventCount: value.valueEventCount,
      hasOwnershipDate: ownership.ownedSince != null,
      hasPurchaseInformation: _hasEventType(
        timeline,
        AtlasTimelineEventType.purchased,
      ),
      hasCollectorNotes: _hasCollectorInformation(timeline),
    );

    final milestones = milestoneAnalyzer.analyze(
      ownership: ownership,
      value: value,
      now: generatedAt,
    );

    final insights = insightAnalyzer.analyze(
      ownership: ownership,
      value: value,
      health: health,
      now: generatedAt,
    );

    return AtlasTimelineIntelligenceReport(
      ownership: ownership,
      value: value,
      health: health,
      insights: insights,
      milestones: milestones,
      generatedAt: generatedAt,
    );
  }

  bool _hasEventType(
    List<AtlasTimelineEvent> timeline,
    AtlasTimelineEventType type,
  ) {
    return timeline.any((event) => event.type == type);
  }

  bool _hasCollectorInformation(List<AtlasTimelineEvent> timeline) {
    return timeline.any(
      (event) =>
          event.type == AtlasTimelineEventType.noteAdded ||
          event.type == AtlasTimelineEventType.collectorMoment,
    );
  }
}
