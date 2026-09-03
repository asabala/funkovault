import '../../models/scan_code.dart';
import '../../tracking/atlas_scan_observation.dart';

enum AtlasContinuousCandidateLifecycle {
  unconfirmed,
  accumulating,
  candidateReady,
  submitted,
}

/// Transient continuous-perception view of one physical scanner track.
///
/// This model never mutates product identity, the scan ledger, or the Vault.
/// It only describes what the perception layer currently knows about a track.
final class AtlasContinuousCandidate {
  const AtlasContinuousCandidate({
    required this.trackId,
    required this.lifecycle,
    required this.firstSeenAt,
    required this.lastSeenAt,
    required this.observationCount,
    required this.barcodeHitCount,
    required this.latestObservationConfidence,
    this.centroid,
    this.normalizedBounds,
    this.stableCode,
    this.barcodeAgreementConfidence,
  });

  final String trackId;
  final AtlasContinuousCandidateLifecycle lifecycle;
  final DateTime firstSeenAt;
  final DateTime lastSeenAt;
  final int observationCount;
  final int barcodeHitCount;
  final double latestObservationConfidence;
  final AtlasNormalizedPoint? centroid;
  final AtlasNormalizedBounds? normalizedBounds;
  final ScanCode? stableCode;
  final double? barcodeAgreementConfidence;

  bool get isResolutionReady =>
      lifecycle == AtlasContinuousCandidateLifecycle.candidateReady;

  bool get isSubmitted =>
      lifecycle == AtlasContinuousCandidateLifecycle.submitted;

  bool get hasStableCode => stableCode != null;
}
