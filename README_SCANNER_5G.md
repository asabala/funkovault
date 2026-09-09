# Scanner 5G — Grail Guard + Final Integration

## Scope

Scanner 5G completes Scanner 5 by integrating the existing Grail Guard policy into the Scanner 4 haul review workflow without creating new scanner architecture.

## Files

### Replace
- `lib/atlas/scan/authenticity/policies/inspection_recommendation_policy.dart`
- `lib/screens/scanner/atlas_haul_review_screen.dart`
- `test/atlas/scan/authenticity/inspection_recommendation_policy_test.dart`

### New
- `lib/atlas/scan/authenticity/services/atlas_grail_guard_service.dart`
- `lib/widgets/scanner/atlas_grail_guard_card.dart`
- `test/atlas/scan/authenticity/atlas_grail_guard_service_test.dart`

## Behavior

Grail Guard recommends a full visual inspection when collector-risk signals justify one. Current signals include collector value threshold, known counterfeit exposure, variant price spread when supplied, unresolved variant evidence, limited-edition status, autograph/authentication evidence, and weak reference coverage when combined with meaningful collector-risk metadata.

Grail Guard does not change catalog identity, does not automatically commit a Vault record, and does not determine authenticity. Existing Scanner 5 authenticity scoring remains authoritative for inspection evidence.

The haul review screen surfaces the recommendation before Vault commit and routes the collector into the existing Scanner 5F visual inspection experience.

## Validation

```powershell
dart format `
  lib/atlas/scan/authenticity/policies/inspection_recommendation_policy.dart `
  lib/atlas/scan/authenticity/services/atlas_grail_guard_service.dart `
  lib/screens/scanner/atlas_haul_review_screen.dart `
  lib/widgets/scanner/atlas_grail_guard_card.dart `
  test/atlas/scan/authenticity/inspection_recommendation_policy_test.dart `
  test/atlas/scan/authenticity/atlas_grail_guard_service_test.dart

flutter test `
  test/atlas/scan/authenticity `
  test/atlas/scan/variant `
  test/widgets/scanner

flutter analyze --no-pub
git diff --check
git status -sb
```
