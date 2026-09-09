# Scanner 6C - Auction Fast Fix 5: Native Tap Lock

## Root cause found
Fix 4 added Dart-side target coordinates and tests, but the replacement package did not include the Android overlay/service implementation that actually captures a tap from TikTok/Whatnot. As a result, Scan One still emitted the old Featured action and continued full-screen OCR/background guessing.

## Fix 5 behavior
- Scan One no longer starts featured guessing.
- Pressing Scan One pauses OCR immediately while MediaProjection keeps the marketplace full-size.
- The floating HUD says `Tap the Pop you want to scan`.
- A transparent full-screen Android overlay captures exactly one tap and consumes it so TikTok/Whatnot does not receive the tap.
- The tap is emitted to Flutter as normalized `targetTap` coordinates.
- After the tap, native OCR processes only a crop around the selected box and upscales that crop before ML Kit recognition.
- OCR line and barcode geometry from the crop are mapped back into full-screen normalized coordinates for the existing Dart candidate engine.
- Previous in-flight full-screen OCR is invalidated so a stale shelf/background result cannot arrive after the user locks a target.
- Tapping the floating Atlas HUD again re-enters target selection for the next auction item.
- Scan All clears the native target and returns to full-screen multi-box recognition.
- MediaProjection never resizes or collapses TikTok/Whatnot.
- Live Sniffer remains read-only and never mutates the Vault.

## Real-device acceptance test
1. Start Live Sniffer on TikTok.
2. When multiple Pops are detected, press Scan One.
3. OCR should pause and HUD should say `Tap the Pop you want to scan`.
4. Tap the foreground Pop. The tap must not activate TikTok controls.
5. HUD should change to `Target locked / Scanning selected Pop...`.
6. Background shelf numbers must stop replacing the selected item.
7. Let the Pop rotate and confirm number/name evidence survives short unreadable frames.
8. Tap the Atlas HUD, then tap a new Pop to retarget.
9. Use Scan All and verify multi-Pop scanning resumes.
