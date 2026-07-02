# ENGINE CHANGELOG

This document tracks architectural changes to the Atlas Engine System.

Purpose:

- Record why engines changed.
- Prevent duplicate work.
- Preserve architectural decisions.
- Make future debugging easier.
- Help contributors understand the evolution of Atlas.

---

## Format

Date

Engine

Changes

Reason

Future Notes

---

# 2026

## Engine Audit Sprint 1

Status

Started

Goal

Review every engine.

Clarify responsibilities.

Reduce overlap.

Improve maintainability.

Align every engine with ENGINE_ARCHITECTURE.md.

---

## atlas_intelligence_engine.dart

Status

Pending Review

Notes

Master orchestration engine.

Should coordinate specialized engines.

Should avoid duplicated intelligence logic.

---

## atlas_decision_engine.dart

Status

Pending Review

Notes

Decision prioritization.

---

## atlas_collector_dna_engine.dart

Status

Reviewed

Changes

None

Reason

Engine has a single responsibility and aligns with the architecture.

Future Notes

Expand from rule-based classification to a weighted multi-trait Collector DNA model. Future analysis should consider collection diversity, completion, activity, rarity, organization, and collecting behavior to produce richer identity profiles.

---

## atlas_memory_engine.dart

Status

Reviewed

Changes

None

Reason

Engine has a clear responsibility and aligns with the Atlas Engine Architecture. It converts collection data into meaningful collector memories without touching UI, navigation, or persistence.

Future Notes

Expand into Atlas Memory 2.0 with activity history, collection anniversaries, first-added collectibles, value milestones, grail acquisition dates, signed item history, and timeline-based memories.

---

## atlas_knowledge_engine.dart

Status

Reviewed

Changes

None

Reason

Engine has a single responsibility and serves as the factual analysis layer for Atlas. It produces collection statistics without making recommendations or decisions.

Future Notes

Expand with additional collection metrics such as duplicate count, grail count, category diversity, completed sets, median value, oldest/newest collectibles, and Vault Health metrics. Long-term, other engines should consume AtlasKnowledge instead of recalculating collection statistics independently.

---

## atlas_confidence_engine.dart

Status

Reviewed

Changes

None

Reason

Engine has a single responsibility and measures collection data completeness and quality. It does not generate recommendations or modify collection state.

Future Notes

Move from equal-weight scoring to weighted confidence based on field importance. Consider additional signals such as purchase date, barcode verification, authentication status, box condition, market validation, and image quality.

---

## atlas_trend_engine.dart

Status

Reviewed

Changes

None

Reason

Current implementation duplicates statistical calculations already provided by AtlasKnowledgeEngine. Engine is stable but its long-term responsibility should shift from reporting facts to analyzing change over time.

Future Notes

Trend Engine 2.0 should compare historical snapshots rather than recalculate current statistics. Future outputs should include collection growth, value change, category movement, wishlist trends, market movement, and historical comparisons.

---

## atlas_insight_engine.dart

Status

Reviewed

Changes

None

Reason

Engine has a clear responsibility and produces useful collector identity insights based on variant, exclusive, sticker, limited edition, and signature data.

Future Notes

Current responsibility is narrower than the file name suggests. Consider renaming to atlas_identity_insight_engine.dart or expanding AtlasInsightEngine to support broader insights such as collection growth, value changes, category trends, and Vault Health.

---

## atlas_recommendation_engine.dart

Status

Reviewed

Changes

None

Reason

Engine has a clear recommendation responsibility and correctly prioritizes collector identity recommendations based on variant, exclusive, sticker, limited edition, signature, value, and purchase data.

Future Notes

Current responsibility is focused on single-collectible identity recommendations. Consider renaming to atlas_identity_recommendation_engine.dart or expanding the engine to support collection-wide recommendations.

---

## atlas_recommendation_engine_v2.dart

Status

Reviewed

Changes

None

Reason

Engine correctly analyzes collection-wide issues and returns prioritized smart recommendations with severity and estimated impact. This aligns well with the Atlas Engine Architecture.

Future Notes

This should become the primary recommendation engine. The original atlas_recommendation_engine.dart may eventually be renamed to atlas_identity_recommendation_engine.dart or folded into a specialized identity recommendation layer.

---

## atlas_mission_engine.dart

Status

Reviewed

Changes

None

Reason

Engine has a single responsibility. It transforms Atlas decisions into actionable collector missions without generating recommendations or calculating priorities.

Future Notes

Expand missions with difficulty levels, Atlas XP rewards, Vault Health impact, mission categories, seasonal events, Premium missions, and community challenges. Mission generation should remain separate from recommendation and decision logic.

---

## atlas_daily_briefing_engine.dart

Status

Reviewed

Changes

None

Reason

Engine successfully builds a daily collector briefing, including greeting, Vault Health, missing values, duplicate groups, and empty Vault messaging.

Future Notes

Refactor later to avoid direct dependency on AppState. Prefer passing clean inputs such as List<Pop>, collectorName, duplicateCount, missingValueCount, and Vault Health. This will make the engine easier to test and reuse.

---

## atlas_achievement_engine.dart

Status

Reviewed

Changes

None

Reason

Engine has a clear responsibility and evaluates collection milestones such as first Pop, collection size, Chase, signed collectibles, Limited Edition, and grail-level value.

Future Notes

Expand with achievement categories, locked/unlocked progress, rarity tiers, achievement dates, XP rewards, profile ribbons, seasonal achievements, and community achievements.

---

Future audits should append to this document rather than replacing previous entries.