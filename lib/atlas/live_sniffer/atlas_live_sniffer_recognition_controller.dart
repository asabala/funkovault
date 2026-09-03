import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../models/pop.dart';
import '../catalog/models/atlas_catalog_product.dart';
import '../collector/services/atlas_collector_resolver.dart';
import '../scan/acquisition/atlas_continuous_scan_coordinator.dart';
import '../scan/continuous/atlas_continuous_perception_coordinator.dart';
import '../scan/models/scan_code.dart';
import '../scan/results/atlas_continuous_scan_result.dart';
import 'atlas_live_sniffer_recognition_bridge.dart';
import 'models/atlas_live_sniffer_box_candidate.dart';
import 'models/atlas_live_sniffer_hud_snapshot.dart';
import 'models/atlas_live_sniffer_native_frame.dart';
import 'models/atlas_live_sniffer_scan_mode.dart';
import 'recognition/atlas_live_sniffer_auction_match_engine.dart';
import 'recognition/atlas_live_sniffer_box_candidate_extractor.dart';
import 'recognition/atlas_live_sniffer_native_observation_adapter.dart';

final class AtlasLiveSnifferRecognitionController extends ChangeNotifier {
  AtlasLiveSnifferRecognitionController({
    AtlasLiveSnifferRecognitionPlatform? platform,
    AtlasCollectorResolver? collectorResolver,
    AtlasLiveSnifferAuctionMatchEngine? auctionMatchEngine,
    AtlasLiveSnifferBoxCandidateExtractor? candidateExtractor,
  }) : _platform = platform ?? const AtlasLiveSnifferRecognitionBridge(),
       _collectorResolver =
           collectorResolver ?? AtlasCollectorResolver.instance,
       _auctionMatchEngine =
           auctionMatchEngine ?? AtlasLiveSnifferAuctionMatchEngine(),
       _candidateExtractor =
           candidateExtractor ?? const AtlasLiveSnifferBoxCandidateExtractor();

  final AtlasLiveSnifferRecognitionPlatform _platform;
  final AtlasCollectorResolver _collectorResolver;
  final AtlasLiveSnifferAuctionMatchEngine _auctionMatchEngine;
  final AtlasLiveSnifferBoxCandidateExtractor _candidateExtractor;

  AtlasContinuousScanCoordinator? _scanCoordinator;
  AtlasContinuousPerceptionCoordinator? _perceptionCoordinator;

  StreamSubscription<Map<Object?, Object?>>? _frameSubscription;
  final Set<String> _projectedTrackIds = <String>{};
  final Map<String, _TemporalBoxEvidence> _temporalEvidence =
      <String, _TemporalBoxEvidence>{};

  String _collectionName = 'All Atlas Collections';
  List<Pop> _collectionPops = const <Pop>[];
  Set<String> _ownedWishlistIdentityKeys = const <String>{};
  AtlasLiveSnifferHudSnapshot _hud =
      const AtlasLiveSnifferHudSnapshot.listening();
  AtlasLiveSnifferScanMode _scanMode = AtlasLiveSnifferScanMode.automatic;
  bool _sessionModeLocked = false;
  bool _awaitingModeChoice = false;
  int _multiCandidateStreak = 0;
  int _lastDetectedCount = 0;
  bool _sessionActive = false;
  bool _ocrProjectionInFlight = false;
  int _sessionGeneration = 0;
  DateTime? _lastFrameAt;
  double? _targetX;
  double? _targetY;

  AtlasLiveSnifferHudSnapshot get hud => _hud;
  bool get sessionActive => _sessionActive;
  AtlasLiveSnifferScanMode get scanMode => _scanMode;

  void setScanMode(AtlasLiveSnifferScanMode mode) {
    if (_sessionActive || _scanMode == mode) return;
    _scanMode = mode;
    notifyListeners();
  }

