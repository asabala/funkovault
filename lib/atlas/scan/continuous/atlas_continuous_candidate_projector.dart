import '../acquisition/atlas_evidence_accumulator.dart';
import '../tracking/atlas_object_track.dart';
import 'models/atlas_continuous_candidate.dart';

abstract final class AtlasContinuousCandidateProjector {
  static AtlasContinuousCandidate project({
    required AtlasObjectTrack track,
    AtlasAccumulatedEvidence? accumulatedEvidence,
  }) {
    final AtlasContinuousCandidateLifecycle lifecycle;

    if (track.isCooldown) {
      lifecycle = AtlasContinuousCandidateLifecycle.submitted;
    } else if (accumulatedEvidence?.isReadyForResolution ?? false) {
      lifecycle = AtlasContinuousCandidateLifecycle.candidateReady;
    } else if (track.isConfirmed || track.observationCount > 1) {
      lifecycle = AtlasContinuousCandidateLifecycle.accumulating;
    } else {
      lifecycle = AtlasContinuousCandidateLifecycle.unconfirmed;
    }

    return AtlasContinuousCandidate(
      trackId: track.trackId,
      lifecycle: lifecycle,
      firstSeenAt: track.firstSeenAt,
      lastSeenAt: track.lastSeenAt,
      observationCount: track.observationCount,
      barcodeHitCount: track.usableBarcodeHitCount,
      latestObservationConfidence: track.latestObservation.confidence,
      centroid: track.centroid,
      normalizedBounds: track.normalizedBounds,
      stableCode: accumulatedEvidence?.stableCode,
      barcodeAgreementConfidence: accumulatedEvidence?.agreementConfidence,
    );
  }
}
