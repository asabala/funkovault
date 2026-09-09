# Scanner 6C Auction Fast - Fix 3

Real-device auction regression correction based on TikTok/Whatnot screenshots.

## What changed

- Native ML Kit OCR now emits **line-level bounding boxes** rather than large text-block boxes.
- Atlas masks the native HUD footprint so its own `#...` and match percentage cannot become Pop evidence.
- Product-number anchors reject prices, percentages, dates/times, and common marketplace chrome.
- Featured scoring is based on the actual number line instead of a large merged OCR neighborhood.
- The local package evidence window extends far enough downward to include front-panel name strips such as `IRIS` and `MONKEY D. GARP`.
- Four-digit Pop numbers remain intact.
- Multiple readable foreground/wall boxes remain separate candidates so Automatic mode can trigger Scan One / Scan All.

## Intent

This is still Auction Fast mode: surface useful evidence immediately, refine across frames, never mutate the Vault automatically.
