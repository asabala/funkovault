import 'package:funkovault2/atlas/timeline/models/atlas_timeline_event.dart';

/// Contract for loading and saving timeline events.
///
/// The initial implementation is intentionally storage-agnostic.
/// Later we can provide Hive, Supabase, or cache-backed implementations
/// without changing the rest of the application.
abstract class AtlasTimelineRepository {
  Future<List<AtlasTimelineEvent>> loadEvents(String popId);

  Future<void> saveEvents(String popId, List<AtlasTimelineEvent> events);

  Future<void> addEvent(AtlasTimelineEvent event);

  Future<void> removeEvent(String eventId);

  Future<void> clearEvents(String popId);
}