  void startSession({
    required String collectionName,
    required List<Pop> collectionPops,
    Set<String> ownedWishlistIdentityKeys = const <String>{},
  }) {
    _collectionName = collectionName.trim().isEmpty
        ? 'All Atlas Collections'
        : collectionName.trim();
    _collectionPops = List<Pop>.unmodifiable(collectionPops);
    _ownedWishlistIdentityKeys = Set<String>.unmodifiable(
      ownedWishlistIdentityKeys,
    );

    _sessionGeneration++;
    _replacePipeline();
    _projectedTrackIds.clear();
    _temporalEvidence.clear();
    _lastFrameAt = null;
    _targetX = null;
    _targetY = null;
    _ocrProjectionInFlight = false;
    _sessionModeLocked = _scanMode != AtlasLiveSnifferScanMode.automatic;
    _awaitingModeChoice = false;
    _multiCandidateStreak = 0;
    _lastDetectedCount = 0;
    _hud = AtlasLiveSnifferHudSnapshot(
      state: AtlasLiveSnifferHudState.listening,
      title: 'Auction Fast Mode',
      statusLabel: switch (_scanMode) {
        AtlasLiveSnifferScanMode.automatic => 'Auto Detect',
        AtlasLiveSnifferScanMode.featured => 'Featured Pop',
        AtlasLiveSnifferScanMode.allVisible => 'All Visible',
      },
      detail: 'Looking for Pop name + number...',
    );
    _sessionActive = true;

    _frameSubscription ??= _platform.frames.listen(
      _handleNativeFrame,
      onError: _handleFrameError,
    );

    unawaited(_publishHud());
    notifyListeners();
  }

  Future<void> stopSession() async {
    _sessionGeneration++;
    _sessionActive = false;
    await _frameSubscription?.cancel();
    _frameSubscription = null;
    final AtlasContinuousScanCoordinator? scanCoordinator = _scanCoordinator;
    final AtlasContinuousPerceptionCoordinator? perceptionCoordinator =
        _perceptionCoordinator;
    _scanCoordinator = null;
    _perceptionCoordinator = null;
    scanCoordinator?.dispose();
    if (perceptionCoordinator != null) {
      await perceptionCoordinator.dispose();
    }
    _projectedTrackIds.clear();
    _temporalEvidence.clear();
    _lastFrameAt = null;
    _targetX = null;
    _targetY = null;
    _ocrProjectionInFlight = false;
    _sessionModeLocked = false;
    _awaitingModeChoice = false;
    _multiCandidateStreak = 0;
    _lastDetectedCount = 0;
    _hud = const AtlasLiveSnifferHudSnapshot.listening();
    notifyListeners();
  }

