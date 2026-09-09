# Scanner 6B — Room / Shelf Intelligence Foundation

## Scope

Scanner 6B projects Scanner 6A continuous perception into a persistent shelf
session and reconciles observed physical copies against the scoped Vault.

## Core invariant

Shelf Intelligence may observe, reconcile, flag, and stage proposed collector
actions. It does **not** write to AppState or the Vault. All proposed mutations
remain explicit collector-confirmation work for a later integration/UI phase.

## Reused authorities

- `AtlasCollectorStateEngine` — exact owned / wishlist / related-release truth.
- `Pop.collectibleIdentityKey` / `similarityReviewKey` — release identity truth.
- `DuplicateReviewService` — existing Vault duplicate / variant review truth.
- `AtlasCompletionResult` — collection completion and catalog-gap truth.
- Scanner 6A candidate/result models — transient camera truth.
- Scanner 4 `AtlasContinuousScanResult` — resolved product truth.

## New 6B concepts

- `AtlasShelfObservation` — persistent shelf-session object independent of a
  short-lived Scanner 6A `trackId`.
- observed-object states: Owned, Not In Vault, Possible Variant, Extra Copy,
  Needs Review.
- `AtlasShelfExpectedItem` — Vault-owned quantity expected in the scanned shelf
  context; distinguishes missing-from-shelf from not-yet-owned completion gaps.
- `AtlasShelfProposedAction` — staged data only; there is intentionally no action
  executor in 6B foundation.
- conservative cross-track reassociation — only exact release identity, one
  eligible inactive prior observation, and a bounded time window. Multiple
  identical inactive copies remain ambiguous and are never guessed.

## Important semantic separation

`Missing From Shelf` means the Vault says the collector owns a copy that was not
observed in this shelf session.

`completionGaps` means a catalog/set release is not owned. It is not treated as a
physical object Atlas expected to see on the shelf.

Likewise, an observed `Extra Copy` means the number of physical observations
exceeds the scoped Vault quantity. It does not automatically mean Trade or Sell.
