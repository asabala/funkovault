# ADR-004 — Atlas Timeline Architecture

**Status:** Approved

**Version:** 1.0

**Date:** July 29, 2026

---

# Purpose

The Atlas Timeline Architecture establishes a universal event system for every collectible stored within Atlas.

Rather than tracking only estimated value history, Atlas records the complete lifecycle of a collectible.

The goal is to transform every collectible from a static inventory record into a living timeline that tells its story.

---

# Vision

Most collection applications answer one question:

> What do I own?

Atlas answers a different question:

> What is the story behind this collectible?

Every collectible should accumulate meaningful events throughout its lifetime.

Examples include:

• Added to Vault
• Estimated Value Updated
• Imported
• Catalog Refresh
• Sticker Updated
• Chase Confirmed
• Exclusive Added
• Signature Added
• Protector Added
• Notes Added
• Purchase Recorded
• Sale Recorded
• Atlas AI Insight
• Custom Collector Moment

The Atlas Timeline becomes the permanent historical record for every collectible.

---

# Design Principles

## 1. Timeline First

The timeline is not a feature.

It is a core platform service.

Every future feature should integrate into the timeline whenever appropriate.

---

## 2. Every Collectible Has A Story

Every collectible deserves a complete historical record regardless of rarity or value.

Timeline functionality is available to every Atlas user.

No Premium subscription is required.

---

## 3. Single Source of Truth

Timeline events may only be created through the Atlas Timeline Service.

UI components must never construct timeline events directly.

Scanner

Importer

Edit Pop

AI

Catalog Refresh

Future integrations

All communicate through the Timeline Service.

---

## 4. Immutable History

Timeline events should never be modified after creation.

If information changes, Atlas records a new event.

History should remain trustworthy.

---

## 5. Engine Driven

The timeline exists independently from any screen.

UI displays timeline data.

The Timeline Engine owns business logic.

---

# Architecture

Atlas Timeline consists of four primary layers.

Atlas Timeline Event

↓

Timeline Service

↓

Timeline Engine

↓

Timeline UI

Each layer has a single responsibility.

---

# Timeline Event

Each event represents one historical action.

Example properties include:

• Event ID

• Event Type

• Timestamp

• Title

• Description

• Source

• Metadata

Some events may contain additional information.

For example:

Estimated Value Updated

Previous Value

Current Value

Dollar Change

Percent Change

Purchase Recorded

Purchase Price

Store

Location

Custom Moment

Title

Description

Photo (future)

Location (future)

---

# Timeline Service

Responsible for creating timeline events.

Responsibilities include:

• Validate events

• Prevent duplicates

• Timestamp events

• Attach metadata

• Sort events

• Persist events

No other system may create timeline entries directly.

---

# Timeline Engine

Responsible for analysis.

Examples include:

Most Recent Event

Highest Value

Lowest Value

Biggest Increase

Biggest Decrease

Longest Time Without Updates

Collection Milestones

Timeline Statistics

The engine performs calculations.

It does not build UI.

---

# Timeline UI

The user interface presents timeline events.

Possible future widgets include:

Atlas Market Timeline Card

Timeline Tile

Timeline Filter

Timeline Summary

Timeline Charts

Timeline Search

Timeline Calendar View

Timeline UI should remain lightweight.

Business logic belongs inside the engine.

---

# Event Types (Version 1)

Initial supported event types:

• Added To Vault

• Value Updated

• Manual Update

• Catalog Refresh

• Imported

---

# Future Event Types

Future versions may include:

Purchase Recorded

Sold

Sticker Updated

Exclusive Updated

Chase Confirmed

Signed

Protector Added

Image Updated

Notes Updated

Collection Moved

Wishlist Added

Wishlist Removed

Atlas Achievement

Atlas AI Insight

Custom Collector Moment

Additional event types may be introduced without changing the architecture.

---

# Atlas Market Timeline

Atlas Market Timeline is the user-facing implementation of this architecture.

Collectors experience a chronological history of every collectible.

Examples:

📦 Added to Vault

💰 Value Increased

⭐ Signed

🏷 Convention Sticker Added

🛡 Protector Added

🤖 Atlas AI Insight

Timeline events should read naturally and tell the story of the collectible.

---

# Atlas AI Integration

Future Atlas AI features will consume Timeline data.

Examples:

"This collectible has increased 38% since purchase."

"This collectible reached a new all-time high."

"You've owned this collectible for 4 years."

"This collectible has become one of your top-performing Freddy Funkos."

Timeline data becomes the foundation for Atlas Intelligence.

---

# Premium Philosophy

The Atlas Timeline itself is free.

Every collector receives:

• Timeline

• Value History

• Collector Moments

• Basic Insights

Premium enhances the timeline through advanced analytics.

Examples:

Interactive Charts

Market Trends

Collection Forecasts

Advanced AI

External Pricing Providers

Portfolio Analytics

Premium expands the experience.

It does not remove ownership of the collector's story.

---

# Long-Term Vision

The Atlas Timeline should become one of the defining experiences of Atlas.

Collectors should feel that Atlas remembers the history of every collectible.

Not simply what they own...

But why it matters.

---

# Guiding Principle

Atlas does not simply catalog collectibles.

Atlas preserves their story.

---

**End of ADR-004**