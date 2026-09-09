# Scanner 5E - Autograph & COA Intelligence

Scanner 5E enriches the existing guided visual-inspection flow with structured autograph and authentication-document evidence.

## Safety boundary

Atlas records what it can observe. It does not claim that JSA, PSA/DNA, Beckett, or another provider verified a certificate unless a future provider adapter actually performs that lookup and returns a verified result.

Missing COA evidence is never treated as counterfeit evidence.

## What changed

- Adds a future-facing authentication-provider adapter contract.
- Adds deterministic interpretation of common provider names and labeled certificate numbers from OCR text.
- Enables OCR for the guided COA capture step.
- Preserves raw certification OCR text in `AtlasVisualInspection`.
- Auto-fills provider/certificate fields from recognized COA text only when those fields are blank.
- Detects internal disagreements between manually entered provider/certificate data and observed COA text.
- Keeps those disagreements advisory/review-level rather than definitive counterfeit conclusions.
- Keeps provider verification state explicitly `notAttempted` in the local Scanner 5E engine.

## Files

### New
- `lib/atlas/scan/authenticity/providers/atlas_authentication_provider.dart`
- `lib/atlas/scan/authenticity/providers/atlas_authentication_evidence_interpreter.dart`
- `test/atlas/scan/authenticity/atlas_autograph_coa_intelligence_test.dart`

### Replace
- `lib/atlas/scan/acquisition/atlas_guided_inspection_capture_plan.dart`
- `lib/atlas/scan/authenticity/models/atlas_visual_inspection.dart`
- `lib/atlas/scan/authenticity/engines/atlas_autograph_coa_inspection_engine.dart`
- `lib/atlas/scan/authenticity/engines/atlas_high_signal_inspection_pipeline.dart`
- `lib/atlas/scan/authenticity/atlas_authenticity_rules.dart`
- `lib/screens/scanner/atlas_visual_inspection_screen.dart`
- `test/atlas/scan/acquisition/atlas_guided_inspection_capture_plan_test.dart`
