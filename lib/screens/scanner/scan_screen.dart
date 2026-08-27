import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:funkovault2/atlas/scan/acquisition/atlas_continuous_scan_coordinator.dart';
import 'package:funkovault2/atlas/scan/acquisition/atlas_evidence_accumulator.dart';
import 'package:funkovault2/atlas/scan/acquisition/atlas_mobile_scanner_observation_adapter.dart';
import 'package:funkovault2/atlas/scan/tracking/atlas_object_track.dart';
import 'package:funkovault2/atlas/scan/tracking/atlas_object_tracker.dart';
import 'package:funkovault2/atlas/scan/tracking/atlas_scan_observation.dart';
import 'package:funkovault2/screens/catalog/funko_catalog_screen.dart';

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

  final AtlasObjectTracker _objectTracker = AtlasObjectTracker();

  final AtlasEvidenceAccumulator _evidenceAccumulator =
      AtlasEvidenceAccumulator();

  late final AtlasContinuousScanCoordinator _coordinator;

  String? _lastStableCode;
  int _activeTrackCount = 0;
  int _confirmedTrackCount = 0;

  @override
  void initState() {
    super.initState();

    _coordinator = AtlasContinuousScanCoordinator(
      onChanged: _handleCoordinatorChanged,
    );
  }

  @override
  void dispose() {
    _coordinator.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _handleCoordinatorChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  void _handleDetection(BarcodeCapture capture) {
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
      return;
    }

    final List<AtlasObjectTrack> tracks = _objectTracker.processFrame(
      observations: trackableObservations,
      timestamp: capturedAt,
    );

    _updateTrackingStatus(tracks);

    for (final AtlasObjectTrack track in tracks) {
      final AtlasAccumulatedEvidence? evidence = _evidenceAccumulator
          .evaluateTrack(track);

      if (evidence == null || !evidence.isReadyForResolution) {
        continue;
      }

      final bool accepted = _coordinator.submit(
        trackId: track.trackId,
        stableCode: evidence.stableCode,
      );

      if (accepted) {
        _lastStableCode = evidence.stableCode.normalizedValue;
      }
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

  Future<void> _openCatalog() async {
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
    final AtlasContinuousScanSnapshot coordinatorSnapshot =
        _coordinator.snapshot;

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
                    snapshot: coordinatorSnapshot,
                  ),
                ),
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
                    'Atlas Haul Scanner',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _HaulStatusLine(
                    snapshot: coordinatorSnapshot,
                    lastStableCode: _lastStableCode,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _openCatalog,
                      icon: const Icon(Icons.search),
                      label: const Text('Browse Catalog'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
    required this.snapshot,
  });

  final int activeTrackCount;
  final int confirmedTrackCount;
  final AtlasContinuousScanSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final String label;

    if (snapshot.hasWorkInFlight) {
      label =
          '🧠 ${snapshot.activeResolutionCount} resolving • '
          '${snapshot.pendingResolutionCount} queued';
    } else if (snapshot.completedCount > 0) {
      label =
          '✅ ${snapshot.completedCount} resolved • '
          '$activeTrackCount tracked';
    } else if (confirmedTrackCount > 0) {
      label =
          '🎯 $confirmedTrackCount confirmed • '
          '$activeTrackCount tracked';
    } else if (activeTrackCount > 0) {
      label = '👀 $activeTrackCount tracked • stabilizing';
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

class _HaulStatusLine extends StatelessWidget {
  const _HaulStatusLine({required this.snapshot, required this.lastStableCode});

  final AtlasContinuousScanSnapshot snapshot;
  final String? lastStableCode;

  @override
  Widget build(BuildContext context) {
    final String text;

    if (snapshot.failedCount > 0) {
      text =
          '⚠️ ${snapshot.failedCount} scan(s) need retry • '
          '${snapshot.completedCount} resolved';
    } else if (snapshot.reviewCount > 0) {
      text =
          '🔎 ${snapshot.reviewCount} scan(s) need review • '
          '${snapshot.resolvedCount} resolved';
    } else if (snapshot.hasWorkInFlight) {
      text = 'Scanning continues while Atlas resolves in the background.';
    } else if (snapshot.completedCount > 0) {
      text = '${snapshot.completedCount} item(s) ready in this haul.';
    } else {
      text = lastStableCode ?? 'Point the camera at collectible barcodes.';
    }

    return Text(text, textAlign: TextAlign.center);
  }
}
