# Academy Folder Cleanup Plan

> **Status: Completed historical migration plan.**
>
> The folder migration described below has been completed. Its phases and file
> lists are retained as a historical record and do not represent the current
> Academy widget inventory; individual widgets may since have been consolidated
> or removed.

## Goal

Clean up the Academy feature structure without breaking imports or changing app behavior.

The cleanup should happen one folder group at a time.

After each group, run:

`flutter analyze`

## Current concern

The folder:

`lib/widgets/academy/`

has grown large because many Academy widgets were created during the Atlas Academy buildout.

The widgets are working, but the folder should be organized before the feature grows more.

## Target widget folders

Future structure:

`lib/widgets/academy/admin/`

Admin request tools, badges, inbox, and local admin UI.

`lib/widgets/academy/ask_atlas/`

Ask Atlas card, answer sheets, and bottom sheet launcher.

`lib/widgets/academy/tracks/`

Track selector, track banner, coming soon track UI, and Funko track section.

`lib/widgets/academy/roadmap/`

Roadmap topic cards, preview launcher, preview sheet, and Funko roadmap section.

`lib/widgets/academy/shared/`

Reusable Academy UI pieces used across multiple Academy sections.

## Suggested move order

### Phase 1 — Admin widgets

Move admin/request widgets first because they are now cleanly separated.

Files:

- `academy_admin_empty_inbox_state.dart`
- `academy_admin_inbox_header.dart`
- `academy_admin_more_requests_label.dart`
- `academy_admin_request_badge_card.dart`
- `academy_admin_request_inbox_card.dart`
- `academy_admin_request_list.dart`
- `academy_admin_request_tile.dart`
- `academy_local_admin_tools_section.dart`
- `academy_request_action_row.dart`
- `academy_request_badge_row.dart`
- `academy_request_status_badge.dart`
- `academy_request_type_badge.dart`

Target:

`lib/widgets/academy/admin/`

Run:

`flutter analyze`

### Phase 2 — Ask Atlas widgets

Files:

- `ask_atlas_card.dart`
- `ask_atlas_answer_sheets.dart`
- `ask_atlas_bottom_sheet_launcher.dart`

Target:

`lib/widgets/academy/ask_atlas/`

Run:

`flutter analyze`

### Phase 3 — Roadmap widgets

Files:

- `academy_roadmap_topic_preview_launcher.dart`
- `academy_roadmap_topic_preview_sheet.dart`
- `academy_topic_roadmap_card.dart`
- `funko_academy_roadmap_section.dart`

Target:

`lib/widgets/academy/roadmap/`

Run:

`flutter analyze`

### Phase 4 — Track widgets

Files:

- `academy_coming_soon_track_section.dart`
- `academy_track_banner.dart`
- `academy_track_coming_soon_card.dart`
- `academy_track_selector_card.dart`
- `funko_academy_track_section.dart`

Target:

`lib/widgets/academy/tracks/`

Run:

`flutter analyze`

### Phase 5 — Shared widgets

Files:

- `academy_category_card.dart`
- `academy_hero_header.dart`
- `academy_learning_path_card.dart`
- `academy_section_header.dart`
- `academy_snackbars.dart`
- `academy_topic_request_card.dart`
- `academy_premium_insight_card.dart`

Target:

`lib/widgets/academy/shared/`

Run:

`flutter analyze`

## Important rule

Move only one phase at a time.

Do not move every file at once.

After each phase:

1. Update imports.
2. Run `flutter analyze`.
3. Fix issues before continuing.
