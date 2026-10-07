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
  String? _turnoverIdentitySignature;
  int _turnoverIdentityHits = 0;
  bool _automaticTurnoverInFlight = false;
  DateTime? _selectedTargetMissingSince;

  // 6C.5 Auction Fast Acquisition: keep the last fully verified foreground
  // result visible across the brief remove/replace handoff, while identity
  // evidence itself is cleared immediately. This is display retention only;
  // the next Pop never inherits the previous Pop's OCR/catalog evidence.
  static const Duration _verifiedResultHandoffDuration = Duration(
    milliseconds: 1500,
  );

  static const Duration _selectedTargetMissingResetDuration = Duration(
    milliseconds: 1500,
  );
  Timer? _verifiedResultHoldTimer;
  AtlasLiveSnifferHudSnapshot? _lastVerifiedFeaturedHud;
  bool _holdingVerifiedFeaturedHud = false;

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
    _clearVerifiedFeaturedHudMemory();
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
    _clearVerifiedFeaturedHudMemory();
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
        // Name-first firewall: selected-target OCR may establish physical
        // identity before a readable product number exists. Catalog lookup is
        // forbidden until visual identity AND a stable number are both present.
        final String evidenceKey = 'selection:$_activeSelectionGeneration';
        final String supplementalText = _candidateExtractor
            .extractSupplementalText(
              frame,
              focusX: _selectionAnchorX ?? _targetX,
              focusY: _selectionAnchorY ?? _targetY,
            );

        if (supplementalText.isNotEmpty) {
          final targetBox = frame.trackedBoundingBox;
          final double centerX = _selectionAnchorX ?? _targetX ?? 0.5;
          final double centerY = _selectionAnchorY ?? _targetY ?? 0.55;

          final _TemporalBoxEvidence updatedEvidence = _temporalEvidence.update(
            evidenceKey,
            (existing) => existing.addSupplementalText(
              supplementalText,
              frame.capturedAt,
            ),
            ifAbsent: () => _TemporalBoxEvidence.fromVisualText(
              candidateId: evidenceKey,
              text: supplementalText,
              at: frame.capturedAt,
              left:
                  targetBox?.left ??
                  (centerX - 0.20).clamp(0.0, 1.0).toDouble(),
              top:
                  targetBox?.top ?? (centerY - 0.24).clamp(0.0, 1.0).toDouble(),
              right:
                  targetBox?.right ??
                  (centerX + 0.20).clamp(0.0, 1.0).toDouble(),
              bottom:
                  targetBox?.bottom ??
                  (centerY + 0.24).clamp(0.0, 1.0).toDouble(),
            ),
          );

          _projectVisualAcquisition(updatedEvidence);

          if (updatedEvidence.readyForCatalogVerification) {
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
              _selectedEvidenceResolutionPending = true;
            }
          }
          return;
        }

        // No text during a turntable rotation is not a target loss. Preserve the
        // last good identity result and wait for another readable face.
        _hud = AtlasLiveSnifferHudSnapshot(
          state: _hud.state,
          title: _hud.title,
          statusLabel: _targetState == AtlasLiveSnifferTargetState.acquiring
              ? 'Locking selected Pop...'
              : 'Tracking selected Pop...',
          detail: 'Waiting for readable physical identity text...',
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
          detail: 'Reading physical name / franchise evidence first.',
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

    final String selectedSupplementalText = frame.isSingleTargetFrame
        ? _candidateExtractor.extractSupplementalText(
            frame,
            focusX: _selectionAnchorX ?? _targetX,
            focusY: _selectionAnchorY ?? _targetY,
          )
        : '';

    if (frame.isSingleTargetFrame && selected.isNotEmpty) {
      final AtlasLiveSnifferBoxCandidate foreground = selected.first;

      final bool numberTurnover = _shouldRestartForContradictoryNumber(
        foreground,
      );

      final bool identityTurnover = _shouldRestartForContradictoryIdentity(
        foreground,
        selectedSupplementalText,
      );

      if (numberTurnover || identityTurnover) {
        _requestAutomaticTurnover();
        return;
      }
    }

    _TemporalBoxEvidence? selectedTemporalEvidence;
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
          if (frame.isSingleTargetFrame) {
            selectedTemporalEvidence = evidence;
          }
          return evidence.toCandidate();
        })
        .toList(growable: false);

    if (frame.isSingleTargetFrame && selectedTemporalEvidence != null) {
      _projectVisualAcquisition(selectedTemporalEvidence!);
      if (!selectedTemporalEvidence!.readyForCatalogVerification) {
        return;
      }
    }

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
    } else if (frame.isSingleTargetFrame) {
      // 6C.5: OCR/catalog lookup can take longer than the 250 ms frame pace.
      // Do not drop a later face of a rotating auction box while a lookup is
      // still running. Temporal evidence has already absorbed this frame; mark
      // it pending so the resolver immediately consumes the newest number +
      // name/series evidence when the in-flight lookup finishes.
      _selectedEvidenceResolutionPending = true;
    }
  }

  bool _handleTargetLifecycleWithoutEvidence(
    AtlasLiveSnifferNativeFrame frame,
  ) {
    final bool hasEvidence =
        frame.textBlocks.isNotEmpty || frame.barcodes.isNotEmpty;

    switch (frame.targetState) {
      case AtlasLiveSnifferTargetState.awaitingSelection:
        _selectedTargetMissingSince = null;

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
      case AtlasLiveSnifferTargetState.reacquiring:
        if (hasEvidence) {
          _selectedTargetMissingSince = null;
          return false;
        }

        _selectedTargetMissingSince ??= frame.capturedAt;

        final Duration missingFor = frame.capturedAt.difference(
          _selectedTargetMissingSince!,
        );

        if (missingFor >= _selectedTargetMissingResetDuration) {
          _selectedTargetMissingSince = null;
          _requestAutomaticTurnover();
          return true;
        }

        _hud = AtlasLiveSnifferHudSnapshot(
          state: _hud.state,
          title: _hud.title,
          statusLabel:
              frame.targetState == AtlasLiveSnifferTargetState.reacquiring
              ? 'Reacquiring selected Pop...'
              : 'Tracking selected Pop...',
          detail: 'Brief visual gap. Holding the foreground identity.',
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

        if (!manuallySelectedTarget) {
          _selectedTargetMissingSince = null;

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
        }

        // A readable target still exists inside the selected physical footprint.
        // Continue normal OCR processing rather than resetting from one tracker gap.
        if (hasEvidence) {
          _selectedTargetMissingSince = null;
          return false;
        }

        _selectedTargetMissingSince ??= frame.capturedAt;

        final Duration missingFor = frame.capturedAt.difference(
          _selectedTargetMissingSince!,
        );

        // A manually selected Pop is allowed to coast through short rotation,
        // hand-cover, blur, and turntable gaps. But it may NOT own the selection
        // indefinitely after the physical product has actually left.
        if (missingFor >= _selectedTargetMissingResetDuration) {
          _selectedTargetMissingSince = null;
          _requestAutomaticTurnover();
          return true;
        }

        _hud = AtlasLiveSnifferHudSnapshot(
          state: _hud.state,
          title: _hud.title,
          statusLabel: 'Reacquiring selected Pop...',
          detail:
              'Holding your selected Pop during a brief target loss. Waiting for it to return.',
          cachedValue: _hud.cachedValue,
          matchConfidence: _hud.matchConfidence,
          items: _hud.items,
        );

        unawaited(_publishHud());
        notifyListeners();
        return true;

      case AtlasLiveSnifferTargetState.none:
        _selectedTargetMissingSince = null;
        return false;

      case AtlasLiveSnifferTargetState.acquiring:
      case AtlasLiveSnifferTargetState.locked:
        _selectedTargetMissingSince = null;
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
      _clearVerifiedFeaturedHudMemory();
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
      _clearVerifiedFeaturedHudMemory();
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
      if (action == 'automaticTurnover') {
        _startVerifiedResultHandoff();
      } else {
        _clearVerifiedFeaturedHudMemory();
        _hud = AtlasLiveSnifferHudSnapshot(
          state: AtlasLiveSnifferHudState.listening,
          title: action == 'sceneDiscontinuity'
              ? 'New auction scene'
              : 'New target detected',
          statusLabel: 'Reading fresh identity...',
          detail: 'Old Pop evidence was cleared before scanning this target.',
        );
      }
      unawaited(_publishHud());
      notifyListeners();
      return;
    }

    if (action == 'allVisible') {
      _clearVerifiedFeaturedHudMemory();
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

  void _projectVisualAcquisition(_TemporalBoxEvidence evidence) {
    if (_holdingVerifiedFeaturedHud) return;

    final String visualLabel = evidence.visualLabel;
    final String stableNumber = evidence.stableProductNumber;

    if (!evidence.hasStableVisualIdentity) {
      _hud = AtlasLiveSnifferHudSnapshot(
        state: AtlasLiveSnifferHudState.listening,
        title: 'Selected Pop',
        statusLabel: 'Reading identity...',
        detail: 'Keep the character name or franchise visible.',
      );
    } else if (stableNumber.isEmpty) {
      _hud = AtlasLiveSnifferHudSnapshot(
        state: AtlasLiveSnifferHudState.listening,
        title: visualLabel,
        statusLabel: 'Name found',
        detail: 'Reading Pop number...',
      );
    } else {
      _hud = AtlasLiveSnifferHudSnapshot(
        state: AtlasLiveSnifferHudState.listening,
        title: '$visualLabel #$stableNumber',
        statusLabel: 'Verifying visual identity...',
        detail: 'Checking the visual name + number against the catalog.',
      );
    }

    unawaited(_publishHud());
    notifyListeners();
  }

  void _projectFeaturedAuctionMatch(AtlasLiveSnifferAuctionMatch match) {
    final AtlasCatalogProduct? product = match.bestMatch;
    if (product == null || !match.hasLikelyMatch) {
      // During the short remove/replace handoff, keep the last verified result
      // visible instead of flashing an unverified number/background read.
      if (_holdingVerifiedFeaturedHud) {
        return;
      }

      final _TemporalBoxEvidence? visualEvidence =
          _activeSelectionGeneration > 0
          ? _temporalEvidence['selection:$_activeSelectionGeneration']
          : null;
      final bool hasVisualIdentity =
          visualEvidence?.hasStableVisualIdentity ?? false;
      final String visualLabel = visualEvidence?.visualLabel ?? '';
      final String visualNumber =
          visualEvidence?.stableProductNumber ??
          match.candidate.productNumber.trim();

      _hud = AtlasLiveSnifferHudSnapshot(
        state: AtlasLiveSnifferHudState.listening,
        title: hasVisualIdentity
            ? '$visualLabel${visualNumber.isEmpty ? '' : ' #$visualNumber'}'
            : (visualNumber.isEmpty ? 'Selected Pop' : '#$visualNumber'),
        statusLabel: hasVisualIdentity
            ? 'Identity not verified'
            : (match.isNumberLocked ? 'Number found' : 'Reading identity...'),
        detail: hasVisualIdentity
            ? 'The visual name/franchise does not agree with this catalog number yet. Keep scanning.'
            : 'Keep the character name or franchise visible.',
        matchConfidence: match.confidence,
      );
      unawaited(_publishHud());
      notifyListeners();
      return;
    }

    // New same-target identity evidence is now meaningful enough to replace a
    // retained prior result, even if Atlas still needs variant refinement.
    _endVerifiedResultHandoff();

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
    final AtlasLiveSnifferHudSnapshot projected = AtlasLiveSnifferHudSnapshot(
      state: _stateForStatus(item.statusLabel),
      title: item.title,
      statusLabel: item.statusLabel,
      cachedValue: item.cachedValue,
      matchConfidence: item.matchConfidence,
      detail: match.hasStrongMatch ? null : 'Refining while the box rotates...',
    );
    _hud = projected;
    if (match.hasStrongMatch) {
      _rememberVerifiedFeaturedHud(projected);
    }
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
    if (oldNumber.isEmpty ||
        newNumber.isEmpty ||
        _sameNumberFamily(oldNumber, newNumber)) {
      _turnoverCandidateNumber = null;
      _turnoverCandidateHits = 0;
      return false;
    }

    // Number-based turnover must also come from the selected foreground core.
    // A repeated shelf/UI number outside the selected Pop may never restart
    // the physical target.
    final double anchorX = _selectionAnchorX ?? _targetX ?? 0.5;
    final double anchorY = _selectionAnchorY ?? _targetY ?? 0.55;
    final bool insideForegroundCore =
        (candidate.centerX - anchorX).abs() <= 0.20 &&
        (candidate.centerY - anchorY).abs() <= 0.18;

    // Only a strong, repeated contradiction from the foreground may overturn
    // an established selected-target identity.
    if (!insideForegroundCore || candidate.featuredScore < 0.42) {
      _turnoverCandidateNumber = null;
      _turnoverCandidateHits = 0;
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

  bool _shouldRestartForContradictoryIdentity(
    AtlasLiveSnifferBoxCandidate candidate,
    String supplementalText,
  ) {
    if (_automaticTurnoverInFlight || _activeSelectionGeneration <= 0) {
      return false;
    }

    final String evidenceKey = 'selection:$_activeSelectionGeneration';
    final _TemporalBoxEvidence? existing = _temporalEvidence[evidenceKey];

    if (existing == null || !existing.hasStableVisualIdentity) {
      _turnoverIdentitySignature = null;
      _turnoverIdentityHits = 0;
      return false;
    }

    // Identity turnover must come from the selected foreground footprint.
    // Repeated shelf/UI OCR outside this core is static clutter, not a new Pop.
    final double anchorX = _selectionAnchorX ?? _targetX ?? 0.5;
    final double anchorY = _selectionAnchorY ?? _targetY ?? 0.55;
    final bool insideForegroundCore =
        (candidate.centerX - anchorX).abs() <= 0.20 &&
        (candidate.centerY - anchorY).abs() <= 0.18;

    if (!insideForegroundCore || candidate.featuredScore < 0.42) {
      _turnoverIdentitySignature = null;
      _turnoverIdentityHits = 0;
      return false;
    }

    final Set<String> oldTokens = _turnoverIdentityTokens(existing.visualLabel);

    final Set<String> newTokens = _turnoverIdentityTokens(
      '${candidate.text} $supplementalText',
    );

    if (oldTokens.isEmpty || newTokens.isEmpty) {
      return false;
    }

    final bool overlapsOldIdentity = oldTokens.any(newTokens.contains);

    if (overlapsOldIdentity) {
      _turnoverIdentitySignature = null;
      _turnoverIdentityHits = 0;
      return false;
    }

    if (newTokens.length < 2) {
      return false;
    }

    final List<String> ranked = newTokens.toList(growable: false)..sort();
    final String signature = ranked.take(4).join('|');

    if (_turnoverIdentitySignature == signature) {
      _turnoverIdentityHits += 1;
    } else {
      _turnoverIdentitySignature = signature;
      _turnoverIdentityHits = 1;
    }

    final String oldNumber = existing.stableProductNumber;
    final String newNumber = candidate.productNumber.trim();

    final bool strongNumberContradiction =
        oldNumber.isNotEmpty &&
        newNumber.isNotEmpty &&
        !_sameNumberFamily(oldNumber, newNumber);

    if (strongNumberContradiction) {
      return _turnoverIdentityHits >= 2;
    }

    return _turnoverIdentityHits >= 3;
  }

  Set<String> _turnoverIdentityTokens(String value) {
    const Set<String> ignored = <String>{
      'pop',
      'funko',
      'vinyl',
      'figure',
      'figures',
      'animation',
      'television',
      'movies',
      'movie',
      'games',
      'game',
      'heroes',
      'exclusive',
      'limited',
      'edition',
      'special',
      'warning',
      'collectible',
      'collectibles',
      'the',
      'and',
      'for',
      'with',
      'from',
      'this',
      'that',
      'your',
      'you',
      'are',
      'was',
      'were',
      'has',
      'have',
    };

    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .split(' ')
        .map((String token) => token.trim())
        .where((String token) {
          if (token.length < 3) return false;
          if (ignored.contains(token)) return false;
          if (RegExp(r'^\d+$').hasMatch(token)) return false;
          return true;
        })
        .toSet();
  }

  bool _sameNumberFamily(String a, String b) {
    final String first = a.trim();
    final String second = b.trim();

    if (first.isEmpty || second.isEmpty) return false;
    if (first == second) return true;

    final String longer = first.length >= second.length ? first : second;
    final String shorter = first.length >= second.length ? second : first;

    // OCR commonly loses one leading digit from a Funko number:
    // 1372 -> 372, 1782 -> 782, 1127 -> 127.
    if (longer.length - shorter.length != 1) {
      return false;
    }

    return longer.endsWith(shorter);
  }

  void _requestAutomaticTurnover() {
    if (_automaticTurnoverInFlight) return;
    _automaticTurnoverInFlight = true;
    _projectedTrackIds.clear();
    _temporalEvidence.clear();
    _ocrProjectionInFlight = false;
    _selectedEvidenceResolutionPending = false;
    _sessionGeneration++;
    _startVerifiedResultHandoff();
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

  void _rememberVerifiedFeaturedHud(AtlasLiveSnifferHudSnapshot snapshot) {
    _verifiedResultHoldTimer?.cancel();
    _verifiedResultHoldTimer = null;
    _holdingVerifiedFeaturedHud = false;
    _lastVerifiedFeaturedHud = snapshot;
  }

  void _startVerifiedResultHandoff() {
    _verifiedResultHoldTimer?.cancel();
    final AtlasLiveSnifferHudSnapshot? retained = _lastVerifiedFeaturedHud;
    if (retained == null) {
      _holdingVerifiedFeaturedHud = false;
      _hud = const AtlasLiveSnifferHudSnapshot(
        state: AtlasLiveSnifferHudState.listening,
        title: 'New Pop detected',
        statusLabel: 'Reading fresh identity...',
        detail:
            'Resetting target: clearing the previous identity and acquiring this Pop.',
      );
      return;
    }

    _holdingVerifiedFeaturedHud = true;
    _hud = retained;
    _verifiedResultHoldTimer = Timer(_verifiedResultHandoffDuration, () {
      if (!_sessionActive || !_holdingVerifiedFeaturedHud) return;
      _holdingVerifiedFeaturedHud = false;
      _verifiedResultHoldTimer = null;
      _hud = const AtlasLiveSnifferHudSnapshot(
        state: AtlasLiveSnifferHudState.listening,
        title: 'New Pop detected',
        statusLabel: 'Reading fresh identity...',
        detail: 'Previous identity evidence was cleared for the new Pop.',
      );
      unawaited(_publishHud());
      notifyListeners();
    });
  }

  void _endVerifiedResultHandoff() {
    _verifiedResultHoldTimer?.cancel();
    _verifiedResultHoldTimer = null;
    _holdingVerifiedFeaturedHud = false;
  }

  void _clearVerifiedFeaturedHudMemory() {
    _endVerifiedResultHandoff();
    _lastVerifiedFeaturedHud = null;
  }

  void _resetTurnoverDetector() {
    _turnoverCandidateNumber = null;
    _turnoverCandidateHits = 0;
    _turnoverIdentitySignature = null;
    _turnoverIdentityHits = 0;
    _automaticTurnoverInFlight = false;
    _selectedTargetMissingSince = null;
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
    final AtlasLiveSnifferHudSnapshot projected = AtlasLiveSnifferHudSnapshot(
      state: _stateForStatus(item.statusLabel),
      title: item.title,
      statusLabel: item.statusLabel,
      cachedValue: item.cachedValue,
      matchConfidence: 1,
      detail: 'Barcode confirmed',
    );
    _hud = projected;
    if (_scanMode != AtlasLiveSnifferScanMode.allVisible) {
      _rememberVerifiedFeaturedHud(projected);
    }
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
    _verifiedResultHoldTimer?.cancel();
    _verifiedResultHoldTimer = null;
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
    required this.numberObservations,
    required this.textWindows,
    required this.anchoredIdentityPhrase,
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
    required this.featuredScore,
    required this.hits,
    required this.lastSeenAt,
  });

  static const int _maxTextWindows = 8;
  static const int _maxNumberObservations = 6;

  static const int _minimumPhraseVotes = 2;
  static const int _minimumNumberVotes = 2;

  static const Set<String> _visualNoiseTokens = <String>{
    'pop',
    'funko',
    'vinyl',
    'figure',
    'figures',
    'animation',
    'games',
    'game',
    'television',
    'movies',
    'movie',
    'heroes',
    'exclusive',
    'limited',
    'edition',
    'special',
    'chase',
    'glow',
    'metallic',
    'flocked',
    'diamond',
    'warning',
    'ages',
    'made',
    'collectible',
    'collectibles',
    'the',
    'and',
    'for',
    'with',
    'from',
    'this',
    'that',
    'your',
    'you',
    'are',
    'was',
    'were',
    'has',
    'have',
    'their',
    'standard',
    'release',
  };

  factory _TemporalBoxEvidence.fromCandidate(
    AtlasLiveSnifferBoxCandidate candidate,
    DateTime at, {
    String? candidateIdOverride,
  }) {
    final String cleanNumber = candidate.productNumber.trim();
    final String cleanText = candidate.text.trim();

    final List<String> initialWindows = cleanText.isEmpty
        ? const <String>[]
        : <String>[cleanText];

    return _TemporalBoxEvidence(
      candidateId: candidateIdOverride ?? candidate.candidateId,
      numberObservations: cleanNumber.isEmpty
          ? const <String>[]
          : <String>[cleanNumber],
      textWindows: initialWindows,
      anchoredIdentityPhrase: '',
      left: candidate.left,
      top: candidate.top,
      right: candidate.right,
      bottom: candidate.bottom,
      featuredScore: candidate.featuredScore,
      hits: 1,
      lastSeenAt: at,
    );
  }

  factory _TemporalBoxEvidence.fromVisualText({
    required String candidateId,
    required String text,
    required DateTime at,
    required double left,
    required double top,
    required double right,
    required double bottom,
  }) {
    final String cleanText = text.trim();

    return _TemporalBoxEvidence(
      candidateId: candidateId,
      numberObservations: const <String>[],
      textWindows: cleanText.isEmpty ? const <String>[] : <String>[cleanText],
      anchoredIdentityPhrase: '',
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      featuredScore: 0.45,
      hits: 1,
      lastSeenAt: at,
    );
  }

  final String candidateId;

  /// Rolling physical OCR observations from the selected target.
  final List<String> numberObservations;
  final List<String> textWindows;

  /// Once Atlas sees a coherent identity phrase repeatedly, it is anchored here.
  ///
  /// Example:
  ///   MICHAEL SCOTT
  ///   MICHAEL SCOTT
  ///
  /// becomes:
  ///   Michael Scott
  ///
  /// Later noisy reads such as:
  ///   spinner
  ///   liked
  ///   scott
  ///
  /// are not allowed to rewrite that established identity.
  final String anchoredIdentityPhrase;

  final double left;
  final double top;
  final double right;
  final double bottom;
  final double featuredScore;
  final int hits;
  final DateTime lastSeenAt;

  // ---------------------------------------------------------------------------
  // Compatibility
  // ---------------------------------------------------------------------------

  String get productNumber => stableProductNumber;

  bool get hasStableVisualIdentity => anchoredIdentityPhrase.isNotEmpty;

  String get visualLabel =>
      anchoredIdentityPhrase.isEmpty ? 'Selected Pop' : anchoredIdentityPhrase;

  bool get readyForCatalogVerification =>
      hasStableVisualIdentity && stableProductNumber.isNotEmpty;

  // ---------------------------------------------------------------------------
  // Stable product number
  // ---------------------------------------------------------------------------

  String get stableProductNumber {
    if (numberObservations.isEmpty) return '';

    final Map<String, int> familyVotes = <String, int>{};

    for (final String raw in numberObservations) {
      final String incoming = raw.trim();

      if (incoming.isEmpty) continue;
      if (!RegExp(r'^\d{1,4}$').hasMatch(incoming)) continue;

      String familyKey = incoming;

      final List<String> existingKeys = familyVotes.keys.toList(
        growable: false,
      );

      for (final String existing in existingKeys) {
        if (!_numbersAreSuffixRelated(existing, incoming)) {
          continue;
        }

        final String longer = existing.length >= incoming.length
            ? existing
            : incoming;

        if (longer != existing) {
          final int carriedVotes = familyVotes.remove(existing) ?? 0;

          familyVotes.update(
            longer,
            (int count) => count + carriedVotes,
            ifAbsent: () => carriedVotes,
          );
        }

        familyKey = longer;
        break;
      }

      familyVotes.update(
        familyKey,
        (int count) => count + 1,
        ifAbsent: () => 1,
      );
    }

    if (familyVotes.isEmpty) return '';

    final List<MapEntry<String, int>> ranked = familyVotes.entries.toList()
      ..sort((a, b) {
        final int voteOrder = b.value.compareTo(a.value);

        if (voteOrder != 0) {
          return voteOrder;
        }

        // If 372 and 1372 have otherwise equivalent evidence,
        // prefer the longer/full number.
        return b.key.length.compareTo(a.key.length);
      });

    final MapEntry<String, int> winner = ranked.first;

    if (winner.value < _minimumNumberVotes) {
      return '';
    }

    return winner.key;
  }

  // ---------------------------------------------------------------------------
  // Catalog evidence
  // ---------------------------------------------------------------------------

  String get text {
    final List<String> parts = <String>[
      if (anchoredIdentityPhrase.isNotEmpty) anchoredIdentityPhrase,
      if (stableProductNumber.isNotEmpty) stableProductNumber,
    ];

    return parts.join(' ');
  }

  // ---------------------------------------------------------------------------
  // Temporal updates
  // ---------------------------------------------------------------------------

  _TemporalBoxEvidence add(
    AtlasLiveSnifferBoxCandidate candidate,
    DateTime at,
  ) {
    final List<String> updatedNumbers = <String>[...numberObservations];

    final String incomingNumber = candidate.productNumber.trim();

    if (incomingNumber.isNotEmpty &&
        RegExp(r'^\d{1,4}$').hasMatch(incomingNumber)) {
      updatedNumbers.add(incomingNumber);
    }

    while (updatedNumbers.length > _maxNumberObservations) {
      updatedNumbers.removeAt(0);
    }

    final List<String> updatedText = _appendTextWindow(
      textWindows,
      candidate.text,
      at: at,
      previousAt: lastSeenAt,
    );

    final String updatedAnchor = _resolveIdentityAnchor(
      existingAnchor: anchoredIdentityPhrase,
      windows: updatedText,
    );

    return _TemporalBoxEvidence(
      candidateId: candidateId,
      numberObservations: List<String>.unmodifiable(updatedNumbers),
      textWindows: List<String>.unmodifiable(updatedText),
      anchoredIdentityPhrase: updatedAnchor,
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
    final String clean = value.trim();

    if (clean.isEmpty) {
      return this;
    }

    final List<String> updatedText = _appendTextWindow(
      textWindows,
      clean,
      at: at,
      previousAt: lastSeenAt,
    );

    final String updatedAnchor = _resolveIdentityAnchor(
      existingAnchor: anchoredIdentityPhrase,
      windows: updatedText,
    );

    return _TemporalBoxEvidence(
      candidateId: candidateId,
      numberObservations: numberObservations,
      textWindows: List<String>.unmodifiable(updatedText),
      anchoredIdentityPhrase: updatedAnchor,
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
      productNumber: stableProductNumber,
      text: text,
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      featuredScore: (featuredScore + temporalBonus).clamp(0.0, 1.0).toDouble(),
    );
  }

  // ---------------------------------------------------------------------------
  // Phrase anchoring
  // ---------------------------------------------------------------------------

  static String _resolveIdentityAnchor({
    required String existingAnchor,
    required List<String> windows,
  }) {
    final Map<String, int> phraseVotes = <String, int>{};

    for (final String window in windows) {
      final Set<String> phrasesSeenThisFrame = _identityPhrases(window);

      for (final String phrase in phrasesSeenThisFrame) {
        phraseVotes.update(phrase, (int count) => count + 1, ifAbsent: () => 1);
      }
    }

    final List<MapEntry<String, int>> eligible = phraseVotes.entries
        .where((entry) => entry.value >= _minimumPhraseVotes)
        .toList();

    if (eligible.isEmpty) {
      return existingAnchor;
    }

    eligible.sort((a, b) {
      final int aWords = a.key.split(' ').length;
      final int bWords = b.key.split(' ').length;

      // Prefer coherent multi-word names over isolated words.
      final int wordCountOrder = bWords.compareTo(aWords);

      if (wordCountOrder != 0) {
        return wordCountOrder;
      }

      final int voteOrder = b.value.compareTo(a.value);

      if (voteOrder != 0) {
        return voteOrder;
      }

      return b.key.length.compareTo(a.key.length);
    });

    final String bestPhrase = eligible.first.key;

    if (existingAnchor.isEmpty) {
      return _titleCasePhrase(bestPhrase);
    }

    final String normalizedExisting = _normalizePhrase(existingAnchor);
    final String normalizedBest = _normalizePhrase(bestPhrase);

    if (normalizedExisting == normalizedBest) {
      return existingAnchor;
    }

    // Once a name has been established, noisy rotation OCR is not allowed
    // to replace it with an unrelated phrase.
    //
    // We only permit an upgrade when the newer phrase clearly contains the
    // already-established identity.
    //
    // Example:
    //   Scott
    // becomes:
    //   Michael Scott
    //
    // But:
    //   Michael Scott
    // does NOT become:
    //   Spinner Scott Liked
    if (_isIdentityUpgrade(
      existing: normalizedExisting,
      proposed: normalizedBest,
    )) {
      return _titleCasePhrase(bestPhrase);
    }

    return existingAnchor;
  }

  static bool _isIdentityUpgrade({
    required String existing,
    required String proposed,
  }) {
    if (existing.isEmpty || proposed.isEmpty) {
      return false;
    }

    final List<String> existingTokens = existing.split(' ');
    final List<String> proposedTokens = proposed.split(' ');

    if (proposedTokens.length <= existingTokens.length) {
      return false;
    }

    int existingIndex = 0;

    for (final String token in proposedTokens) {
      if (existingIndex < existingTokens.length &&
          token == existingTokens[existingIndex]) {
        existingIndex++;
      }
    }

    return existingIndex == existingTokens.length;
  }

  static Set<String> _identityPhrases(String value) {
    final List<String> tokens = _identityTokenList(value);

    if (tokens.isEmpty) {
      return const <String>{};
    }

    final Set<String> phrases = <String>{};

    // Multi-word names/series are strongest.
    //
    // We create contiguous 2-, 3-, and 4-word phrases from the physical OCR
    // while preserving the actual OCR word order.
    for (int length = 2; length <= 4; length++) {
      if (tokens.length < length) {
        continue;
      }

      for (int start = 0; start <= tokens.length - length; start++) {
        final String phrase = tokens
            .sublist(start, start + length)
            .join(' ')
            .trim();

        if (phrase.isNotEmpty) {
          phrases.add(phrase);
        }
      }
    }

    // Single-word identities are needed for characters such as:
    //   Shredder
    //   Wolverine
    //   Astarion
    //
    // Require a reasonably distinctive length. They still need repeated
    // temporal votes before they can become authoritative.
    for (final String token in tokens) {
      if (token.length >= 5) {
        phrases.add(token);
      }
    }

    return phrases;
  }

  static List<String> _identityTokenList(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .split(' ')
        .map((String token) => token.trim())
        .where((String token) {
          if (token.length < 2) {
            return false;
          }

          if (_visualNoiseTokens.contains(token)) {
            return false;
          }

          if (RegExp(r'^\d+$').hasMatch(token)) {
            return false;
          }

          return true;
        })
        .toList(growable: false);
  }

  // ---------------------------------------------------------------------------
  // Text window management
  // ---------------------------------------------------------------------------

  static List<String> _appendTextWindow(
    List<String> existing,
    String value, {
    required DateTime at,
    required DateTime previousAt,
  }) {
    final String clean = value.trim();

    if (clean.isEmpty) {
      return <String>[...existing];
    }

    final List<String> updated = <String>[...existing];

    // Candidate text and supplemental text from the same native frame count
    // as ONE OCR observation, not two votes.
    if (updated.isNotEmpty && at == previousAt) {
      final String merged = '${updated.last} $clean'
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      updated[updated.length - 1] = merged;
    } else {
      updated.add(clean);
    }

    while (updated.length > _maxTextWindows) {
      updated.removeAt(0);
    }

    return updated;
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static String _normalizePhrase(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String _titleCasePhrase(String phrase) {
    return phrase
        .split(' ')
        .where((String token) => token.isNotEmpty)
        .map((String token) {
          return '${token[0].toUpperCase()}${token.substring(1)}';
        })
        .join(' ');
  }

  static bool _numbersAreSuffixRelated(String a, String b) {
    if (a.isEmpty || b.isEmpty) {
      return false;
    }

    if (a == b) {
      return true;
    }

    final String longer = a.length >= b.length ? a : b;
    final String shorter = a.length >= b.length ? b : a;

    // Repair exactly one lost leading digit:
    //
    // 1372 <-> 372
    // 1782 <-> 782
    // 1127 <-> 127
    //
    // Do not treat arbitrary partial reads as related.
    if (longer.length - shorter.length != 1) {
      return false;
    }

    return longer.endsWith(shorter);
  }
}
