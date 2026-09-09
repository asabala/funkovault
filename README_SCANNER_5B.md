# Scanner 5B — Guided Visual Capture

This package upgrades the existing Scanner 5 visual-inspection UI instead of creating a parallel scanner.

## Files

New:
- `lib/atlas/scan/acquisition/atlas_guided_inspection_capture_plan.dart`
- `test/atlas/scan/acquisition/atlas_guided_inspection_capture_plan_test.dart`

Replace:
- `lib/atlas/scan/authenticity/models/atlas_visual_inspection.dart`
- `lib/screens/scanner/atlas_visual_inspection_screen.dart`

Existing files intentionally reused unchanged:
- `lib/atlas/scan/acquisition/atlas_inspection_image_capture_service.dart`
- `lib/atlas/scan/recognition/atlas_text_recognition_service.dart`
- `lib/atlas/scan/authenticity/atlas_visual_inspection_service.dart`
- `lib/widgets/scanner/atlas_authenticity_card.dart`

The guided plan covers front box, sticker/window, bottom stamp, packaging/copyright, autograph, and COA. Condition remains Scanner 6.
