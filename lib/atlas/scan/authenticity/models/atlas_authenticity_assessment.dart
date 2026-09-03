import 'atlas_authenticity_evidence.dart';
import 'atlas_authenticity_signal.dart';
import 'atlas_production_stamp.dart';

enum AtlasAuthenticityStatus {
  strongEvidence,
  developingEvidence,
  reviewRecommended,
  insufficientEvidence,
}

enum AtlasAuthenticityConcernLevel {
  noObviousConcerns,
  reviewRecommended,
  significantInconsistencies,
  strongCounterfeitIndicators,
  insufficientData,
}

final class AtlasAuthenticityAssessment {
  AtlasAuthenticityAssessment({
    required this.status,
    required this.concernLevel,
    required double evidenceConfidence,
    required double referenceCoverage,
    required double inspectionCoverage,
    required double aggregatedConcernScore,
    required this.summary,
    required List<AtlasAuthenticitySignal> signals,
    List<AtlasEvaluatedAuthenticitySignal> evaluatedSignals =
        const <AtlasEvaluatedAuthenticitySignal>[],
    List<AtlasInspectionArea> uninspectedAreas = const <AtlasInspectionArea>[],
    List<String> auditLog = const <String>[],
    this.productionStamp,
  }) : evidenceConfidence = _unitScore(
         evidenceConfidence,
         'evidenceConfidence',
       ),
       referenceCoverage = _unitScore(referenceCoverage, 'referenceCoverage'),
       inspectionCoverage = _unitScore(
         inspectionCoverage,
         'inspectionCoverage',
       ),
       aggregatedConcernScore = _unitScore(
         aggregatedConcernScore,
         'aggregatedConcernScore',
       ),
       signals = List<AtlasAuthenticitySignal>.unmodifiable(signals),
       evaluatedSignals = List<AtlasEvaluatedAuthenticitySignal>.unmodifiable(
         evaluatedSignals,
       ),
       uninspectedAreas = List<AtlasInspectionArea>.unmodifiable(
         uninspectedAreas,
       ),
       auditLog = List<String>.unmodifiable(auditLog);

  final AtlasAuthenticityStatus status;
  final AtlasAuthenticityConcernLevel concernLevel;

  /// How clearly Atlas could observe the supplied evidence.
  final double evidenceConfidence;

  /// How complete/trustworthy the product reference criteria are.
  final double referenceCoverage;

  /// How much of the guided inspection surface was actually inspected.
  final double inspectionCoverage;

  /// Normalized concern score after category caps and correlation clamping.
  final double aggregatedConcernScore;

  final String summary;
  final List<AtlasAuthenticitySignal> signals;
  final List<AtlasEvaluatedAuthenticitySignal> evaluatedSignals;
  final List<AtlasInspectionArea> uninspectedAreas;
  final List<String> auditLog;
  final AtlasProductionStamp? productionStamp;

  // Backward-compatible accessors used by the existing engine/UI.
  int get confidenceScore =>
      (evidenceConfidence * 100).round().clamp(0, 100).toInt();
  int get evidenceCoverage =>
      (inspectionCoverage * 100).round().clamp(0, 100).toInt();

  bool get requiresReview =>
      concernLevel == AtlasAuthenticityConcernLevel.reviewRecommended ||
      concernLevel ==
          AtlasAuthenticityConcernLevel.significantInconsistencies ||
      concernLevel ==
          AtlasAuthenticityConcernLevel.strongCounterfeitIndicators ||
      concernLevel == AtlasAuthenticityConcernLevel.insufficientData;

  bool get hasWarnings => signals.any((AtlasAuthenticitySignal signal) {
    return signal.isWarning;
  });

  bool get hasEnoughReferenceData => referenceCoverage >= 0.50;

  static double _unitScore(double value, String name) {
    if (!value.isFinite || value < 0.0 || value > 1.0) {
      throw ArgumentError.value(
        value,
        name,
        '$name must be between 0.0 and 1.0.',
      );
    }
    return value;
  }
}
