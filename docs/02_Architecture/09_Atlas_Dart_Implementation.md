# Atlas Dart Implementation Plan
### Version 1.0
### "Translating the Architecture into Maintainable Code"

---

# Purpose

This document defines the implementation sequence for translating the Atlas architecture contracts into Dart.

Implementation must follow the architecture.

The architecture must not be reshaped merely to make one screen easier to build.

The first implementation target is Identity Intelligence.

---

# Implementation Principles

The Dart implementation must be:

- Immutable
- Strongly typed
- Reusable
- Independently testable
- Serializable
- Versioned
- Platform-independent
- Free of Flutter dependencies in the intelligence layer

---

# Dependency Direction

```text
Flutter Screens
        ↓
Application Services
        ↓
Analysts and Builders
        ↓
Engines
        ↓
Policies
        ↓
Domain Models
        ↓
Observations and Data Sources
```

Dependencies must not flow upward.

---

# Proposed Folder Structure

```text
lib/
└── atlas/
    ├── core/
    │   ├── engine/
    │   ├── result/
    │   ├── finding/
    │   ├── decision/
    │   ├── recommendation/
    │   ├── evidence/
    │   ├── confidence/
    │   └── versioning/
    │
    ├── identity/
    │   ├── observation/
    │   ├── attribute/
    │   ├── policy/
    │   ├── profile/
    │   ├── fingerprint/
    │   ├── health/
    │   ├── relationship/
    │   ├── comparison/
    │   ├── engine/
    │   ├── analyst/
    │   ├── builder/
    │   ├── adapters/
    │   └── extensions/
    │
    └── application/
        └── identity/
```

The final folder structure may be adjusted to match the existing Atlas repository, but responsibilities must remain separated.

---

# Phase 1 — Universal Atlas Core

Implement the category-neutral contracts first.

Suggested implementation order:

```text
AtlasResultStatus
        ↓
AtlasWarning
        ↓
AtlasExecutionMetadata
        ↓
AtlasResult<T>
        ↓
AtlasFinding
        ↓
AtlasDecision
        ↓
AtlasRecommendation
        ↓
AtlasEngine<TInput, TOutput>
```

---

# AtlasResultStatus

Create a strongly typed status enum.

Suggested states:

```text
success
partialSuccess
validationFailure
policyFailure
missingData
conflictingEvidence
executionFailure
```

Avoid using free-form status strings.

---

# AtlasExecutionMetadata

Metadata should include fields such as:

- Engine name
- Engine version
- Schema version
- Policy version
- Started at
- Completed at
- Execution duration
- Warnings
- Evidence summary
- Correlation identifier

Metadata should be immutable.

---

# AtlasResult<T>

AtlasResult should provide:

- Status
- Optional output
- Errors
- Warnings
- Execution metadata
- Success helpers
- Failure helpers
- Serialization support where appropriate

A failed result should not require throwing an exception for expected domain failures.

Unexpected programming failures may still throw during development and testing.

---

# AtlasFinding

AtlasFinding should include:

- Finding identifier
- Category
- Severity
- Summary
- Explanation
- Confidence
- Evidence references
- Metadata
- Schema version

Findings should not contain Flutter presentation instructions.

---

# AtlasDecision

AtlasDecision should include:

- Decision identifier
- Engine identifier
- Classification
- Confidence
- Findings
- Evidence
- Reasoning
- Metadata
- Created timestamp
- Schema version

A Decision must remain independent of the action a screen chooses to offer.

---

# AtlasRecommendation

AtlasRecommendation should include:

- Recommendation identifier
- Priority
- Action type
- Summary
- Reason
- Supporting decision references
- Confidence
- Optional expiration
- Metadata
- Schema version

Recommendations should be advisory unless an explicitly approved workflow states otherwise.

---

# AtlasEngine

Define a universal engine abstraction.

Conceptually:

```text
AtlasEngine<TInput, TOutput>

Engine Name
Engine Version

Validate Input
Prepare Context
Execute
Post-Process
Build Result
```

The final Dart interface should remain small.

Avoid creating an oversized base class that forces every engine to implement unnecessary methods.

Prefer composition over deep inheritance.

---

# Phase 2 — Identity Primitive Models

Implement the smallest Identity models next.

Suggested order:

