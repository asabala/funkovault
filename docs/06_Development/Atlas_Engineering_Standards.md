# Atlas Engineering Standards

Version 1.0

---

# Purpose

This document defines the engineering standards used throughout the Atlas platform.

These standards exist to keep Atlas consistent, maintainable, scalable, and easy to understand.

Every contribution should follow these guidelines.

---

# Engineering Philosophy

Atlas is built as a platform.

Not a collection of unrelated features.

Every implementation should strengthen the platform.

Never bypass architecture for convenience.

---

# Architecture First

Before implementing a major feature:

Understand the problem.

Review existing engines.

Review existing services.

Review existing contracts.

Create an Architecture Decision Record (ADR) when appropriate.

Only then begin implementation.

---

# Definition of Done

A feature is considered complete when:

✓ Architecture documented

✓ Feature documented

✓ Engine implemented

✓ Service implemented

✓ UI connected

✓ Documentation updated

✓ Flutter analyze passes

✓ Existing functionality remains intact

Code is not considered complete until documentation is also complete.

---

# Folder Responsibilities

Core

Shared platform infrastructure.

Identity

Collectible identification.

Timeline

Historical events.

Market

Market value and trends.

Vault

Collection management.

Academy

Collector education.

Scanner

Scanning workflows.

AI

Conversational interface.

Analytics

Reporting and insights.

Every file belongs to exactly one platform.

---

# Engine Rules

Every engine:

Has one responsibility.

Contains business logic.

Is reusable.

Does not depend on UI.

Produces deterministic results whenever practical.

Is independently testable.

---

# Service Rules

Services coordinate workflows.

Services may call multiple engines.

Services persist data.

Services do not contain presentation logic.

---

# Repository Rules

Repositories read and write data.

Repositories never contain business rules.

Repositories never perform calculations.

---

# Widget Rules

Widgets display information.

Widgets never calculate business logic.

Widgets should remain reusable.

---

# Screen Rules

Screens organize experiences.

Screens should remain thin.

Business logic belongs elsewhere.

---

# Documentation Rules

Every significant architectural decision should be documented.

Every new platform should receive:

Architecture document.

Feature document.

Implementation notes.

Future roadmap updates.

Documentation evolves alongside code.

---

# Naming Standards

Prefer descriptive names.

Examples

AtlasTimelineEngine

AtlasDecisionEngine

AtlasMarketService

AtlasIdentityResult

Avoid vague names.

Examples

Helper

Manager

Util2

Stuff

Names should communicate responsibility.

---

# Reuse Standards

Before creating:

A widget

A service

An engine

A model

A utility

Ask:

Does one already exist?

Reuse before creating new implementations.

---

# Premium Philosophy

Core collector functionality remains available to every user.

Premium enhances intelligence.

Premium should not restrict ownership or history.

---

# Code Quality

Readable code is preferred over clever code.

Consistency is preferred over personal preference.

Maintainability is preferred over short-term optimization.

Future contributors should immediately understand the project.

---

# Documentation Philosophy

Documentation is a first-class deliverable.

Architecture without documentation becomes difficult to maintain.

Code without documentation loses context over time.

Atlas documentation should always explain:

What

Why

How

Future considerations

---

# Engineering Checklist

Before every pull request or checkpoint:

Architecture reviewed

Documentation updated

Naming reviewed

Dependencies verified

Flutter analyze clean

No duplicated business logic

Reusable where practical

Future extensibility considered

---

# Final Principle

Every line of code should make Atlas easier to grow tomorrow than it was yesterday.