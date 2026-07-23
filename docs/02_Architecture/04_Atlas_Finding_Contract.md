# Atlas Finding Contract
### Version 1.0
### "The Atomic Unit of Reasoning"

---

# Purpose

A Finding is the smallest explainable conclusion produced during analysis.

Findings are facts discovered by an Engine.

Decisions are collections of Findings.

---

# Philosophy

Engines should never jump directly to conclusions.

They should build conclusions from Findings.

---

# Conceptual Structure

```
AtlasFinding

Category

Severity

Message

Evidence

Confidence

Source

Metadata
```

---

# Severity

Possible severities include:

- Informational
- Low
- Medium
- High
- Critical

---

# Categories

Examples:

- Identity
- Variant
- Market
- Portfolio
- Authentication
- Recommendation
- Risk

---

# Evidence

Every significant Finding should reference supporting evidence.

Confidence without evidence weakens trust.

---

# Principles

- Independent
- Explainable
- Traceable
- Immutable
- Reusable

---

# Example

Finding:

Variant Finish differs.

Severity:

Medium

Evidence:

Manufacturer Catalog

OCR

Barcode

Confidence:

98%

---

# Atlas Promise

A Decision is only as trustworthy as the Findings that support it.