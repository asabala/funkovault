import 'dart:async';

import '../../catalog/models/atlas_catalog_product.dart';
import '../../catalog/services/atlas_barcode_catalog_resolver.dart';
import '../engine/barcode_intelligence_engine.dart';
import '../engine/engine_context.dart';
import '../ledger/atlas_scan_ledger.dart';
import '../ledger/atlas_scan_ledger_entry.dart';
import '../models/scan_code.dart';
import '../models/scan_session.dart';
import '../models/scanner_type.dart';
import '../pipeline/standard_scan_pipeline.dart';
import '../queue/atlas_resolution_job.dart';
import '../queue/atlas_resolution_queue.dart';
import '../results/atlas_continuous_scan_result.dart';
import '../workflow/scan_intent.dart';
import '../workflow/scan_performance_mode.dart';

typedef AtlasContinuousScanChanged = void Function();

class AtlasContinuousScanSnapshot {
  const AtlasContinuousScanSnapshot({
    required this.activeResolutionCount,
    required this.pendingResolutionCount,
    required this.observedCount,
    required this.queuedCount,
    required this.resolvingCount,
    required this.resolvedCount,
    required this.reviewCount,
    required this.failedCount,
    required this.committedCount,
  });

  final int activeResolutionCount;
  final int pendingResolutionCount;
  final int observedCount;
  final int queuedCount;
  final int resolvingCount;
  final int resolvedCount;
  final int reviewCount;
  final int failedCount;
  final int committedCount;

  int get completedCount => resolvedCount + reviewCount + committedCount;

  bool get hasWorkInFlight =>
      activeResolutionCount > 0 || pendingResolutionCount > 0;
}

/// Coordinates stable physical tracks with Atlas's existing resolution stack.
///
/// This class owns queueing and ledger state, but it does not mutate the Vault.
/// A resolved item remains separate from an explicitly committed item.
class AtlasContinuousScanCoordinator {
  AtlasContinuousScanCoordinator({
    AtlasResolutionQueue? resolutionQueue,
    AtlasScanLedger? ledger,
    AtlasBarcodeCatalogResolver? catalogResolver,
    this.onChanged,
  }) : resolutionQueue =
           resolutionQueue ?? AtlasResolutionQueue(maxConcurrentJobs: 4),
       ledger = ledger ?? AtlasScanLedger(),
       _catalogResolver = catalogResolver ?? AtlasBarcodeCatalogResolver();

  final AtlasResolutionQueue resolutionQueue;
  final AtlasScanLedger ledger;
  final AtlasBarcodeCatalogResolver _catalogResolver;
  final AtlasContinuousScanChanged? onChanged;

  final Map<String, AtlasContinuousScanResult> _resultsByTrack =
      <String, AtlasContinuousScanResult>{};

  bool _isDisposed = false;

  List<AtlasContinuousScanResult> get results {
    return List<AtlasContinuousScanResult>.unmodifiable(_resultsByTrack.values);
  }

  AtlasContinuousScanResult? resultForTrack(String trackId) {
    return _resultsByTrack[trackId.trim()];
  }

  AtlasContinuousScanSnapshot get snapshot {
    final AtlasResolutionQueueSnapshot queueSnapshot = resolutionQueue.snapshot;

    int observed = 0;
    int queued = 0;
    int resolving = 0;
    int resolved = 0;
    int review = 0;
    int failed = 0;
    int committed = 0;

    for (final AtlasScanLedgerEntry entry in ledger.entries) {
      switch (entry.status) {
        case AtlasScanLedgerStatus.observed:
          observed++;
        case AtlasScanLedgerStatus.queued:
          queued++;
        case AtlasScanLedgerStatus.resolving:
          resolving++;
        case AtlasScanLedgerStatus.resolved:
          resolved++;
        case AtlasScanLedgerStatus.needsReview:
          review++;
        case AtlasScanLedgerStatus.failed:
          failed++;
        case AtlasScanLedgerStatus.committed:
          committed++;
      }
    }

    return AtlasContinuousScanSnapshot(
      activeResolutionCount: queueSnapshot.activeCount,
      pendingResolutionCount: queueSnapshot.pendingCount,
      observedCount: observed,
      queuedCount: queued,
      resolvingCount: resolving,
      resolvedCount: resolved,
      reviewCount: review,
      failedCount: failed,
      committedCount: committed,
    );
  }

  /// Submits stable evidence from one physical track.
  ///
  /// Returns true only when a new background resolution job was accepted.
  bool submit({required String trackId, required ScanCode stableCode}) {
    if (_isDisposed) {
      return false;
    }

    final String normalizedTrackId = trackId.trim();

    if (normalizedTrackId.isEmpty) {
      throw ArgumentError.value(trackId, 'trackId', 'trackId cannot be empty.');
    }

    final DateTime now = DateTime.now().toUtc();
    final AtlasScanLedgerEntry? existing = ledger.entryForTrack(
      normalizedTrackId,
    );

    if (existing != null) {
      return false;
    }

    ledger.observe(trackId: normalizedTrackId, stableCode: stableCode, at: now);

    ledger.markQueued(trackId: normalizedTrackId, at: now);

    _notifyChanged();

    final String jobId = _createJobId(
      trackId: normalizedTrackId,
      createdAt: now,
    );

    unawaited(
      resolutionQueue
          .enqueue(
            AtlasResolutionJob(
              jobId: jobId,
              trackId: normalizedTrackId,
              createdAt: now,
              execute: () => _resolveTrack(
                trackId: normalizedTrackId,
                stableCode: stableCode,
              ),
            ),
          )
          .catchError((Object error, StackTrace stackTrace) {
            _handleQueueFailure(trackId: normalizedTrackId, error: error);
          }),
    );

    return true;
  }

