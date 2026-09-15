class TimelineHealth {
  const TimelineHealth({
    required this.timelineEventCount,
    required this.valueEventCount,
    required this.healthScore,
    required this.confidenceScore,
    required this.missingInformation,
    required this.recommendations,
  });

  /// Number of valid collector Timeline events analyzed.
  final int timelineEventCount;

  /// Number of valid value history records analyzed.
  final int valueEventCount;

  /// Overall history completeness score from 0 to 100.
  ///
  /// This reflects how complete the collectible's Timeline and value history
  /// appear to be.
  final double healthScore;

  /// Confidence score from 0 to 100.
  ///
  /// This reflects how confidently Atlas can interpret the available history.
  final double confidenceScore;

  /// Important history details that are currently unavailable.
  ///
  /// Examples:
  /// - Purchase information
  /// - First value
  /// - Ownership date
  final List<String> missingInformation;

  /// Collector-facing actions that can improve Timeline quality.
  ///
  /// Examples:
  /// - Add purchase information
  /// - Record a collector note
  /// - Add the first estimated value
  final List<String> recommendations;

  bool get hasTimelineEvents => timelineEventCount > 0;

  bool get hasValueEvents => valueEventCount > 0;

  bool get hasMissingInformation => missingInformation.isNotEmpty;

  bool get hasRecommendations => recommendations.isNotEmpty;

  bool get isComplete => healthScore >= 90;

  bool get isHealthy => healthScore >= 70;

  bool get hasHighConfidence => confidenceScore >= 80;

  String get healthLabel {
    if (healthScore >= 90) {
      return 'Excellent';
    }

    if (healthScore >= 70) {
      return 'Good';
    }

    if (healthScore >= 50) {
      return 'Developing';
    }

    if (healthScore > 0) {
      return 'Limited';
    }

    return 'Unknown';
  }

  String get confidenceLabel {
    if (confidenceScore >= 90) {
      return 'Very High';
    }

    if (confidenceScore >= 75) {
      return 'High';
    }

    if (confidenceScore >= 50) {
      return 'Moderate';
    }

    if (confidenceScore > 0) {
      return 'Low';
    }

    return 'Unknown';
  }

  TimelineHealth copyWith({
    int? timelineEventCount,
    int? valueEventCount,
    double? healthScore,
    double? confidenceScore,
    List<String>? missingInformation,
    List<String>? recommendations,
  }) {
    return TimelineHealth(
      timelineEventCount: timelineEventCount ?? this.timelineEventCount,
      valueEventCount: valueEventCount ?? this.valueEventCount,
      healthScore: healthScore ?? this.healthScore,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      missingInformation: missingInformation ?? this.missingInformation,
      recommendations: recommendations ?? this.recommendations,
    );
  }

  @override
  String toString() {
    return 'TimelineHealth('
        'timelineEventCount: $timelineEventCount, '
        'valueEventCount: $valueEventCount, '
        'healthScore: $healthScore, '
        'confidenceScore: $confidenceScore, '
        'missingInformation: $missingInformation, '
        'recommendations: $recommendations'
        ')';
  }
}
