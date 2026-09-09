# Scanner 6A - Continuous Perception Foundation

## Scope

Scanner 6A adds a transient, plugin-neutral continuous-perception layer on top of the existing Scanner 4 tracking and resolution architecture.

### Preserved authoritative components

- `AtlasObjectTracker` / `AtlasObjectTrack` own spatial and temporal physical-object tracking.
- `AtlasEvidenceAccumulator` owns stable multi-frame barcode agreement.
- `AtlasContinuousScanCoordinator` remains the Scanner 4 boundary for queue/ledger resolution work.
- `AtlasScanLedger` remains keyed by physical `trackId` and keeps resolved state separate from explicit commit.

### New 6A contracts

- `AtlasContinuousCandidate`
- `AtlasFrameQualitySample` / `AtlasFrameQualityAssessment`
- `AtlasFrameTriageGate`
- `AtlasPerceptionFrameResult`
- `AtlasContinuousPerceptionCoordinator`

## Candidate lifecycle

`unconfirmed -> accumulating -> candidateReady -> submitted`

There is intentionally no long-lived `stale` candidate state. `AtlasObjectTracker` already owns TTL-based expiration. The perception result emits `expiredTrackIds` so HUDs can animate/remove expired objects without introducing a competing tracker lifecycle.

## Frame triage

The current `mobile_scanner` adapter exposes barcode captures, capture size, and corner geometry, but this audited boundary does not expose raw frame pixel planes. Therefore Scanner 6A does **not** hard-code Laplacian variance, histogram clipping, or optical flow into the shared domain.

Instead, `AtlasFrameTriageGate` accepts normalized, precomputed metrics:

- `sharpnessScore`: 0.0 blurry -> 1.0 sharp
- `glareRatio`: 0.0 none -> 1.0 extreme clipping/glare
- `motionScore`: 0.0 stable -> 1.0 extreme motion

A future camera/MediaProjection/native adapter can compute these metrics using the cheapest supported platform method before OCR or identity work.

The default gate accepts frames with no metrics for backward compatibility. Future strict ingestion paths can set `requireAtLeastOneMetric: true`.

## Cadence

The perception coordinator defaults to 250 ms minimum frame spacing (about 4 FPS), inside the planned 3-5 FPS budget. Cadence is configurable and is not tied to camera UI code.

## Submission boundary

`AtlasContinuousPerceptionCoordinator` accepts an optional `submitStableCandidate` callback. Wire this to the existing Scanner 4 coordinator's `submit` method during integration. Only stable, resolution-ready evidence crosses that boundary. Successful submissions move the physical track into the existing cooldown lifecycle.

The 6A layer never silently changes product identity and never mutates the Vault.

## Intentionally deferred

- Raw-pixel blur/glare/motion metric producer
- `scan_screen.dart` integration
- Room/shelf collection diff engine
- Cached market lookup adapter
- Android MediaProjection / floating HUD
- iOS alternate live-feed ingestion

These depend on later 6A integration/6B/6C work and should not be guessed into the foundation contracts.

## Validation

After extracting over the repo root:

```powershell
dart format `
  lib/atlas/scan/continuous `
  test/atlas/scan/continuous

flutter test `
  test/atlas/scan/continuous `
  test/atlas/scan/tracking `
  test/atlas/scan/queue

flutter analyze --no-pub

git diff --check

git status -sb
```
