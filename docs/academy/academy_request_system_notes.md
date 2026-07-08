# Academy Request System Notes

## Current storage mode

Academy requests currently use the local in-memory repository.

Config file:

`lib/academy/config/academy_request_storage_config.dart`

Current mode:

`AcademyRequestStorageMode.local`

Future mode:

`AcademyRequestStorageMode.supabase`

## Main flow

`AtlasAcademyScreen`
uses:

`AcademyRequestRepositoryProvider.create()`

which returns:

`AcademyRequestRepositoryContract`

The screen does not need to know whether the repository is local or Supabase later.

## Local repository

File:

`lib/academy/repository/academy_request_repository.dart`

Responsibilities:

- Store requests locally in memory
- Return all requests
- Return new requests
- Count new requests
- Add topic requests
- Add track requests
- Mark reviewed
- Approve
- Decline
- Clear all

## Request model

File:

`lib/academy/models/academy_request.dart`

Supports:

- `toMap()`
- `fromMap()`
- `copyWith()`
- readable type labels
- readable status labels
- topic/track helper getters
- new request helper getter

## Supabase-ready files

Table constants:

`lib/academy/data/academy_request_table.dart`

Repository placeholder:

`lib/academy/repository/supabase_academy_request_repository.dart`

Storage config:

`lib/academy/config/academy_request_storage_config.dart`

Repository provider:

`lib/academy/config/academy_request_repository_provider.dart`

## Helper files

Request factory:

`lib/academy/helpers/academy_request_factory.dart`

Request ID builder:

`lib/academy/helpers/academy_request_id_builder.dart`

Request status updater:

`lib/academy/helpers/academy_request_status_updater.dart`

Request message builder:

`lib/academy/helpers/academy_request_message_builder.dart`

Ask Atlas suggestions builder:

`lib/academy/helpers/ask_atlas_suggestions_builder.dart`

## Admin UI cleanup

Admin inbox UI has been split into smaller widgets:

- `academy_admin_request_inbox_card.dart`
- `academy_admin_inbox_header.dart`
- `academy_admin_request_list.dart`
- `academy_admin_request_tile.dart`
- `academy_admin_empty_inbox_state.dart`
- `academy_admin_more_requests_label.dart`
- `academy_request_action_row.dart`
- `academy_request_badge_row.dart`
- `academy_request_status_badge.dart`
- `academy_request_type_badge.dart`

## Future folder cleanup idea

Later, move Academy widgets into folders:

- `admin/`
- `ask_atlas/`
- `tracks/`
- `roadmap/`
- `shared/`

Move one group at a time and run:

`flutter analyze`

after each group.