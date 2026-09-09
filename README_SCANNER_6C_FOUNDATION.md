# Scanner 6C — Android Live Sniffer Foundation

This checkpoint adds the Android-native lifecycle needed for Atlas Live Sniffer. It intentionally does **not** perform live OCR, barcode decoding from MediaProjection frames, pricing, or Vault writes yet.

## Architecture

Android MediaProjection permission
→ foreground `AtlasLiveSnifferService`
→ reduced capture surface
→ frames dropped at the native boundary for this checkpoint
→ draggable floating Atlas HUD

Flutter communicates with Android through `atlas/live_sniffer` and exposes status through `AtlasLiveSnifferController`.

## Invariant

Live Sniffer observes and recommends. It does not automatically change collector identity or Vault records.

## Files

### Replace
- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/kotlin/com/example/funkovault2/MainActivity.kt`
- `lib/screens/scanner/scan_screen.dart`

### New
- `android/app/src/main/kotlin/com/example/funkovault2/AtlasLiveSnifferService.kt`
- `android/app/src/main/kotlin/com/example/funkovault2/AtlasLiveSnifferStateStore.kt`
- `lib/atlas/live_sniffer/atlas_live_sniffer_status.dart`
- `lib/atlas/live_sniffer/atlas_live_sniffer_bridge.dart`
- `lib/atlas/live_sniffer/atlas_live_sniffer_controller.dart`
- `lib/screens/scanner/atlas_live_sniffer_screen.dart`
- `test/atlas/live_sniffer/atlas_live_sniffer_status_test.dart`
- `test/atlas/live_sniffer/atlas_live_sniffer_controller_test.dart`

## Manual Android test

1. Open **Scan**.
2. Tap **Android Live Sniffer**.
3. Grant **Display over other apps**.
4. Grant notifications if Android requests it.
5. Tap **Start Live Sniffer**.
6. Accept Android's screen-capture prompt.
7. Switch to another app.
8. Confirm the draggable `ATLAS LIVE / Listening...` HUD remains visible.
9. Return to Atlas and tap **Stop Live Sniffer**.

At this checkpoint the capture surface is intentionally consumed and discarded. The next 6C checkpoint will add sampled-frame recognition and Live Sniffer intelligence.

## Validation

```powershell
dart format `
  lib/atlas/live_sniffer `
  lib/screens/scanner/atlas_live_sniffer_screen.dart `
  lib/screens/scanner/scan_screen.dart `
  test/atlas/live_sniffer

flutter test `
  test/atlas/live_sniffer `
  test/atlas/scan/continuous `
  test/atlas/scan/tracking

flutter analyze --no-pub

cd android
.\gradlew.bat :app:compileDebugKotlin
cd ..

git diff --check
git status -sb
```

Do not stage until Flutter tests, analyzer, and Kotlin compilation are green.
