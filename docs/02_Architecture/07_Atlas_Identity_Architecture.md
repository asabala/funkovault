# Atlas Identity Architecture
### Version 1.0
### "Understanding What a Collectible Was Created to Be"

---

# Purpose

Identity Intelligence is the first implementation of the Atlas Decision Architecture.

Its responsibility is to determine what a collectible was intentionally created to be.

Identity Intelligence supports:

- Duplicate review
- Variant detection
- Catalog matching
- Import safety
- Market matching
- Set completion
- Recommendations
- Authentication workflows
- Collector intelligence

Identity must remain separate from ownership, condition, grading, market value, and collection placement.

---

# Identity Definition

Identity is:

> The immutable, factory-level description of what a collectible was intentionally created to be.

Identity answers:

- What is this product?
- Who created it?
- What catalog entry does it belong to?
- Which release or edition is it?
- Is it a factory-created variant?
- How is it related to other products?

Identity does not answer:

- Who owns it?
- What condition is it in?
- What was paid for it?
- Where is it stored?
- What is it worth?
- Is this physical copy signed or graded?

Those responsibilities belong to other Atlas domains.

---

# Core Domain Separation

Atlas separates four major domains:

```text
Identity
    ↓
Instance
    ↓
Ownership
    ↓
Collection
```

Intelligence operates across these domains without merging their responsibilities.

---

# Identity

Identity describes the product as intentionally created.

Examples:

- Funko Pop Spider-Man #1234
- Glow Chase factory variant
- First Edition Pokémon card
- Comic issue with a specific variant cover
- Coin with a particular year and mint mark

---

# Instance

Instance represents one physical copy of an identity.

Instance may include:

- Condition
- Damage
- Grading
- Certification
- Aftermarket autograph
- Authentication
- Restoration
- Unique serial number

Multiple physical instances may share one identity.

---

# Ownership

Ownership represents the relationship between a collector and an instance.

Ownership may include:

- Owner
- Purchase date
- Purchase price
- Seller
- Acquisition method
- Storage location
- Personal notes
- Trade status

---

# Collection

Collection is an aggregate of owned or tracked instances.

Collection may provide:

- Vault totals
- Set completion
- Portfolio views
- Cleanup opportunities
- Collector DNA
- Collection health

Collection is not itself an identity attribute.

---

# Identity Hierarchy

Atlas uses a layered identity hierarchy.

```text
Entity
    ↓
Product Family
    ↓
Catalog Product
    ↓
Edition or Release
    ↓
Factory Variant
    ↓
Physical Instance
```

---

# Entity

The person, character, object, property, franchise, team, or subject represented by the collectible.

Examples:

- Spider-Man
- Pikachu
- Michael Jordan
- Batman
- Ford Mustang

---

# Product Family

The general product line or collectible format.

Examples:

- Funko Pop!
- Pokémon Trading Card Game
- Comic Book
- Hot Wheels
- Sports Card
- Coin

---

# Catalog Product

The primary cataloged product.

Examples:

- Spider-Man #1234
- Charizard 4/102
- Amazing Spider-Man #300
- 1964 Kennedy Half Dollar

---

# Edition or Release

A specific release context for the catalog product.

Examples:

- First Edition
- 2025 Retail Release
- Convention Release
- Regional Release
- Reprint
- Second Printing

---

# Factory Variant

A manufacturer-intended variation.

Examples:

- Chase
- Glow
- Metallic
- Blacklight
- Variant Cover
- Alternate Art
- Different Mint Mark
- Factory-Issued Signed Edition

---

# Physical Instance

One real-world copy of the identity.

Examples:

- Arthur's graded copy
- A damaged copy
- An aftermarket-signed copy
- A sealed copy
- A restored copy

---

# Universal Identity Roles

Every collectible category maps its data into universal identity roles.

The standard roles are:

- Category
- Maker
- Entity Anchor
- Catalog Index
- Primary Descriptor
- Temporal Marker
- Release Context
- Variant Modifier

These roles provide a shared identity language across collectible categories.

---

# Category

The broad collectible category.

Examples:

- Funko
- Comics
- Coins
- Pokémon
- Hot Wheels

---

# Maker

The manufacturer, publisher, mint, brand, or issuing organization.

Examples:

- Funko
- Marvel Comics
- The Pokémon Company
- United States Mint
- Mattel

---

# Entity Anchor

The central subject represented by the collectible.

Examples:

- Spider-Man
- Pikachu
- Michael Jordan
- Darth Vader

---

# Catalog Index

The catalog identifier assigned to the product.

Examples:

- 1234
- 4/102
- Issue 300
- Set Number 75257

---

# Primary Descriptor

The primary product name or description.

Examples:

- Spider-Man
- Charizard
- Amazing Spider-Man
- Kennedy Half Dollar

---

# Temporal Marker

A date, year, era, printing, or generation that helps establish identity.

Examples:

- 2025
- First Edition
- 1964
- Second Printing

---

