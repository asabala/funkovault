import 'dart:async';
import 'dart:collection';

import 'atlas_resolution_job.dart';

/// Snapshot of queue activity for diagnostics and future scanner HUDs.
class AtlasResolutionQueueSnapshot {
  const AtlasResolutionQueueSnapshot({
    required this.activeCount,
    required this.pendingCount,
    required this.activeTrackIds,
    required this.pendingTrackIds,
  });

  final int activeCount;
  final int pendingCount;
  final Set<String> activeTrackIds;
  final Set<String> pendingTrackIds;

  bool get isIdle => activeCount == 0 && pendingCount == 0;
}

class AtlasResolutionQueue {
  AtlasResolutionQueue({this.maxConcurrentJobs = 4}) {
    if (maxConcurrentJobs < 1) {
      throw ArgumentError.value(
        maxConcurrentJobs,
        'maxConcurrentJobs',
        'maxConcurrentJobs must be at least 1.',
      );
    }
  }

  final int maxConcurrentJobs;

  final Queue<_QueuedResolutionJob> _pending = Queue<_QueuedResolutionJob>();

  final Set<String> _activeTrackIds = <String>{};
  final Set<String> _pendingTrackIds = <String>{};

  int _activeCount = 0;
  bool _isDisposed = false;

  AtlasResolutionQueueSnapshot get snapshot {
    return AtlasResolutionQueueSnapshot(
      activeCount: _activeCount,
      pendingCount: _pending.length,
      activeTrackIds: Set<String>.unmodifiable(_activeTrackIds),
      pendingTrackIds: Set<String>.unmodifiable(_pendingTrackIds),
    );
  }

  bool containsTrack(String trackId) {
    final String normalized = trackId.trim();

    return _activeTrackIds.contains(normalized) ||
        _pendingTrackIds.contains(normalized);
  }

  Future<void> enqueue(AtlasResolutionJob job) {
    if (_isDisposed) {
      return Future<void>.error(
        StateError('AtlasResolutionQueue has been disposed.'),
      );
    }

    final String trackId = job.trackId.trim();

    if (containsTrack(trackId)) {
      return Future<void>.error(
        StateError(
          'A resolution job for track "$trackId" is already queued or active.',
        ),
      );
    }

    final Completer<void> completer = Completer<void>();

    _pending.add(_QueuedResolutionJob(job: job, completer: completer));
    _pendingTrackIds.add(trackId);

    _drain();

    return completer.future;
  }

  void dispose() {
    if (_isDisposed) {
      return;
    }

    _isDisposed = true;

    while (_pending.isNotEmpty) {
      final _QueuedResolutionJob queued = _pending.removeFirst();
      _pendingTrackIds.remove(queued.job.trackId.trim());

      if (!queued.completer.isCompleted) {
        queued.completer.completeError(
          StateError('Resolution queue disposed before the job started.'),
        );
      }
    }
  }

  void _drain() {
    if (_isDisposed) {
      return;
    }

    while (_activeCount < maxConcurrentJobs && _pending.isNotEmpty) {
      final _QueuedResolutionJob queued = _pending.removeFirst();
      final String trackId = queued.job.trackId.trim();

      _pendingTrackIds.remove(trackId);
      _activeTrackIds.add(trackId);
      _activeCount++;

      unawaited(_run(queued));
    }
  }

  Future<void> _run(_QueuedResolutionJob queued) async {
    final String trackId = queued.job.trackId.trim();

    try {
      await queued.job.execute();

      if (!queued.completer.isCompleted) {
        queued.completer.complete();
      }
    } catch (error, stackTrace) {
      if (!queued.completer.isCompleted) {
        queued.completer.completeError(error, stackTrace);
      }
    } finally {
      _activeTrackIds.remove(trackId);
      _activeCount--;

      if (!_isDisposed) {
        _drain();
      }
    }
  }
}

class _QueuedResolutionJob {
  const _QueuedResolutionJob({required this.job, required this.completer});

  final AtlasResolutionJob job;
  final Completer<void> completer;
}
