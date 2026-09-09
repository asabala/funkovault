# Scanner 5A - Visual Inspection & Authenticity Intelligence Foundation

This package upgrades the existing Atlas authenticity subsystem rather than creating a parallel scanner architecture.

## Replacement files

- `lib/atlas/scan/authenticity/atlas_authenticity_rules.dart`
- `lib/atlas/scan/authenticity/atlas_authenticity_engine.dart`
- `lib/atlas/scan/authenticity/atlas_visual_inspection_service.dart`
- `lib/atlas/scan/authenticity/models/atlas_visual_inspection.dart`
- `lib/atlas/scan/authenticity/models/atlas_authenticity_assessment.dart`
- `test/atlas/scan/authenticity/atlas_authenticity_engine_test.dart`

## New files

- `lib/atlas/scan/authenticity/models/normalized_image_region.dart`
- `lib/atlas/scan/authenticity/models/atlas_inspection_reference.dart`
- `lib/atlas/scan/authenticity/models/atlas_authenticity_evidence.dart`
- `lib/atlas/scan/authenticity/policies/inspection_recommendation_policy.dart`
- `test/atlas/scan/authenticity/atlas_authenticity_foundation_test.dart`
- `test/atlas/scan/authenticity/inspection_recommendation_policy_test.dart`

## Scanner 5A rules locked in this checkpoint

- Evidence confidence, reference coverage, and authenticity concern are independent dimensions.
- Uninspected areas do not create risk.
- Low-quality evidence does not create risk.
- Weak reference coverage does not create risk.
- Correlated discrepancies are capped per evidence category.
- The strongest concern state requires critical contradictions in at least two independent categories.
- Autograph/COA data is observational only in Scanner 5A.
- Existing `ScanImage` references remain authoritative; no image byte buffers are introduced.
- Existing Scanner 4 tracker, queue, ledger, coordinator, camera, and UI are untouched.