  void _handleNativeFrame(Map<Object?, Object?> payload) {
    if (!_sessionActive) return;

    final String payloadType = payload['type']?.toString() ?? '';
    if (payloadType == 'control') {
      _handleOverlayControl(payload);
      return;
    }
    if (payloadType != 'frame') return;

    AtlasLiveSnifferNativeFrame frame = AtlasLiveSnifferNativeFrame.fromMap(
      payload,
    );

    final DateTime? previousFrameAt = _lastFrameAt;
    if (previousFrameAt != null && !frame.capturedAt.isAfter(previousFrameAt)) {
      frame = AtlasLiveSnifferNativeFrame(
        capturedAt: previousFrameAt.add(const Duration(microseconds: 1)),
        barcodes: frame.barcodes,
        textBlocks: frame.textBlocks,
        recognizedText: frame.recognizedText,
      );
    }
    _lastFrameAt = frame.capturedAt;

    // UPC/EAN remains a bonus signal. It still crosses the canonical 6A ->
    // Scanner 4 boundary when the marketplace happens to expose a barcode.
    final observations = AtlasLiveSnifferNativeObservationAdapter.fromFrame(
      frame,
    );
    _perceptionCoordinator?.processFrame(
      timestamp: frame.capturedAt,
      observations: observations,
    );

    _expireTemporalEvidence(frame.capturedAt);
    final List<AtlasLiveSnifferBoxCandidate> extracted = _candidateExtractor
        .extract(frame, focusX: _targetX, focusY: _targetY);

    if (extracted.isEmpty) {
      if (frame.recognizedText.isNotEmpty &&
          _hud.state == AtlasLiveSnifferHudState.listening) {
        _hud = AtlasLiveSnifferHudSnapshot(
          state: AtlasLiveSnifferHudState.listening,
          title: 'Box text detected',
          statusLabel: _scanMode == AtlasLiveSnifferScanMode.featured
              ? 'Finding featured Pop...'
              : 'Finding visible Pops...',
          detail: 'Name + number are the fastest identity clues.',
        );
        unawaited(_publishHud());
        notifyListeners();
      }
      return;
    }

    final List<AtlasLiveSnifferBoxCandidate> plausible = _plausibleCandidates(
      extracted,
    );
    _lastDetectedCount = plausible.length;

    if (_scanMode == AtlasLiveSnifferScanMode.automatic &&
        !_sessionModeLocked) {
      if (plausible.length >= 2) {
        _multiCandidateStreak++;
      } else {
        _multiCandidateStreak = 0;
      }

      if (_multiCandidateStreak >= 2 && !_awaitingModeChoice) {
        _awaitingModeChoice = true;
        _hud = AtlasLiveSnifferHudSnapshot(
          state: AtlasLiveSnifferHudState.listening,
          title: '${plausible.length} Pops detected',
          statusLabel: 'Scan one or all?',
          detail:
              'Choose on the Atlas overlay. Featured scanning continues while you decide.',
        );
        unawaited(_publishHud());
        notifyListeners();
      }
    }

    final AtlasLiveSnifferScanMode effectiveMode =
        _scanMode == AtlasLiveSnifferScanMode.automatic
        ? AtlasLiveSnifferScanMode.featured
        : _scanMode;

    final List<AtlasLiveSnifferBoxCandidate> selected;
    if (effectiveMode == AtlasLiveSnifferScanMode.featured) {
      final AtlasLiveSnifferBoxCandidate featured =
          _targetX != null && _targetY != null
          ? _closestToTarget(plausible, _targetX!, _targetY!)
          : plausible.first;
      selected = <AtlasLiveSnifferBoxCandidate>[featured];
    } else {
      selected = plausible.take(12).toList(growable: false);
    }

    final List<AtlasLiveSnifferBoxCandidate> accumulated = selected
        .map((AtlasLiveSnifferBoxCandidate candidate) {
          final _TemporalBoxEvidence evidence = _temporalEvidence.update(
            candidate.candidateId,
            (existing) => existing.add(candidate, frame.capturedAt),
            ifAbsent: () =>
                _TemporalBoxEvidence.fromCandidate(candidate, frame.capturedAt),
          );
          return evidence.toCandidate();
        })
        .toList(growable: false);

    // Auction mode must not queue unbounded OCR catalog work. One projection can
    // be in flight while native capture continues sampling the full screen.
    if (!_ocrProjectionInFlight) {
      _ocrProjectionInFlight = true;
      final int generation = _sessionGeneration;
      unawaited(_resolveAuctionCandidates(accumulated, generation));
    }
  }

  Future<void> _resolveAuctionCandidates(
    List<AtlasLiveSnifferBoxCandidate> candidates,
    int generation,
  ) async {
    try {
      final List<AtlasLiveSnifferAuctionMatch> matches = await Future.wait(
        candidates.map(_auctionMatchEngine.match),
      );
      if (!_sessionActive || generation != _sessionGeneration) return;

      final AtlasLiveSnifferScanMode effectiveMode =
          _scanMode == AtlasLiveSnifferScanMode.automatic
          ? AtlasLiveSnifferScanMode.featured
          : _scanMode;
      if (effectiveMode == AtlasLiveSnifferScanMode.featured) {
        _projectFeaturedAuctionMatch(matches.first);
      } else {
        _projectAllAuctionMatches(matches);
      }
    } catch (_) {
      if (_sessionActive && generation == _sessionGeneration) {
        _hud = const AtlasLiveSnifferHudSnapshot(
          state: AtlasLiveSnifferHudState.needsReview,
          title: 'Live lookup paused',
          statusLabel: 'Keep watching',
          detail: 'Atlas will retry on the next readable frame.',
        );
        unawaited(_publishHud());
        notifyListeners();
      }
    } finally {
      if (generation == _sessionGeneration) {
        _ocrProjectionInFlight = false;
      }
    }
  }

