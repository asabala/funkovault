# Atlas LiveLens / Scanner 6C
## Selected Target Persistence / Tap Authority Hotfix

This package is intentionally narrow. It does **not** redesign LiveLens, change catalog matching, change candidate scoring, or change the frame format pipeline.

## Complete replacement files

Copy these two files into the same paths under:

`C:\Users\Arthur Sabala\Documents\funkovault2`

1. `android/app/src/main/kotlin/com/example/funkovault2/AtlasLiveSnifferService.kt`
2. `lib/atlas/live_sniffer/atlas_live_sniffer_recognition_controller.dart`

## What changed

### Android / Kotlin target lifecycle

- A manual tap now owns the selected target identity.
- Temporary ML Kit tracker loss no longer rolls `targetGeneration` after the old ~750 ms loss threshold.
- `foregroundOcrBounds`, the original tap coordinates, selected target bounds, and generation are retained while the tracker is coasting/reacquiring/lost.
- Selected-target reacquisition hold is extended to 8 seconds before the UI can even enter the `lost` state.
- Entering `lost` for a manually selected target does **not** call `rollTargetGenerationForViewportExit()`.
- OCR/barcode evidence from the stable selected ROI remains allowed during selected-target reacquisition and even after tracker loss, because tracking is now an aid rather than identity authority.
- A changed ML Kit tracking ID is treated as the same selected Pop when its geometry remains spatially compatible. After two consistent hits, the new tracker ID is adopted **without** rolling generation.
- A tracker-only replacement can roll generation only when it is both spatially different and persistent: at least 8 hits after at least 2.5 seconds without the old track.
- Broad scene-discontinuity detection no longer revokes a manual tap by itself. Manual selected-target turnover must be proven by persistent replacement tracking or the existing contradictory-number path.
- Existing non-manual turnover behavior remains on the original short lifecycle.

### Dart recognition lifecycle

- `lost` no longer clears `_temporalEvidence`, `_projectedTrackIds`, or static-clutter state when a manual selection is still active.
- If OCR/barcode evidence is still produced for the selected ROI while native tracking is lost, Dart continues normal identity resolution.
- In-flight resolution results are no longer rejected merely because the tracker state became `lost`; generation mismatch remains the identity fence.
- Existing repeated contradictory-number turnover logic remains unchanged and authoritative.

## Intentionally not changed

- Catalog matching
- OCR candidate scoring / ranked-number extraction
- Front-panel authority
- HUD redesign
- ML Kit bitmap/YUV frame pipeline
- `InputImage.fromBitmap(...)` warning
- MediaProjection cleanup behavior

## Gemini review prompt

Review these exact replacement files only:

- `android/app/src/main/kotlin/com/example/funkovault2/AtlasLiveSnifferService.kt`
- `lib/atlas/live_sniffer/atlas_live_sniffer_recognition_controller.dart`

Scope: Scanner 6C selected-target persistence / tap authority hotfix. Confirm that a manually tapped Pop keeps the same `targetGeneration`, `foregroundOcrBounds`, tap coordinates, and Dart temporal evidence through transient ML Kit track loss/reacquisition; that a changed tracker ID can be adopted as continuity without clearing identity; that timeout/lost alone cannot trigger viewport-exit turnover; and that generation only rolls for strong persistent replacement tracking or the existing repeated contradictory-number turnover. Verify non-manual behavior is preserved and flag any compile issue, race, stale-frame leak, accidental catalog/scoring change, or path where evidence could still be cleared during manual reacquisition. Do not propose a redesign or roadmap.

## Validation commands

Run from the project root unless the command changes directory:

```powershell
dart format lib/atlas/live_sniffer

flutter test test/atlas/live_sniffer test/atlas/scan/continuous test/atlas/scan/tracking

flutter analyze --no-pub

git diff --check

$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"

cd android
.\gradlew.bat :app:compileDebugKotlin
cd ..
```

## Expected live behavior after validation

After tapping a Pop, rotating it or briefly losing the ML Kit blue-box track should show coasting/reacquiring/holding behavior without starting a fresh identity generation. The same Pop may receive a different ML Kit tracking ID, but compatible reacquisition should attach that ID to the existing selected target rather than treating it as a new Pop. A true new Pop can still turn over through persistent replacement evidence or repeated strong contradictory product-number evidence.
