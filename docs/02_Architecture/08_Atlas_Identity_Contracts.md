# Atlas Identity Contracts
### Version 1.0
### "The Core Contracts of Identity Intelligence"

---

# Purpose

This document defines the conceptual contracts used by Atlas Identity Intelligence.

These contracts remain independent of:

- Flutter
- Supabase
- Hive
- Screens
- Widgets
- Navigation
- Specific collectible categories

The contracts are written conceptually first.

Their Dart implementations must preserve the same responsibilities and boundaries.

---

# Contract Dependency Order

```text
IdentityObservation
        ↓
IdentityAttribute
        ↓
IdentityPolicy
        ↓
IdentityProfile
        ↓
IdentityComparisonEvidence
        ↓
IdentityComparisonResult
```

---

# 1. IdentityObservation

## Purpose

IdentityObservation represents one raw claim about a collectible.

An observation is not automatically trusted truth.

It preserves what a source reported before normalization or policy evaluation.

---

## Conceptual Structure

```text
IdentityObservation

Observation ID
Attribute Key
Original Value
Source
Source Type
Observed At
Confidence
Evidence
Metadata
Schema Version
```

---

## Required Information

Every observation should identify:

- What was observed
- Where it came from
- When it was observed
- Which attribute it may support
- How confident the source is
- Which evidence is available

---

## Source Types

Examples:

- User Input
- Manufacturer Catalog
- Barcode
- OCR
- Image Recognition
- CSV Import
- Marketplace Listing
- External API
- Atlas Internal Dataset

---

## Observation Principles

An IdentityObservation must be:

- Immutable
- Serializable
- Traceable
- Source-preserving
- Reprocessable
- Independent of policy conclusions

---

## Observation Rules

1. Original values are never overwritten.
2. Conflicting observations may coexist.
3. An observation does not determine identity significance.
4. An observation may support more than one normalization attempt.
5. Policy changes may reprocess old observations.

---

# 2. IdentityAttribute

## Purpose

IdentityAttribute is the smallest trusted unit of identity information.

It represents a normalized and policy-evaluated identity fact.

---

## Conceptual Structure

```text
IdentityAttribute

Key
Display Label
Role
Original Value
Normalized Value
Presence
Classification
Source Summary
Confidence
Evidence
Normalization Rule
Policy Version
Aliases
Metadata
Schema Version
```

---

## Required Fields

An IdentityAttribute should include:

- Key
- Role
- Original value or source reference
- Normalized value when known
- Presence state
- Classification
- Source information
- Confidence
- Policy version
- Schema version

---

## Optional Fields

An IdentityAttribute may include:

- Display label
- Evidence
- Normalization rule
- Aliases
- Category metadata
- Comparison hints

---

## Identity Roles

Supported universal roles:

- Category
- Maker
- Entity Anchor
- Catalog Index
- Primary Descriptor
- Temporal Marker
- Release Context
- Variant Modifier

---

## Presence States

Supported presence states:

- Known
- Unknown
- Not Applicable
- Conflicting

---

## Classifications

Supported classifications:

- Defining
- Influencing
- Contextual
- Instance-Only
- Unknown

---

## Attribute Invariants

1. Known attributes require a normalized value.
2. Unknown attributes must not invent placeholder values.
3. Not Applicable must remain distinct from Unknown.
4. Conflicting attributes must preserve all credible observations.
5. Confidence must remain within the supported range.
6. Original values must remain available.
7. Instance-only attributes never contribute to canonical identity.
8. Comparison uses normalized values unless a policy explicitly states otherwise.
9. Normalization rules and policy versions must be traceable.
10. Attributes are immutable after publication.

---

## Attribute Equality

Atlas recognizes three forms of equality.

### Record Equality

All stored fields are equal.

### Semantic Equality

The normalized values and meanings are equal.

### Comparison Equality

The current Identity Policy determines that the attributes should be treated as equivalent for a specific comparison.

Comparison equality is policy-driven.

---

# 3. IdentityPolicy

## Purpose

IdentityPolicy defines how one collectible category interprets identity information.

Policies contain category knowledge.

The universal Identity Engine consumes policies but does not contain their rules.