  List<AtlasLiveSnifferBoxCandidate> _plausibleCandidates(
    List<AtlasLiveSnifferBoxCandidate> extracted,
  ) {
    if (extracted.isEmpty) return const <AtlasLiveSnifferBoxCandidate>[];
    final double topScore = extracted.first.featuredScore;
    final double floor = (topScore - 0.24).clamp(0.28, 0.72).toDouble();
    final List<AtlasLiveSnifferBoxCandidate> plausible = extracted
        .where((AtlasLiveSnifferBoxCandidate candidate) {
          return candidate.featuredScore >= floor;
        })
        .toList(growable: false);
    return plausible.isEmpty
        ? <AtlasLiveSnifferBoxCandidate>[extracted.first]
        : plausible;
  }

  void _handleOverlayControl(Map<Object?, Object?> payload) {
    final String action = payload['action']?.toString() ?? '';
    if (action == 'targetSelectionStarted') {
      _targetX = null;
      _targetY = null;
      _scanMode = AtlasLiveSnifferScanMode.featured;
      _sessionModeLocked = true;
      _awaitingModeChoice = false;
      _multiCandidateStreak = 0;
      _temporalEvidence.clear();
      _ocrProjectionInFlight = false;
      _sessionGeneration++;
      _hud = const AtlasLiveSnifferHudSnapshot(
        state: AtlasLiveSnifferHudState.listening,
        title: 'Tap the Pop you want to scan',
        statusLabel: 'Target selection',
        detail: 'Scanning is paused until you tap the box.',
      );
      unawaited(_publishHud());
      notifyListeners();
      return;
    }

    if (action == 'targetTap') {
      final double? x = _readUnitDouble(payload['x']);
      final double? y = _readUnitDouble(payload['y']);
      if (x == null || y == null) return;
      _targetX = x;
      _targetY = y;
      _scanMode = AtlasLiveSnifferScanMode.featured;
      _sessionModeLocked = true;
      _awaitingModeChoice = false;
      _multiCandidateStreak = 0;
      // A user tap is authoritative. Drop prior automatic/background evidence so
      // a stale shelf number can never survive into the selected Pop result.
      _temporalEvidence.clear();
      _ocrProjectionInFlight = false;
      _sessionGeneration++;
      _hud = const AtlasLiveSnifferHudSnapshot(
        state: AtlasLiveSnifferHudState.listening,
        title: 'Target locked',
        statusLabel: 'Scanning selected Pop...',
        detail: 'Tap the Atlas HUD again any time to retarget.',
      );
      unawaited(_publishHud());
      notifyListeners();
      return;
    }

    if (action == 'allVisible') {
      _targetX = null;
      _targetY = null;
      _scanMode = AtlasLiveSnifferScanMode.allVisible;
    } else if (action == 'featured') {
      _scanMode = AtlasLiveSnifferScanMode.featured;
    } else {
      return;
    }
    _sessionModeLocked = true;
    _awaitingModeChoice = false;
    _multiCandidateStreak = 0;
    _hud = AtlasLiveSnifferHudSnapshot(
      state: AtlasLiveSnifferHudState.listening,
      title: _scanMode == AtlasLiveSnifferScanMode.featured
          ? 'Featured Pop'
          : 'All Visible',
      statusLabel: _scanMode == AtlasLiveSnifferScanMode.featured
          ? 'Locked to foreground item'
          : 'Scanning $_lastDetectedCount visible Pops',
      detail: 'Mode locked for this live session.',
    );
    unawaited(_publishHud());
    notifyListeners();
  }

  AtlasLiveSnifferBoxCandidate _closestToTarget(
    List<AtlasLiveSnifferBoxCandidate> candidates,
    double x,
    double y,
  ) {
    return candidates.reduce((
      AtlasLiveSnifferBoxCandidate a,
      AtlasLiveSnifferBoxCandidate b,
    ) {
      final double adx = a.centerX - x;
      final double ady = a.centerY - y;
      final double bdx = b.centerX - x;
      final double bdy = b.centerY - y;
      final double aDistance = adx * adx + ady * ady;
      final double bDistance = bdx * bdx + bdy * bdy;
      return aDistance <= bDistance ? a : b;
    });
  }

