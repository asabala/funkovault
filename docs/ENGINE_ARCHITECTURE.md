# ENGINE ARCHITECTURE

Version: 1.0

---

# Purpose

The Atlas Engine System is the intelligence layer of the platform.

Engines are responsible for thinking.

They analyze data.

They make decisions.

They calculate scores.

They generate recommendations.

They never build UI.

They never manage navigation.

They never directly store data.

---

# Philosophy

Every engine should have one responsibility.

Good engines are:

- Small
- Focused
- Testable
- Independent
- Reusable

If an engine starts doing multiple unrelated jobs, split it into multiple engines.

---

# Engine Workflow

```text
Models
      │
Repositories
      │
      ▼
Engines
      │
Widgets
      │
Screens
```

Repositories retrieve data.

Engines analyze data.

Widgets display results.

Screens assemble the experience.

---

# Current Engine Inventory

## Atlas Intelligence Engine

File

atlas_intelligence_engine.dart

Purpose

Master coordinator.

Should combine the output from multiple engines into a single intelligence response.

Owns:

- Overall collector intelligence
- Cross-engine orchestration
- Future AI integrations

Should NOT duplicate the work of specialized engines.

---

## Atlas Recommendation Engine

Purpose

Recommend what the collector should do next.

Examples

- Next Pop to buy
- Collection gaps
- Wishlist suggestions
- Category recommendations

Input

Collection

Wishlist

Market

Output

Recommendation

Priority

Confidence

---

## Atlas Mission Engine

Purpose

Generate daily and weekly collector missions.

Examples

Complete a Horror shelf.

Scan five new Pops.

Review your wishlist.

Update collection values.

Future

Seasonal missions

Convention missions

Achievement missions

---

## Atlas Achievement Engine

Purpose

Award achievements.

Examples

Master Collector

Vault Legend

Marvel Expert

Convention Veteran

Owns

Achievement unlocks

Progress tracking

Milestone rewards

Does NOT calculate collector score.

---

## Collector Score Engine

Purpose

Calculate a collector score.

Outputs

Collector Score

Collector Rank

Collector Tier

Future

Weighted scoring

Collection quality

Rarity

Diversity

Activity

Market value

This engine calculates.

It does NOT award achievements.

---

## Atlas Confidence Engine

Purpose

Measure confidence in Atlas data.

Examples

Price confidence

Collection completeness

Recommendation confidence

Matching confidence

Future AI confidence

---

## Atlas Trend Engine

Purpose

Detect trends.

Examples

Growing categories

Collection changes

Market movement

Wishlist growth

Future

Price forecasting

Demand prediction

---

## Atlas Insight Engine

Purpose

Generate insights.

Examples

Your Marvel collection grew 12%.

Anime is now your fastest-growing category.

Your average Pop value increased.

Insights explain.

Recommendations suggest.

---

## Atlas Daily Briefing Engine

Purpose

Generate today's dashboard briefing.

Examples

Today's mission

Collection summary

Market news

Achievements

Recommendations

Future weather-style dashboard.

---

## Atlas Memory Engine

Purpose

Remember collector history.

Examples

Recent activity

Collection timeline

Historical trends

Future

Collector journal

Memory search

Anniversaries

---

## Atlas Reflection Engine

Purpose

Analyze long-term behavior.

Examples

How has the collection changed?

Favorite categories over time.

Biggest collecting months.

Personal growth.

Reflection is historical.

Insight is current.

---

## Atlas Knowledge Engine

Purpose

Provide factual information.

Examples

Funko information

Series information

Franchise knowledge

Convention history

Character information

Knowledge never changes collector state.

---

## Atlas Decision Engine

Purpose

Prioritize competing engine results.

Example

Mission says buy Marvel.

Recommendation says finish Horror.

Trend Engine detects Star Wars prices dropping.

Decision Engine determines what should be surfaced first.

Decision Engine coordinates.

It does not calculate.

---

## Atlas Collector DNA Engine

Purpose

Understand WHO the collector is.

Examples

Completionist

Investor

Character Collector

Franchise Collector

Grail Hunter

Casual Collector

Collector DNA should evolve over time.

---

# Engine Communication

Engines should remain loosely coupled.

Preferred:

```text
Recommendation Engine

↓

Collector Score Engine

↓

Decision Engine

↓

Dashboard
```

Avoid engines calling multiple unrelated engines directly.

The Intelligence Engine should orchestrate.

---

# Future Engines

Potential additions

Atlas Market Engine

Atlas Rarity Engine

Atlas Scanner Engine

Atlas Authentication Engine

Atlas Community Engine

Atlas Trading Engine

Atlas Event Engine

Atlas Notification Engine

Atlas Prediction Engine

Atlas Collection Health Engine

Atlas Sync Engine

Atlas Analytics Engine

---

# Design Rules

Every engine should answer:

What is my responsibility?

What data do I require?

What do I return?

Who consumes my output?

---

# Naming Standard

All engines should begin with:

atlas_

Examples

atlas_mission_engine.dart

atlas_trend_engine.dart

atlas_memory_engine.dart

atlas_decision_engine.dart

atlas_achievement_engine.dart

atlas_collector_score_engine.dart

---

# Engine Lifecycle

Every engine follows:

Input

↓

Analysis

↓

Decision

↓

Output

Engines should not perform UI work.

Engines should not navigate.

Engines should not display dialogs.

---

# Long-Term Vision

Atlas should eventually become a network of specialized intelligence engines coordinated by Atlas Intelligence Engine.

Instead of one large AI system, Atlas will consist of many focused experts.

Each engine will become better over time while remaining independent.

This architecture allows Atlas to grow without becoming difficult to maintain.

---

# Guiding Principle

Small engines.

Clear responsibility.

Shared intelligence.

Simple.

Scalable.

Beautiful.