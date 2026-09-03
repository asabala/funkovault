import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/atlas/scan/acquisition/atlas_evidence_accumulator.dart';
import 'package:funkovault2/atlas/scan/continuous/atlas_continuous_perception_coordinator.dart';
import 'package:funkovault2/atlas/scan/continuous/atlas_frame_triage_gate.dart';
import 'package:funkovault2/atlas/scan/continuous/models/atlas_continuous_candidate.dart';
import 'package:funkovault2/atlas/scan/continuous/models/atlas_frame_quality_assessment.dart';
import 'package:funkovault2/atlas/scan/continuous/models/atlas_perception_frame_result.dart';
import 'package:funkovault2/atlas/scan/models/scan_code.dart';
import 'package:funkovault2/atlas/scan/tracking/atlas_object_tracker.dart';
import 'package:funkovault2/atlas/scan/tracking/atlas_scan_observation.dart';

void main() {
  test(
    'stable candidate crosses submission boundary once and enters cooldown',
    () async {
      int submitCount = 0;
      final AtlasContinuousPerceptionCoordinator coordinator =
          AtlasContinuousPerceptionCoordinator(
            objectTracker: AtlasObjectTracker(
              config: const AtlasObjectTrackerConfig(confirmationMinHits: 2),
            ),
            evidenceAccumulator: AtlasEvidenceAccumulator(
              config: const AtlasEvidenceAccumulatorConfig(
                minBarcodeHits: 2,
                dominantBarcodeThreshold: 0.75,
              ),
            ),
            config: const AtlasContinuousPerceptionConfig(
              minimumFrameInterval: Duration.zero,
            ),
            submitStableCandidate:
                ({required String trackId, required ScanCode stableCode}) {
                  submitCount++;
                  return true;
                },
          );

      final DateTime t0 = DateTime.utc(2026, 9, 3, 12);
      coordinator.processFrame(
        timestamp: t0,
        observations: <AtlasScanObservation>[
          _observation('obs_1', t0, '889698123456'),
        ],
      );

      final AtlasPerceptionFrameResult second = coordinator.processFrame(
        timestamp: t0.add(const Duration(milliseconds: 100)),
        observations: <AtlasScanObservation>[
          _observation(
            'obs_2',
            t0.add(const Duration(milliseconds: 100)),
            '889698123456',
          ),
        ],
      );

      expect(submitCount, 1);
      expect(second.submittedTrackIds, hasLength(1));
      expect(
        second.candidates.single.lifecycle,
        AtlasContinuousCandidateLifecycle.submitted,
      );

      coordinator.processFrame(
        timestamp: t0.add(const Duration(milliseconds: 200)),
        observations: <AtlasScanObservation>[
          _observation(
            'obs_3',
            t0.add(const Duration(milliseconds: 200)),
            '889698123456',
          ),
        ],
      );

      expect(submitCount, 1);
      await coordinator.dispose();
    },
  );

  test(
    'quality rejection drops observations before they can pollute tracking',
    () async {
      final AtlasContinuousPerceptionCoordinator coordinator =
          AtlasContinuousPerceptionCoordinator(
            frameTriageGate: AtlasFrameTriageGate(
              config: const AtlasFrameTriageConfig(
                requireAtLeastOneMetric: true,
              ),
            ),
            config: const AtlasContinuousPerceptionConfig(
              minimumFrameInterval: Duration.zero,
            ),
          );

      final DateTime t0 = DateTime.utc(2026, 9, 3, 12);
      final AtlasPerceptionFrameResult result = coordinator.processFrame(
        timestamp: t0,
        observations: <AtlasScanObservation>[
          _observation('bad_1', t0, '889698123456'),
        ],
        qualitySample: AtlasFrameQualitySample(
          sharpnessScore: 0.05,
          glareRatio: 0.90,
          motionScore: 0.95,
        ),
      );

      expect(result.wasQualityRejected, isTrue);
      expect(result.candidates, isEmpty);
      expect(coordinator.objectTracker.tracks, isEmpty);
      await coordinator.dispose();
    },
  );

  test(
    'expired tracks are emitted as events instead of becoming a second stale state',
    () async {
      final AtlasContinuousPerceptionCoordinator coordinator =
          AtlasContinuousPerceptionCoordinator(
            objectTracker: AtlasObjectTracker(
              config: const AtlasObjectTrackerConfig(
                tentativeTtl: Duration(milliseconds: 500),
                confirmationMinHits: 3,
              ),
            ),
            config: const AtlasContinuousPerceptionConfig(
              minimumFrameInterval: Duration.zero,
            ),
          );

      final DateTime t0 = DateTime.utc(2026, 9, 3, 12);
      final AtlasPerceptionFrameResult first = coordinator.processFrame(
        timestamp: t0,
        observations: <AtlasScanObservation>[
          _observation('stale_1', t0, '889698123456'),
        ],
      );
      final String trackId = first.candidates.single.trackId;

      final AtlasPerceptionFrameResult expired = coordinator.processFrame(
        timestamp: t0.add(const Duration(milliseconds: 501)),
        observations: const <AtlasScanObservation>[],
      );

      expect(expired.expiredTrackIds, contains(trackId));
      expect(expired.candidates, isEmpty);
      await coordinator.dispose();
    },
  );

  test('cadence skips frames without advancing tracker evidence', () async {
    final AtlasContinuousPerceptionCoordinator coordinator =
        AtlasContinuousPerceptionCoordinator(
          config: const AtlasContinuousPerceptionConfig(
            minimumFrameInterval: Duration(milliseconds: 250),
          ),
        );

    final DateTime t0 = DateTime.utc(2026, 9, 3, 12);
    coordinator.processFrame(
      timestamp: t0,
      observations: <AtlasScanObservation>[
        _observation('cadence_1', t0, '889698123456'),
      ],
    );

    final AtlasPerceptionFrameResult skipped = coordinator.processFrame(
      timestamp: t0.add(const Duration(milliseconds: 100)),
      observations: <AtlasScanObservation>[
        _observation(
          'cadence_2',
          t0.add(const Duration(milliseconds: 100)),
          '889698123456',
        ),
      ],
    );

    expect(skipped.wasCadenceSkipped, isTrue);
    expect(coordinator.objectTracker.tracks.single.observationCount, 1);
    await coordinator.dispose();
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
