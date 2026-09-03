import '../../models/pop.dart';
import '../catalog/converters/atlas_catalog_converter.dart';
import '../completion/models/atlas_completion_result.dart';
import '../scan/continuous/models/atlas_perception_frame_result.dart';
import '../scan/results/atlas_continuous_scan_result.dart';
import '../scan/tracking/atlas_scan_observation.dart';
import 'engine/atlas_shelf_reconciliation_engine.dart';
import 'models/atlas_shelf_observation.dart';
import 'models/atlas_shelf_scan_session.dart';

final class AtlasShelfSessionConfig {
  const AtlasShelfSessionConfig({
    this.reidentificationWindow = const Duration(seconds: 8),
    this.enableConservativeReidentification = true,
  });

  final Duration reidentificationWindow;

  /// Reassociation is intentionally conservative: exact release identity,
  /// inactive prior observation, within the time window, and exactly one
  /// eligible prior object. Ambiguous same-release copies are never merged.
  final bool enableConservativeReidentification;
}

/// Owns transient Room/Shelf scan-session state.
///
/// This coordinator has no AppState dependency and exposes no Vault mutation
/// methods. Reconciliation produces staged actions only.
final class AtlasShelfSessionCoordinator {
  AtlasShelfSessionCoordinator({
    required String sessionId,
    required String collectionName,
    DateTime? startedAt,
    AtlasShelfReconciliationEngine? reconciliationEngine,
    this.config = const AtlasShelfSessionConfig(),
  }) : reconciliationEngine =
           reconciliationEngine ?? const AtlasShelfReconciliationEngine(),
       _session = AtlasShelfScanSession(
         sessionId: sessionId,
         collectionName: collectionName,
         startedAt: (startedAt ?? DateTime.now()).toUtc(),
         lastUpdatedAt: (startedAt ?? DateTime.now()).toUtc(),
       ) {
    if (sessionId.trim().isEmpty) {
      throw ArgumentError.value(sessionId, 'sessionId', 'cannot be empty');
    }
    if (collectionName.trim().isEmpty) {
      throw ArgumentError.value(
        collectionName,
        'collectionName',
        'cannot be empty',
      );
    }
    if (config.reidentificationWindow.isNegative) {
      throw ArgumentError.value(
        config.reidentificationWindow,
        'reidentificationWindow',
        'cannot be negative',
      );
    }
  }

  final AtlasShelfReconciliationEngine reconciliationEngine;
  final AtlasShelfSessionConfig config;

  AtlasShelfScanSession _session;
  int _nextObservationSequence = 1;

  AtlasShelfScanSession get session => _session;

  AtlasShelfObservation observeResolved({
    required String trackId,
    required Pop? product,
    required DateTime observedAt,
    bool requiresUserReview = false,
    String scannedBarcode = '',
    double confidence = 1,
    AtlasNormalizedBounds? bounds,
  }) {
    final String normalizedTrackId = trackId.trim();
    if (normalizedTrackId.isEmpty) {
      throw ArgumentError.value(trackId, 'trackId', 'cannot be empty');
    }
    if (!confidence.isFinite || confidence < 0 || confidence > 1) {
      throw ArgumentError.value(
        confidence,
        'confidence',
        'must be between 0 and 1',
      );
    }

    final DateTime timestamp = observedAt.toUtc();
    final List<AtlasShelfObservation> observations =
        List<AtlasShelfObservation>.from(_session.observations);

    final int existingTrackIndex = observations.indexWhere(
      (observation) => observation.sourceTrackIds.contains(normalizedTrackId),
    );

    if (existingTrackIndex >= 0) {
      final AtlasShelfObservation updated = observations[existingTrackIndex]
          .copyWith(
            lastSeenAt: timestamp,
            activeTrackId: normalizedTrackId,
            product: product,
            scannedBarcode: scannedBarcode,
            confidence: confidence,
            resolutionRequiresReview: requiresUserReview,
            lastKnownBounds: bounds,
          );
      observations[existingTrackIndex] = updated;
      _replaceObservations(observations, timestamp);
      return updated;
    }

    final AtlasShelfObservation? reidentified = _findReidentificationCandidate(
      observations: observations,
      product: product,
      observedAt: timestamp,
    );

    if (reidentified != null) {
      final int index = observations.indexWhere(
        (observation) =>
            observation.observationId == reidentified.observationId,
      );
      final Set<String> trackIds = <String>{
        ...reidentified.sourceTrackIds,
        normalizedTrackId,
      };
      final AtlasShelfObservation updated = reidentified.copyWith(
        lastSeenAt: timestamp,
        sourceTrackIds: trackIds,
        activeTrackId: normalizedTrackId,
        product: product,
        scannedBarcode: scannedBarcode,
        confidence: confidence,
        resolutionRequiresReview: requiresUserReview,
        lastKnownBounds: bounds,
        reidentificationConfidence: 0.85,
        notes: <String>[
          ...reidentified.notes,
          'Reassociated after track expiry using exact release identity.',
        ],
      );
      observations[index] = updated;
      _replaceObservations(observations, timestamp);
      return updated;
    }

    final AtlasShelfObservation created = AtlasShelfObservation(
      observationId: _createObservationId(),
      firstSeenAt: timestamp,
      lastSeenAt: timestamp,
      sourceTrackIds: <String>{normalizedTrackId},
      activeTrackId: normalizedTrackId,
      product: product,
      scannedBarcode: scannedBarcode,
      confidence: confidence,
      resolutionRequiresReview: requiresUserReview,
      lastKnownBounds: bounds,
    );
    observations.add(created);
    _replaceObservations(observations, timestamp);
    return created;
  }

