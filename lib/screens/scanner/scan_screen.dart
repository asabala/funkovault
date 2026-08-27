import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import 'package:funkovault2/services/app_state.dart';
import 'package:funkovault2/atlas/catalog/models/atlas_catalog_product.dart';
import 'package:funkovault2/atlas/catalog/services/atlas_barcode_catalog_resolver.dart';
import 'package:funkovault2/atlas/scan/acquisition/atlas_evidence_accumulator.dart';
import 'package:funkovault2/atlas/scan/acquisition/atlas_mobile_scanner_observation_adapter.dart';
import 'package:funkovault2/atlas/scan/engine/barcode_intelligence_engine.dart';
import 'package:funkovault2/atlas/scan/engine/engine_context.dart';
import 'package:funkovault2/atlas/scan/models/scan_code.dart';
import 'package:funkovault2/atlas/scan/models/scan_session.dart';
import 'package:funkovault2/atlas/scan/models/scanner_type.dart';
import 'package:funkovault2/atlas/scan/pipeline/standard_scan_pipeline.dart';
import 'package:funkovault2/atlas/scan/tracking/atlas_object_track.dart';
import 'package:funkovault2/atlas/scan/tracking/atlas_object_tracker.dart';
import 'package:funkovault2/atlas/scan/tracking/atlas_scan_observation.dart';
import 'package:funkovault2/atlas/scan/workflow/scan_intent.dart';
import 'package:funkovault2/atlas/scan/workflow/scan_performance_mode.dart';
import 'package:funkovault2/screens/catalog/funko_catalog_screen.dart';
import 'package:funkovault2/screens/scanner/atlas_scan_result_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() {
    return _ScanScreenState();
  }
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    formats: const <BarcodeFormat>[
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.ean8,
      BarcodeFormat.ean13,
      BarcodeFormat.qrCode,
    ],
  );

  final AtlasBarcodeCatalogResolver _catalogResolver =
      AtlasBarcodeCatalogResolver();

  final AtlasObjectTracker _objectTracker = AtlasObjectTracker();

  final AtlasEvidenceAccumulator _evidenceAccumulator =
      AtlasEvidenceAccumulator();

  final Set<String> _processingTrackIds = <String>{};

  String? _scannedCode;
  bool _isProcessing = false;
  int _activeTrackCount = 0;
  int _confirmedTrackCount = 0;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleDetection(BarcodeCapture capture) async {
    final DateTime capturedAt = DateTime.now().toUtc();

    final List<AtlasScanObservation> observations =
        AtlasMobileScannerObservationAdapter.fromCapture(
          capture,
          capturedAt: capturedAt,
        );

    if (observations.isEmpty) {
      return;
    }

    final List<AtlasScanObservation> trackableObservations = observations
        .where((AtlasScanObservation observation) => observation.hasGeometry)
        .toList(growable: false);

    if (trackableObservations.isEmpty) {
      if (_isProcessing) {
        return;
      }

      final ScanCode? fallbackCode = _firstUsableObservationCode(observations);

      if (fallbackCode == null) {
        return;
      }

      await _processStableCode(fallbackCode, trackId: null);
      return;
    }

    final List<AtlasObjectTrack> tracks = _objectTracker.processFrame(
      observations: trackableObservations,
      timestamp: capturedAt,
    );

    _updateTrackingStatus(tracks);

    if (_isProcessing) {
      return;
    }

    for (final AtlasObjectTrack track in tracks) {
      if (_processingTrackIds.contains(track.trackId)) {
        continue;
      }

      final AtlasAccumulatedEvidence? evidence = _evidenceAccumulator
          .evaluateTrack(track);

      if (evidence == null || !evidence.isReadyForResolution) {
        continue;
      }

      await _processStableCode(evidence.stableCode, trackId: track.trackId);
      return;
    }
  }

  void _updateTrackingStatus(List<AtlasObjectTrack> tracks) {
    final int confirmedCount = tracks
        .where((AtlasObjectTrack track) => track.isConfirmed)
        .length;

    if (!mounted ||
        (_activeTrackCount == tracks.length &&
            _confirmedTrackCount == confirmedCount)) {
      return;
    }

    setState(() {
      _activeTrackCount = tracks.length;
      _confirmedTrackCount = confirmedCount;
    });
  }

  ScanCode? _firstUsableObservationCode(
    List<AtlasScanObservation> observations,
  ) {
    for (final AtlasScanObservation observation in observations) {
      final ScanCode? code = observation.code;

      if (code != null &&
          code.isValid &&
          code.isProductBarcode &&
          code.normalizedValue.trim().isNotEmpty) {
        return code;
      }
    }

    return null;
  }

  Future<void> _processStableCode(
    ScanCode scanCode, {
    required String? trackId,
  }) async {
    if (_isProcessing) {
      return;
    }

    final String collectionName = context.read<AppState>().selectedCollection;

    if (trackId != null) {
      _processingTrackIds.add(trackId);
    }

    setState(() {
      _isProcessing = true;
      _scannedCode = scanCode.normalizedValue;
    });

    await _scannerController.stop();

    try {
      final DateTime startedAt = DateTime.now().toUtc();

      final String executionId = _createExecutionId(
        startedAt,
        scanCode.normalizedValue,
      );

      final Map<String, Object?> engineAttributes = <String, Object?>{
        'scanSource': ScanCodeSource.camera.name,
        'scannerType': ScannerType.mobileScanner.name,
        'barcodeFormat': scanCode.format.name,
      };

      if (trackId != null) {
        engineAttributes['trackId'] = trackId;
      }

      final EngineContext engineContext = EngineContext(
        requestId: executionId,
        createdAt: startedAt,
        connectivity: EngineConnectivity.unknown,
        deviceType: EngineDeviceType.mobile,
        deviceCapabilities: const <String>{
          BarcodeIntelligenceEngine.capabilityId,
        },
        attributes: engineAttributes,
      );

      final ScanSession initialSession = ScanSession(
        sessionId: executionId,
        startedAt: startedAt,
        status: ScanSessionStatus.analyzing,
        intent: ScanIntent.identifyProduct,
        performanceMode: ScanPerformanceMode.fastBarcodeOnly,
        scannerType: ScannerType.mobileScanner,
        detectedCodes: <ScanCode>[scanCode],
        bestCandidate: scanCode,
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

      if (!mounted) {
        return;
      }

      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (_) {
            return AtlasScanResultScreen(
              session: finalSession,
              catalogResolution: catalogResolution,
              collectionName: collectionName,
            );
          },
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Atlas could not process this scan: $error')),
        );
    } finally {
      if (trackId != null) {
        _objectTracker.markCooldown(
          trackId: trackId,
          startedAt: DateTime.now().toUtc(),
        );
        _processingTrackIds.remove(trackId);
      }

      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        await _scannerController.start();
      }
    }
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

  Future<void> _openCatalog() async {
    if (_isProcessing) {
      return;
    }

    await _scannerController.stop();

    if (!mounted) {
      return;
    }

    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) {
          return const FunkoCatalogScreen();
        },
      ),
    );

    if (mounted) {
      await _scannerController.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Pop')),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  controller: _scannerController,
                  onDetect: _handleDetection,
                ),
                const _ScannerGuide(),
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: _TrackingStatusOverlay(
                    activeTrackCount: _activeTrackCount,
                    confirmedTrackCount: _confirmedTrackCount,
                    isProcessing: _isProcessing,
                  ),
                ),
                if (_isProcessing) const _ProcessingOverlay(),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Atlas Continuous Scanner Ready',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _openCatalog,
                      icon: const Icon(Icons.search),
                      label: const Text('Browse Catalog'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isProcessing
                        ? 'Atlas is analyzing the stable scan...'
                        : _scannerStatusText(),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _scannerStatusText() {
    if (_confirmedTrackCount > 0) {
      return 'Tracking $_activeTrackCount item(s) — '
          '$_confirmedTrackCount confirmed';
    }

    if (_activeTrackCount > 0) {
      return 'Tracking $_activeTrackCount item(s) — '
          'gathering stable evidence';
    }

    return _scannedCode ?? 'Waiting for scan...';
  }
}

class _ScannerGuide extends StatelessWidget {
  const _ScannerGuide();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Container(
          width: 280,
          height: 170,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 3),
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

class _TrackingStatusOverlay extends StatelessWidget {
  const _TrackingStatusOverlay({
    required this.activeTrackCount,
    required this.confirmedTrackCount,
    required this.isProcessing,
  });

  final int activeTrackCount;
  final int confirmedTrackCount;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    final String label;

    if (isProcessing) {
      label = '🧠 Resolving stable scan';
    } else if (confirmedTrackCount > 0) {
      label =
          '🎯 $confirmedTrackCount confirmed • '
          '$activeTrackCount tracked';
    } else if (activeTrackCount > 0) {
      label =
          '👀 $activeTrackCount tracked • '
          'stabilizing';
    } else {
      label = '📷 Continuous tracking active';
    }

    return IgnorePointer(
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProcessingOverlay extends StatelessWidget {
  const _ProcessingOverlay();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black54,
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Atlas is analyzing...',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Validating stable evidence and checking the Atlas catalog',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
