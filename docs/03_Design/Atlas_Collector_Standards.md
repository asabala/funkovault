# Atlas Collector Standards

## Document Purpose

This document defines how Atlas communicates, evaluates collectibles, and presents collector intelligence.

These standards apply across:

- Barcode Scan
- Universal Search
- Collector Summary
- Pop Details
- Entire Vault
- Atlas AI
- Shelf Scan
- Market Intelligence
- Notifications
- Future collectible categories

The goal is to ensure every Atlas feature uses the same terminology, visual language, ownership rules, recommendation philosophy, and collector-first experience.

---

# 1. Atlas Product Principle

Every Atlas screen should answer a collector’s question instead of only displaying database fields.

Examples:

- Scanner: Should I buy this collectible?
- Search: Where is this collectible in my collection?
- Collector Summary: What should I know right now?
- Pop Details: What makes this collectible special?
- Vault: What do I own?
- Market Intelligence: Is this priced fairly?
- Atlas AI: What should I know or do next?
- Shelf Scan: Which collectibles on this shelf matter to me?

Atlas should translate raw data into useful collector decisions.

---

# 2. Core Architecture Standard

Collector intelligence should flow through reusable engines and models.

```text
Scanner / Search / Shelf Scan / Pop Details
                    ↓
        Identity and Collection Engines
                    ↓
         Collector Intelligence Models
                    ↓
    Collector Summary / Search / Overlay / AI