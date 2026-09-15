import 'package:flutter/foundation.dart';

import 'recommendation_evidence.dart';

@immutable
class RecommendationReason {
  const RecommendationReason({
    required this.id,
    required this.title,
    required this.explanation,
    required this.confidence,
    this.evidence = const <RecommendationEvidence>[],
    this.metadata = const <String, Object?>{},
  }) : assert(
         confidence >= 0 && confidence <= 1,
         'confidence must be between 0 and 1',
       );

  final String id;

  /// Short interpretation suitable for cards and summaries.
  ///
  /// Example:
  /// "You are close to completing this collection."
  final String title;

  /// Full explanation of why Atlas reached this conclusion.
  ///
  /// Example:
  /// "You already own 18 of the 21 collectibles in this series."
  final String explanation;

  /// Confidence stored as a normalized value from 0.0 to 1.0.
  ///
  /// Examples:
  /// - 0.95 = 95%
  /// - 0.72 = 72%
  final double confidence;

  /// Facts that support this interpretation.
  final List<RecommendationEvidence> evidence;

  /// Additional structured context for future analysts,
  /// Atlas Voice, reports, or recommendation comparisons.
  final Map<String, Object?> metadata;

  int get confidencePercent {
    return (confidence * 100).round();
  }

  bool get hasEvidence => evidence.isNotEmpty;

  RecommendationReason copyWith({
    String? id,
    String? title,
    String? explanation,
    double? confidence,
    List<RecommendationEvidence>? evidence,
    Map<String, Object?>? metadata,
  }) {
    return RecommendationReason(
      id: id ?? this.id,
      title: title ?? this.title,
      explanation: explanation ?? this.explanation,
      confidence: confidence ?? this.confidence,
      evidence: evidence ?? this.evidence,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is RecommendationReason &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            title == other.title &&
            explanation == other.explanation &&
            confidence == other.confidence &&
            listEquals(evidence, other.evidence) &&
            mapEquals(metadata, other.metadata);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      explanation,
      confidence,
      Object.hashAll(evidence),
      Object.hashAll(
        metadata.entries.map((entry) => Object.hash(entry.key, entry.value)),
      ),
    );
  }

  @override
  String toString() {
    return 'RecommendationReason('
        'id: $id, '
        'title: $title, '
        'confidence: $confidence, '
        'evidenceCount: ${evidence.length}'
        ')';
  }
}
