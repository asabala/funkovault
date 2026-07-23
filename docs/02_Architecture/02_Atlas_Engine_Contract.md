# Atlas Engine Contract
### Version 1.0
### "The Universal Contract for Atlas Intelligence"

---

# Purpose

Every capability within Atlas is built from Engines.

An Engine is an isolated unit of responsibility that transforms trusted inputs into structured outputs.

Engines are reusable.

Engines are explainable.

Engines are composable.

Every future capability inside Atlas should begin by identifying the Engine responsible for the work.

---

# The Atlas Engine Philosophy

Engines do not exist to create screens.

Engines do not exist to return widgets.

Engines do not exist to store data.

Engines exist to transform information into knowledge.

Every Engine should answer one question well.

Nothing more.

---

# Universal Engine Lifecycle

Every Atlas Engine follows the same execution lifecycle.

```
Receive Input

↓

Validate

↓

Prepare Context

↓

Execute

↓

Post-Process

↓

Build Result

↓

Return Output
```

No Engine should skip a stage.

---

# Engine Responsibilities

Every Engine must define:

## Input

What information is required?

Examples:

- Identity Profile
- Market History
- Image
- CSV
- Barcode
- OCR Result

---

## Validation

Before execution, every Engine validates its inputs.

Invalid input never reaches execution.

Validation failures should produce structured errors rather than exceptions whenever possible.

---

## Context Preparation

An Engine may prepare additional context before execution.

Examples include:

- Loading policies
- Loading cached information
- Normalizing values
- Building lookup tables
- Loading relationships

Preparation should not modify the original input.

---

## Execution

Execution is where the Engine performs its primary responsibility.

Examples:

Identity Engine

- Compare identities

Market Engine

- Analyze pricing history

OCR Engine

- Extract text

Recommendation Engine

- Generate recommendations

Execution should remain focused on one responsibility.

---

## Post-Processing

Execution results may require additional refinement.

Examples include:

- Ranking
- Filtering
- Aggregation
- Confidence calculation
- Explanation generation

---

## Result Construction

Every Engine returns a structured Result.

Engines never return UI.

Engines never return widgets.

Engines never return presentation objects.

---

# AtlasResult

Every Engine returns an AtlasResult.

Conceptually:

```
AtlasResult<T>

Engine

Version

Output

Warnings

Metadata
```

Specialized engines may extend AtlasResult while preserving the same structure.

Examples:

- DecisionResult
- NormalizationResult
- OCRResult
- RecommendationResult

---

# Engine Principles

## 1. Single Responsibility

Every Engine performs exactly one analytical responsibility.

If an Engine begins solving unrelated problems, split it.

---

## 2. Deterministic Whenever Possible

Given identical inputs, policies, and versions, an Engine should produce identical outputs.

Deterministic behavior builds trust.

---

## 3. Explainable

Every significant output should be explainable.

The Engine should be capable of answering:

"Why was this produced?"

---

## 4. Evidence Driven

Confidence should never exist without evidence.

Evidence should accompany conclusions whenever practical.

---

## 5. Independent

Engines never depend on:

- Flutter
- Widgets
- UI
- Navigation
- Presentation

Business intelligence belongs inside Engines.

---

## 6. Versioned

Every Engine maintains:

- Engine Version
- Schema Version
- Policy Version

Changes should be traceable.

---

## 7. Testable

Every Engine should be independently testable.

No Engine should require a screen to execute.

---

## 8. Reusable

An Engine should solve a problem once.

Other Engines should consume its output rather than duplicate its logic.

---

# Engine Composition

Engines may compose other Engines.

Example:

```
Recommendation Engine

↓

Identity Engine

↓

Market Engine

↓

Collector DNA Engine
```

Composition is encouraged.

Duplication is not.

---

# Engine Families

Atlas organizes Engines into families.

## Normalization Engines

Responsible for transforming observations into standardized information.

Examples:

- OCR Normalizer
- Barcode Normalizer
- CSV Normalizer
- Identity Normalizer

---

## Decision Engines

Responsible for making structured conclusions.

Examples:

- Identity Engine
- Market Engine
- Authentication Engine
- Portfolio Engine
- Risk Engine

---

## Analysis Engines

Responsible for combining multiple Decisions into meaningful intelligence.

Examples:

- Vault Health
- Collector DNA
- Collection Insights
- Timeline Analysis

---

## Recommendation Engines

Responsible for generating actionable suggestions.

Examples:

- Purchase Recommendations
- Cleanup Suggestions
- Pricing Alerts
- Collection Improvements

---

## Orchestration Engines

Responsible for coordinating multiple Engines to solve larger workflows.

They should contain orchestration rather than analytical logic.

---

# Dependency Rules

Dependencies flow in one direction.

```
Observations

↓

Normalization

↓

Decision Engines

↓

Analysis Engines

↓

Recommendation Engines

↓

Experience Layer
```

No layer should bypass another.

No presentation layer should implement business logic.

---

# Engine Metadata

Every execution should record metadata when appropriate.

Examples include:

- Engine Name
- Engine Version
- Execution Time
- Policy Version
- Confidence
- Warnings
- Evidence Summary

Metadata improves explainability and debugging.

---

# Failure Handling

Engines should fail gracefully.

Possible outcomes include:

- Success
- Partial Success
- Validation Failure
- Policy Failure
- Missing Data
- Conflicting Evidence

Failures should be structured and explainable.

---

# Engine Boundaries

An Engine owns one responsibility.

It should never:

- Navigate screens
- Save UI state
- Display dialogs
- Render widgets
- Control presentation

Its responsibility ends when it produces a Result.

---

# Engineering Checklist

Before creating a new Engine, ask:

1. Does this solve one responsibility?

2. Can another Engine already solve this?

3. Can the result be reused elsewhere?

4. Can every conclusion be explained?

5. Is evidence preserved?

6. Is the Engine independent of presentation?

7. Would another collectible category reuse this?

If not, reconsider the design.

---

# The Atlas Engine Law

Every capability inside Atlas begins with an Engine.

Features are temporary.

Screens evolve.

Frameworks change.

Engines become the permanent intelligence of the platform.

Protect them accordingly.

---

# The Atlas Promise

An Engine should always produce knowledge that is:

- Explainable
- Reusable
- Deterministic
- Versioned
- Independent
- Trustworthy

Every Engine should leave Atlas smarter than it was before execution.

---

# The Atlas North Star

A great feature solves today's problem.

A great Engine solves tomorrow's problems as well.

Design Engines that outlive the technologies built around them.