import '../models/scan_code.dart';

enum AtlasScanLedgerStatus {
  observed,
  queued,
  resolving,
  resolved,
  needsReview,
  failed,
  committed,
}

/// Immutable lifecycle record for one physical scanner track.
///
/// A resolved track is deliberately not the same thing as a committed track.
/// Collection quantity changes must only occur after an explicit commit.
class AtlasScanLedgerEntry {
  const AtlasScanLedgerEntry({
    required this.trackId,
    required this.stableCode,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.attemptCount,
    this.resolutionSessionId,
    this.failureMessage,
    this.committedAt,
  });

  final String trackId;
  final ScanCode stableCode;
  final AtlasScanLedgerStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int attemptCount;
  final String? resolutionSessionId;
  final String? failureMessage;
  final DateTime? committedAt;

  bool get isObserved => status == AtlasScanLedgerStatus.observed;
  bool get isQueued => status == AtlasScanLedgerStatus.queued;
  bool get isResolving => status == AtlasScanLedgerStatus.resolving;
  bool get isResolved => status == AtlasScanLedgerStatus.resolved;
  bool get needsReview => status == AtlasScanLedgerStatus.needsReview;
  bool get hasFailed => status == AtlasScanLedgerStatus.failed;
  bool get isCommitted => status == AtlasScanLedgerStatus.committed;

  bool get canRetry => hasFailed;

  AtlasScanLedgerEntry copyWith({
    AtlasScanLedgerStatus? status,
    DateTime? updatedAt,
    int? attemptCount,
    String? resolutionSessionId,
    String? failureMessage,
    DateTime? committedAt,
    bool clearFailureMessage = false,
  }) {
    return AtlasScanLedgerEntry(
      trackId: trackId,
      stableCode: stableCode,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      attemptCount: attemptCount ?? this.attemptCount,
      resolutionSessionId: resolutionSessionId ?? this.resolutionSessionId,
      failureMessage: clearFailureMessage
          ? null
          : failureMessage ?? this.failureMessage,
      committedAt: committedAt ?? this.committedAt,
    );
  }
}
