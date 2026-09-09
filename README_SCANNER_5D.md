# Scanner 5D — Variant Resolution + Authenticity Integration

This checkpoint bridges Scanner 5C structured sticker/variant observations into Atlas's existing `ScanVariantResolution` model.

## Rules
- Visual evidence never rewrites canonical product identity.
- Missing/unclassified evidence does not create or downgrade a variant result.
- A matching sticker/variant observation becomes `likelyMatch`, not `exactMatch`.
- A mismatch, reference contradiction, or classified variant with no resolved variant becomes `visualConfirmationRequired`.
- Explicit collector confirmation is modeled separately by `AtlasVariantConfirmationService`.
- Authenticity aggregation remains owned by Scanner 5A.

## Files
NEW:
- `lib/atlas/scan/variant/atlas_variant_resolution_bridge.dart`
- `lib/atlas/scan/variant/atlas_variant_confirmation_service.dart`
- `test/atlas/scan/variant/atlas_variant_resolution_bridge_test.dart`

REPLACE:
- `lib/atlas/scan/authenticity/atlas_visual_inspection_service.dart`