# Release Context

The commercial, regional, event, or distribution context of the release.

Examples:

- SDCC
- Target Exclusive
- Japanese Release
- Retail Edition
- Convention Edition

---

# Variant Modifier

A factory-created characteristic that distinguishes the product from its base identity.

Examples:

- Chase
- Glow
- Metallic
- Blacklight
- Variant Cover
- Alternate Art

---

# Identity Presence States

Every identity role or attribute must distinguish among:

- Known
- Unknown
- Not Applicable
- Conflicting

---

# Known

The value is present and trusted enough to use.

---

# Unknown

The value may exist, but Atlas does not currently know it.

Unknown must never be represented by invented placeholders.

---

# Not Applicable

The attribute does not apply to this product category or identity.

---

# Conflicting

Multiple credible observations disagree.

Conflicts must be preserved and surfaced rather than silently resolved.

---

# Attribute Classification

Each category policy classifies attributes according to their identity effect.

The standard classifications are:

- Defining
- Influencing
- Contextual
- Instance-Only
- Unknown

---

# Defining Attributes

Defining attributes directly contribute to canonical identity.

A difference may indicate a different product identity or factory variant.

Examples:

- Chase
- First Edition
- Variant Cover
- Mint Mark
- Catalog Number
- Alternate Art

---

# Influencing Attributes

Influencing attributes affect identity comparison but may require context.

Examples:

- Retail-exclusive sticker
- Convention sticker
- Production code
- Regional packaging
- Distribution channel

---

# Contextual Attributes

Contextual attributes provide useful information but normally do not define identity.

Examples:

- Story arc
- Artist
- Franchise
- Team
- Character biography

---

# Instance-Only Attributes

Instance-only attributes describe a physical copy rather than the factory identity.

Examples:

- Condition
- Grade
- Aftermarket autograph
- Damage
- Storage
- Purchase price

Instance-only attributes never contribute to the canonical identity fingerprint.

---

# Unknown Classification

Unknown classification means Atlas has not yet determined how the attribute affects identity.

Unknown attributes should be preserved for future policy improvements.

---

# Identity Observations

Raw source data enters Atlas as Identity Observations.

An observation may come from:

- User input
- Barcode
- OCR
- Image recognition
- Manufacturer catalog
- CSV import
- Marketplace listing
- External API
- Internal Atlas dataset

Observations are not automatically trusted facts.

They must be normalized and evaluated before becoming Identity Attributes.

---

# Observation Pipeline

```text
Raw Source
    ↓
Identity Observation
    ↓
Normalization
    ↓
Policy Evaluation
    ↓
Identity Attribute
```

Multiple observations may support one identity attribute.

No original observation should be discarded.

---

# Identity Adapters

Each collectible category uses an Identity Adapter.

An adapter converts category-specific source data into Atlas identity concepts.

Examples:

- Funko Identity Adapter
- Comic Identity Adapter
- Pokémon Identity Adapter
- Coin Identity Adapter
- Hot Wheels Identity Adapter

---

# Adapter Responsibilities

Every adapter must:

1. Accept category-specific source data.
2. Preserve original values.
3. Normalize values.
4. Map values to universal identity roles.
5. Apply category policy.
6. Classify identity significance.
7. Report missing and conflicting information.
8. Produce a structured Identity Profile.
9. Generate deterministic canonical material.
10. Remain independent of Flutter and presentation.

---

# Adapter Pipeline

```text
Raw Category Data
        ↓
Normalize
        ↓
Classify Roles
        ↓
Apply Identity Policy
        ↓
Produce Identity Profile
```

---

# Category Policies

Identity behavior belongs inside category policies.

The core Identity Engine must not contain category-specific rules.

Policies define:

- Required identity roles
- Attribute significance
- Normalization rules
- Variant rules
- Comparison weights
- Conflict handling
- Completeness rules
- Fingerprint contribution
- Relationship behavior

---

# Identity Policy Rule

```text
Category-specific knowledge belongs in policies.

Universal reasoning belongs in engines.
```

---

# Category Extensions

Category-specific information is preserved through versioned extensions.

Conceptually:

```text
CategoryExtension

Category
Schema Version
Normalized Fields
Original Fields
Metadata
```

Examples:

A Funko extension may contain:

- Pop number
- Chase status
- Exclusive retailer
- Sticker information
- Finish
- Product line

A comic extension may contain:

- Issue number
- Printing
- Cover variant
- Publisher
- Volume
- Artist

A coin extension may contain:

- Denomination
- Mint mark
- Year
- Composition
- Country

Category extensions never replace universal identity roles.

They supplement them.

---

# Identity Profile

IdentityProfile is the canonical, immutable representation of one product identity.

The profile is built from validated Identity Attributes.

It may include:

- Profile identifier
- Category
- Attributes
- Derived universal roles
- Canonical fingerprint
- Identity health
- Relationships
- Provenance
- Version metadata
- Category extension

---

# Universal Roles as Derived Views

