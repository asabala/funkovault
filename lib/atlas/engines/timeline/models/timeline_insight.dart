enum TimelineInsightPriority {
  low,
  medium,
  high,
  critical,
}

enum TimelineInsightCategory {
  ownership,
  value,
  milestone,
  identity,
  timeline,
  health,
  collector,
  atlasAi,
}

class TimelineInsight {
  const TimelineInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.category,
    required this.createdAt,
  });

  /// Stable identifier for this generated insight.
  final String id;

  /// Short collector-facing title.
  ///
  /// Example:
  /// "Value Increased"
  final String title;

  /// Longer explanation shown in Atlas.
  ///
  /// Example:
  /// "This collectible has increased 34% since it entered your Vault."
  final String description;

  /// Importance of this insight.
  final TimelineInsightPriority priority;

  /// General category used for filtering and future UI.
  final TimelineInsightCategory category;

  /// When Atlas generated this insight.
  final DateTime createdAt;

  bool get isHighPriority =>
      priority == TimelineInsightPriority.high ||
          priority == TimelineInsightPriority.critical;

  bool get isCritical =>
      priority == TimelineInsightPriority.critical;

  TimelineInsight copyWith({
    String? id,
    String? title,
    String? description,
    TimelineInsightPriority? priority,
    TimelineInsightCategory? category,
    DateTime? createdAt,
  }) {
    return TimelineInsight(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'TimelineInsight('
        'id: $id, '
        'title: $title, '
        'priority: $priority, '
        'category: $category'
        ')';
  }
}