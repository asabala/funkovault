# Scanner 5C — High-Signal Inspection Engines

This checkpoint adds deterministic specialized evidence engines on top of the Scanner 5A authenticity foundation and Scanner 5B guided capture workflow.

## Added

- `AtlasStickerVariantInspectionEngine`
- `AtlasProductionStampInspectionEngine`
- `AtlasPackagingConsistencyEngine`
- `AtlasAutographCoaInspectionEngine`
- `AtlasHighSignalInspectionPipeline`
- focused deterministic engine/pipeline tests
- structured-evidence precedence in `AtlasAuthenticityRules` so the same legacy field is not scored twice after specialization

## Integration

`AtlasVisualInspectionService` now enriches a guided inspection with structured observations before adding the existing `VisualInspectionContribution` and running the existing `AtlasAuthenticityEngine`.

No parallel authenticity contribution type, capability, scanner, or scoring system is introduced.

## Safety / evidence rules

- Missing evidence creates no discrepancy.
- Unknown sticker text is observational.
- Unsupported production stamp formats are observational.
- Critical sticker/reference mismatch requires comprehensive reference coverage, >= 0.85 completeness, and specialist-vetted provenance.
- Critical copyright/reference mismatch additionally requires expected copyright years for every known production run.
- Autograph / COA evidence remains observational and explicitly records `providerVerified: false`.
- Missing COA is never treated as counterfeit evidence.
- Macro packaging checks remain macro-level only; no pixel-perfect typography, microscopic border, ink-density, or condition scoring is introduced.

## Validation

Run:

```powershell
dart format lib/atlas/scan/authenticity test/atlas/scan/authenticity

flutter test test/atlas/scan/authenticity

flutter analyze --no-pub

git diff --check

git status -sb
```
