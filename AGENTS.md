# Project Atlas / Funko Vault — Repository Operating Guide

This file applies to the entire repository. All contributors and coding agents must follow these rules while working on Project Atlas / Funko Vault.

## Project Principles

- Guiding principle: **Simple. Scalable. Beautiful.**
- Prefer maintainable architecture over quick patches.
- Work smarter, not harder: when a change clearly requires supporting files, navigation wiring, shared components, or related cleanup, include the sensible related work rather than creating unnecessary follow-up work.
- Do not rewrite stable architecture without a concrete reason.
- Inspect existing implementations before creating new models, widgets, engines, repositories, constants, or services.
- Avoid duplicate sources of truth.

## Flutter Workflow

- Run `flutter analyze` after meaningful code changes.
- Do not consider a change complete while analyzer errors remain.
- Preserve existing working behavior unless the task explicitly changes it.
- Prefer clear, descriptive names.
- Keep screens as thin orchestration layers when practical.
- Put reusable business rules into shared engines, services, or repositories.
- Extract reusable UI rather than duplicating the same component across screens.

## Atlas Design System 2.0

- Reuse existing ADS 2.0 tokens and shared Atlas components before creating screen-specific styling.
- Prefer existing `AtlasGlassCard`, `AtlasSectionHeader`, `AtlasStatusChip`, `AtlasInfoBanner`, `AtlasActionRow`, `AtlasFormField`, and other shared Atlas widgets when appropriate.
- Avoid introducing raw one-off colors, spacing, typography, cards, borders, or visual patterns when ADS 2.0 already provides the equivalent.
- Preserve the premium dark/glass Atlas visual language.
- Before creating a new shared component, search the project for an existing equivalent.

## Funko Vault Product Rules

- Basic/free must remain a complete collection-management experience.
- Barcode scanning remains Basic/free.
- Premium enhances the experience through advanced intelligence, analytics, personalization, themes, backups, reports, and convenience. Do not lock essential collection-management functionality behind Premium.
- Funko Pops with the same name and box/reference number are **not** automatically duplicates.
- Common, Chase, Glow, Metallic, Flocked, Exclusive, sticker variants, Limited Edition, Signed, and other variants may share a name and number.
- Name + number is only a possible duplicate/variant review key.
- Never automatically merge or delete collectibles based only on name + number.

## Atlas Architecture

- Flutter is the application UI.
- Supabase is the intended system of record for persistent and cloud data.
- Heavy catalog ingestion, parsing, matching, synchronization, and data processing should happen server-side rather than inside the Flutter client.
- Atlas Intelligence should consume trusted Atlas engines and data and remain approval-based before making user-data changes.
- Prefer reusable engines and shared components over repeated screen-specific logic.

## Code Changes

- Inspect relevant callers and dependencies before changing public APIs.
- When changing a model, consider likely near-term fields and requirements so the same foundation does not require repeated refactoring.
- Do not create speculative complexity solely for hypothetical future needs.
- Preserve compatibility unless there is a justified migration.
- Remove obsolete code only after verifying it is unused.
- Do not silently delete functionality.

## Documentation

- Keep documentation aligned when architecture or major features change.
- Respect the existing `docs/` structure.
- Record significant architectural decisions when appropriate.
- Do not generate documentation churn for trivial changes.

## Git Safety

- Do not commit or push unless explicitly asked.
- Do not discard unrelated working-tree changes.
- Before broad refactors, inspect `git status`.
- Never use destructive Git commands unless explicitly authorized.

## Security

- Never expose, commit, print, or copy secrets, API keys, Supabase service-role credentials, signing keys, passwords, or environment secrets.
- Do not weaken authentication or security controls for convenience.

## Audit Behavior

- When asked to audit or clean an area, inspect the whole relevant feature before editing.
- Identify duplicate architecture, legacy UI, dead code, inconsistent ADS usage, and opportunities for safe consolidation.
- Group related fixes into logical batches rather than forcing a one-file-at-a-time workflow.
- Keep each batch reviewable and run `flutter analyze` afterward.
