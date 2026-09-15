import 'package:flutter/foundation.dart';

import 'analysis_finding.dart';
import 'recommendation.dart';

@immutable
class AtlasAnalysis<TResult> {
  const AtlasAnalysis({
    required this.result,
    required this.confidence,
    this.findings = const <AnalysisFinding>[],
    this.recommendations = const <Recommendation>[],
    this.metadata = const <String, Object?>{},
  }) : assert(
         confidence >= 0 && confidence <= 1,
         'confidence must be between 0 and 1',
       );

  // The primary structured result produced by the analyst.
  //
  // Examples:
  //
  // CollectorTraitProfile
  // VaultHealthAnalysis
  // AtlasTimeline
  // List<Recommendation>
  final TResult result;

  // Overall confidence in this analysis.
  final double confidence;

  // Important discoveries made during analysis.
  final List<AnalysisFinding> findings;

  // Recommended actions produced by the analyst.
  final List<Recommendation> recommendations;

  // Extensible structured context for future framework features.
  final Map<String, Object?> metadata;

  int get confidencePercent {
    return (confidence * 100).round();
  }

  bool get hasFindings {
    return findings.isNotEmpty;
  }

  bool get hasRecommendations {
    return recommendations.isNotEmpty;
  }

  bool get hasMetadata {
    return metadata.isNotEmpty;
  }

  AtlasAnalysis<TResult> copyWith({
    TResult? result,
    double? confidence,
    List<AnalysisFinding>? findings,
    List<Recommendation>? recommendations,
    Map<String, Object?>? metadata,
  }) {
    return AtlasAnalysis<TResult>(
      result: result ?? this.result,
      confidence: confidence ?? this.confidence,
      findings: findings ?? this.findings,
      recommendations: recommendations ?? this.recommendations,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AtlasAnalysis<TResult> &&
            runtimeType == other.runtimeType &&
            result == other.result &&
            confidence == other.confidence &&
            listEquals(findings, other.findings) &&
            listEquals(recommendations, other.recommendations) &&
            mapEquals(metadata, other.metadata);
  }

  @override
  int get hashCode {
    return Object.hash(
      result,
      confidence,
      Object.hashAll(findings),
      Object.hashAll(recommendations),
      Object.hashAll(
        metadata.entries.map((entry) => Object.hash(entry.key, entry.value)),
      ),
    );
  }

  @override
  String toString() {
    return 'AtlasAnalysis('
        'confidence: $confidence, '
        'findings: ${findings.length}, '
        'recommendations: ${recommendations.length}'
        ')';
  }
}