  double? _readUnitDouble(Object? value) {
    final double? parsed = value is num
        ? value.toDouble()
        : double.tryParse(value?.toString() ?? '');
    if (parsed == null) return null;
    return parsed.clamp(0.0, 1.0).toDouble();
  }

  void _projectFeaturedAuctionMatch(AtlasLiveSnifferAuctionMatch match) {
    final AtlasCatalogProduct? product = match.bestMatch;
    if (product == null || !match.hasLikelyMatch) {
      _hud = AtlasLiveSnifferHudSnapshot(
        state: AtlasLiveSnifferHudState.listening,
        title: '#${match.candidate.productNumber}',
        statusLabel: 'Scanning box...',
        detail: 'Keep the name or front panel visible.',
        matchConfidence: match.confidence,
      );
      unawaited(_publishHud());
      notifyListeners();
      return;
    }

    if (!match.hasStrongMatch && match.matches.length > 1) {
      _hud = AtlasLiveSnifferHudSnapshot(
        state: AtlasLiveSnifferHudState.possibleVariant,
        title: _catalogTitle(product),
        statusLabel: '${match.matches.length} possible releases',
        detail: 'Refining sticker / variant clues...',
        matchConfidence: match.confidence,
      );
      unawaited(_publishHud());
      notifyListeners();
      return;
    }

    final AtlasLiveSnifferHudItem item = _collectorItem(
      product,
      match.confidence,
      provisional: !match.hasStrongMatch,
    );
    _hud = AtlasLiveSnifferHudSnapshot(
      state: _stateForStatus(item.statusLabel),
      title: item.title,
      statusLabel: item.statusLabel,
      cachedValue: item.cachedValue,
      matchConfidence: item.matchConfidence,
      detail: match.hasStrongMatch ? null : 'Refining while the box rotates...',
    );
    unawaited(_publishHud());
    notifyListeners();
  }

  void _projectAllAuctionMatches(List<AtlasLiveSnifferAuctionMatch> matches) {
    final List<AtlasLiveSnifferHudItem> items = <AtlasLiveSnifferHudItem>[];

    for (final AtlasLiveSnifferAuctionMatch match in matches) {
      final AtlasCatalogProduct? product = match.bestMatch;
      if (product == null || !match.hasLikelyMatch) {
        items.add(
          AtlasLiveSnifferHudItem(
            title: '#${match.candidate.productNumber}',
            statusLabel: 'MATCHING...',
            matchConfidence: match.confidence,
          ),
        );
        continue;
      }

      if (!match.hasStrongMatch && match.matches.length > 1) {
        items.add(
          AtlasLiveSnifferHudItem(
            title: _catalogTitle(product),
            statusLabel: 'POSSIBLE VARIANT',
            matchConfidence: match.confidence,
          ),
        );
        continue;
      }

      items.add(
        _collectorItem(
          product,
          match.confidence,
          provisional: !match.hasStrongMatch,
        ),
      );
    }

    _hud = AtlasLiveSnifferHudSnapshot(
      state: AtlasLiveSnifferHudState.listening,
      title: '${items.length} Pops detected',
      statusLabel: 'Auction Fast Mode — All Visible',
      detail: 'Results refine while the screen stays full size.',
      items: List<AtlasLiveSnifferHudItem>.unmodifiable(items),
    );
    unawaited(_publishHud());
    notifyListeners();
  }

