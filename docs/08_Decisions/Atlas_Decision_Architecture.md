# Atlas Decision Architecture
### Version 1.0
### "From Observation to Intelligence"

---

# Purpose

Atlas is **not** a collection of AI features.

Atlas is a collection of **Decision Engines**.

Every capability within Atlas—Identity, Market, Portfolio, Collector DNA, Recommendations, Risk, Authentication, Timeline, and future AI systems—follows the exact same decision pipeline.

The goal is consistency.

Every decision should be:

- Explainable
- Deterministic (when appropriate)
- Versioned
- Auditable
- Reproducible
- Category-neutral
- Independent of Flutter, UI, or platform

---

# The Atlas Intelligence Pipeline

```
                 OBSERVATIONS
                       │
                       ▼
              Normalization Layer
                       │
                       ▼
              Identity Attributes
                       │
                       ▼
               Category Policies
                       │
                       ▼
               Identity Profile
                       │
                       ▼
               Decision Engine
                       │
                       ▼
                  Decision
                       │
                       ▼
                  Analysis
                       │
                       ▼
                 User Experience
```

---

# Layer 1 — Observation

Observations are the raw facts collected by Atlas.

Observations are **not trusted truth**.

Examples include:

- Barcode scans
- OCR
- Image recognition
- CSV imports
- Manufacturer catalogs
- External APIs
- User input
- Marketplace listings
- Voice input
- Future sensors

Multiple observations may describe the same fact.

Example:

```
OCR
    "Metalic"

Manufacturer Catalog
    "Metallic"

Barcode Lookup
    "Metallic"
```

Atlas preserves every observation.

Nothing is discarded.

---

# Layer 2 — Normalization

Normalization converts observations into standardized values.

Examples:

```
#010
Pop No. 10
10
```

becomes

```
10
```

Normalization is:

- Deterministic
- Versioned
- Category-aware

Normalization never destroys the original observation.

---

# Layer 3 — Identity Attributes

Normalized observations become trusted Identity Attributes.

Each attribute includes:

- normalized value
- original value
- identity role
- identity scope
- significance
- confidence
- source
- provenance
- evidence
- policy version

Identity Attributes are the smallest trusted facts within Atlas.

---

# Layer 4 — Category Policies

Category Policies define how a collectible category behaves.

Policies determine:

- required attributes
- normalization rules
- identity significance
- comparison rules
- variant rules
- hierarchy behavior
- completeness requirements

The Decision Engine never contains category-specific rules.

Instead:

```
Funko Policy

Comic Policy

Pokemon Policy

Coin Policy

LEGO Policy

Hot Wheels Policy
```

all implement the same contract.

---

# Layer 5 — Identity Profile

IdentityProfile represents the canonical product identity.

It contains validated Identity Attributes.

IdentityProfile never contains:

- owner
- condition
- purchase history
- value
- market data
- collection placement

Identity represents only:

> What product was intentionally created?

IdentityProfile is immutable.

Corrections produce new profile versions.

---

# Layer 6 — Decision Engine

The Decision Engine is the heart of Atlas Intelligence.

Every engine receives trusted inputs.

Every engine returns structured decisions.

Examples:

```
Identity Decision Engine

Market Decision Engine

Recommendation Decision Engine

Portfolio Decision Engine

Collector DNA Engine

Risk Engine

Authentication Engine
```

Decision Engines never return:

```
true

false
```

They always return structured reasoning.

---

# Layer 7 — Decision

A Decision is Atlas's conclusion.

Example:

```
Classification

Same Product

Different Factory Variant

Confidence

96%

Evidence

Manufacturer Catalog

HobbyDB

OCR

Reason

Variant Finish differs.

Release Context differs.

Catalog Number matches.

Character matches.
```

The Decision is platform-independent.

It contains no UI.

It contains no Flutter.

It contains no navigation.

---

# Layer 8 — Analysis

Analysis transforms Decisions into user-facing intelligence.

Examples:

```
Duplicate Review

Collector DNA

Vault Health

Market Summary

Recommendations

Timeline

Portfolio Insights
```

Multiple Decisions may contribute to one Analysis.

---

# Layer 9 — Experience

Experiences consume Analyses.

Examples:

```
Flutter

Web

Desktop

Voice

Watch

API

Future Platforms
```

Experiences never implement business rules.

They present Analysis.

---

# The Atlas Rule

Every capability follows exactly the same pipeline.

```
Observation

↓

Normalization

↓

Attributes

↓

Policy

↓

Profile

↓

Decision Engine

↓

Decision

↓

Analysis

↓

Experience
```

Nothing skips a layer.

Nothing reaches around another layer.

---

# Architecture Principles

## 1. Preserve Truth

Never discard original observations.

Always preserve source evidence.

---

## 2. Normalize Once

Normalize data one time.

Reuse normalized values everywhere.

---

## 3. Trust Policies

Category behavior belongs inside Policies.

Never hardcode category logic into engines.

---

## 4. Engines Produce Decisions

Decision Engines answer questions.

They do not build screens.

They do not navigate.

They do not display widgets.

---

## 5. Analyses Tell Stories

Analyses combine multiple Decisions into meaningful intelligence.

---

## 6. Experiences Stay Thin

Flutter should present information.

It should never become the source of truth.

---

# Decision Hierarchy

Not every Decision Engine compares two objects.

Instead:

```
Observation

↓

Decision
```

Comparison is simply one specialization.

Examples:

```
Barcode Scan

↓

Identity Decision

CSV Import

↓

Merge Decision

Market Update

↓

Pricing Decision

Vault Scan

↓

Health Decision

User Behavior

↓

Collector DNA Decision
```

The output is always a Decision.

---

# Why This Architecture Exists

Atlas is not being designed around today's features.

Atlas is being designed around tomorrow's intelligence.

Every new capability should fit naturally into this architecture without requiring rewrites.

Identity Intelligence is simply the first implementation of the Atlas Decision Architecture.

The same framework will later power:

- Identity Intelligence
- Collector DNA
- Market Intelligence
- Recommendation Intelligence
- Portfolio Intelligence
- Timeline Intelligence
- Authentication Intelligence
- Risk Intelligence
- Atlas Voice
- Future AI capabilities

---

# The Atlas Promise

Atlas does not guess.

Atlas observes.

Atlas normalizes.

Atlas reasons.

Atlas explains.

Then Atlas helps collectors make better decisions.

---

# The Atlas North Star

> Build once.
>
> Evolve forever.
>
> Every decision should become reusable intelligence.