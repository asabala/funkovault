enum TimelineMilestoneType {
  ownership,
  value,
  collection,
  collector,
  identity,
  anniversary,
  atlas,
}

class TimelineMilestone {
  const TimelineMilestone({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.achievedAt,
  });

  /// Stable identifier for this milestone.
  final String id;

  /// Category of milestone.
  final TimelineMilestoneType type;

  /// Collector-facing title.
  ///
  /// Example:
  /// "Owned One Year"
  final String title;

  /// Optional explanation shown to the collector.
  ///
  /// Example:
  /// "You've owned this collectible for one full year."
  final String description;

  /// Date the milestone was achieved.
  final DateTime achievedAt;

  TimelineMilestone copyWith({
    String? id,
    TimelineMilestoneType? type,
    String? title,
    String? description,
    DateTime? achievedAt,
  }) {
    return TimelineMilestone(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      achievedAt: achievedAt ?? this.achievedAt,
    );
  }

  @override
  String toString() {
    return 'TimelineMilestone('
        'id: $id, '
        'type: $type, '
        'title: $title'
        ')';
  }
}