  AtlasLiveSnifferHudItem _collectorItem(
    AtlasCatalogProduct catalogProduct,
    double confidence, {
    required bool provisional,
  }) {
    final resolved = _collectorResolver.resolve(
      catalogProduct: catalogProduct,
      collectionPops: _collectionPops,
      ownedWishlistIdentityKeys: _ownedWishlistIdentityKeys,
      collectionName: _collectionName,
      source: 'Atlas Live Sniffer Auction OCR',
    );

    final String catalogIdentity = resolved.catalogPop.collectibleIdentityKey
        .trim();
    final List<Pop> exactOwned = resolved.collectorState.ownedMatches
        .where((Pop pop) {
          return catalogIdentity.isNotEmpty &&
              pop.collectibleIdentityKey.trim() == catalogIdentity;
        })
        .toList(growable: false);
    final List<Pop> exactWishlist = resolved.collectorState.wishlistMatches
        .where((Pop pop) {
          return catalogIdentity.isNotEmpty &&
              pop.collectibleIdentityKey.trim() == catalogIdentity;
        })
        .toList(growable: false);

    final bool hasRelatedDifferentRelease =
        exactOwned.length != resolved.collectorState.ownedMatches.length ||
        exactWishlist.length !=
            resolved.collectorState.wishlistMatches.length ||
        resolved.collectorState.hasRelatedMatches;

    final int ownedQuantity = exactOwned.fold<int>(
      0,
      (int total, Pop pop) => total + pop.quantity,
    );

    String status;
    if (ownedQuantity > 0) {
      status = provisional
          ? 'LIKELY OWNED x$ownedQuantity'
          : 'OWNED x$ownedQuantity';
    } else if (hasRelatedDifferentRelease) {
      status = 'POSSIBLE VARIANT';
    } else if (exactWishlist.isNotEmpty ||
        resolved.collectorState.isOwnedWishlisted) {
      status = provisional ? 'LIKELY WISHLIST' : 'WISHLIST';
    } else {
      status = provisional ? 'LIKELY NOT OWNED' : 'NOT OWNED';
    }

    double? cachedValue;
    if (resolved.catalogPop.value > 0) {
      cachedValue = resolved.catalogPop.value;
    } else {
      for (final Pop pop in exactOwned) {
        if (pop.value > 0 && (cachedValue == null || pop.value > cachedValue)) {
          cachedValue = pop.value;
        }
      }
    }

    return AtlasLiveSnifferHudItem(
      title: _catalogTitle(catalogProduct),
      statusLabel: status,
      cachedValue: cachedValue,
      matchConfidence: confidence,
    );
  }

  AtlasLiveSnifferHudState _stateForStatus(String status) {
    if (status.contains('POSSIBLE')) {
      return AtlasLiveSnifferHudState.possibleVariant;
    }
    if (status.contains('WISHLIST')) {
      return AtlasLiveSnifferHudState.wishlisted;
    }
    if (status.contains('NOT OWNED')) {
      return AtlasLiveSnifferHudState.notOwned;
    }
    if (status.contains('OWNED')) {
      return AtlasLiveSnifferHudState.owned;
    }
    return AtlasLiveSnifferHudState.listening;
  }

  String _catalogTitle(AtlasCatalogProduct product) {
    final String number = product.productNumber?.trim() ?? '';
    return number.isEmpty
        ? product.displayName
        : '${product.displayName} #$number';
  }

  void _expireTemporalEvidence(DateTime now) {
    _temporalEvidence.removeWhere((String _, _TemporalBoxEvidence evidence) {
      return now.difference(evidence.lastSeenAt) > const Duration(seconds: 2);
    });
  }

  void _handleFrameError(Object error, StackTrace stackTrace) {
    if (!_sessionActive) return;
    _hud = const AtlasLiveSnifferHudSnapshot(
      state: AtlasLiveSnifferHudState.needsReview,
      title: 'Live recognition paused',
      statusLabel: 'Needs Review',
      detail: 'Atlas could not read the latest screen frame.',
    );
    unawaited(_publishHud());
    notifyListeners();
  }

  bool _submitStableCandidate({
    required String trackId,
    required ScanCode stableCode,
  }) {
    final AtlasContinuousScanCoordinator? scanCoordinator = _scanCoordinator;
    if (scanCoordinator == null) return false;
    return scanCoordinator.submit(trackId: trackId, stableCode: stableCode);
  }

  void _handleScanCoordinatorChanged() {
    final AtlasContinuousScanCoordinator? scanCoordinator = _scanCoordinator;
    if (!_sessionActive || scanCoordinator == null) return;

    for (final AtlasContinuousScanResult result in scanCoordinator.results) {
      if (_projectedTrackIds.contains(result.trackId)) continue;
      _projectedTrackIds.add(result.trackId);
      _projectBarcodeResult(result);
    }
  }

