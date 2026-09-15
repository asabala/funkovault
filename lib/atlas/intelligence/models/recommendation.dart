import 'package:flutter/foundation.dart';

import 'recommendation_reason.dart';

enum RecommendationPriority { low, medium, high, critical }

@immutable
class Recommendation {
  const Recommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.confidence,
    this.reasons = const <RecommendationReason>[],
    this.expectedImpact,
    this.metadata = const <String, Object?>{},
  }) : assert(
         confidence >= 0 && confidence <= 1,
         'confidence must be between 0 and 1',
       );

  final String id;

  /// Short recommendation title.
  final String title;

  /// Full explanation presented to the collector.
  final String description;

  /// Importance relative to other recommendations.
  final RecommendationPriority priority;

  /// Overall confidence from 0.0–1.0.
  final double confidence;

  /// Structured reasoning behind this recommendation.
  final List<RecommendationReason> reasons;

  /// Optional measurable outcome.
  ///
  /// Examples:
  /// +18% Collection Health
  /// +$740 Estimated Value
  /// Complete Disney Collection
  final String? expectedImpact;

  /// Expandable structured context.
  final Map<String, Object?> metadata;

  int get confidencePercent => (confidence * 100).round();

  bool get hasReasons => reasons.isNotEmpty;

  bool get hasExpectedImpact =>
      expectedImpact != null && expectedImpact!.trim().isNotEmpty;

  Recommendation copyWith({
    String? id,
    String? title,
    String? description,
    RecommendationPriority? priority,
    double? confidence,
    List<RecommendationReason>? reasons,
    String? expectedImpact,
    bool clearExpectedImpact = false,
    Map<String, Object?>? metadata,
  }) {
    return Recommendation(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      confidence: confidence ?? this.confidence,
      reasons: reasons ?? this.reasons,
      expectedImpact: clearExpectedImpact
          ? null
          : expectedImpact ?? this.expectedImpact,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Recommendation &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            title == other.title &&
            description == other.description &&
            priority == other.priority &&
            confidence == other.confidence &&
            listEquals(reasons, other.reasons) &&
            expectedImpact == other.expectedImpact &&
            mapEquals(metadata, other.metadata);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      description,
      priority,
      confidence,
      Object.hashAll(reasons),
      expectedImpact,
      Object.hashAll(
        metadata.entries.map((entry) => Object.hash(entry.key, entry.value)),
      ),
    );
  }

  @override
  String toString() {
    return 'Recommendation('
        'id: $id, '
        'priority: $priority, '
        'confidence: $confidence, '
        'reasonCount: ${reasons.length}'
        ')';
  }
}