  AtlasShelfObservation? ingestContinuousResult(
    AtlasContinuousScanResult result, {
    AtlasNormalizedBounds? bounds,
  }) {
    final catalogProduct = result.resolvedCatalogProduct;
    final Pop? product = catalogProduct == null
        ? null
        : AtlasCatalogConverter.toPop(
            catalogProduct,
            owner: 'Atlas Shelf',
            quantity: 1,
            timestamp: result.completedAt,
          );

    final String scannedBarcode =
        result.session.bestCandidate?.normalizedValue.trim() ?? '';

    return observeResolved(
      trackId: result.trackId,
      product: product,
      observedAt: result.completedAt,
      requiresUserReview: result.requiresUserReview,
      scannedBarcode: scannedBarcode,
      confidence: result.session.confidence.clamp(0, 1).toDouble(),
      bounds: bounds,
    );
  }

  void applyPerceptionFrame(AtlasPerceptionFrameResult frame) {
    final List<AtlasShelfObservation> observations =
        List<AtlasShelfObservation>.from(_session.observations);
    bool changed = false;

    for (var index = 0; index < observations.length; index++) {
      AtlasShelfObservation observation = observations[index];
      final String? activeTrackId = observation.activeTrackId;

      if (activeTrackId != null &&
          frame.expiredTrackIds.contains(activeTrackId)) {
        observation = observation.copyWith(
          lastSeenAt: frame.timestamp,
          clearActiveTrackId: true,
        );
        changed = true;
      }

      if (activeTrackId != null) {
        for (final candidate in frame.candidates) {
          if (candidate.trackId == activeTrackId &&
              candidate.normalizedBounds != null) {
            observation = observation.copyWith(
              lastSeenAt: candidate.lastSeenAt,
              lastKnownBounds: candidate.normalizedBounds,
            );
            changed = true;
            break;
          }
        }
      }

      observations[index] = observation;
    }

    if (changed) {
      _replaceObservations(observations, frame.timestamp.toUtc());
    }
  }

  AtlasShelfScanSession reconcile({
    required List<Pop> collectionPops,
    Set<String> ownedWishlistIdentityKeys = const <String>{},
    AtlasCompletionResult? completionResult,
    DateTime? at,
  }) {
    final result = reconciliationEngine.reconcile(
      observations: _session.observations,
      collectionPops: collectionPops,
      ownedWishlistIdentityKeys: ownedWishlistIdentityKeys,
      completionResult: completionResult,
    );

    _session = _session.copyWith(
      lastUpdatedAt: (at ?? DateTime.now()).toUtc(),
      status: AtlasShelfScanSessionStatus.reviewReady,
      observations: result.observations,
      reconciliation: result,
    );
    return _session;
  }

  AtlasShelfScanSession markCompleted({DateTime? at}) {
    _session = _session.copyWith(
      lastUpdatedAt: (at ?? DateTime.now()).toUtc(),
      status: AtlasShelfScanSessionStatus.completed,
    );
    return _session;
  }

  AtlasShelfObservation? _findReidentificationCandidate({
    required List<AtlasShelfObservation> observations,
    required Pop? product,
    required DateTime observedAt,
  }) {
    if (!config.enableConservativeReidentification || product == null) {
      return null;
    }

    final String identityKey = product.collectibleIdentityKey.trim();
    if (identityKey.isEmpty) return null;

    final List<AtlasShelfObservation> candidates = observations
        .where((item) {
          if (item.isActive || item.collectibleIdentityKey != identityKey) {
            return false;
          }
          final Duration elapsed = observedAt.difference(item.lastSeenAt);
          return !elapsed.isNegative &&
              elapsed <= config.reidentificationWindow;
        })
        .toList(growable: false);

    // More than one identical inactive copy is physically ambiguous. Do not
    // guess which copy returned to frame.
    return candidates.length == 1 ? candidates.single : null;
  }

  void _replaceObservations(
    List<AtlasShelfObservation> observations,
    DateTime updatedAt,
  ) {
    _session = _session.copyWith(
      lastUpdatedAt: updatedAt.toUtc(),
      observations: observations,
      clearReconciliation: true,
      status: AtlasShelfScanSessionStatus.scanning,
    );
  }

  String _createObservationId() {
    final int sequence = _nextObservationSequence++;
    return 'shelf_${_session.sessionId}_$sequence';
  }
}
