# Scanner 6C Fix 6 — Persistent Physical Target Lock

## Goal

Fix the real-device failure where **Scan One** could briefly read the selected Pop, then lose it during turntable rotation and start using text/numbers from background boxes.

Fix 6 makes the user's tap authoritative for the lifetime of that selection.

## Hard invariant

When Scan One is active:

> The selected physical target is the only object allowed to contribute OCR/barcode evidence until the user retargets or explicitly chooses Scan All.

Target loss never falls back to Scan All and never chooses another background Pop automatically.

## Native Android pipeline

MediaProjection remains RGBA_8888 and the marketplace app remains full-screen.

```
RGBA_8888 screen frame
  -> ARGB_8888 Bitmap
  -> 640px-long-edge ML Kit object-tracker input
  -> selected native spatial track
  -> dynamic target bounding box + 15% padding
  -> OCR/barcode only inside that target ROI
  -> frameSequence + selectionGeneration + track metadata
  -> Flutter
```

### New dependency

```kotlin
implementation("com.google.mlkit:object-detection:17.0.2")
```

The existing minimum SDK is already 23, which satisfies the current ML Kit object detection requirement.

## Hybrid acquisition for auction speed

ML Kit stream tracking can require warm-up. Fix 6 therefore does **not** wait for a native tracking ID before doing anything useful.

Immediately after the tap:

1. Atlas creates a tight bootstrap ROI centered on the tap.
2. OCR may read only that ROI for a short 850ms bootstrap window.
3. In parallel, ML Kit searches the full frame for the physical object nearest/containing the tap.
4. Once a spatial target is found, the ROI follows the object's bounding box.
5. If the tracker is unavailable or still warming up, Atlas does not return to full-frame Scan One recognition.

This preserves auction speed without allowing a background wall to become the selected target.

## Target lifecycle

```
AWAITING_SELECTION
  -> ACQUIRING
  -> LOCKED
  -> COASTING      (0–600ms temporary spatial loss)
  -> REACQUIRING   (600–1500ms)
  -> TARGET_LOST   (>1500ms)
  -> Await explicit retap
```

`TARGET_LOST` is terminal for the current selection generation. Atlas will not bind a different object until the user retaps.

## Reacquisition

While within the 1500ms window, Atlas first searches for the exact native tracking ID. If ML Kit reassigns the ID, Atlas may rebind only to an object that spatially overlaps or remains very close to the last authoritative bounding box.

OCR strings are never used to decide which physical object is being tracked.

## Visible target reticle

Fix 6 adds a non-touchable outline around the current target. It moves with the native tracked bounding box.

- blue: acquiring/locked
- amber: coasting/reacquiring
- red: target lost

This is intentionally visible during real-device testing so coordinate/track mistakes can be diagnosed immediately.

## Native -> Flutter contract

Frames now carry:

- `frameSequence`
- `nativeTimestampMs`
- `selectionGeneration`
- `lockedTrackId`
- `targetState`
- `trackedBoundingBox`
- `activeTracks`
- track-stamped OCR lines
- track-stamped barcodes

The ML Kit `trackId` remains a spatial tracking ID only. It is **not** an Atlas catalog ID, collectible identity, or Vault identity.

## Dart invalidation gates

Flutter now:

- drops out-of-order frame sequences instead of rewriting their timestamps;
- drops stale timestamps;
- drops mismatched selection generations;
- scopes locked-target OCR/barcodes to the active native track when one exists;
- uses one persistent temporal-evidence key for the selected physical target;
- preserves selected-target evidence across rotation/blank sides;
- preserves evidence after TARGET_LOST until explicit retarget/session reset;
- invalidates in-flight catalog work across retargets/mode changes.

## Scan All

Fix 6 deliberately does **not** force ML Kit object detection to become the Scan All identity engine. Google's standard object detector has a small per-frame object limit and real-time multi-object tracking can reduce throughput.

Scan All therefore keeps the existing OCR multi-candidate path (up to the existing Atlas candidate limit) instead of accidentally limiting a 9-Pop wall to the native detector's object cap.

Future **Select Pops** can build multiple persistent target tracks on top of this Fix 6 single-target foundation.

## Files changed

### Android

- `android/app/build.gradle.kts`
- `android/app/src/main/kotlin/com/example/funkovault2/AtlasLiveSnifferService.kt`
- `android/app/src/main/kotlin/com/example/funkovault2/AtlasLiveSnifferStateStore.kt`

### Flutter

- `lib/atlas/live_sniffer/atlas_live_sniffer_recognition_controller.dart`
- `lib/atlas/live_sniffer/models/atlas_live_sniffer_native_frame.dart`
- `lib/atlas/live_sniffer/models/atlas_live_sniffer_target_state.dart` **NEW**
- `lib/atlas/live_sniffer/models/atlas_live_sniffer_track.dart` **NEW**
- `lib/atlas/live_sniffer/recognition/atlas_live_sniffer_box_candidate_extractor.dart`

### Tests

- `test/atlas/live_sniffer/atlas_live_sniffer_native_frame_test.dart`
- `test/atlas/live_sniffer/atlas_live_sniffer_recognition_controller_test.dart`

## Validation

```powershell
dart format `
  lib/atlas/live_sniffer `
  test/atlas/live_sniffer

flutter test `
  test/atlas/live_sniffer `
  test/atlas/scan/continuous `
  test/atlas/scan/tracking

flutter analyze --no-pub

$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"

cd android
.\gradlew.bat :app:compileDebugKotlin
cd ..

git diff --check
git status -sb
```

Do not commit until the real TikTok/Whatnot target-lock smoke test passes.

## Real-device acceptance test

1. Open a live with a foreground Pop and several background Pops.
2. Choose **Scan One**.
3. Tap the foreground Pop.
4. Confirm the target reticle appears around the tapped object.
5. Let the turntable rotate.
6. The reticle should follow the same physical box.
7. Previously learned number/name evidence must remain while a blank side is visible.
8. Background box numbers must never replace the selected target's evidence.
9. Brief obstruction should show Tracking/Reacquiring, not switch targets.
10. If the selected Pop leaves the frame for more than 1500ms, Atlas must show Target lost and wait for retap.
11. Tap the Atlas HUD, select a new Pop, and confirm the old generation cannot reappear.
12. Switch to Scan All and confirm the existing multi-Pop flow still works.
