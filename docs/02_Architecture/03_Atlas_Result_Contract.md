# Atlas Result Contract
### Version 1.0
### "The Universal Output of Every Atlas Engine"

---

# Purpose

Every Atlas Engine produces exactly one Result.

A Result represents the structured outcome of an Engine execution.

Regardless of the Engine type, every Result should share the same language, lifecycle, and metadata.

Results make Engines interchangeable and composable.

---

# Philosophy

An Engine should never return arbitrary objects.

An Engine should always return an AtlasResult.

Consistency is more valuable than convenience.

---

# Conceptual Structure

```
AtlasResult<T>

Engine

Version

Status

Output

Warnings

Metadata
```

---

# Responsibilities

Every Result contains:

- Engine identity
- Engine version
- Schema version
- Execution status
- Primary output
- Execution metadata
- Warnings
- Timing information

---

# Result Status

Possible execution states include:

- Success
- Partial Success
- Validation Failure
- Policy Failure
- Missing Data
- Conflicting Evidence
- Execution Failure

Results should explain failure rather than hide it.

---

# Metadata

Metadata may include:

- Execution time
- Policy version
- Schema version
- Confidence summary
- Evidence summary
- Warning count

---

# Result Principles

1. Immutable
2. Explainable
3. Versioned
4. Serializable
5. Platform Independent
6. Reusable

---

# Specializations

Examples include:

- DecisionResult
- NormalizationResult
- OCRResult
- RecommendationResult

Each specialization extends AtlasResult while preserving the same contract.

---

# Atlas Promise

Every Engine speaks the same language.

That language is AtlasResult.