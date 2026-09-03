import 'models/atlas_frame_quality_assessment.dart';

final class AtlasFrameTriageConfig {
  const AtlasFrameTriageConfig({
    this.minimumSharpnessScore = 0.35,
    this.maximumGlareRatio = 0.30,
    this.maximumMotionScore = 0.55,
    this.requireAtLeastOneMetric = false,
  });

  final double minimumSharpnessScore;
  final double maximumGlareRatio;
  final double maximumMotionScore;
  final bool requireAtLeastOneMetric;
}

/// Fast-fail quality gate that runs before OCR or expensive identity work.
///
/// The gate consumes normalized metrics instead of raw pixels so the shared
/// scan domain remains independent from camera, MediaProjection, and image
/// processing plugins.
final class AtlasFrameTriageGate {
  AtlasFrameTriageGate({this.config = const AtlasFrameTriageConfig()}) {
    _validateConfig(config);
  }

  final AtlasFrameTriageConfig config;

  AtlasFrameQualityAssessment evaluate(AtlasFrameQualitySample sample) {
    final Set<AtlasFrameQualityIssue> issues = <AtlasFrameQualityIssue>{};

    if (!sample.hasAnyMetric && config.requireAtLeastOneMetric) {
      issues.add(AtlasFrameQualityIssue.missingMetrics);
    }

    final double? sharpness = sample.sharpnessScore;
    if (sharpness != null && sharpness < config.minimumSharpnessScore) {
      issues.add(AtlasFrameQualityIssue.blur);
    }

    final double? glare = sample.glareRatio;
    if (glare != null && glare > config.maximumGlareRatio) {
      issues.add(AtlasFrameQualityIssue.glare);
    }

    final double? motion = sample.motionScore;
    if (motion != null && motion > config.maximumMotionScore) {
      issues.add(AtlasFrameQualityIssue.motion);
    }

    return AtlasFrameQualityAssessment(
      decision: issues.isEmpty
          ? AtlasFrameQualityDecision.accepted
          : AtlasFrameQualityDecision.rejected,
      issues: Set<AtlasFrameQualityIssue>.unmodifiable(issues),
      availableMetricCount: sample.availableMetricCount,
    );
  }

  static void _validateConfig(AtlasFrameTriageConfig config) {
    _validateUnitScore(config.minimumSharpnessScore, 'minimumSharpnessScore');
    _validateUnitScore(config.maximumGlareRatio, 'maximumGlareRatio');
    _validateUnitScore(config.maximumMotionScore, 'maximumMotionScore');
  }

  static void _validateUnitScore(double value, String fieldName) {
    if (!value.isFinite || value < 0.0 || value > 1.0) {
      throw ArgumentError.value(
        value,
        fieldName,
        '$fieldName must be between 0.0 and 1.0.',
      );
    }
  }
}