  void dispose() {
    if (_isDisposed) {
      return;
    }

    _isDisposed = true;
    resolutionQueue.dispose();
  }

  Future<void> _resolveTrack({
    required String trackId,
    required ScanCode stableCode,
  }) async {
    if (_isDisposed) {
      return;
    }

    final DateTime startedAt = DateTime.now().toUtc();

    ledger.markResolving(trackId: trackId, at: startedAt);
    _notifyChanged();

    try {
      final String executionId = _createExecutionId(
        startedAt,
        stableCode.normalizedValue,
      );

      final EngineContext engineContext = EngineContext(
        requestId: executionId,
        createdAt: startedAt,
        connectivity: EngineConnectivity.unknown,
        deviceType: EngineDeviceType.mobile,
        deviceCapabilities: const <String>{
          BarcodeIntelligenceEngine.capabilityId,
        },
        attributes: <String, Object?>{
          'scanSource': ScanCodeSource.camera.name,
          'scannerType': ScannerType.mobileScanner.name,
          'barcodeFormat': stableCode.format.name,
          'trackId': trackId,
          'continuousScan': true,
        },
      );

      final ScanSession initialSession = ScanSession(
        sessionId: executionId,
        startedAt: startedAt,
        status: ScanSessionStatus.analyzing,
        intent: ScanIntent.identifyProduct,
        performanceMode: ScanPerformanceMode.fastBarcodeOnly,
        scannerType: ScannerType.mobileScanner,
        detectedCodes: <ScanCode>[stableCode],
        bestCandidate: stableCode,
      );

      final pipeline = StandardScanPipeline.create(engineContext);
      final result = await pipeline.process(initialSession, engineContext);

      final ScanSession finalSession = result.finalSession;

      final ScanCode? resolvedCode =
          finalSession.bestCandidate ?? _firstDetectedCode(finalSession);

      final AtlasBarcodeResolution catalogResolution;

      if (resolvedCode == null ||
          !resolvedCode.isValid ||
          !resolvedCode.isProductBarcode) {
        catalogResolution = AtlasBarcodeResolution.invalid(
          barcode: resolvedCode?.normalizedValue ?? '',
        );
      } else if (finalSession.catalogProduct != null) {
        catalogResolution = AtlasBarcodeResolution.matches(
          barcode: resolvedCode.normalizedValue,
          matches: <AtlasCatalogProduct>[finalSession.catalogProduct!],
        );
      } else {
        catalogResolution = await _catalogResolver.resolve(
          resolvedCode.normalizedValue,
        );
      }

      final DateTime completedAt = DateTime.now().toUtc();

      _resultsByTrack[trackId] = AtlasContinuousScanResult(
        trackId: trackId,
        session: finalSession,
        catalogResolution: catalogResolution,
        completedAt: completedAt,
      );

      if (finalSession.requiresUserAction) {
        ledger.markNeedsReview(
          trackId: trackId,
          resolutionSessionId: finalSession.sessionId,
          at: completedAt,
        );
      } else {
        ledger.markResolved(
          trackId: trackId,
          resolutionSessionId: finalSession.sessionId,
          at: completedAt,
        );
      }
    } catch (error) {
      ledger.markFailed(
        trackId: trackId,
        error: error,
        at: DateTime.now().toUtc(),
      );
      rethrow;
    } finally {
      _notifyChanged();
    }
  }

  void _handleQueueFailure({required String trackId, required Object error}) {
    final AtlasScanLedgerEntry? entry = ledger.entryForTrack(trackId);

    if (entry == null || entry.hasFailed) {
      _notifyChanged();
      return;
    }

    if (entry.isQueued) {
      ledger.markResolving(trackId: trackId, at: DateTime.now().toUtc());
    }

    final AtlasScanLedgerEntry? current = ledger.entryForTrack(trackId);

    if (current != null && current.isResolving) {
      ledger.markFailed(
        trackId: trackId,
        error: error,
        at: DateTime.now().toUtc(),
      );
    }

    _notifyChanged();
  }

  ScanCode? _firstDetectedCode(ScanSession session) {
    if (session.detectedCodes.isEmpty) {
      return null;
    }

    return session.detectedCodes.first;
  }

  String _createExecutionId(DateTime createdAt, String code) {
    final int codeHash = code.hashCode.abs();

    return 'scan_'
        '${createdAt.microsecondsSinceEpoch}_'
        '$codeHash';
  }

  String _createJobId({required String trackId, required DateTime createdAt}) {
    return 'resolution_'
        '${createdAt.microsecondsSinceEpoch}_'
        '${trackId.hashCode.abs()}';
  }

  void _notifyChanged() {
    if (_isDisposed) {
      return;
    }

    onChanged?.call();
  }
}
