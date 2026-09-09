# Scanner 6C Auction Fast - Field Test Fix 2

This correction is based on the first real TikTok/Whatnot field test.

## Fixes

- Default scan mode is now Auto.
- One clear foreground Pop is scanned immediately.
- Two or more plausible stable Pop candidates for two consecutive frames trigger a floating overlay choice: Scan One / Scan All.
- The choice is remembered for the current live session.
- Recognition continues in featured mode while the user decides, so a five-second auction is not paused by the prompt.
- Featured scoring now favors central/lower-central, larger readable packaging text and suppresses obvious Atlas HUD / marketplace chrome.
- The source marketplace remains full-size. All masks/crops are recognition-only.
- The floating overlay is still draggable; its action buttons do not resize the source app.

## Deliberately conservative

This is still OCR-first recognition. It does not pretend that OCR text bounds are true physical box bounds. The field-test goal is to stop obvious background/UI number grabs and establish the correct one-vs-all decision flow before adding a heavier visual box detector.