---

## Conceptual Structure

```text
IdentityPolicy

Policy ID
Category
Policy Version
Schema Version
Required Roles
Optional Roles
Normalization Rules
Classification Rules
Comparison Rules
Variant Rules
Fingerprint Rules
Completeness Rules
Conflict Rules
Relationship Rules
Metadata
```

---

## Policy Responsibilities

An IdentityPolicy must define:

- Which roles are required
- Which attributes are identity-defining
- Which attributes influence comparison
- Which attributes are contextual
- Which attributes are instance-only
- How raw values are normalized
- How variants are recognized
- How conflicts are handled
- Which values contribute to fingerprints
- How comparison confidence is calculated
- How identity completeness is evaluated

---

## Policy Operations

Conceptually, a policy may provide operations such as:

```text
Normalize Observation

Classify Attribute

Resolve Presence

Determine Fingerprint Contribution

Compare Attributes

Calculate Identity Health

Identify Variant Difference

Validate Profile

Generate Canonical Material
```

---

## Policy Rules

1. Policies must be versioned.
2. Policies must be deterministic whenever possible.
3. Policies must not depend on Flutter.
4. Policies must not save data.
5. Policies must not perform navigation.
6. Policies must preserve unknown and conflicting information.
7. Policy changes must not silently mutate published profiles.
8. Re-evaluation should create a new profile version.

---

# 4. CanonicalFingerprint

## Purpose

CanonicalFingerprint provides a deterministic identifier derived from policy-approved identity information.

---

## Conceptual Structure

```text
CanonicalFingerprint

Algorithm
Algorithm Version
Policy Version
Canonical Material Version
Fingerprint
Generated At
```

---

## Fingerprint Rules

1. Only identity-approved attributes may contribute.
2. Instance, ownership, condition, and value data are excluded.
3. Attribute ordering must be deterministic.
4. Normalization must occur before fingerprint generation.
5. Algorithm and canonical-material versions must be stored.
6. A fingerprint is not a replacement for the profile.
7. Different fingerprint versions may coexist.

---

# 5. IdentityHealth

## Purpose

IdentityHealth communicates the quality and completeness of an Identity Profile.

---

## Conceptual Structure

```text
IdentityHealth

Completeness
Confidence
Evidence Quality
Conflict Count
Source Diversity
Verification Status
Warnings
```

---

## Verification Status

Suggested values:

- Unverified
- Partially Verified
- Verified
- Manufacturer Verified
- Conflicting
- Requires Review

---

## Health Rules

IdentityHealth should never hide missing information behind a single score.

The complete health breakdown should remain available for explanation and review.

---

# 6. IdentityRelationship

## Purpose

IdentityRelationship connects one Identity Profile to another.

---

## Conceptual Structure

```text
IdentityRelationship

Relationship ID
Source Profile ID
Target Profile ID
Relationship Type
Confidence
Evidence
Policy Version
Metadata
```

---

## Relationship Types

Suggested relationship types:

- Parent
- Child
- Variant Of
- Reprint Of
- Regional Release Of
- Equivalent Catalog Identity
- Same Entity
- Same Product Family
- Successor
- Predecessor

---

# 7. IdentityProfile

## Purpose

IdentityProfile is the canonical, immutable representation of a collectible product identity.

It is built from validated Identity Attributes.

---

## Conceptual Structure

```text
IdentityProfile

Profile ID
Category
Attributes
Derived Universal Roles
Canonical Fingerprint
Identity Health
Relationships
Category Extension
Provenance
Created At
Profile Version
Schema Version
Policy Version
Status
```

---

## Source of Truth

The IdentityAttribute collection is the source of truth.

Universal role views are derived from the attributes.

Cached role views must never become a competing authority.

---

## Profile Status

Suggested values:

- Draft
- Published
- Superseded
- Conflicting
- Requires Review
- Archived

---

## Profile Invariants