  void _projectBarcodeResult(AtlasContinuousScanResult result) {
    if (result.requiresUserReview) return;
    final AtlasCatalogProduct? product = result.resolvedCatalogProduct;
    if (product == null) return;

    final AtlasLiveSnifferHudItem item = _collectorItem(
      product,
      1,
      provisional: false,
    );
    _hud = AtlasLiveSnifferHudSnapshot(
      state: _stateForStatus(item.statusLabel),
      title: item.title,
      statusLabel: item.statusLabel,
      cachedValue: item.cachedValue,
      matchConfidence: 1,
      detail: 'Barcode confirmed',
    );
    unawaited(_publishHud());
    notifyListeners();
  }

  void _replacePipeline() {
    final AtlasContinuousScanCoordinator? previousScan = _scanCoordinator;
    final AtlasContinuousPerceptionCoordinator? previousPerception =
        _perceptionCoordinator;

    previousScan?.dispose();
    if (previousPerception != null) {
      unawaited(previousPerception.dispose());
    }

    _scanCoordinator = AtlasContinuousScanCoordinator(
      onChanged: _handleScanCoordinatorChanged,
    );
    _perceptionCoordinator = AtlasContinuousPerceptionCoordinator(
      submitStableCandidate: _submitStableCandidate,
    );
  }

  Future<void> _publishHud() async {
    try {
      await _platform.updateHud(
        _hud.toOverlayText(),
        showScanChoices: _awaitingModeChoice,
        detectedCount: _lastDetectedCount,
      );
    } catch (_) {
      // Service may be moving between foreground/background lifecycle states.
    }
  }

  @override
  void dispose() {
    _sessionGeneration++;
    unawaited(_frameSubscription?.cancel());
    _frameSubscription = null;
    _scanCoordinator?.dispose();
    _scanCoordinator = null;
    final AtlasContinuousPerceptionCoordinator? perceptionCoordinator =
        _perceptionCoordinator;
    _perceptionCoordinator = null;
    if (perceptionCoordinator != null) {
      unawaited(perceptionCoordinator.dispose());
    }
    super.dispose();
  }
}

final class _TemporalBoxEvidence {
  const _TemporalBoxEvidence({
    required this.candidateId,
    required this.productNumber,
    required this.text,
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
    required this.featuredScore,
    required this.hits,
    required this.lastSeenAt,
  });

  factory _TemporalBoxEvidence.fromCandidate(
    AtlasLiveSnifferBoxCandidate candidate,
    DateTime at,
  ) {
    return _TemporalBoxEvidence(
      candidateId: candidate.candidateId,
      productNumber: candidate.productNumber,
      text: candidate.text,
      left: candidate.left,
      top: candidate.top,
      right: candidate.right,
      bottom: candidate.bottom,
      featuredScore: candidate.featuredScore,
      hits: 1,
      lastSeenAt: at,
    );
  }

  final String candidateId;
  final String productNumber;
  final String text;
  final double left;
  final double top;
  final double right;
  final double bottom;
  final double featuredScore;
  final int hits;
  final DateTime lastSeenAt;

  _TemporalBoxEvidence add(
    AtlasLiveSnifferBoxCandidate candidate,
    DateTime at,
  ) {
    final Set<String> parts = <String>{
      ...text.split(' '),
      ...candidate.text.split(' '),
    }..removeWhere((String value) => value.trim().isEmpty);
    return _TemporalBoxEvidence(
      candidateId: candidateId,
      productNumber: productNumber,
      text: parts.join(' '),
      left: candidate.left,
      top: candidate.top,
      right: candidate.right,
      bottom: candidate.bottom,
      featuredScore: candidate.featuredScore,
      hits: hits + 1,
      lastSeenAt: at,
    );
  }

  AtlasLiveSnifferBoxCandidate toCandidate() {
    final double temporalBonus = ((hits - 1) * 0.04)
        .clamp(0.0, 0.16)
        .toDouble();
    return AtlasLiveSnifferBoxCandidate(
      candidateId: candidateId,
      productNumber: productNumber,
      text: text,
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      featuredScore: (featuredScore + temporalBonus).clamp(0.0, 1.0).toDouble(),
    );
  }
}
