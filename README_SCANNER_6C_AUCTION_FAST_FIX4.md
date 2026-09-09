# Scanner 6C — Auction Fast Fix 4: Touch-to-Lock ROI

## Why this fix exists
Real TikTok/Whatnot testing showed that automatic foreground scoring can still select readable shelf boxes behind the active auction item. A spinning foreground box may only expose its number/name for one or two useful frames.

## Fix 4 behavior
- **Scan One is now explicit**: tapping **Scan One** enters a one-tap target picker.
- The picker is a transparent full-screen overlay. It **does not resize the marketplace** and it consumes the selection tap so the tap is not passed through to bidding/like controls.
- The tap becomes an authoritative normalized focus point.
- Native OCR crops around that point and upscales the crop before ML Kit text recognition.
- Dart candidate extraction rejects text outside the selected region and adds strong touch-proximity scoring.
- Prior automatic/background temporal evidence is cleared when a target is chosen.
- The target remains locked while the box spins; short OCR misses do not immediately replace the HUD with a background box.
- **Tap the Atlas HUD again to retarget** the next Pop without restarting Live Sniffer.
- **Scan All** keeps the existing multi-Pop behavior and clears any native touch focus.
- UPC/EAN remain bonus evidence only.
- Vault mutation remains forbidden; all Live Sniffer output is read-only intelligence.

## Real-device regression cases
1. One turntable Pop in front of a shelf: tap the front box; shelf numbers must not replace it.
2. Spinning box: number/name may disappear for frames; last useful selected-box result should remain.
3. Multi-Pop wall: prompt still offers Scan One / Scan All.
4. Scan One: selection tap must not trigger marketplace UI beneath it.
5. Retarget: tap Atlas HUD, then tap the next Pop.
6. Source marketplace stays full-size throughout.
