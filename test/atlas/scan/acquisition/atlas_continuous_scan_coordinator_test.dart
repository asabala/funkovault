import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/atlas/scan/acquisition/atlas_continuous_scan_coordinator.dart';
import 'package:funkovault2/atlas/scan/models/scan_code.dart';
import 'package:funkovault2/atlas/scan/queue/atlas_resolution_job.dart';
import 'package:funkovault2/atlas/scan/queue/atlas_resolution_queue.dart';

void main() {
  test(
    'duplicate submit for the same track is rejected before queueing again',
    () {
      final _HoldingResolutionQueue queue = _HoldingResolutionQueue();
      final AtlasContinuousScanCoordinator coordinator =
          AtlasContinuousScanCoordinator(resolutionQueue: queue);

      final ScanCode code = _code('889698111111');

      final bool first = coordinator.submit(
        trackId: 'track_1',
        stableCode: code,
      );

      final bool second = coordinator.submit(
        trackId: 'track_1',
        stableCode: code,
      );

      expect(first, isTrue);
      expect(second, isFalse);
      expect(coordinator.ledger.entries, hasLength(1));
      expect(queue.acceptedJobs, hasLength(1));

      coordinator.dispose();
    },
  );

  test('different tracks with the same UPC are accepted independently', () {
    final _HoldingResolutionQueue queue = _HoldingResolutionQueue();
    final AtlasContinuousScanCoordinator coordinator =
        AtlasContinuousScanCoordinator(resolutionQueue: queue);

    final ScanCode shared = _code('889698222222');

    expect(
      coordinator.submit(trackId: 'track_left', stableCode: shared),
      isTrue,
    );

    expect(
      coordinator.submit(trackId: 'track_right', stableCode: shared),
      isTrue,
    );

    expect(coordinator.ledger.entries, hasLength(2));
    expect(queue.acceptedJobs, hasLength(2));

    coordinator.dispose();
  });

  test('snapshot exposes queued work without committing it', () {
    final _HoldingResolutionQueue queue = _HoldingResolutionQueue();
    final AtlasContinuousScanCoordinator coordinator =
        AtlasContinuousScanCoordinator(resolutionQueue: queue);

    coordinator.submit(
      trackId: 'track_queued',
      stableCode: _code('889698333333'),
    );

    final AtlasContinuousScanSnapshot snapshot = coordinator.snapshot;

    expect(snapshot.queuedCount, 1);
    expect(snapshot.committedCount, 0);
    expect(snapshot.completedCount, 0);

    coordinator.dispose();
  });
  test('explicit commit only succeeds for a resolved ledger entry', () {
    final _HoldingResolutionQueue queue = _HoldingResolutionQueue();
    final AtlasContinuousScanCoordinator coordinator =
        AtlasContinuousScanCoordinator(resolutionQueue: queue);

    final DateTime now = DateTime.utc(2026, 8, 27, 12);

    coordinator.ledger.observe(
      trackId: 'track_commit',
      stableCode: _code('889698444444'),
      at: now,
    );

    expect(coordinator.markCommitted(trackId: 'track_commit'), isFalse);

    coordinator.ledger.markQueued(trackId: 'track_commit', at: now);
    coordinator.ledger.markResolving(trackId: 'track_commit', at: now);
    coordinator.ledger.markResolved(
      trackId: 'track_commit',
      resolutionSessionId: 'session_commit',
      at: now,
    );

    expect(
      coordinator.markCommitted(
        trackId: 'track_commit',
        at: now.add(const Duration(seconds: 1)),
      ),
      isTrue,
    );

    expect(
      coordinator.ledger.entryForTrack('track_commit')!.isCommitted,
      isTrue,
    );

    expect(
      coordinator.markCommitted(
        trackId: 'track_commit',
        at: now.add(const Duration(seconds: 2)),
      ),
      isTrue,
    );

    coordinator.dispose();
  });

  test('failed track retries without creating a second ledger entry', () {
    final _HoldingResolutionQueue queue = _HoldingResolutionQueue();
    final AtlasContinuousScanCoordinator coordinator =
        AtlasContinuousScanCoordinator(resolutionQueue: queue);

    final DateTime now = DateTime.utc(2026, 8, 27, 12);

    coordinator.ledger.observe(
      trackId: 'track_retry',
      stableCode: _code('889698555555'),
      at: now,
    );
    coordinator.ledger.markQueued(trackId: 'track_retry', at: now);
    coordinator.ledger.markResolving(trackId: 'track_retry', at: now);
    coordinator.ledger.markFailed(
      trackId: 'track_retry',
      error: StateError('network unavailable'),
      at: now,
    );

    final bool accepted = coordinator.retryFailedTrack(trackId: 'track_retry');

    expect(accepted, isTrue);
    expect(coordinator.ledger.entries, hasLength(1));
    expect(coordinator.ledger.entryForTrack('track_retry')!.isQueued, isTrue);
    expect(queue.acceptedJobs, hasLength(1));

    coordinator.dispose();
  });

  test('retry is rejected for a track that has not failed', () {
    final _HoldingResolutionQueue queue = _HoldingResolutionQueue();
    final AtlasContinuousScanCoordinator coordinator =
        AtlasContinuousScanCoordinator(resolutionQueue: queue);

    coordinator.ledger.observe(
      trackId: 'track_not_failed',
      stableCode: _code('889698666666'),
      at: DateTime.utc(2026, 8, 27, 12),
    );

    expect(coordinator.retryFailedTrack(trackId: 'track_not_failed'), isFalse);
    expect(queue.acceptedJobs, isEmpty);

    coordinator.dispose();
  });
}

class _HoldingResolutionQueue extends AtlasResolutionQueue {
  _HoldingResolutionQueue() : super(maxConcurrentJobs: 4);

  final List<AtlasResolutionJob> acceptedJobs = <AtlasResolutionJob>[];

  @override
  Future<void> enqueue(AtlasResolutionJob job) {
    acceptedJobs.add(job);
    return Completer<void>().future;
  }

  @override
  AtlasResolutionQueueSnapshot get snapshot {
    return AtlasResolutionQueueSnapshot(
      activeCount: 0,
      pendingCount: acceptedJobs.length,
      activeTrackIds: const <String>{},
      pendingTrackIds: acceptedJobs
          .map((AtlasResolutionJob job) => job.trackId)
          .toSet(),
    );
  }

  @override
  void dispose() {}
}

ScanCode _code(String value) {
  final DateTime capturedAt = DateTime.utc(2026, 8, 27, 12);

  return ScanCode(
    rawValue: value,
    normalizedValue: value,
    format: ScanCodeFormat.upcA,
    source: ScanCodeSource.camera,
    capturedAt: capturedAt,
    isValid: true,
    confidence: 1.0,
  );
}