1. Published profiles are immutable.
2. Profile changes create a new version.
3. A profile belongs to one collectible category.
4. Every defining value must be represented by an IdentityAttribute.
5. Original observations remain traceable.
6. Fingerprints must identify their algorithm and version.
7. Identity-only data is permitted.
8. Ownership, value, condition, and storage are excluded.
9. Universal roles are derived from attributes.
10. Conflicts remain visible.
11. Policy version is always recorded.
12. Category extensions must be versioned.

---

# 8. IdentityComparisonEvidence

## Purpose

IdentityComparisonEvidence explains how two Identity Profiles were compared.

It preserves evidence supporting both similarities and differences.

---

## Conceptual Structure

```text
IdentityComparisonEvidence

Matched Evidence
Differing Evidence
Missing Evidence
Conflicting Evidence
Supporting Sources
Policy Rules Applied
Confidence
Metadata
```

---

## Evidence Responsibilities

Comparison evidence should answer:

- Which attributes matched?
- Which attributes differed?
- Which required values were missing?
- Which observations conflicted?
- Which policy rules were applied?
- Which sources supported the result?
- How strong was the supporting evidence?

---

# 9. IdentityAttributeDifference

## Purpose

IdentityAttributeDifference records one attribute-level comparison.

---

## Conceptual Structure

```text
IdentityAttributeDifference

Attribute Key
Role
Left Value
Right Value
Comparison State
Identity Effect
Confidence
Evidence
Explanation
```

---

## Comparison States

Suggested states:

- Match
- Equivalent
- Different
- Missing Left
- Missing Right
- Missing Both
- Conflicting
- Not Comparable
- Not Applicable

---

## Identity Effects

Suggested effects:

- No Identity Effect
- Contextual Difference
- Influencing Difference
- Defining Difference
- Factory Variant Difference
- Insufficient Information
- Requires Review

---

# 10. IdentityComparisonResult

## Purpose

IdentityComparisonResult is the structured output of the Identity Decision Engine.

It specializes the universal Atlas decision and result contracts.

---

## Conceptual Structure

```text
IdentityComparisonResult

Result Metadata
Left Profile Reference
Right Profile Reference
Classification
Confidence
Attribute Differences
Matched Roles
Different Roles
Missing Roles
Conflicting Roles
Comparison Evidence
Findings
Decision
Explanation
Warnings
Recommended Review State
```

---

## Comparison Classifications

Supported classifications should include:

- Exact Identity
- Same Base Product, Different Factory Variant
- Related Product
- Different Identity
- Insufficient Data
- Conflicting Data

---

## Recommended Review States

Suggested values:

- No Review Required
- Safe Match
- Review Suggested
- Variant Review Required
- Conflict Review Required
- Do Not Merge
- Insufficient Data

---

## Comparison Invariants

1. A comparison never returns only a Boolean.
2. Classification must be present.
3. Confidence never replaces evidence.
4. All defining differences must be reported.
5. Missing information must remain explicit.
6. Conflicting information must remain explicit.
7. Destructive actions are never automatic.
8. The comparison must identify the policy version used.
9. The result must remain platform-independent.
10. Explanations must be understandable by humans and machines.

---

# Example Identity Comparison

```text
Classification:
Same Base Product, Different Factory Variant

Confidence:
0.97

Matched Roles:
Category
Maker
Entity Anchor
Catalog Index
Primary Descriptor

Different Roles:
Variant Modifier
Release Context

Findings:
Catalog number matches.
Character matches.
Glow finish differs.
Convention release differs.

Decision:
These profiles represent different factory variants of the same base product.

Recommended Review State:
Do Not Merge
```

---

# Serialization Principles

All Identity contracts should be:

- Serializable
- Immutable
- Versioned
- Forward-compatible where practical
- Safe for local storage
- Safe for API transport
- Independent of presentation

Unknown fields should be handled safely during schema evolution.

---

# Contract Evolution

Every contract should carry a schema version.

Policy behavior should carry a policy version.

Fingerprint behavior should carry an algorithm version.

A change to one version does not automatically require changing every other version.

---

# Identity Contract Promise

These contracts ensure that Atlas can understand new collectible categories without changing its universal intelligence foundation.

Adapters teach Atlas a category.

Policies teach Atlas the rules.

Profiles preserve identity.

Engines produce decisions.

Collectors remain in control.