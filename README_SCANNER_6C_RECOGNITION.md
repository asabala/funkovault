# Scanner 6C - Live Recognition + HUD Intelligence

## Checkpoint goal

Connect the already-pushed Android Live Sniffer foundation to real, low-rate screen recognition and read-only collector intelligence.

This checkpoint preserves the Scanner 6 invariant:

> Live Sniffer may observe, identify, compare, and recommend. It never silently adds, edits, merges, or otherwise mutates the Vault.

## What this package adds

### Android acquisition + recognition

- Keeps the existing MediaProjection foreground service and reduced 960px-long-edge capture surface.
- Samples recognition work at no more than once every 250 ms.
- Converts RGBA_8888 ImageReader frames into an ML Kit-compatible Bitmap while handling row padding.
- Runs bundled ML Kit barcode recognition for UPC-A, UPC-E, EAN-8, EAN-13, and QR.
- Runs lightweight Latin text recognition only when no barcode was found in that sample.
- Emits normalized frame observations over `atlas/live_sniffer/events`.
- Keeps all EventChannel delivery on Android's main thread.
- Updates the existing draggable native HUD through the current `atlas/live_sniffer` MethodChannel.

### Flutter intelligence

- Adapts native barcode rectangles into existing `AtlasScanObservation` objects.
- Reuses `AtlasContinuousPerceptionCoordinator` (6A) for cadence/tracking/evidence.
- Reuses `AtlasContinuousScanCoordinator` (Scanner 4) for safe catalog resolution.
- Reuses `AtlasCollectorResolver` for collector-state intelligence.
- Requires exact `collectibleIdentityKey` agreement before the HUD says `OWNED`.
- Treats barcode-related but release-different records as `POSSIBLE VARIANT` rather than collapsing Common/Chase/sticker releases.
- Shows read-only HUD states: Listening, Owned, Not Owned, Wishlist, Possible Variant, Needs Review.
- Shows `Cached Value` only when Atlas already has a catalog-converted or exact-owned value.
- Lightweight OCR is a hint only. Text alone does not assign product identity or ownership.

## Intentionally not invented

The current audited models do not provide real `targetPrice` or `currentBid` fields. This package therefore does **not** fabricate those HUD rows.

The current file-path OCR service is also not repurposed for raw MediaProjection frames. The Android capture adapter performs lightweight OCR natively and sends only a text hint to Flutter. Product identity still requires safe catalog resolution.

## Files

### REPLACE

- `android/app/build.gradle.kts`
- `android/app/src/main/kotlin/com/example/funkovault2/MainActivity.kt`
- `android/app/src/main/kotlin/com/example/funkovault2/AtlasLiveSnifferService.kt`
- `android/app/src/main/kotlin/com/example/funkovault2/AtlasLiveSnifferStateStore.kt`
- `lib/screens/scanner/atlas_live_sniffer_screen.dart`

### NEW

- `lib/atlas/live_sniffer/atlas_live_sniffer_recognition_bridge.dart`
- `lib/atlas/live_sniffer/atlas_live_sniffer_recognition_controller.dart`
- `lib/atlas/live_sniffer/models/atlas_live_sniffer_hud_snapshot.dart`
- `lib/atlas/live_sniffer/models/atlas_live_sniffer_native_frame.dart`
- `lib/atlas/live_sniffer/recognition/atlas_live_sniffer_native_observation_adapter.dart`
- `test/atlas/live_sniffer/atlas_live_sniffer_hud_snapshot_test.dart`
- `test/atlas/live_sniffer/atlas_live_sniffer_native_frame_test.dart`
- `test/atlas/live_sniffer/atlas_live_sniffer_recognition_controller_test.dart`

## Android note

This checkpoint raises the app's effective Android minimum SDK to 23 because the native ML Kit live-recognition path requires API 23+.

The app directly declares the bundled ML Kit barcode and Latin text-recognition artifacts so the foreground service has a compile-time native dependency instead of depending on Flutter plugin implementation visibility.

## Validation

From the repo root:

```powershell
dart format `
  lib/atlas/live_sniffer `
  lib/screens/scanner/atlas_live_sniffer_screen.dart `
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

Do not stage until all validation is clean except known line-ending/deprecation warnings.

## Physical Android smoke test

After the compile succeeds, test on a real Android device:

1. Open Atlas -> Scan -> Android Live Sniffer.
2. Grant overlay/notification permissions if needed.
3. Tap **Start Live Sniffer** and approve Android screen sharing.
4. Switch to another app or browser.
5. Put a supported UPC/EAN barcode clearly on screen and hold it steady for roughly one second.
6. Confirm the HUD changes from `Listening...` to an Atlas product/collector result.
7. Verify exact owned items show `OWNED xN`.
8. Verify a same-barcode/different-release situation does not silently become Owned; it should remain review-oriented / Possible Variant.
9. Show listing text without a barcode and confirm Atlas may report that text was detected while still waiting for a safe product match.
10. Stop Live Sniffer and confirm the overlay disappears.
11. Verify no Vault record changed as a side effect of the live session.

## Scope after this checkpoint

If validation and the physical smoke test pass, the core 6C Android pipeline is complete:

`MediaProjection -> sampled frame -> barcode/OCR hint -> 6A perception -> Scanner 4 resolution -> collector state -> floating HUD`

A later pricing/listing-intelligence checkpoint can introduce actual observed listing price, target price, and bid models before those values appear in the HUD.