```text
IdentityPresence
        ↓
IdentityClassification
        ↓
IdentityRole
        ↓
IdentitySourceType
        ↓
IdentityObservation
        ↓
IdentityAttribute
```

---

# IdentityPresence

Suggested enum values:

```text
known
unknown
notApplicable
conflicting
```

---

# IdentityClassification

Suggested enum values:

```text
defining
influencing
contextual
instanceOnly
unknown
```

---

# IdentityRole

Suggested enum values:

```text
category
maker
entityAnchor
catalogIndex
primaryDescriptor
temporalMarker
releaseContext
variantModifier
```

---

# IdentityObservation

IdentityObservation should:

- Preserve raw input
- Record source
- Record source confidence
- Reference evidence
- Remain immutable
- Support serialization
- Allow policy reprocessing

---

# IdentityAttribute

IdentityAttribute should:

- Preserve normalized and original values
- Record presence
- Record classification
- Record identity role
- Preserve evidence
- Record normalization rule
- Record policy version
- Remain immutable

Validation should enforce attribute invariants at construction time.

---

# Phase 3 — Identity Policy

Create the IdentityPolicy abstraction only after primitive models exist.

The policy interface should define category behavior without referencing Flutter or repositories.

Suggested responsibilities:

```text
normalizeObservation()

classifyAttribute()

validateAttribute()

compareAttributes()

contributesToFingerprint()

calculateIdentityHealth()

validateProfile()
```

The exact method names may change during implementation.

The responsibilities should not.

---

# Policy Design Rule

Keep the universal IdentityPolicy contract focused.

Category-specific implementations may use private helpers or dedicated rule objects.

Avoid creating one enormous policy class.

Possible internal components:

```text
NormalizationRules
ClassificationRules
ComparisonRules
VariantRules
FingerprintRules
CompletenessRules
ConflictRules
```

---

# Phase 4 — Identity Profile Models

Suggested order:

```text
CanonicalFingerprint
        ↓
IdentityHealth
        ↓
IdentityRelationship
        ↓
CategoryExtension
        ↓
IdentityProfile
```

---

# CanonicalFingerprint

The fingerprint model should include:

- Algorithm name
- Algorithm version
- Canonical material version
- Policy version
- Fingerprint value
- Generated timestamp

Do not expose the hashing library as part of the domain contract.

---

# IdentityHealth

IdentityHealth should include:

- Completeness
- Confidence
- Evidence quality
- Conflict count
- Source diversity
- Verification status
- Warnings

Use dedicated value objects when doing so improves validation and clarity.

---

# IdentityRelationship

Identity relationships should reference profile identifiers rather than embedding complete profiles recursively.

This prevents:

- Infinite serialization
- Excessively large objects
- Circular dependencies

---

# IdentityProfile

IdentityProfile should be immutable.

Suggested fields:

- Profile identifier
- Category
- Attributes
- Fingerprint
- Health
- Relationships
- Category extension
- Provenance
- Profile version
- Schema version
- Policy version
- Status
- Timestamps

Universal role values should be derived from attributes through helper methods or a derived view.

---

# Phase 5 — Comparison Models

Suggested order:

```text
IdentityComparisonClassification
        ↓
IdentityComparisonState
        ↓
IdentityEffect
        ↓
IdentityAttributeDifference
        ↓
IdentityComparisonEvidence
        ↓
IdentityComparisonInput
        ↓
IdentityComparisonResult
```

---

# IdentityComparisonInput

Use a dedicated input object rather than passing unrelated positional parameters.

It may include:

- Left profile
- Right profile
- Identity policy
- Comparison mode
- Requested explanation depth
- Correlation identifier

---

# IdentityComparisonResult

IdentityComparisonResult should specialize the universal Atlas result and decision concepts without duplicating them unnecessarily.

Avoid storing the same information in multiple places.

For example:

- Classification belongs in the Decision.
- Execution status belongs in AtlasResult.
- Attribute differences belong in the identity-specific output.
- Findings support the Decision.
- Recommendations remain separate.

---

# Phase 6 — Identity Decision Engine

Create the Identity Decision Engine after all required models and policies are stable.

Suggested lifecycle:

```text
Receive IdentityComparisonInput
        ↓
Validate Profiles
        ↓
Validate Policy Compatibility
        ↓
Compare Universal Roles
        ↓
Compare Identity Attributes
        ↓
Apply Variant Rules
        ↓
Evaluate Missing and Conflicting Data
        ↓
Build Findings
        ↓
Build Identity Decision
        ↓
Build Identity Comparison Result
```

