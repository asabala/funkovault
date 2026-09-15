import 'atlas_recommendation_priority.dart';
import 'atlas_recommendation_type.dart';

/// One actionable recommendation produced by Atlas.
///
/// This object contains intelligence only. Widgets, routes, colors,
/// and button behavior remain outside the engine layer.
class AtlasRecommendation {
  const AtlasRecommendation({
    required this.id,
    required this.type,
    required this.priority,
    required this.title,
    required this.description,
    required this.reason,
    required this.actionLabel,
    this.isCompleted = false,
  });

  final String id;
  final AtlasRecommendationType type;
  final AtlasRecommendationPriority priority;

  final String title;
  final String description;
  final String reason;
  final String actionLabel;

  final bool isCompleted;

  bool get isHighPriority =>
      priority == AtlasRecommendationPriority.high ||
      priority == AtlasRecommendationPriority.critical;

  AtlasRecommendation copyWith({
    String? id,
    AtlasRecommendationType? type,
    AtlasRecommendationPriority? priority,
    String? title,
    String? description,
    String? reason,
    String? actionLabel,
    bool? isCompleted,
  }) {
    return AtlasRecommendation(
      id: id ?? this.id,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      title: title ?? this.title,
      description: description ?? this.description,
      reason: reason ?? this.reason,
      actionLabel: actionLabel ?? this.actionLabel,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
