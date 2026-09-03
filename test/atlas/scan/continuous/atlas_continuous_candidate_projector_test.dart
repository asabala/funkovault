import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/atlas/scan/acquisition/atlas_evidence_accumulator.dart';
import 'package:funkovault2/atlas/scan/continuous/atlas_continuous_candidate_projector.dart';
import 'package:funkovault2/atlas/scan/continuous/models/atlas_continuous_candidate.dart';
import 'package:funkovault2/atlas/scan/models/scan_code.dart';
import 'package:funkovault2/atlas/scan/tracking/atlas_object_track.dart';
import 'package:funkovault2/atlas/scan/tracking/atlas_scan_observation.dart';

void main() {
  test('projects tracker state without replacing tracker authority', () {
    final DateTime t0 = DateTime.utc(2026, 9, 3, 12);
    final AtlasObjectTrack tentative = AtlasObjectTrack.createInitial(
      trackId: 'track_1',
      observation: _observation('obs_1', t0, '889698123456'),
    );

    expect(
      AtlasContinuousCandidateProjector.project(track: tentative).lifecycle,
      AtlasContinuousCandidateLifecycle.unconfirmed,
    );

    final AtlasObjectTrack confirmed = tentative.confirm();
    expect(
      AtlasContinuousCandidateProjector.project(track: confirmed).lifecycle,
      AtlasContinuousCandidateLifecycle.accumulating,
    );

    final AtlasAccumulatedEvidence ready = AtlasAccumulatedEvidence(
      trackId: confirmed.trackId,
      stableCode: confirmed.latestObservation.code!,
      agreementConfidence: 1.0,
      totalBarcodeHits: 3,
      dominantBarcodeHits: 3,
      isReadyForResolution: true,
    );

    expect(
      AtlasContinuousCandidateProjector.project(
        track: confirmed,
        accumulatedEvidence: ready,
      ).lifecycle,
      AtlasContinuousCandidateLifecycle.candidateReady,
    );

    final AtlasObjectTrack cooldown = confirmed.startCooldown(
      t0.add(const Duration(seconds: 1)),
    );
    expect(
      AtlasContinuousCandidateProjector.project(
        track: cooldown,
        accumulatedEvidence: ready,
      ).lifecycle,
      AtlasContinuousCandidateLifecycle.submitted,
    );
  });
}

AtlasScanObservation _observation(
  String id,
  DateTime capturedAt,
  String barcode,
) {
  return AtlasScanObservation(
    observationId: id,
    capturedAt: capturedAt,
    code: ScanCode(
      rawValue: barcode,
      normalizedValue: barcode,
      format: ScanCodeFormat.upcA,
      source: ScanCodeSource.camera,
      capturedAt: capturedAt,
      isValid: true,
      confidence: 1.0,
    ),
    cornerPoints: <AtlasNormalizedPoint>[
      AtlasNormalizedPoint(x: 0.45, y: 0.45),
      AtlasNormalizedPoint(x: 0.55, y: 0.45),
      AtlasNormalizedPoint(x: 0.55, y: 0.55),
      AtlasNormalizedPoint(x: 0.45, y: 0.55),
    ],
  );
}
