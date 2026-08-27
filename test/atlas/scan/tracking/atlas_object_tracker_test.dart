import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/atlas/scan/acquisition/atlas_evidence_accumulator.dart';
import 'package:funkovault2/atlas/scan/models/scan_code.dart';
import 'package:funkovault2/atlas/scan/tracking/atlas_object_track.dart';
import 'package:funkovault2/atlas/scan/tracking/atlas_object_tracker.dart';
import 'package:funkovault2/atlas/scan/tracking/atlas_scan_observation.dart';

void main() {
  group('AtlasObjectTracker', () {
    test('two observations in the same frame cannot claim the same track', () {
      final AtlasObjectTracker tracker = AtlasObjectTracker(
        config: const AtlasObjectTrackerConfig(
          maxMatchDistance: 0.20,
          confirmationMinHits: 2,
        ),
      );

      final DateTime t0 = DateTime.utc(2026, 8, 27, 12);

      tracker.processFrame(
        observations: <AtlasScanObservation>[
          _observation(
            id: 'obs_1',
            capturedAt: t0,
            barcode: '889698111111',
            centerX: 0.50,
            centerY: 0.50,
          ),
        ],
        timestamp: t0,
      );

      final List<AtlasObjectTrack> tracks = tracker.processFrame(
        observations: <AtlasScanObservation>[
          _observation(
            id: 'obs_2',
            capturedAt: t0.add(const Duration(milliseconds: 100)),
            barcode: '889698111111',
            centerX: 0.49,
            centerY: 0.50,
          ),
          _observation(
            id: 'obs_3',
            capturedAt: t0.add(const Duration(milliseconds: 100)),
            barcode: '889698111111',
            centerX: 0.51,
            centerY: 0.50,
          ),
        ],
        timestamp: t0.add(const Duration(milliseconds: 100)),
      );

      expect(tracks, hasLength(2));
      expect(
        tracks.map((AtlasObjectTrack track) => track.observationCount),
        containsAll(<int>[2, 1]),
      );
    });

    test(
      'two physical objects may share the same UPC and remain separate tracks',
      () {
        final AtlasObjectTracker tracker = AtlasObjectTracker(
          config: const AtlasObjectTrackerConfig(
            maxMatchDistance: 0.08,
            confirmationMinHits: 2,
          ),
        );

        final DateTime t0 = DateTime.utc(2026, 8, 27, 12);

        List<AtlasObjectTrack> tracks = tracker.processFrame(
          observations: <AtlasScanObservation>[
            _observation(
              id: 'left_1',
              capturedAt: t0,
              barcode: '889698222222',
              centerX: 0.25,
              centerY: 0.50,
            ),
            _observation(
              id: 'right_1',
              capturedAt: t0,
              barcode: '889698222222',
              centerX: 0.75,
              centerY: 0.50,
            ),
          ],
          timestamp: t0,
        );

        expect(tracks, hasLength(2));

        tracks = tracker.processFrame(
          observations: <AtlasScanObservation>[
            _observation(
              id: 'left_2',
              capturedAt: t0.add(const Duration(milliseconds: 100)),
              barcode: '889698222222',
              centerX: 0.26,
              centerY: 0.50,
            ),
            _observation(
              id: 'right_2',
              capturedAt: t0.add(const Duration(milliseconds: 100)),
              barcode: '889698222222',
              centerX: 0.74,
              centerY: 0.50,
            ),
          ],
          timestamp: t0.add(const Duration(milliseconds: 100)),
        );

        expect(tracks, hasLength(2));
        expect(
          tracks.every((AtlasObjectTrack track) => track.isConfirmed),
          isTrue,
        );
        expect(
          tracks.every(
            (AtlasObjectTrack track) =>
                track.barcodeEvidenceByKey.length == 1 &&
                track.usableBarcodeHitCount == 2,
          ),
          isTrue,
        );
      },
    );

    test('tentative track confirms after configured hit threshold', () {
      final AtlasObjectTracker tracker = AtlasObjectTracker(
        config: const AtlasObjectTrackerConfig(confirmationMinHits: 3),
      );

      final DateTime t0 = DateTime.utc(2026, 8, 27, 12);

      List<AtlasObjectTrack> tracks = tracker.processFrame(
        observations: <AtlasScanObservation>[
          _observation(
            id: 'confirm_1',
            capturedAt: t0,
            barcode: '889698333333',
          ),
        ],
        timestamp: t0,
      );

      expect(tracks.single.isTentative, isTrue);

      tracks = tracker.processFrame(
        observations: <AtlasScanObservation>[
          _observation(
            id: 'confirm_2',
            capturedAt: t0.add(const Duration(milliseconds: 100)),
            barcode: '889698333333',
          ),
        ],
        timestamp: t0.add(const Duration(milliseconds: 100)),
      );

      expect(tracks.single.isTentative, isTrue);

      tracks = tracker.processFrame(
        observations: <AtlasScanObservation>[
          _observation(
            id: 'confirm_3',
            capturedAt: t0.add(const Duration(milliseconds: 200)),
            barcode: '889698333333',
          ),
        ],
        timestamp: t0.add(const Duration(milliseconds: 200)),
      );

      expect(tracks.single.isConfirmed, isTrue);
      expect(tracks.single.observationCount, 3);
    });

    test('stale tracks expire using elapsed time', () {
      final AtlasObjectTracker tracker = AtlasObjectTracker(
        config: const AtlasObjectTrackerConfig(
          tentativeTtl: Duration(milliseconds: 500),
          confirmedTtl: Duration(seconds: 2),
          confirmationMinHits: 3,
        ),
      );

      final DateTime t0 = DateTime.utc(2026, 8, 27, 12);

      tracker.processFrame(
        observations: <AtlasScanObservation>[
          _observation(id: 'stale_1', capturedAt: t0, barcode: '889698444444'),
        ],
        timestamp: t0,
      );

      expect(tracker.tracks, hasLength(1));

      tracker.processFrame(
        observations: const <AtlasScanObservation>[],
        timestamp: t0.add(const Duration(milliseconds: 499)),
      );

      expect(tracker.tracks, hasLength(1));

      tracker.processFrame(
        observations: const <AtlasScanObservation>[],
        timestamp: t0.add(const Duration(milliseconds: 501)),
      );

      expect(tracker.tracks, isEmpty);
    });

    test(
      'cooldown track keeps claiming the same visible object without spawning duplicates',
      () {
        final AtlasObjectTracker tracker = AtlasObjectTracker(
          config: const AtlasObjectTrackerConfig(
            confirmationMinHits: 1,
            cooldownDuration: Duration(seconds: 4),
          ),
        );

        final DateTime t0 = DateTime.utc(2026, 8, 27, 12);

        final AtlasObjectTrack initial = tracker
            .processFrame(
              observations: <AtlasScanObservation>[
                _observation(
                  id: 'cooldown_visible_1',
                  capturedAt: t0,
                  barcode: '889698555550',
                ),
              ],
              timestamp: t0,
            )
            .single;

        tracker.markCooldown(trackId: initial.trackId, startedAt: t0);

        final List<AtlasObjectTrack> tracks = tracker.processFrame(
          observations: <AtlasScanObservation>[
            _observation(
              id: 'cooldown_visible_2',
              capturedAt: t0.add(const Duration(milliseconds: 100)),
              barcode: '889698555550',
              centerX: 0.51,
            ),
          ],
          timestamp: t0.add(const Duration(milliseconds: 100)),
        );

        expect(tracks, hasLength(1));
        expect(tracks.single.trackId, initial.trackId);
        expect(tracks.single.isCooldown, isTrue);
        expect(
          tracks.single.lastSeenAt,
          t0.add(const Duration(milliseconds: 100)),
        );
      },
    );

    test(
      'cooldown expires only after the object has been absent for the TTL',
      () {
        final AtlasObjectTracker tracker = AtlasObjectTracker(
          config: const AtlasObjectTrackerConfig(
            confirmationMinHits: 1,
            cooldownDuration: Duration(seconds: 4),
          ),
        );

        final DateTime t0 = DateTime.utc(2026, 8, 27, 12);

        final AtlasObjectTrack initial = tracker
            .processFrame(
              observations: <AtlasScanObservation>[
                _observation(
                  id: 'cooldown_absent_1',
                  capturedAt: t0,
                  barcode: '889698555551',
                ),
              ],
              timestamp: t0,
            )
            .single;

        tracker.markCooldown(trackId: initial.trackId, startedAt: t0);

        tracker.processFrame(
          observations: <AtlasScanObservation>[
            _observation(
              id: 'cooldown_absent_2',
              capturedAt: t0.add(const Duration(seconds: 3)),
              barcode: '889698555551',
            ),
          ],
          timestamp: t0.add(const Duration(seconds: 3)),
        );

        tracker.processFrame(
          observations: const <AtlasScanObservation>[],
          timestamp: t0.add(const Duration(seconds: 6, milliseconds: 999)),
        );
        expect(tracker.tracks, hasLength(1));

        tracker.processFrame(
          observations: const <AtlasScanObservation>[],
          timestamp: t0.add(const Duration(seconds: 7, milliseconds: 1)),
        );
        expect(tracker.tracks, isEmpty);
      },
    );

    test('cooldown preserves camera lastSeenAt', () {
      final AtlasObjectTracker tracker = AtlasObjectTracker(
        config: const AtlasObjectTrackerConfig(confirmationMinHits: 1),
      );

      final DateTime seenAt = DateTime.utc(2026, 8, 27, 12);
      final DateTime cooldownAt = seenAt.add(const Duration(seconds: 1));

      final AtlasObjectTrack track = tracker
          .processFrame(
            observations: <AtlasScanObservation>[
              _observation(
                id: 'cooldown_1',
                capturedAt: seenAt,
                barcode: '889698555555',
              ),
            ],
            timestamp: seenAt,
          )
          .single;

      expect(track.isConfirmed, isTrue);

      final bool changed = tracker.markCooldown(
        trackId: track.trackId,
        startedAt: cooldownAt,
      );

      expect(changed, isTrue);

      final AtlasObjectTrack cooledTrack = tracker.trackForId(track.trackId)!;

      expect(cooledTrack.isCooldown, isTrue);
      expect(cooledTrack.lastSeenAt, seenAt);
      expect(cooledTrack.cooldownStartedAt, cooldownAt);
    });
  });

  group('AtlasEvidenceAccumulator', () {
    test(
      'agreement confidence uses usable barcode hits rather than all observations',
      () {
        final AtlasEvidenceAccumulator accumulator = AtlasEvidenceAccumulator(
          config: const AtlasEvidenceAccumulatorConfig(
            minBarcodeHits: 3,
            dominantBarcodeThreshold: 0.75,
          ),
        );

        final DateTime t0 = DateTime.utc(2026, 8, 27, 12);

        AtlasObjectTrack track = AtlasObjectTrack.createInitial(
          trackId: 'track_confidence',
          observation: _observation(
            id: 'evidence_1',
            capturedAt: t0,
            barcode: '889698666666',
          ),
        );

        track = track.incorporateObservation(
          _observation(
            id: 'evidence_2',
            capturedAt: t0.add(const Duration(milliseconds: 100)),
            barcode: '889698666666',
          ),
        );

        track = track.incorporateObservation(
          _observation(
            id: 'evidence_3',
            capturedAt: t0.add(const Duration(milliseconds: 200)),
            barcode: '889698666666',
          ),
        );

        track = track.incorporateObservation(
          _observation(
            id: 'evidence_4',
            capturedAt: t0.add(const Duration(milliseconds: 300)),
            barcode: '889698666666',
          ),
        );

        track = track.incorporateObservation(
          _observation(
            id: 'evidence_5',
            capturedAt: t0.add(const Duration(milliseconds: 400)),
            barcode: '889698777777',
          ),
        );

        track = track.incorporateObservation(
          _observationWithoutBarcode(
            id: 'visual_only_1',
            capturedAt: t0.add(const Duration(milliseconds: 500)),
          ),
        );

        track = track.incorporateObservation(
          _observationWithoutBarcode(
            id: 'visual_only_2',
            capturedAt: t0.add(const Duration(milliseconds: 600)),
          ),
        );

        track = track.incorporateObservation(
          _observationWithoutBarcode(
            id: 'visual_only_3',
            capturedAt: t0.add(const Duration(milliseconds: 700)),
          ),
        );

        track = track.confirm();

        final AtlasAccumulatedEvidence? evidence = accumulator.evaluateTrack(
          track,
        );

        expect(evidence, isNotNull);
        expect(evidence!.totalBarcodeHits, 5);
        expect(evidence.dominantBarcodeHits, 4);
        expect(evidence.agreementConfidence, closeTo(0.80, 0.0001));
        expect(evidence.isReadyForResolution, isTrue);
        expect(evidence.stableCode.normalizedValue, '889698666666');
      },
    );
  });
}

AtlasScanObservation _observation({
  required String id,
  required DateTime capturedAt,
  required String barcode,
  double centerX = 0.50,
  double centerY = 0.50,
}) {
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
    cornerPoints: _boxAround(centerX: centerX, centerY: centerY),
  );
}

AtlasScanObservation _observationWithoutBarcode({
  required String id,
  required DateTime capturedAt,
}) {
  return AtlasScanObservation(
    observationId: id,
    capturedAt: capturedAt,
    cornerPoints: _boxAround(centerX: 0.50, centerY: 0.50),
  );
}

List<AtlasNormalizedPoint> _boxAround({
  required double centerX,
  required double centerY,
}) {
  const double halfWidth = 0.02;
  const double halfHeight = 0.03;

  return <AtlasNormalizedPoint>[
    AtlasNormalizedPoint(x: centerX - halfWidth, y: centerY - halfHeight),
    AtlasNormalizedPoint(x: centerX + halfWidth, y: centerY - halfHeight),
    AtlasNormalizedPoint(x: centerX + halfWidth, y: centerY + halfHeight),
    AtlasNormalizedPoint(x: centerX - halfWidth, y: centerY + halfHeight),
  ];
}
