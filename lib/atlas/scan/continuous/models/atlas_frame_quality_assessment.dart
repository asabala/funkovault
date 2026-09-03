enum AtlasFrameQualityIssue { blur, glare, motion, missingMetrics }

enum AtlasFrameQualityDecision { accepted, rejected }

/// Plugin-neutral frame-quality metrics normalized to the range 0.0-1.0.
///
/// Pixel algorithms are intentionally outside this model. Camera, screen-capture,
/// or native adapters may compute these metrics using the cheapest available
/// implementation and pass them into the shared Atlas triage gate.
final class AtlasFrameQualitySample {
  AtlasFrameQualitySample({
    this.sharpnessScore,
    this.glareRatio,
    this.motionScore,
  }) {
    _validateUnitScore(sharpnessScore, 'sharpnessScore');
    _validateUnitScore(glareRatio, 'glareRatio');
    _validateUnitScore(motionScore, 'motionScore');
  }

  final double? sharpnessScore;

  /// Approximate fraction of the frame affected by clipped/highlight glare.
  final double? glareRatio;

  /// Normalized motion magnitude where 0.0 is stable and 1.0 is extreme motion.
  final double? motionScore;

  int get availableMetricCount => <double?>[
    sharpnessScore,
    glareRatio,
    motionScore,
  ].whereType<double>().length;

  bool get hasAnyMetric => availableMetricCount > 0;

  bool get hasAllMetrics => availableMetricCount == 3;

  static void _validateUnitScore(double? value, String fieldName) {
    if (value == null) return;
    if (!value.isFinite || value < 0.0 || value > 1.0) {
      throw ArgumentError.value(
        value,
        fieldName,
        '$fieldName must be between 0.0 and 1.0.',
      );
    }
  }
}

final class AtlasFrameQualityAssessment {
  const AtlasFrameQualityAssessment({
    required this.decision,
    required this.issues,
    required this.availableMetricCount,
  });

  final AtlasFrameQualityDecision decision;
  final Set<AtlasFrameQualityIssue> issues;
  final int availableMetricCount;

  bool get isAccepted => decision == AtlasFrameQualityDecision.accepted;

  bool get isRejected => decision == AtlasFrameQualityDecision.rejected;

  bool get hasQualityMetrics => availableMetricCount > 0;

  bool get hasCompleteQualityMetrics => availableMetricCount == 3;
}
