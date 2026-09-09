# Scanner 6B - Room / Shelf UI Integration

This package wires the committed Scanner 6A/6B foundations into the existing Atlas collection room without changing the normal ScanScreen flow.

## Files

Replace:
- `lib/screens/vault/atlas_room_screen.dart`
- `test/screens/vault/atlas_room_screen_test.dart`

Add:
- `lib/screens/scanner/atlas_shelf_scan_screen.dart`
- `lib/screens/scanner/atlas_shelf_batch_review_screen.dart`

## Flow

`AtlasRoomScreen -> Start Shelf Scan -> MobileScanner -> AtlasMobileScannerObservationAdapter -> AtlasContinuousPerceptionCoordinator -> AtlasContinuousScanCoordinator -> AtlasShelfSessionCoordinator -> Finish & Review Shelf -> AtlasShelfBatchReviewScreen`

## Safety / mutation boundary

Shelf scan and reconciliation never write to the Vault. Proposed `addToVault` and `addAnotherCopy` actions open the existing `AddPopScreen`; only a successful explicit save is followed by scanner-ledger commit. Variant or unresolved observations route into the existing haul review workflow. There is no silent Confirm All mutation path.

## Deliberate scope

The shelf review displays completion gaps only when an `AtlasCompletionResult` has been attached to reconciliation. The current Room-launched pass has no catalog completion query/context, so it truthfully reports that no completion-gap context was attached instead of inventing or duplicating completion logic.

## Validate

```powershell
dart format `
  lib/screens/vault/atlas_room_screen.dart `
  lib/screens/scanner/atlas_shelf_scan_screen.dart `
  lib/screens/scanner/atlas_shelf_batch_review_screen.dart `
  test/screens/vault/atlas_room_screen_test.dart

flutter test `
  test/screens/vault/atlas_room_screen_test.dart `
  test/atlas/shelf `
  test/atlas/scan/continuous `
  test/atlas/scan/tracking

flutter analyze --no-pub

git diff --check

git status -sb
```
