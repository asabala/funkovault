import '../models/scan_code.dart';
import 'atlas_scan_ledger_entry.dart';

/// In-memory ledger for one continuous scanner workflow.
///
/// Entries are keyed by physical track ID rather than barcode or product ID so
/// two identical collectibles with the same UPC can remain separate items.
class AtlasScanLedger {
  final Map<String, AtlasScanLedgerEntry> _entries =
      <String, AtlasScanLedgerEntry>{};

  List<AtlasScanLedgerEntry> get entries {
    return List<AtlasScanLedgerEntry>.unmodifiable(_entries.values);
  }

  AtlasScanLedgerEntry? entryForTrack(String trackId) {
    return _entries[trackId.trim()];
  }

  bool containsTrack(String trackId) {
    return _entries.containsKey(trackId.trim());
  }

  AtlasScanLedgerEntry observe({
    required String trackId,
    required ScanCode stableCode,
    required DateTime at,
  }) {
    final String normalizedTrackId = _normalizeTrackId(trackId);
    final AtlasScanLedgerEntry? existing = _entries[normalizedTrackId];

    if (existing != null) {
      return existing;
    }

    final AtlasScanLedgerEntry entry = AtlasScanLedgerEntry(
      trackId: normalizedTrackId,
      stableCode: stableCode,
      status: AtlasScanLedgerStatus.observed,
      createdAt: at,
      updatedAt: at,
      attemptCount: 0,
    );

    _entries[normalizedTrackId] = entry;

    return entry;
  }

  AtlasScanLedgerEntry markQueued({
    required String trackId,
    required DateTime at,
    bool allowRetry = false,
  }) {
    final AtlasScanLedgerEntry entry = _requireEntry(trackId);

    if (entry.isCommitted) {
      throw StateError(
        'Committed track "${entry.trackId}" cannot be queued again.',
      );
    }

    if (entry.hasFailed && !allowRetry) {
      throw StateError(
        'Failed track "${entry.trackId}" requires an explicit retry.',
      );
    }

    if (entry.isQueued || entry.isResolving) {
      return entry;
    }

    if (entry.isResolved || entry.needsReview) {
      throw StateError(
        'Resolved track "${entry.trackId}" cannot be queued again.',
      );
    }

    final AtlasScanLedgerEntry updated = entry.copyWith(
      status: AtlasScanLedgerStatus.queued,
      updatedAt: at,
      clearFailureMessage: allowRetry,
    );

    _entries[entry.trackId] = updated;

    return updated;
  }

  AtlasScanLedgerEntry markResolving({
    required String trackId,
    required DateTime at,
  }) {
    final AtlasScanLedgerEntry entry = _requireEntry(trackId);

    if (!entry.isQueued) {
      throw StateError(
        'Track "${entry.trackId}" must be queued before resolving.',
      );
    }

    final AtlasScanLedgerEntry updated = entry.copyWith(
      status: AtlasScanLedgerStatus.resolving,
      updatedAt: at,
      attemptCount: entry.attemptCount + 1,
      clearFailureMessage: true,
    );

    _entries[entry.trackId] = updated;

    return updated;
  }

  AtlasScanLedgerEntry markResolved({
    required String trackId,
    required String resolutionSessionId,
    required DateTime at,
  }) {
    final AtlasScanLedgerEntry entry = _requireEntry(trackId);

    if (!entry.isResolving) {
      throw StateError(
        'Track "${entry.trackId}" must be resolving before it can resolve.',
      );
    }

    final String normalizedSessionId = resolutionSessionId.trim();

    if (normalizedSessionId.isEmpty) {
      throw ArgumentError.value(
        resolutionSessionId,
        'resolutionSessionId',
        'resolutionSessionId cannot be empty.',
      );
    }

    final AtlasScanLedgerEntry updated = entry.copyWith(
      status: AtlasScanLedgerStatus.resolved,
      updatedAt: at,
      resolutionSessionId: normalizedSessionId,
      clearFailureMessage: true,
    );

    _entries[entry.trackId] = updated;

    return updated;
  }

  AtlasScanLedgerEntry markNeedsReview({
    required String trackId,
    required String resolutionSessionId,
    required DateTime at,
  }) {
    final AtlasScanLedgerEntry entry = _requireEntry(trackId);

    if (!entry.isResolving) {
      throw StateError(
        'Track "${entry.trackId}" must be resolving before review.',
      );
    }

    final String normalizedSessionId = resolutionSessionId.trim();

    if (normalizedSessionId.isEmpty) {
      throw ArgumentError.value(
        resolutionSessionId,
        'resolutionSessionId',
        'resolutionSessionId cannot be empty.',
      );
    }

    final AtlasScanLedgerEntry updated = entry.copyWith(
      status: AtlasScanLedgerStatus.needsReview,
      updatedAt: at,
      resolutionSessionId: normalizedSessionId,
      clearFailureMessage: true,
    );

    _entries[entry.trackId] = updated;

    return updated;
  }

  AtlasScanLedgerEntry markFailed({
    required String trackId,
    required Object error,
    required DateTime at,
  }) {
    final AtlasScanLedgerEntry entry = _requireEntry(trackId);

    if (!entry.isResolving) {
      throw StateError(
        'Track "${entry.trackId}" must be resolving before it can fail.',
      );
    }

    final AtlasScanLedgerEntry updated = entry.copyWith(
      status: AtlasScanLedgerStatus.failed,
      updatedAt: at,
      failureMessage: error.toString(),
    );

    _entries[entry.trackId] = updated;

    return updated;
  }

  AtlasScanLedgerEntry markCommitted({
    required String trackId,
    required DateTime at,
  }) {
    final AtlasScanLedgerEntry entry = _requireEntry(trackId);

    if (entry.isCommitted) {
      return entry;
    }

    if (!entry.isResolved && !entry.needsReview) {
      throw StateError(
        'Track "${entry.trackId}" must be resolved before commit.',
      );
    }

    final AtlasScanLedgerEntry updated = entry.copyWith(
      status: AtlasScanLedgerStatus.committed,
      updatedAt: at,
      committedAt: at,
    );

    _entries[entry.trackId] = updated;

    return updated;
  }

  void clear() {
    _entries.clear();
  }

  AtlasScanLedgerEntry _requireEntry(String trackId) {
    final String normalizedTrackId = _normalizeTrackId(trackId);
    final AtlasScanLedgerEntry? entry = _entries[normalizedTrackId];

    if (entry == null) {
      throw StateError(
        'No scan ledger entry exists for track "$normalizedTrackId".',
      );
    }

    return entry;
  }

  String _normalizeTrackId(String trackId) {
    final String normalized = trackId.trim();

    if (normalized.isEmpty) {
      throw ArgumentError.value(trackId, 'trackId', 'trackId cannot be empty.');
    }

    return normalized;
  }
}
