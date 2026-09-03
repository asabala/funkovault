import 'dart:async';

import '../acquisition/atlas_evidence_accumulator.dart';
import '../models/scan_code.dart';
import '../tracking/atlas_object_track.dart';
import '../tracking/atlas_object_tracker.dart';
import '../tracking/atlas_scan_observation.dart';
import 'atlas_continuous_candidate_projector.dart';
import 'atlas_frame_triage_gate.dart';
import 'models/atlas_continuous_candidate.dart';
import 'models/atlas_frame_quality_assessment.dart';
import 'models/atlas_perception_frame_result.dart';

typedef AtlasStableCandidateSubmitter =
    bool Function({required String trackId, required ScanCode stableCode});

final class AtlasContinuousPerceptionConfig {
  const AtlasContinuousPerceptionConfig({
    this.minimumFrameInterval = const Duration(milliseconds: 250),
  });

  /// Default 250 ms cadence targets approximately 4 FPS, inside the 3-5 FPS
  /// continuous-perception budget. Callers may tune this without changing the
  /// tracking or evidence contracts.
  final Duration minimumFrameInterval;
}

/// Shared 6A foundation for camera Shelf Scan and future live-feed ingestion.
///
/// Responsibilities:
/// - sample cadence enforcement
/// - frame-quality fast-fail
/// - reuse AtlasObjectTracker for spatial persistence
/// - reuse AtlasEvidenceAccumulator for stable barcode agreement
/// - emit transient candidate/result models for HUD consumers
/// - optionally cross the existing Scanner 4 submission boundary
///
/// This coordinator never mutates the Vault and never rewrites product identity.
final class AtlasContinuousPerceptionCoordinator {
  AtlasContinuousPerceptionCoordinator({
    AtlasObjectTracker? objectTracker,
    AtlasEvidenceAccumulator? evidenceAccumulator,
    AtlasFrameTriageGate? frameTriageGate,
    this.submitStableCandidate,
    this.config = const AtlasContinuousPerceptionConfig(),
  }) : objectTracker = objectTracker ?? AtlasObjectTracker(),
       evidenceAccumulator = evidenceAccumulator ?? AtlasEvidenceAccumulator(),
       frameTriageGate = frameTriageGate ?? AtlasFrameTriageGate() {
    if (config.minimumFrameInterval.isNegative) {
      throw ArgumentError.value(
        config.minimumFrameInterval,
        'minimumFrameInterval',
        'minimumFrameInterval cannot be negative.',
      );
    }
  }

  final AtlasObjectTracker objectTracker;
  final AtlasEvidenceAccumulator evidenceAccumulator;
  final AtlasFrameTriageGate frameTriageGate;
  final AtlasStableCandidateSubmitter? submitStableCandidate;
  final AtlasContinuousPerceptionConfig config;

  final StreamController<AtlasPerceptionFrameResult> _resultsController =
      StreamController<AtlasPerceptionFrameResult>.broadcast(sync: true);

  final Set<String> _knownTrackIds = <String>{};
  final Set<String> _submittedTrackIds = <String>{};

  DateTime? _lastInputAt;
  DateTime? _lastProcessedAt;
  AtlasPerceptionFrameResult? _latestResult;
  bool _isDisposed = false;

  Stream<AtlasPerceptionFrameResult> get results => _resultsController.stream;

  AtlasPerceptionFrameResult? get latestResult => _latestResult;

  AtlasPerceptionFrameResult processFrame({
    required DateTime timestamp,
    required List<AtlasScanObservation> observations,
    AtlasFrameQualitySample? qualitySample,
  }) {
    if (_isDisposed) {
      throw StateError('AtlasContinuousPerceptionCoordinator is disposed.');
    }

    final DateTime normalizedTimestamp = timestamp.toUtc();
    final DateTime? previousInput = _lastInputAt;
    if (previousInput != null && normalizedTimestamp.isBefore(previousInput)) {
      throw ArgumentError.value(
        timestamp,
        'timestamp',
        'Frame timestamps must be monotonic.',
      );
    }
    _lastInputAt = normalizedTimestamp;

    final AtlasFrameQualityAssessment qualityAssessment = frameTriageGate
        .evaluate(qualitySample ?? AtlasFrameQualitySample());

    final DateTime? previousProcessed = _lastProcessedAt;
    if (previousProcessed != null &&
        normalizedTimestamp.difference(previousProcessed) <
            config.minimumFrameInterval) {
      return _emit(
        AtlasPerceptionFrameResult(
          timestamp: normalizedTimestamp,
          disposition: AtlasPerceptionFrameDisposition.skippedCadence,
          qualityAssessment: qualityAssessment,
          candidates: _projectCurrentCandidates(),
        ),
      );
    }

    _lastProcessedAt = normalizedTimestamp;

    final List<AtlasObjectTrack> tracked = objectTracker.processFrame(
      observations: qualityAssessment.isAccepted
          ? observations
          : const <AtlasScanObservation>[],
      timestamp: normalizedTimestamp,
    );

    final Set<String> currentTrackIds = tracked
        .map((AtlasObjectTrack track) => track.trackId)
        .toSet();
    final Set<String> expiredTrackIds = _knownTrackIds.difference(
      currentTrackIds,
    );
    _knownTrackIds
      ..clear()
      ..addAll(currentTrackIds);

    final Set<String> submittedThisFrame = <String>{};

    if (qualityAssessment.isAccepted && submitStableCandidate != null) {
      for (final AtlasObjectTrack track in tracked) {
        if (track.isCooldown || _submittedTrackIds.contains(track.trackId)) {
          continue;
        }

        final AtlasAccumulatedEvidence? evidence = evidenceAccumulator
            .evaluateTrack(track);
        if (evidence == null || !evidence.isReadyForResolution) {
          continue;
        }

        final bool accepted = submitStableCandidate!(
          trackId: track.trackId,
          stableCode: evidence.stableCode,
        );

        if (accepted) {
          _submittedTrackIds.add(track.trackId);
          submittedThisFrame.add(track.trackId);
          objectTracker.markCooldown(
            trackId: track.trackId,
            startedAt: normalizedTimestamp,
          );
        }
      }
    }

    final AtlasPerceptionFrameResult result = AtlasPerceptionFrameResult(
      timestamp: normalizedTimestamp,
      disposition: qualityAssessment.isAccepted
          ? AtlasPerceptionFrameDisposition.processed
          : AtlasPerceptionFrameDisposition.rejectedQuality,
      qualityAssessment: qualityAssessment,
      candidates: _projectCurrentCandidates(),
      expiredTrackIds: expiredTrackIds,
      submittedTrackIds: submittedThisFrame,
    );

    return _emit(result);
  }

  void reset() {
    if (_isDisposed) return;
    objectTracker.reset();
    _knownTrackIds.clear();
    _submittedTrackIds.clear();
    _lastInputAt = null;
    _lastProcessedAt = null;
    _latestResult = null;
  }

  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await _resultsController.close();
  }

  List<AtlasContinuousCandidate> _projectCurrentCandidates() {
    return objectTracker.tracks
        .map((AtlasObjectTrack track) {
          final AtlasAccumulatedEvidence? evidence = evidenceAccumulator
              .evaluateTrack(track);
          return AtlasContinuousCandidateProjector.project(
            track: track,
            accumulatedEvidence: evidence,
          );
        })
        .toList(growable: false);
  }

  AtlasPerceptionFrameResult _emit(AtlasPerceptionFrameResult result) {
    _latestResult = result;
    _resultsController.add(result);
    return result;
  }
}
