import 'atlas_continuous_candidate.dart';
import 'atlas_frame_quality_assessment.dart';

enum AtlasPerceptionFrameDisposition {
  processed,
  rejectedQuality,
  skippedCadence,
}

/// Immutable result emitted for one sampled perception frame.
///
/// Expired tracks are represented as IDs because spatial staleness remains
/// authoritative in AtlasObjectTracker; this model does not create a second
/// competing stale-track lifecycle.
final class AtlasPerceptionFrameResult {
  AtlasPerceptionFrameResult({
    required this.timestamp,
    required this.disposition,
    required this.qualityAssessment,
    List<AtlasContinuousCandidate> candidates =
        const <AtlasContinuousCandidate>[],
    Set<String> expiredTrackIds = const <String>{},
    Set<String> submittedTrackIds = const <String>{},
  }) : candidates = List<AtlasContinuousCandidate>.unmodifiable(candidates),
       expiredTrackIds = Set<String>.unmodifiable(expiredTrackIds),
       submittedTrackIds = Set<String>.unmodifiable(submittedTrackIds);

  final DateTime timestamp;
  final AtlasPerceptionFrameDisposition disposition;
  final AtlasFrameQualityAssessment qualityAssessment;
  final List<AtlasContinuousCandidate> candidates;
  final Set<String> expiredTrackIds;
  final Set<String> submittedTrackIds;

  bool get wasProcessed =>
      disposition == AtlasPerceptionFrameDisposition.processed;

  bool get wasQualityRejected =>
      disposition == AtlasPerceptionFrameDisposition.rejectedQuality;

  bool get wasCadenceSkipped =>
      disposition == AtlasPerceptionFrameDisposition.skippedCadence;
}
