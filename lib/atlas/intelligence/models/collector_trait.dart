import 'package:flutter/foundation.dart';

import 'recommendation_evidence.dart';

@immutable
class CollectorTrait {
  const CollectorTrait({
    required this.id,
    required this.name,
    required this.description,
    required this.normalizedScore,
    required this.confidence,
    this.evidence = const <RecommendationEvidence>[],
    this.metadata = const <String, Object?>{},
  })  : assert(
  normalizedScore >= 0 && normalizedScore <= 1,
  'normalizedScore must be between 0 and 1',
  ),
        assert(
        confidence >= 0 && confidence <= 1,
        'confidence must be between 0 and 1',
        );

  /// Stable framework identifier.
  ///
  /// Examples:
  /// - completionist
  /// - variant_hunter
  /// - value_focused
  /// - franchise_loyalty_marvel
  final String id;

  /// User-facing trait name.
  ///
  /// Example:
  /// "Completionist"
  final String name;

  /// Plain-language explanation of what this trait measures.
  final String description;

  /// Strength of the trait, normalized from 0.0 to 1.0.
  ///
  /// Example:
  /// 0.92 = very strong completionist behavior.
  final double normalizedScore;

  /// Confidence that Atlas has enough reliable data to support the score.
  ///
  /// This is separate from the trait score.
  ///
  /// Example:
  /// A collector may have a score of 0.90 but only 0.45 confidence
  /// because the collection has very little historical data.
  final double confidence;

  /// Structured facts supporting this trait.
  final List<RecommendationEvidence> evidence;

  /// Expandable structured context for analysts, reports,
  /// Atlas Voice, Watch, and recommendation comparisons.
  final Map<String, Object?> metadata;

  int get scorePercent {
    return (normalizedScore * 100).round();
  }

  int get confidencePercent {
    return (confidence * 100).round();
  }

  bool get hasEvidence => evidence.isNotEmpty;

  bool get isStrong => normalizedScore >= 0.75;

  bool get isModerate =>
      normalizedScore >= 0.40 && normalizedScore < 0.75;

  bool get isWeak => normalizedScore < 0.40;

  CollectorTrait copyWith({
    String? id,
    String? name,
    String? description,
    double? normalizedScore,
    double? confidence,
    List<RecommendationEvidence>? evidence,
    Map<String, Object?>? metadata,
  }) {
    return CollectorTrait(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      normalizedScore: normalizedScore ?? this.normalizedScore,
      confidence: confidence ?? this.confidence,
      evidence: evidence ?? this.evidence,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CollectorTrait &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            name == other.name &&
            description == other.description &&
            normalizedScore == other.normalizedScore &&
            confidence == other.confidence &&
            listEquals(evidence, other.evidence) &&
            mapEquals(metadata, other.metadata);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      description,
      normalizedScore,
      confidence,
      Object.hashAll(evidence),
      Object.hashAll(
        metadata.entries.map(
              (entry) => Object.hash(entry.key, entry.value),
        ),
      ),
    );
  }

  @override
  String toString() {
    return 'CollectorTrait('
        'id: $id, '
        'name: $name, '
        'score: $normalizedScore, '
        'confidence: $confidence, '
        'evidenceCount: ${evidence.length}'
        ')';
  }
}