---

# Engine Responsibilities

The Identity Decision Engine owns:

- Profile comparison
- Policy application
- Attribute-level reasoning
- Classification
- Confidence calculation
- Finding generation
- Decision construction
- Comparison result construction

---

# Engine Non-Responsibilities

The engine must not:

- Save profiles
- Modify ownership
- Merge records
- Delete records
- Navigate screens
- Render widgets
- Show dialogs
- Call Supabase directly
- Decide UI colors
- Automatically approve destructive actions

---

# Phase 7 — Identity Analyst and Builder

The existing Atlas architecture includes:

```text
Experience
    ↓
Analyst
    ↓
Builder
    ↓
Engine
```

Preserve that pattern.

---

# IdentityAnalysisBuilder

The builder transforms engine output into a structured Atlas analysis.

It may:

- Organize findings
- Generate summaries
- Group differences
- Produce explanation sections
- Connect recommendations
- Prepare reusable analysis output

It must not change the engine's Decision.

---

# IdentityAnalyst

The analyst coordinates the identity workflow.

It may:

- Request comparisons
- Select the correct category policy
- Call the Identity Decision Engine
- Call the Identity Analysis Builder
- Return AtlasAnalysis<Identity Intelligence>

It should remain independent of Flutter screens.

---

# Phase 8 — Funko Identity Adapter

Funko should be the first category adapter because Atlas already contains Funko data and duplicate-review workflows.

The Funko adapter should map existing data into universal identity roles.

Example mapping:

```text
Category
    Funko

Maker
    Funko

Entity Anchor
    Character or figure subject

Catalog Index
    Pop number

Primary Descriptor
    Product name

Temporal Marker
    Release year when known

Release Context
    Retailer or convention release

Variant Modifier
    Chase, Glow, Metallic, Blacklight, and other factory variants
```

---

# Funko Identity Fields

Potential Funko identity inputs include:

- Product name
- Pop number
- Product line
- Series
- Character
- Variant
- Chase status
- Glow status
- Metallic status
- Blacklight status
- Exclusive retailer
- Convention information
- Sticker information
- Limited-edition information
- Factory-issued signature
- Release year
- UPC
- Manufacturer catalog ID

The policy will determine which are defining, influencing, contextual, or unknown.

---

# Sticker Rule

Sticker information requires careful policy treatment.

A sticker may indicate:

- Distribution context
- Convention context
- Shared exclusive
- Retail exclusive
- Regional release
- Packaging difference
- Replacement or aftermarket sticker

The first implementation should preserve sticker information and avoid assuming all sticker differences create separate identities.

Uncertain cases should produce variant review rather than automatic merging.

---

# Signature Rule

Differentiate:

```text
Factory-Issued Signed Edition
    Identity

Aftermarket Autograph
    Instance
```

This distinction must be explicit in the Funko policy.

---

# Phase 9 — Existing Duplicate Review Integration

Do not replace the current duplicate-review service immediately.

Use a staged migration.

---

# Migration Stage 1

Run the new Identity Engine alongside the existing duplicate logic in development.

Compare results.

Do not change the user experience yet.

---

# Migration Stage 2

Add diagnostic logging or development-only comparison summaries.

Identify disagreements between:

- Existing DuplicateReviewService
- New Identity Decision Engine

Review disagreements manually.

---

# Migration Stage 3

Use the Identity Engine to supply duplicate and possible-variant classifications.

Keep collector approval requirements.

---

# Migration Stage 4

Retire duplicated identity logic only after:

- Tests pass
- Existing behavior is preserved or intentionally improved
- Variant handling is verified
- Import safety is verified
- No destructive workflow bypasses approval

---

# Phase 10 — Persistence

Domain models should not depend directly on Supabase or Hive.

Use repository and mapper layers.

Conceptually:

```text
Domain Model
        ↕
Persistence Mapper
        ↕
Supabase or Hive Record
```

This allows persistence technology to change without rewriting the domain.

---

# Persistence Rules

1. Store schema versions.
2. Store policy versions.
3. Store fingerprint versions.
4. Preserve original observations.
5. Preserve profile history.
6. Never overwrite published profile history silently.
7. Use migrations for structural changes.
8. Avoid storing presentation-only fields in domain tables.

