import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../atlas/scan/acquisition/atlas_continuous_scan_coordinator.dart';
import '../../atlas/scan/acquisition/atlas_mobile_scanner_observation_adapter.dart';
import '../../atlas/scan/continuous/atlas_continuous_perception_coordinator.dart';
import '../../atlas/scan/continuous/models/atlas_perception_frame_result.dart';
import '../../atlas/scan/results/atlas_continuous_scan_result.dart';
import '../../atlas/scan/models/scan_code.dart';
import '../../atlas/scan/tracking/atlas_scan_observation.dart';
import '../../atlas/shelf/atlas_shelf_session_coordinator.dart';
import '../../services/app_state.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/atlas_glass_panel.dart';
import '../../widgets/atlas/components/atlas_info_banner.dart';
import '../../widgets/atlas/components/atlas_section_header.dart';
import '../../widgets/atlas/components/atlas_status_chip.dart';
import 'atlas_shelf_batch_review_screen.dart';

class AtlasShelfScanScreen extends StatefulWidget {
  const AtlasShelfScanScreen({super.key, required this.collectionName});

  final String collectionName;

  @override
  State<AtlasShelfScanScreen> createState() => _AtlasShelfScanScreenState();
}

class _AtlasShelfScanScreenState extends State<AtlasShelfScanScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    formats: const <BarcodeFormat>[
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.ean8,
      BarcodeFormat.ean13,
      BarcodeFormat.qrCode,
    ],
  );

  late final AtlasContinuousScanCoordinator _resolutionCoordinator;
  late final AtlasContinuousPerceptionCoordinator _perceptionCoordinator;
  late final AtlasShelfSessionCoordinator _shelfCoordinator;

  final Set<String> _ingestedResultTrackIds = <String>{};
  final Map<String, AtlasNormalizedBounds> _latestBoundsByTrack =
      <String, AtlasNormalizedBounds>{};

  AtlasPerceptionFrameResult? _latestFrame;
  bool _finishing = false;

  @override
  void initState() {
    super.initState();

    final DateTime startedAt = DateTime.now().toUtc();
    _resolutionCoordinator = AtlasContinuousScanCoordinator(
      onChanged: _handleResolutionChanged,
    );
    _perceptionCoordinator = AtlasContinuousPerceptionCoordinator(
      submitStableCandidate: _submitStableCandidate,
    );
    _shelfCoordinator = AtlasShelfSessionCoordinator(
      sessionId: 'shelf_${startedAt.microsecondsSinceEpoch}',
      collectionName: widget.collectionName,
      startedAt: startedAt,
    );
  }

  @override
  void dispose() {
    _resolutionCoordinator.dispose();
    _perceptionCoordinator.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  bool _submitStableCandidate({
    required String trackId,
    required ScanCode stableCode,
  }) {
    return _resolutionCoordinator.submit(
      trackId: trackId,
      stableCode: stableCode,
    );
  }

  void _handleDetection(BarcodeCapture capture) {
    if (_finishing) return;

    final DateTime capturedAt = DateTime.now().toUtc();
    final List<AtlasScanObservation> observations =
        AtlasMobileScannerObservationAdapter.fromCapture(
              capture,
              capturedAt: capturedAt,
            )
            .where((AtlasScanObservation item) => item.hasGeometry)
            .toList(growable: false);

    final AtlasPerceptionFrameResult frame = _perceptionCoordinator
        .processFrame(timestamp: capturedAt, observations: observations);

    for (final candidate in frame.candidates) {
      final bounds = candidate.normalizedBounds;
      if (bounds != null) {
        _latestBoundsByTrack[candidate.trackId] = bounds;
      }
    }

    _shelfCoordinator.applyPerceptionFrame(frame);
    _latestFrame = frame;

    if (mounted) {
      setState(() {});
    }
  }

  void _handleResolutionChanged() {
    for (final AtlasContinuousScanResult result
        in _resolutionCoordinator.results) {
      if (!_ingestedResultTrackIds.add(result.trackId)) {
        continue;
      }

      _shelfCoordinator.ingestContinuousResult(
        result,
        bounds: _latestBoundsByTrack[result.trackId],
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _finishScan() async {
    if (_finishing) return;

    setState(() => _finishing = true);
    await _scannerController.stop();

    if (!mounted) return;

    final AppState appState = context.read<AppState>();
    _shelfCoordinator.reconcile(
      collectionPops: appState.popsForCollection(widget.collectionName),
      ownedWishlistIdentityKeys: appState
          .ownedWishlistIdentityKeysForCollection(widget.collectionName),
    );

    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => AtlasShelfBatchReviewScreen(
          collectionName: widget.collectionName,
          shelfCoordinator: _shelfCoordinator,
          resolutionCoordinator: _resolutionCoordinator,
        ),
      ),
    );

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final session = _shelfCoordinator.session;
    final resolution = _resolutionCoordinator.snapshot;
    final int tracked = _latestFrame?.candidates.length ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text('Shelf Scan • ${widget.collectionName}')),
      body: Column(
        children: [
          SizedBox(
            height: 300,
            child: Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  controller: _scannerController,
                  onDetect: _handleDetection,
                ),
                const _ShelfScannerGuide(),
                Positioned(
                  top: AtlasSpacing.md,
                  left: AtlasSpacing.md,
                  right: AtlasSpacing.md,
                  child: _ShelfTrackingOverlay(
                    trackedCount: tracked,
                    resolvedCount: resolution.completedCount,
                    shelfCount: session.observations.length,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.all(AtlasSpacing.md),
                children: [
                  const AtlasInfoBanner(
                    title: '📚 Shelf Intelligence',
                    message:
                        'Pan slowly across the shelf. Atlas aggregates physical observations and stages reconciliation suggestions; it does not change the Vault while scanning.',
                    icon: Icons.view_in_ar_outlined,
                    accentColor: AtlasColors.intelligenceBlue,
                  ),
                  const SizedBox(height: AtlasSpacing.md),
                  AtlasGlassCard(
                    accentColor: AtlasColors.intelligenceBlue,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AtlasSectionHeader(
                          title: 'Live Shelf Session',
                          subtitle:
                              '${session.observations.length} persistent shelf object${session.observations.length == 1 ? '' : 's'} observed.',
                          icon: Icons.inventory_2_outlined,
                          accentColor: AtlasColors.intelligenceBlue,
                        ),
                        const SizedBox(height: AtlasSpacing.md),
                        Wrap(
                          spacing: AtlasSpacing.sm,
                          runSpacing: AtlasSpacing.sm,
                          children: [
                            AtlasStatusChip(
                              label: '$tracked tracked now',
                              icon: Icons.center_focus_strong_rounded,
                              accentColor: AtlasColors.intelligenceBlue,
                            ),
                            AtlasStatusChip(
                              label: '${resolution.completedCount} resolved',
                              icon: Icons.task_alt_rounded,
                              accentColor: AtlasColors.success,
                            ),
                            AtlasStatusChip(
                              label:
                                  '${session.observations.length} shelf objects',
                              icon: Icons.inventory_2_outlined,
                              accentColor: AtlasColors.vaultGold,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AtlasSpacing.md),
                  AtlasGlassPanel(
                    child: Text(
                      'Tip: keep labels and barcodes visible long enough for Atlas to stabilize them. When you finish, every proposed add or copy change is reviewed individually before it can reach the Vault.',
                      style: AtlasTypography.bodySmall.copyWith(
                        color: AtlasColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AtlasSpacing.lg),
                  FilledButton.icon(
                    key: const ValueKey('finish-shelf-scan'),
                    onPressed: _finishing ? null : _finishScan,
                    icon: _finishing
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.fact_check_outlined),
                    label: Text(
                      _finishing
                          ? 'Preparing Review...'
                          : 'Finish & Review Shelf',
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

class _ShelfScannerGuide extends StatelessWidget {
  const _ShelfScannerGuide();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Container(
          width: 300,
          height: 180,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 3),
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

class _ShelfTrackingOverlay extends StatelessWidget {
  const _ShelfTrackingOverlay({
    required this.trackedCount,
    required this.resolvedCount,
    required this.shelfCount,
  });

  final int trackedCount;
  final int resolvedCount;
  final int shelfCount;

  @override
  Widget build(BuildContext context) {
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
              '👀 $trackedCount tracked • ✅ $resolvedCount resolved • 📚 $shelfCount persistent',
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
