# Scanner 5F — ADS 2.0 Inspection UI

## Scope
Presentation/integration only. No new scanner architecture and no change to canonical scanner identity rules.

## Files

### Replace
- `lib/screens/scanner/atlas_visual_inspection_screen.dart`
- `lib/widgets/scanner/atlas_authenticity_card.dart`

### Add
- `lib/widgets/scanner/atlas_inspection_intelligence_dashboard.dart`
- `test/widgets/scanner/atlas_inspection_intelligence_dashboard_test.dart`

## UI delivered
- Six guided inspection sections: Front, Sticker, Bottom Stamp, Packaging, Autograph, COA.
- Per-area state: Not inspected / Captured / Reviewed / Needs attention.
- Guided inspection progress header.
- Five intelligence surfaces:
  1. Evidence Confidence
  2. Reference Coverage
  3. Authenticity Concern
  4. Variant Confirmation
  5. Autograph / COA Evidence
- Existing capture, OCR, preview assessment, and save flow preserved.
- Variant evidence is presentation-only in 5F; the UI does not rewrite catalog identity.
- Authenticity wording remains non-definitive.
- Missing evidence is not presented as counterfeit evidence.

## Validation
Run after extracting over the repository root:

```powershell
dart format `
  lib/screens/scanner/atlas_visual_inspection_screen.dart `
  lib/widgets/scanner/atlas_authenticity_card.dart `
  lib/widgets/scanner/atlas_inspection_intelligence_dashboard.dart `
  test/widgets/scanner/atlas_inspection_intelligence_dashboard_test.dart

flutter test `
  test/widgets/scanner/atlas_inspection_intelligence_dashboard_test.dart `
  test/atlas/scan/authenticity `
  test/atlas/scan/acquisition/atlas_guided_inspection_capture_plan_test.dart `
  test/atlas/scan/variant

flutter analyze --no-pub
git diff --check
git status -sb
```