The source of truth is the profile's Identity Attributes.

Universal role values are derived from those attributes.

They may be cached or indexed for performance, but they should not become a competing source of truth.

---

# Canonical Fingerprint

Every published Identity Profile receives a deterministic fingerprint.

Conceptually:

```text
CanonicalFingerprint

Algorithm
Version
Fingerprint
```

The fingerprint must be generated only from policy-approved identity attributes.

It must exclude:

- Ownership
- Condition
- Market value
- Storage
- Instance-only data

Fingerprint algorithms must be versioned independently from the profile schema.

---

# Identity Health

Identity completeness should not be represented by one number alone.

Atlas uses Identity Health.

Conceptually:

```text
IdentityHealth

Completeness
Confidence
Evidence Quality
Conflict Count
Source Diversity
Verification Status
```

---

# Completeness

Measures whether expected identity information is present.

---

# Confidence

Measures certainty in the resolved identity information.

---

# Evidence Quality

Measures the strength and reliability of supporting evidence.

---

# Conflict Count

Records unresolved disagreements among observations.

---

# Source Diversity

Measures whether identity is supported by multiple independent sources.

---

# Verification Status

Examples:

- Unverified
- Partially Verified
- Verified
- Manufacturer Verified
- Conflicting
- Requires Review

---

# Identity Relationships

Identity Profiles may have relationships to other identities.

Relationship types may include:

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

Relationships support:

- Variant browsing
- Set completion
- Recommendations
- Timeline intelligence
- Catalog navigation
- Market matching

---

# Identity Comparison

The Identity Engine compares two Identity Profiles.

It never returns only:

```text
true
false
```

It returns a structured Identity Comparison Result.

---

# Comparison Classifications

Suggested classifications include:

- Exact Identity
- Same Base Product, Different Factory Variant
- Related Product
- Different Identity
- Insufficient Data
- Conflicting Data

---

# Comparison Output

A comparison should include:

- Classification
- Confidence
- Matched roles
- Different roles
- Missing roles
- Conflicting roles
- Attribute differences
- Comparison evidence
- Decision
- Explanation
- Recommended review state

---

# Comparison Evidence

Comparison Evidence records why two profiles were considered equal, related, or different.

It may contain:

- Matched observations
- Differing observations
- Supporting sources
- Evidence confidence
- Policy rules applied
- Attribute-level reasoning

---

# Decision Separation

Identity comparison produces reasoning before action.

```text
Comparison
    ↓
Decision
    ↓
Recommendation
    ↓
Experience Action
```

A Decision is platform-independent.

A Recommendation provides guidance.

The Experience chooses how to present or act on that guidance.

---

# Duplicate Safety

Identity Intelligence must never automatically merge or delete collectibles solely because names and catalog numbers match.

Examples of identity differences that must be reviewed include:

- Chase
- Glow
- Metallic
- Blacklight
- Sticker differences
- Retail exclusives
- Convention exclusives
- Factory signatures
- Limited editions
- Alternate art
- Variant covers
- Regional releases
- Printing differences
- Mint marks

Atlas may identify possible duplicates.

The collector remains in control.

---

# Identity Guarantees

The Identity Architecture guarantees:

1. Deterministic identity fingerprints.
2. Immutable published profiles.
3. Category-neutral core reasoning.
4. Deterministic adapters whenever possible.
5. Separation from ownership, value, grading, and condition.
6. Complete source traceability.
7. Explicit uncertainty.
8. Structured comparison.
9. Explainable decisions.
10. Versioned schema evolution.
11. Preservation of conflicting evidence.
12. No automatic destructive action.

---

# Identity Intelligence Pipeline

```text
Category Source
        ↓
Identity Observation
        ↓
Identity Adapter
        ↓
Normalization
        ↓
Identity Policy
        ↓
Identity Attributes
        ↓
Identity Profile
        ↓
Identity Decision Engine
        ↓
Identity Comparison Result
        ↓
Identity Analysis
        ↓
Recommendation
        ↓
Collector Experience
```

---

# Dependency Rules

Identity components depend only downward.

```text
Experience
    ↓
Identity Analysis
    ↓
Recommendations
    ↓
Identity Decisions
    ↓
Identity Profiles
    ↓
Identity Attributes
    ↓
Identity Observations
```

No screen may implement identity comparison.

No widget may generate canonical identity keys.

No repository may invent identity rules.

No category rule belongs directly inside the universal Identity Engine.

---

# The Identity Promise

Atlas will not treat similar-looking collectibles as identical without evidence.

Atlas will preserve uncertainty.

Atlas will explain differences.

Atlas will protect collectors from unsafe merges.

Atlas will continuously improve identity knowledge without rewriting the platform.

---

# The Identity North Star

Identity is not a name.

Identity is not a barcode.

Identity is not a database row.

Identity is the explainable result of observations, evidence, policy, normalization, and reasoning.

Build identity carefully.

Every future Atlas intelligence capability depends on it.