# Scanner 6C — Auction Fast Visual Recognition

This checkpoint revises Android Live Sniffer around real TikTok/Whatnot auction behavior.

## Core behavior

- The source marketplace stays full-screen. Atlas uses a mirror capture surface; it does not resize the source app or force picture-in-picture.
- Barcode is optional bonus evidence, not the primary identity path.
- Native ML Kit barcode and OCR run in parallel on sampled MediaProjection frames.
- OCR emits spatial text blocks so Atlas can reason about multiple visible Funko boxes rather than one flat screen string.
- Auction Fast Mode prioritizes product number + box/name text for a quick provisional match, then refines as later frames expose more series/variant/sticker text.
- Two modes are available before starting a live session:
  - Featured Pop — prioritize the largest/most-central candidate.
  - All Visible — scan multiple stable visible candidates in parallel.
- Temporal evidence is retained briefly across frames while the box rotates.
- UPC/EAN still crosses the existing 6A -> Scanner 4 path when visible.
- OCR catalog matches use AtlasCatalogService.search and AtlasCollectorResolver.
- Provisional ownership language is explicitly marked LIKELY until evidence is strong enough.
- No Live Sniffer path mutates Vault data.

## Files

### Replace

- `android/app/src/main/kotlin/com/example/funkovault2/AtlasLiveSnifferService.kt`
- `lib/atlas/live_sniffer/atlas_live_sniffer_recognition_controller.dart`
- `lib/atlas/live_sniffer/models/atlas_live_sniffer_hud_snapshot.dart`
- `lib/atlas/live_sniffer/models/atlas_live_sniffer_native_frame.dart`
- `lib/screens/scanner/atlas_live_sniffer_screen.dart`
- `test/atlas/live_sniffer/atlas_live_sniffer_native_frame_test.dart`
- `test/atlas/live_sniffer/atlas_live_sniffer_recognition_controller_test.dart`

### New

- `lib/atlas/live_sniffer/models/atlas_live_sniffer_scan_mode.dart`
- `lib/atlas/live_sniffer/models/atlas_live_sniffer_box_candidate.dart`
- `lib/atlas/live_sniffer/recognition/atlas_live_sniffer_box_candidate_extractor.dart`
- `lib/atlas/live_sniffer/recognition/atlas_live_sniffer_auction_match_engine.dart`
- `test/atlas/live_sniffer/atlas_live_sniffer_box_candidate_extractor_test.dart`
- `test/atlas/live_sniffer/atlas_live_sniffer_scan_mode_test.dart`

The existing 6C barcode dependency/build.gradle, Method/Event channel foundation, state store, recognition bridge, and barcode observation adapter remain valid and are included in the package so it can overlay the currently staged checkpoint safely.

## Validation

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
git diff --cached --check
git status -sb
```

Do not commit until a physical Android auction smoke test confirms overlay, full-screen source preservation, fast OCR response, multi-item behavior, and clean stop/removal.