---

# Phase 11 — Testing Strategy

Tests should be created with each implementation phase.

---

# Unit Tests

Test:

- Normalization rules
- Attribute invariants
- Policy classification
- Fingerprint determinism
- Identity health calculations
- Attribute comparison
- Classification logic
- Confidence calculations
- Conflict handling
- Missing-data behavior

---

# Golden Identity Cases

Create category-specific identity fixtures.

Funko examples should include:

- Exact duplicate
- Common versus Chase
- Common versus Glow
- Common versus Blacklight
- Retail exclusive versus common
- Convention sticker difference
- Shared sticker difference
- Factory-signed edition
- Aftermarket autograph
- Limited edition
- Same name with different number
- Same number with different product
- Missing variant data
- Conflicting source data

---

# Determinism Test

Given identical:

- Observations
- Policy
- Policy version
- Engine version

Atlas should produce identical:

- Attributes
- Fingerprints
- Findings
- Decisions
- Comparison classifications

---

# Regression Tests

Use regression tests to protect the current duplicate-review behavior during migration.

Every bug fix should add a test case.

---

# Phase 12 — Flutter Integration

Flutter consumes analyses and results.

Flutter does not implement identity rules.

Suggested UI integration flow:

```text
Screen
    ↓
Application Service or Analyst
    ↓
Identity Analysis
    ↓
Reusable UI Components
```

---

# UI Responsibilities

Flutter may:

- Display comparison classifications
- Display findings
- Display confidence
- Display evidence
- Display warnings
- Offer review actions
- Request collector approval

Flutter may not:

- Generate fingerprints
- Classify variants
- Decide identity equality
- Merge automatically
- Reimplement policy rules

---

# Implementation Checkpoints

Use small, clean checkpoints.

---

## Checkpoint 1

Universal Atlas result models implemented.

Run:

```text
flutter analyze
```

Add unit tests.

---

## Checkpoint 2

Identity primitive enums and observation model implemented.

Run:

```text
flutter analyze
```

Add unit tests.

---

## Checkpoint 3

IdentityAttribute implemented with invariants.

Run:

```text
flutter analyze
```

Add unit tests.

---

## Checkpoint 4

IdentityPolicy contract implemented.

Run:

```text
flutter analyze
```

Add mock policy tests.

---

## Checkpoint 5

IdentityProfile, fingerprint, health, and relationships implemented.

Run:

```text
flutter analyze
```

Add serialization and determinism tests.

---

## Checkpoint 6

Comparison models implemented.

Run:

```text
flutter analyze
```

Add attribute-difference tests.

---

## Checkpoint 7

Identity Decision Engine implemented.

Run:

```text
flutter analyze
```

Add golden identity cases.

---

## Checkpoint 8

Identity Analyst and Builder implemented.

Run:

```text
flutter analyze
```

Add analysis tests.

---

## Checkpoint 9

Funko Identity Adapter and Policy implemented.

Run:

```text
flutter analyze
```

Add Funko identity fixtures.

---

## Checkpoint 10

Parallel duplicate-review evaluation implemented.

Run:

```text
flutter analyze
```

Verify existing workflows.

---

# First Coding Milestone

The first coding milestone should not attempt to build the entire Identity Engine.

Begin with:

```text
AtlasResultStatus
AtlasExecutionMetadata
AtlasResult<T>
```

Then run analysis and tests.

This gives every later engine a trusted universal result foundation.

---

# Definition of Done

Identity Intelligence v1 is complete when:

- Universal Atlas contracts exist in Dart.
- Identity observations are preserved.
- Identity attributes are normalized and classified.
- Funko identity rules live in a dedicated policy.
- Profiles are immutable and versioned.
- Fingerprints are deterministic and versioned.
- Comparisons return structured results.
- Findings explain every important difference.
- Duplicate and variant decisions are safe.
- No destructive action occurs automatically.
- Existing duplicate workflows are migrated safely.
- Flutter contains no duplicated identity logic.
- Tests cover known Funko identity cases.
- `flutter analyze` reports no issues.

---

# Implementation Promise

Architecture comes first.

Contracts come second.

Tests protect both.

Screens consume the result.

Atlas Intelligence must remain reusable long after the current interface changes.