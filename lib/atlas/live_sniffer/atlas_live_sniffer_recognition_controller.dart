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
import 'models/atlas_live_sniffer_target_state.dart';
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
  bool _selectedEvidenceResolutionPending = false;
  int _sessionGeneration = 0;
  DateTime? _lastFrameAt;
  int _lastFrameSequence = 0;
  int _activeSelectionGeneration = 0;
  AtlasLiveSnifferTargetState _targetState = AtlasLiveSnifferTargetState.none;
  double? _targetX;
  double? _targetY;
  double? _selectionAnchorX;
  double? _selectionAnchorY;
  final _StaticClutterTracker _staticClutterTracker = _StaticClutterTracker();
  String? _turnoverCandidateNumber;
  int _turnoverCandidateHits = 0;
  bool _automaticTurnoverInFlight = false;

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
    _lastFrameSequence = 0;
    _activeSelectionGeneration = 0;
    _targetState = AtlasLiveSnifferTargetState.none;
    _targetX = null;
    _targetY = null;
    _selectionAnchorX = null;
    _selectionAnchorY = null;
    _staticClutterTracker.reset();
    _resetTurnoverDetector();
    _ocrProjectionInFlight = false;
    _selectedEvidenceResolutionPending = false;
    _sessionModeLocked = _scanMode != AtlasLiveSnifferScanMode.automatic;
    _awaitingModeChoice = false;
    _multiCandidateStreak = 0;
    _lastDetectedCount = 0;
    _hud = AtlasLiveSnifferHudSnapshot(
      state: AtlasLiveSnifferHudState.listening,
      title: 'LiveLens Auction Mode',
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
    _lastFrameSequence = 0;
    _activeSelectionGeneration = 0;
    _targetState = AtlasLiveSnifferTargetState.none;
    _targetX = null;
    _targetY = null;
    _selectionAnchorX = null;
    _selectionAnchorY = null;
    _staticClutterTracker.reset();
    _resetTurnoverDetector();
    _ocrProjectionInFlight = false;
    _selectedEvidenceResolutionPending = false;
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
    if (_automaticTurnoverInFlight) return;

    AtlasLiveSnifferNativeFrame frame = AtlasLiveSnifferNativeFrame.fromMap(
      payload,
    );

    // Native frame sequence is authoritative. Never rewrite an old frame to look
    // new; stale asynchronous results must simply disappear.
    if (frame.frameSequence > 0 && frame.frameSequence <= _lastFrameSequence) {
      return;
    }

    final DateTime? previousFrameAt = _lastFrameAt;
    if (previousFrameAt != null && !frame.capturedAt.isAfter(previousFrameAt)) {
      return;
    }

    if (frame.isSingleTargetFrame) {
      if (_activeSelectionGeneration == 0) {
        _activeSelectionGeneration = frame.selectionGeneration;
      }
      if (frame.selectionGeneration != _activeSelectionGeneration) {
        return;
      }
    } else if (_activeSelectionGeneration > 0 &&
        frame.selectionGeneration < _activeSelectionGeneration) {
      return;
    }

    if (frame.frameSequence > 0) {
      _lastFrameSequence = frame.frameSequence;
    }
    _lastFrameAt = frame.capturedAt;

    if (frame.isSingleTargetFrame) {
      _targetState = frame.targetState;
      final targetBox = frame.trackedBoundingBox;
      if (targetBox != null) {
        _targetX = targetBox.centerX;
        _targetY = targetBox.centerY;
      }

      if (_handleTargetLifecycleWithoutEvidence(frame)) {
        return;
      }

      // Native crop ownership is authoritative. When a physical tracker ID is
      // available, reject any OCR/barcode token that is not stamped with it.
      frame = frame.scopedToLockedTrack();
      frame = _filterStaticClutter(frame);
    }

    // UPC/EAN remains bonus evidence and still crosses the canonical 6A ->
    // Scanner 4 boundary. In Scan One the native layer has already scoped it to
    // the selected physical target.
    final observations = AtlasLiveSnifferNativeObservationAdapter.fromFrame(
      frame,
    );
    _perceptionCoordinator?.processFrame(
      timestamp: frame.capturedAt,
      observations: observations,
    );

    _expireTemporalEvidence(frame.capturedAt);
    final List<AtlasLiveSnifferBoxCandidate> extracted = _candidateExtractor
        .extract(
          frame,
          focusX: _selectionAnchorX ?? _targetX,
          focusY: _selectionAnchorY ?? _targetY,
        );

    if (extracted.isEmpty) {
      if (frame.isSingleTargetFrame) {
        // A dedicated header/nameplate OCR pass may contain useful words but no
        // product number. Once this selection already has numbered evidence,
        // retain those scoped words so the next catalog projection can use the
        // character/release name seen on another face of the rotating box.
        final String evidenceKey = 'selection:$_activeSelectionGeneration';
        final _TemporalBoxEvidence? existing = _temporalEvidence[evidenceKey];
        if (existing != null) {
          final String supplementalText = _candidateExtractor
              .extractSupplementalText(
                frame,
                focusX: _selectionAnchorX ?? _targetX,
                focusY: _selectionAnchorY ?? _targetY,
              );
          if (supplementalText.isNotEmpty) {
            final _TemporalBoxEvidence updatedEvidence = existing
                .addSupplementalText(supplementalText, frame.capturedAt);
            _temporalEvidence[evidenceKey] = updatedEvidence;

            // Number -> name handoff: a rotating box often exposes the number
            // and title on different faces. As soon as name-only OCR arrives,
            // immediately re-run the catalog partition using the preserved
            // number plus the newly accumulated name/series evidence. Do not
            // wait for another frame that happens to contain the number again.
            if (!_ocrProjectionInFlight) {
              _ocrProjectionInFlight = true;
              final int generation = _sessionGeneration;
              unawaited(
                _resolveAuctionCandidates(
                  <AtlasLiveSnifferBoxCandidate>[updatedEvidence.toCandidate()],
                  generation,
                  selectionGeneration: frame.selectionGeneration,
                ),
              );
            } else {
              // Do not lose a name that arrived while the prior catalog lookup
              // was still running. The resolver's finally block immediately
              // consumes the newest selected-target evidence next.
              _selectedEvidenceResolutionPending = true;
            }

            _hud = AtlasLiveSnifferHudSnapshot(
              state: _hud.state,
              title: _hud.title,
              statusLabel: 'Resolving selected Pop...',
              detail: 'Combining the locked number with the box name...',
              cachedValue: _hud.cachedValue,
              matchConfidence: _hud.matchConfidence,
              items: _hud.items,
            );
            unawaited(_publishHud());
            notifyListeners();
            return;
          }
        }

        // No text during a turntable rotation is not a target loss. Preserve the
        // last good identity result and wait for another readable face.
        _hud = AtlasLiveSnifferHudSnapshot(
          state: _hud.state,
          title: _hud.title,
          statusLabel: _targetState == AtlasLiveSnifferTargetState.acquiring
              ? 'Locking selected Pop...'
              : 'Tracking selected Pop...',
          detail: 'Waiting for a readable name, number, or sticker...',
          cachedValue: _hud.cachedValue,
          matchConfidence: _hud.matchConfidence,
          items: _hud.items,
        );
        unawaited(_publishHud());
        notifyListeners();
      } else if (frame.recognizedText.isNotEmpty &&
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
      // Tracking associates evidence with a physical region; it does not own
      // identity. Rank OCR candidates against the user's selected foreground
      // anchor so a sharp, static shelf number cannot beat the auction item.
      final AtlasLiveSnifferBoxCandidate featured = frame.isSingleTargetFrame
          ? _bestForegroundCandidate(plausible)
          : _targetX != null && _targetY != null
          ? _closestToTarget(plausible, _targetX!, _targetY!)
          : plausible.first;
      selected = <AtlasLiveSnifferBoxCandidate>[featured];
    } else {
      selected = plausible.take(12).toList(growable: false);
    }

    if (frame.isSingleTargetFrame &&
        selected.isNotEmpty &&
        _shouldRestartForContradictoryNumber(selected.first)) {
      _requestAutomaticTurnover();
      return;
    }

    final String selectedSupplementalText = frame.isSingleTargetFrame
        ? _candidateExtractor.extractSupplementalText(
            frame,
            focusX: _selectionAnchorX ?? _targetX,
            focusY: _selectionAnchorY ?? _targetY,
          )
        : '';

    final List<AtlasLiveSnifferBoxCandidate> accumulated = selected
        .map((AtlasLiveSnifferBoxCandidate candidate) {
          final String evidenceKey = frame.isSingleTargetFrame
              ? 'selection:$_activeSelectionGeneration'
              : candidate.candidateId;
          _TemporalBoxEvidence evidence = _temporalEvidence.update(
            evidenceKey,
            (existing) => existing.add(candidate, frame.capturedAt),
            ifAbsent: () => _TemporalBoxEvidence.fromCandidate(
              candidate,
              frame.capturedAt,
              candidateIdOverride: evidenceKey,
            ),
          );
          if (frame.isSingleTargetFrame &&
              selectedSupplementalText.isNotEmpty) {
            evidence = evidence.addSupplementalText(
              selectedSupplementalText,
              frame.capturedAt,
            );
            _temporalEvidence[evidenceKey] = evidence;
          }
          return evidence.toCandidate();
        })
        .toList(growable: false);

    if (!_ocrProjectionInFlight) {
      _ocrProjectionInFlight = true;
      final int generation = _sessionGeneration;
      unawaited(
        _resolveAuctionCandidates(
          accumulated,
          generation,
          selectionGeneration: frame.isSingleTargetFrame
              ? frame.selectionGeneration
              : 0,
        ),
      );
    }
  }

  bool _handleTargetLifecycleWithoutEvidence(
    AtlasLiveSnifferNativeFrame frame,
  ) {
    final bool hasEvidence =
        frame.textBlocks.isNotEmpty || frame.barcodes.isNotEmpty;
    switch (frame.targetState) {
      case AtlasLiveSnifferTargetState.awaitingSelection:
        _hud = const AtlasLiveSnifferHudSnapshot(
          state: AtlasLiveSnifferHudState.listening,
          title: 'Tap the Pop you want to scan',
          statusLabel: 'Target selection',
          detail: 'Recognition is paused until you choose the physical box.',
        );
        unawaited(_publishHud());
        notifyListeners();
        return true;
      case AtlasLiveSnifferTargetState.coasting:
        // Fix 6.4: physical tracking no longer gates recognition. If the native
        // foreground footprint still produced OCR/barcode evidence, let that
        // evidence continue to identity resolution during the short coast.
        if (hasEvidence) return false;
        _hud = AtlasLiveSnifferHudSnapshot(
          state: _hud.state,
          title: _hud.title,
          statusLabel: 'Tracking selected Pop...',
          detail: 'Brief visual gap. Holding the foreground identity.',
          cachedValue: _hud.cachedValue,
          matchConfidence: _hud.matchConfidence,
          items: _hud.items,
        );
        unawaited(_publishHud());
        notifyListeners();
        return true;
      case AtlasLiveSnifferTargetState.reacquiring:
        // Reacquiring is also evidence-capable. A readable foreground number or
        // name is more useful than waiting for ML Kit to declare a perfect lock.
        if (hasEvidence) return false;
        _hud = AtlasLiveSnifferHudSnapshot(
          state: _hud.state,
          title: _hud.title,
          statusLabel: 'Reacquiring selected Pop...',
          detail: 'Watching the foreground footprint for readable evidence.',
          cachedValue: _hud.cachedValue,
          matchConfidence: _hud.matchConfidence,
          items: _hud.items,
        );
        unawaited(_publishHud());
        notifyListeners();
        return true;
      case AtlasLiveSnifferTargetState.lost:
        final bool manuallySelectedTarget =
            _activeSelectionGeneration > 0 &&
            _selectionAnchorX != null &&
            _selectionAnchorY != null;
        if (manuallySelectedTarget) {
          // Native track loss does not revoke a user's tap. Preserve the selected
          // generation and all accumulated temporal identity evidence. If the
          // stable foreground ROI still produced OCR/barcode evidence, continue
          // through normal identity resolution.
          if (hasEvidence) return false;
          _hud = AtlasLiveSnifferHudSnapshot(
            state: _hud.state,
            title: _hud.title,
            statusLabel: 'Reacquiring selected Pop...',
            detail:
                'Holding your selected Pop while LiveLens reacquires the tracker.',
            cachedValue: _hud.cachedValue,
            matchConfidence: _hud.matchConfidence,
            items: _hud.items,
          );
          unawaited(_publishHud());
          notifyListeners();
          return true;
        }
        _projectedTrackIds.clear();
        _temporalEvidence.clear();
        _staticClutterTracker.reset();
        _hud = const AtlasLiveSnifferHudSnapshot(
          state: AtlasLiveSnifferHudState.listening,
          title: 'Target lost',
          statusLabel: 'Watching for the next Pop...',
          detail:
              'Atlas LiveLens will reacquire a persistent replacement automatically.',
        );
        unawaited(_publishHud());
        notifyListeners();
        return true;
      case AtlasLiveSnifferTargetState.none:
      case AtlasLiveSnifferTargetState.acquiring:
      case AtlasLiveSnifferTargetState.locked:
        return false;
    }
  }

  Future<void> _resolveAuctionCandidates(
    List<AtlasLiveSnifferBoxCandidate> candidates,
    int generation, {
    required int selectionGeneration,
  }) async {
    try {
      final List<AtlasLiveSnifferAuctionMatch> matches = await Future.wait(
        candidates.map(_auctionMatchEngine.match),
      );
      if (!_sessionActive || generation != _sessionGeneration) return;
      if (selectionGeneration > 0 &&
          selectionGeneration != _activeSelectionGeneration) {
        return;
      }

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

        if (_selectedEvidenceResolutionPending &&
            _sessionActive &&
            selectionGeneration > 0 &&
            selectionGeneration == _activeSelectionGeneration) {
          final String evidenceKey = 'selection:$_activeSelectionGeneration';
          final _TemporalBoxEvidence? latestEvidence =
              _temporalEvidence[evidenceKey];
          _selectedEvidenceResolutionPending = false;
          if (latestEvidence != null) {
            _ocrProjectionInFlight = true;
            unawaited(
              _resolveAuctionCandidates(
                <AtlasLiveSnifferBoxCandidate>[latestEvidence.toCandidate()],
                generation,
                selectionGeneration: selectionGeneration,
              ),
            );
          }
        }
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
    final int controlGeneration = _readInt(payload['selectionGeneration']);

    if (action == 'targetSelectionStarted') {
      _activeSelectionGeneration = controlGeneration;
      _targetState = AtlasLiveSnifferTargetState.awaitingSelection;
      _targetX = null;
      _targetY = null;
      _selectionAnchorX = null;
      _selectionAnchorY = null;
      _staticClutterTracker.reset();
      _scanMode = AtlasLiveSnifferScanMode.featured;
      _sessionModeLocked = true;
      _awaitingModeChoice = false;
      _multiCandidateStreak = 0;
      _resetTurnoverDetector();
      _projectedTrackIds.clear();
      _temporalEvidence.clear();
      _ocrProjectionInFlight = false;
      _selectedEvidenceResolutionPending = false;
      _sessionGeneration++;
      _hud = const AtlasLiveSnifferHudSnapshot(
        state: AtlasLiveSnifferHudState.listening,
        title: 'Tap the Pop you want to scan',
        statusLabel: 'Target selection',
        detail: 'Scanning is paused until you tap the physical box.',
      );
      unawaited(_publishHud());
      notifyListeners();
      return;
    }

    if (action == 'targetTap') {
      final double? x = _readUnitDouble(payload['x']);
      final double? y = _readUnitDouble(payload['y']);
      if (x == null || y == null) return;
      _activeSelectionGeneration = controlGeneration;
      _targetState = AtlasLiveSnifferTargetState.acquiring;
      _targetX = x;
      _targetY = y;
      _selectionAnchorX = x;
      _selectionAnchorY = y;
      _staticClutterTracker.reset();
      _scanMode = AtlasLiveSnifferScanMode.featured;
      _sessionModeLocked = true;
      _awaitingModeChoice = false;
      _multiCandidateStreak = 0;
      // The tap starts a new physical-target generation. Old catalog/OCR work
      // can never carry across this boundary.
      _resetTurnoverDetector();
      _projectedTrackIds.clear();
      _temporalEvidence.clear();
      _ocrProjectionInFlight = false;
      _selectedEvidenceResolutionPending = false;
      _sessionGeneration++;
      _hud = const AtlasLiveSnifferHudSnapshot(
        state: AtlasLiveSnifferHudState.listening,
        title: 'Selected Pop',
        statusLabel: 'Scanning selected area...',
        detail:
            'Rotate the box slowly. Atlas will scan only this target until you retarget or Scan All.',
      );
      unawaited(_publishHud());
      notifyListeners();
      return;
    }

    if (action == 'targetGenerationRolled' ||
        action == 'sceneDiscontinuity' ||
        action == 'automaticTurnover') {
      if (controlGeneration <= 0) return;
      _activeSelectionGeneration = controlGeneration;
      _targetState = AtlasLiveSnifferTargetState.acquiring;
      _scanMode = AtlasLiveSnifferScanMode.featured;
      _sessionModeLocked = true;
      _awaitingModeChoice = false;
      _multiCandidateStreak = 0;
      _resetTurnoverDetector();
      _staticClutterTracker.reset();
      _projectedTrackIds.clear();
      _temporalEvidence.clear();
      _ocrProjectionInFlight = false;
      _selectedEvidenceResolutionPending = false;
      _sessionGeneration++;
      _hud = AtlasLiveSnifferHudSnapshot(
        state: AtlasLiveSnifferHudState.listening,
        title: switch (action) {
          'sceneDiscontinuity' => 'New auction scene',
          'automaticTurnover' => 'New Pop detected',
          _ => 'New target detected',
        },
        statusLabel: 'Reading fresh identity...',
        detail: 'Old Pop evidence was cleared before scanning this target.',
      );
      unawaited(_publishHud());
      notifyListeners();
      return;
    }

    if (action == 'allVisible') {
      _activeSelectionGeneration = controlGeneration;
      _targetState = AtlasLiveSnifferTargetState.none;
      _targetX = null;
      _targetY = null;
      _selectionAnchorX = null;
      _selectionAnchorY = null;
      _staticClutterTracker.reset();
      _scanMode = AtlasLiveSnifferScanMode.allVisible;
    } else if (action == 'featured') {
      _scanMode = AtlasLiveSnifferScanMode.featured;
    } else {
      return;
    }
    _sessionGeneration++;
    _ocrProjectionInFlight = false;
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

  AtlasLiveSnifferNativeFrame _filterStaticClutter(
    AtlasLiveSnifferNativeFrame frame,
  ) {
    if (!frame.isSingleTargetFrame || frame.textBlocks.isEmpty) return frame;
    final double anchorX = _selectionAnchorX ?? _targetX ?? 0.5;
    final double anchorY = _selectionAnchorY ?? _targetY ?? 0.55;
    final List<AtlasLiveSnifferNativeTextBlock> filtered = _staticClutterTracker
        .filter(
          frame.textBlocks,
          capturedAt: frame.capturedAt,
          anchorX: anchorX,
          anchorY: anchorY,
        );
    if (filtered.length == frame.textBlocks.length) return frame;
    return AtlasLiveSnifferNativeFrame(
      capturedAt: frame.capturedAt,
      barcodes: frame.barcodes,
      textBlocks: filtered,
      recognizedText: filtered.map((block) => block.text).join(' '),
      frameSequence: frame.frameSequence,
      selectionGeneration: frame.selectionGeneration,
      nativeTimestampMs: frame.nativeTimestampMs,
      lockedTrackId: frame.lockedTrackId,
      targetState: frame.targetState,
      trackedBoundingBox: frame.trackedBoundingBox,
      activeTracks: frame.activeTracks,
    );
  }

  AtlasLiveSnifferBoxCandidate _bestForegroundCandidate(
    List<AtlasLiveSnifferBoxCandidate> candidates,
  ) {
    final double anchorX = _selectionAnchorX ?? _targetX ?? 0.5;
    final double anchorY = _selectionAnchorY ?? _targetY ?? 0.58;
    return candidates.reduce((a, b) {
      return _foregroundCandidateScore(b, anchorX, anchorY) >
              _foregroundCandidateScore(a, anchorX, anchorY)
          ? b
          : a;
    });
  }

  double _foregroundCandidateScore(
    AtlasLiveSnifferBoxCandidate candidate,
    double anchorX,
    double anchorY,
  ) {
    final double dx = candidate.centerX - anchorX;
    final double dy = candidate.centerY - anchorY;
    final double distanceSq = dx * dx + dy * dy;
    final double proximity = (1.0 - distanceSq / 0.20)
        .clamp(0.0, 1.0)
        .toDouble();
    final double area =
        ((candidate.right - candidate.left).abs() *
                (candidate.bottom - candidate.top).abs())
            .clamp(0.0, 1.0)
            .toDouble();
    final double areaSignal = (area / 0.10).clamp(0.0, 1.0).toDouble();
    final double centerSignal = (1.0 - ((candidate.centerX - 0.5).abs() / 0.5))
        .clamp(0.0, 1.0)
        .toDouble();
    final double lowerCenterSignal =
        (1.0 - ((candidate.centerY - 0.58).abs() / 0.58))
            .clamp(0.0, 1.0)
            .toDouble();
    final double upperBackgroundPenalty = candidate.top < 0.22
        ? ((0.22 - candidate.top) / 0.22).clamp(0.0, 1.0).toDouble() * 0.20
        : 0.0;
    return candidate.featuredScore * 0.44 +
        proximity * 0.30 +
        areaSignal * 0.10 +
        centerSignal * 0.07 +
        lowerCenterSignal * 0.09 -
        upperBackgroundPenalty;
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

  int _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
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
      statusLabel: 'LiveLens Auction Mode — All Visible',
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
      source: 'Atlas LiveLens Auction OCR',
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

  bool _shouldRestartForContradictoryNumber(
    AtlasLiveSnifferBoxCandidate candidate,
  ) {
    if (_automaticTurnoverInFlight || _activeSelectionGeneration <= 0) {
      return false;
    }
    final String evidenceKey = 'selection:$_activeSelectionGeneration';
    final _TemporalBoxEvidence? existing = _temporalEvidence[evidenceKey];
    if (existing == null || existing.hits < 2) {
      _turnoverCandidateNumber = null;
      _turnoverCandidateHits = 0;
      return false;
    }

    final String oldNumber = existing.productNumber.trim();
    final String newNumber = candidate.productNumber.trim();
    if (oldNumber.isEmpty || newNumber.isEmpty || oldNumber == newNumber) {
      _turnoverCandidateNumber = null;
      _turnoverCandidateHits = 0;
      return false;
    }

    // Only a strong, repeated contradiction may overturn an established
    // selected-target identity. This protects against one-frame shelf/UI OCR.
    if (candidate.featuredScore < 0.42) {
      return false;
    }
    if (_turnoverCandidateNumber == newNumber) {
      _turnoverCandidateHits += 1;
    } else {
      _turnoverCandidateNumber = newNumber;
      _turnoverCandidateHits = 1;
    }

    final int requiredHits = candidate.featuredScore >= 0.62 ? 2 : 3;
    return _turnoverCandidateHits >= requiredHits;
  }

  void _requestAutomaticTurnover() {
    if (_automaticTurnoverInFlight) return;
    _automaticTurnoverInFlight = true;
    _projectedTrackIds.clear();
    _temporalEvidence.clear();
    _ocrProjectionInFlight = false;
    _selectedEvidenceResolutionPending = false;
    _sessionGeneration++;
    _hud = const AtlasLiveSnifferHudSnapshot(
      state: AtlasLiveSnifferHudState.listening,
      title: 'New Pop detected',
      statusLabel: 'Resetting target...',
      detail:
          'LiveLens is clearing the previous identity and acquiring this Pop.',
    );
    unawaited(_publishHud());
    notifyListeners();
    unawaited(_restartSelectedTargetAfterContradiction());
  }

  Future<void> _restartSelectedTargetAfterContradiction() async {
    final AtlasLiveSnifferRecognitionPlatform platform = _platform;
    final bool restarted =
        platform is AtlasLiveSnifferRecognitionTurnoverPlatform
        ? await (platform as AtlasLiveSnifferRecognitionTurnoverPlatform)
              .restartSelectedTarget()
        : false;
    if (restarted || !_sessionActive) return;
    _automaticTurnoverInFlight = false;
    _hud = const AtlasLiveSnifferHudSnapshot(
      state: AtlasLiveSnifferHudState.needsReview,
      title: 'Fresh target needed',
      statusLabel: 'Tap LiveLens once',
      detail: 'Automatic turnover could not restart the native target.',
    );
    unawaited(_publishHud());
    notifyListeners();
  }

  void _resetTurnoverDetector() {
    _turnoverCandidateNumber = null;
    _turnoverCandidateHits = 0;
    _automaticTurnoverInFlight = false;
  }

  void _expireTemporalEvidence(DateTime now) {
    final String protectedSelectionKey =
        'selection:$_activeSelectionGeneration';
    _temporalEvidence.removeWhere((String key, _TemporalBoxEvidence evidence) {
      // The selected physical target owns its evidence until explicit retarget,
      // Scan All, or session stop. Rotation/occlusion must never erase it.
      if (_activeSelectionGeneration > 0 &&
          key == protectedSelectionKey &&
          _targetState.isSingleTargetLifecycle) {
        return false;
      }
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

final class _StaticClutterTracker {
  final Map<String, _StaticClutterObservation> _observations =
      <String, _StaticClutterObservation>{};

  void reset() => _observations.clear();

  List<AtlasLiveSnifferNativeTextBlock> filter(
    List<AtlasLiveSnifferNativeTextBlock> blocks, {
    required DateTime capturedAt,
    required double anchorX,
    required double anchorY,
  }) {
    final Set<String> seen = <String>{};
    final List<AtlasLiveSnifferNativeTextBlock> result =
        <AtlasLiveSnifferNativeTextBlock>[];
    for (final AtlasLiveSnifferNativeTextBlock block in blocks) {
      final String normalized = block.text
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
          .trim();
      if (normalized.isEmpty) continue;
      final String key =
          '$normalized:${(block.centerX * 24).round()}:${(block.centerY * 24).round()}';
      seen.add(key);
      final _StaticClutterObservation? previous = _observations[key];
      final bool consecutive =
          previous != null &&
          capturedAt.difference(previous.lastSeen).abs() <=
              const Duration(milliseconds: 850);
      final int hits = consecutive ? previous.hits + 1 : 1;
      _observations[key] = _StaticClutterObservation(
        hits: hits,
        lastSeen: capturedAt,
      );

      final bool insideForegroundCore =
          (block.centerX - anchorX).abs() <= 0.20 &&
          (block.centerY - anchorY).abs() <= 0.24;
      final bool numberHeavy = RegExp(
        r'(^|\D)\d{1,4}(\D|$)',
      ).hasMatch(normalized);
      final bool suppress = !insideForegroundCore && hits >= 2 && numberHeavy;
      if (!suppress) result.add(block);
    }
    _observations.removeWhere((String key, _StaticClutterObservation value) {
      return !seen.contains(key) &&
          capturedAt.difference(value.lastSeen) > const Duration(seconds: 2);
    });
    return List<AtlasLiveSnifferNativeTextBlock>.unmodifiable(result);
  }
}

final class _StaticClutterObservation {
  const _StaticClutterObservation({required this.hits, required this.lastSeen});
  final int hits;
  final DateTime lastSeen;
}

final class _TemporalBoxEvidence {
  const _TemporalBoxEvidence({
    required this.candidateId,
    required this.productNumber,
    required this.numberVotes,
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
    DateTime at, {
    String? candidateIdOverride,
  }) {
    return _TemporalBoxEvidence(
      candidateId: candidateIdOverride ?? candidate.candidateId,
      productNumber: candidate.productNumber,
      numberVotes: <String, int>{candidate.productNumber: 1},
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
  final Map<String, int> numberVotes;
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
    final Map<String, int> updatedVotes = <String, int>{...numberVotes};
    updatedVotes.update(
      candidate.productNumber,
      (int count) => count + 1,
      ifAbsent: () => 1,
    );
    String winningNumber = productNumber;
    int winningVotes = updatedVotes[winningNumber] ?? 0;
    for (final MapEntry<String, int> entry in updatedVotes.entries) {
      if (entry.value > winningVotes) {
        winningNumber = entry.key;
        winningVotes = entry.value;
      }
    }
    return _TemporalBoxEvidence(
      candidateId: candidateId,
      productNumber: winningNumber,
      numberVotes: Map<String, int>.unmodifiable(updatedVotes),
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

  _TemporalBoxEvidence addSupplementalText(String value, DateTime at) {
    final Set<String> parts = <String>{...text.split(' '), ...value.split(' ')}
      ..removeWhere((String item) => item.trim().isEmpty);
    return _TemporalBoxEvidence(
      candidateId: candidateId,
      productNumber: productNumber,
      numberVotes: numberVotes,
      text: parts.join(' '),
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      featuredScore: featuredScore,
      hits: hits,
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
