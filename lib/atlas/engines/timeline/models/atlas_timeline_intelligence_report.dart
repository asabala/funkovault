import 'ownership_analysis.dart';
import 'timeline_health.dart';
import 'timeline_insight.dart';
import 'timeline_milestone.dart';
import 'value_analysis.dart';

class AtlasTimelineIntelligenceReport {
  const AtlasTimelineIntelligenceReport({
    required this.ownership,
    required this.value,
    required this.health,
    required this.insights,
    required this.milestones,
    required this.generatedAt,
  });

  /// Ownership-related intelligence derived from Timeline history.
  final OwnershipAnalysis ownership;

  /// Value intelligence derived from value history.
  final ValueAnalysis value;

  /// Completeness and confidence assessment for the available history.
  final TimelineHealth health;

  /// Collector-facing observations generated from the available evidence.
  final List<TimelineInsight> insights;

  /// Achievements derived from ownership, value, and Timeline history.
  final List<TimelineMilestone> milestones;

  /// Date and time this report was generated.
  final DateTime generatedAt;

  bool get hasInsights => insights.isNotEmpty;

  bool get hasMilestones => milestones.isNotEmpty;

  bool get hasOwnershipHistory => ownership.hasOwnershipHistory;

  bool get hasValueHistory => value.hasValueHistory;

  bool get hasMeaningfulIntelligence =>
      hasOwnershipHistory || hasValueHistory || hasInsights || hasMilestones;

  int get highPriorityInsightCount {
    return insights.where((insight) => insight.isHighPriority).length;
  }

  int get criticalInsightCount {
    return insights.where((insight) => insight.isCritical).length;
  }

  List<TimelineInsight> get highPriorityInsights {
    return List<TimelineInsight>.unmodifiable(
      insights.where((insight) => insight.isHighPriority),
    );
  }

  List<TimelineInsight> get criticalInsights {
    return List<TimelineInsight>.unmodifiable(
      insights.where((insight) => insight.isCritical),
    );
  }

  AtlasTimelineIntelligenceReport copyWith({
    OwnershipAnalysis? ownership,
    ValueAnalysis? value,
    TimelineHealth? health,
    List<TimelineInsight>? insights,
    List<TimelineMilestone>? milestones,
    DateTime? generatedAt,
  }) {
    return AtlasTimelineIntelligenceReport(
      ownership: ownership ?? this.ownership,
      value: value ?? this.value,
      health: health ?? this.health,
      insights: insights ?? this.insights,
      milestones: milestones ?? this.milestones,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  @override
  String toString() {
    return 'AtlasTimelineIntelligenceReport('
        'ownership: $ownership, '
        'value: $value, '
        'health: $health, '
        'insightCount: ${insights.length}, '
        'milestoneCount: ${milestones.length}, '
        'generatedAt: $generatedAt'
        ')';
  }
}
