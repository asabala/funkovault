import 'atlas_shelf_observation.dart';
import 'atlas_shelf_reconciliation_result.dart';

enum AtlasShelfScanSessionStatus { scanning, reviewReady, completed, cancelled }

final class AtlasShelfScanSession {
  AtlasShelfScanSession({
    required this.sessionId,
    required this.collectionName,
    required this.startedAt,
    required this.lastUpdatedAt,
    this.status = AtlasShelfScanSessionStatus.scanning,
    Iterable<AtlasShelfObservation> observations =
        const <AtlasShelfObservation>[],
    this.reconciliation,
  }) : observations = List<AtlasShelfObservation>.unmodifiable(observations);

  final String sessionId;
  final String collectionName;
  final DateTime startedAt;
  final DateTime lastUpdatedAt;
  final AtlasShelfScanSessionStatus status;
  final List<AtlasShelfObservation> observations;
  final AtlasShelfReconciliationResult? reconciliation;

  int get activeObservationCount =>
      observations.where((observation) => observation.isActive).length;

  int get reviewCount => reconciliation?.needsReviewCount ?? 0;

  AtlasShelfScanSession copyWith({
    DateTime? lastUpdatedAt,
    AtlasShelfScanSessionStatus? status,
    Iterable<AtlasShelfObservation>? observations,
    AtlasShelfReconciliationResult? reconciliation,
    bool clearReconciliation = false,
  }) {
    return AtlasShelfScanSession(
      sessionId: sessionId,
      collectionName: collectionName,
      startedAt: startedAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      status: status ?? this.status,
      observations: observations ?? this.observations,
      reconciliation: clearReconciliation
          ? null
          : (reconciliation ?? this.reconciliation),
    );
  }
}
