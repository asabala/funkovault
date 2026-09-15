final class AtlasCatalogSyncResult {
  const AtlasCatalogSyncResult({
    required this.syncRunId,
    required this.sourceType,
    required this.rowsReceived,
    required this.rowsProcessed,
    required this.rowsInserted,
    required this.rowsUpdated,
    required this.rowsSkipped,
    required this.rowsFailed,
    required this.startedAt,
    required this.finishedAt,
    this.errorMessage,
  });

  final int syncRunId;

  final String sourceType;

  final int rowsReceived;
  final int rowsProcessed;
  final int rowsInserted;
  final int rowsUpdated;
  final int rowsSkipped;
  final int rowsFailed;

  final DateTime startedAt;
  final DateTime finishedAt;

  final String? errorMessage;

  bool get succeeded {
    return errorMessage == null && rowsFailed == 0;
  }

  bool get completedWithErrors {
    return rowsFailed > 0;
  }

  int get rowsChanged {
    return rowsInserted + rowsUpdated;
  }

  Duration get duration {
    return finishedAt.difference(startedAt);
  }
}
