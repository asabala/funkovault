import 'package:flutter/foundation.dart';

import 'recommendation_evidence.dart';

enum AnalysisFindingSeverity {
  info,
  positive,
  warning,
  critical,
}

@immutable
class AnalysisFinding {
  const AnalysisFinding({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.confidence,
    this.evidence = const <RecommendationEvidence>[],
    this.metadata = const <String, Object?>{},
  })  : assert(
  confidence >= 0 && confidence <= 1,
  'confidence must be between 0 and 1',
  );

  // Stable framework identifier.
  //
  // Examples:
  // - missing_values
  // - strongest_franchise
  // - possible_variant_groups
  final String id;

  // Short user-facing summary.
  //
  // Example:
  // "27 collectibles are missing values."
  final String title;

  // Full explanation of what the analyst discovered.
  final String description;

  // Importance or meaning of the finding.
  final AnalysisFindingSeverity severity;

  // Confidence that this finding is supported by reliable data.
  final double confidence;

  // Structured facts supporting this finding.
  final List<RecommendationEvidence> evidence;

  // Additional context for analysts, reports, Voice, Watch,
  // dashboards, and future framework features.
  final Map<String, Object?> metadata;

  int get confidencePercent {
    return (confidence * 100).round();
  }

  bool get hasEvidence {
    return evidence.isNotEmpty;
  }

  bool get isActionable {
    return severity == AnalysisFindingSeverity.warning ||
        severity == AnalysisFindingSeverity.critical;
  }

  AnalysisFinding copyWith({
    String? id,
    String? title,
    String? description,
    AnalysisFindingSeverity? severity,
    double? confidence,
    List<RecommendationEvidence>? evidence,
    Map<String, Object?>? metadata,
  }) {
    return AnalysisFinding(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      confidence: confidence ?? this.confidence,
      evidence: evidence ?? this.evidence,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AnalysisFinding &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            title == other.title &&
            description == other.description &&
            severity == other.severity &&
            confidence == other.confidence &&
            listEquals(evidence, other.evidence) &&
            mapEquals(metadata, other.metadata);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      description,
      severity,
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
    return 'AnalysisFinding('
        'id: $id, '
        'severity: $severity, '
        'confidence: $confidence, '
        'evidenceCount: ${evidence.length}'
        ')';
  }
}