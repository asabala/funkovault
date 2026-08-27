import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/atlas/scan/ledger/atlas_scan_ledger.dart';
import 'package:funkovault2/atlas/scan/ledger/atlas_scan_ledger_entry.dart';
import 'package:funkovault2/atlas/scan/models/scan_code.dart';
import 'package:funkovault2/atlas/scan/queue/atlas_resolution_job.dart';
import 'package:funkovault2/atlas/scan/queue/atlas_resolution_queue.dart';

void main() {
  group('AtlasResolutionQueue', () {
    test(
      'never exceeds configured concurrency and preserves waiting jobs',
      () async {
        final AtlasResolutionQueue queue = AtlasResolutionQueue(
          maxConcurrentJobs: 4,
        );

        int active = 0;
        int maximumObserved = 0;
        int completed = 0;

        final List<Completer<void>> gates = List<Completer<void>>.generate(
          6,
          (_) => Completer<void>(),
        );

        final List<Future<void>> futures = <Future<void>>[];

        for (int index = 0; index < 6; index++) {
          futures.add(
            queue.enqueue(
              AtlasResolutionJob(
                jobId: 'job_$index',
                trackId: 'track_$index',
                createdAt: DateTime.utc(2026, 8, 27, 12, 0, index),
                execute: () async {
                  active++;
                  if (active > maximumObserved) {
                    maximumObserved = active;
                  }

                  await gates[index].future;

                  active--;
                  completed++;
                },
              ),
            ),
          );
        }

        await Future<void>.delayed(Duration.zero);

        expect(queue.snapshot.activeCount, 4);
        expect(queue.snapshot.pendingCount, 2);
        expect(maximumObserved, 4);

        gates[0].complete();
        gates[1].complete();

        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        expect(queue.snapshot.activeCount, 4);
        expect(queue.snapshot.pendingCount, 0);
        expect(maximumObserved, 4);

        for (int index = 2; index < gates.length; index++) {
          gates[index].complete();
        }

        await Future.wait(futures);

        expect(completed, 6);
        expect(maximumObserved, 4);
        expect(queue.snapshot.isIdle, isTrue);
      },
    );

    test('same track cannot be queued twice at the same time', () async {
      final AtlasResolutionQueue queue = AtlasResolutionQueue(
        maxConcurrentJobs: 1,
      );

      final Completer<void> gate = Completer<void>();

      final Future<void> first = queue.enqueue(
        AtlasResolutionJob(
          jobId: 'job_a',
          trackId: 'track_same',
          createdAt: DateTime.utc(2026, 8, 27, 12),
          execute: () => gate.future,
        ),
      );

      await expectLater(
        queue.enqueue(
          AtlasResolutionJob(
            jobId: 'job_b',
            trackId: 'track_same',
            createdAt: DateTime.utc(2026, 8, 27, 12, 0, 1),
            execute: () async {},
          ),
        ),
        throwsStateError,
      );

      gate.complete();
      await first;
    });

    test(
      'failed track can be queued again after the failed job exits',
      () async {
        final AtlasResolutionQueue queue = AtlasResolutionQueue(
          maxConcurrentJobs: 1,
        );

        await expectLater(
          queue.enqueue(
            AtlasResolutionJob(
              jobId: 'job_fail',
              trackId: 'track_retry',
              createdAt: DateTime.utc(2026, 8, 27, 12),
              execute: () async {
                throw StateError('temporary failure');
              },
            ),
          ),
          throwsStateError,
        );

        await queue.enqueue(
          AtlasResolutionJob(
            jobId: 'job_retry',
            trackId: 'track_retry',
            createdAt: DateTime.utc(2026, 8, 27, 12, 0, 1),
            execute: () async {},
          ),
        );

        expect(queue.snapshot.isIdle, isTrue);
      },
    );
  });

  group('AtlasScanLedger', () {
    test('resolved and committed are separate states', () {
      final AtlasScanLedger ledger = AtlasScanLedger();
      final DateTime t0 = DateTime.utc(2026, 8, 27, 12);

      ledger.observe(
        trackId: 'track_1',
        stableCode: _code('889698111111', t0),
        at: t0,
      );

      ledger.markQueued(
        trackId: 'track_1',
        at: t0.add(const Duration(milliseconds: 100)),
      );

      ledger.markResolving(
        trackId: 'track_1',
        at: t0.add(const Duration(milliseconds: 200)),
      );

      final AtlasScanLedgerEntry resolved = ledger.markResolved(
        trackId: 'track_1',
        resolutionSessionId: 'session_1',
        at: t0.add(const Duration(milliseconds: 300)),
      );

      expect(resolved.isResolved, isTrue);
      expect(resolved.isCommitted, isFalse);
      expect(resolved.committedAt, isNull);

      final AtlasScanLedgerEntry committed = ledger.markCommitted(
        trackId: 'track_1',
        at: t0.add(const Duration(milliseconds: 400)),
      );

      expect(committed.isCommitted, isTrue);
      expect(committed.committedAt, isNotNull);
    });

    test('committing the same track twice is idempotent', () {
      final AtlasScanLedger ledger = AtlasScanLedger();
      final DateTime t0 = DateTime.utc(2026, 8, 27, 12);

      ledger.observe(
        trackId: 'track_2',
        stableCode: _code('889698222222', t0),
        at: t0,
      );
      ledger.markQueued(trackId: 'track_2', at: t0);
      ledger.markResolving(trackId: 'track_2', at: t0);
      ledger.markResolved(
        trackId: 'track_2',
        resolutionSessionId: 'session_2',
        at: t0,
      );

      final AtlasScanLedgerEntry first = ledger.markCommitted(
        trackId: 'track_2',
        at: t0.add(const Duration(seconds: 1)),
      );

      final AtlasScanLedgerEntry second = ledger.markCommitted(
        trackId: 'track_2',
        at: t0.add(const Duration(seconds: 2)),
      );

      expect(second.committedAt, first.committedAt);
      expect(second.updatedAt, first.updatedAt);
    });

    test('different physical tracks may share the same UPC', () {
      final AtlasScanLedger ledger = AtlasScanLedger();
      final DateTime t0 = DateTime.utc(2026, 8, 27, 12);
      final ScanCode shared = _code('889698333333', t0);

      ledger.observe(trackId: 'track_left', stableCode: shared, at: t0);

      ledger.observe(trackId: 'track_right', stableCode: shared, at: t0);

      expect(ledger.entries, hasLength(2));
      expect(ledger.entries.map((entry) => entry.trackId).toSet(), <String>{
        'track_left',
        'track_right',
      });
      expect(
        ledger.entries.every(
          (entry) => entry.stableCode.normalizedValue == shared.normalizedValue,
        ),
        isTrue,
      );
    });

    test('failed entry requires explicit retry and increments attempts', () {
      final AtlasScanLedger ledger = AtlasScanLedger();
      final DateTime t0 = DateTime.utc(2026, 8, 27, 12);

      ledger.observe(
        trackId: 'track_retry',
        stableCode: _code('889698444444', t0),
        at: t0,
      );
      ledger.markQueued(trackId: 'track_retry', at: t0);
      ledger.markResolving(trackId: 'track_retry', at: t0);
      ledger.markFailed(
        trackId: 'track_retry',
        error: StateError('network'),
        at: t0,
      );

      expect(
        () => ledger.markQueued(
          trackId: 'track_retry',
          at: t0.add(const Duration(seconds: 1)),
        ),
        throwsStateError,
      );

      ledger.markQueued(
        trackId: 'track_retry',
        at: t0.add(const Duration(seconds: 1)),
        allowRetry: true,
      );

      final AtlasScanLedgerEntry retrying = ledger.markResolving(
        trackId: 'track_retry',
        at: t0.add(const Duration(seconds: 2)),
      );

      expect(retrying.attemptCount, 2);
      expect(retrying.failureMessage, isNull);
      expect(retrying.status, AtlasScanLedgerStatus.resolving);
    });
  });
}

ScanCode _code(String value, DateTime capturedAt) {
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
