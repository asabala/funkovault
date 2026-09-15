import '../../event/funko_event.dart';
import '../atlas_registry_domain.dart';
import '../atlas_registry_entry.dart';
import '../atlas_registry_provider.dart';

// Supplies Event entries for the Atlas Registry.
final class EventRegistryProvider implements AtlasRegistryProvider {
  const EventRegistryProvider();

  @override
  Iterable<AtlasRegistryEntry> buildEntries() {
    final List<AtlasRegistryEntry> entries = <AtlasRegistryEntry>[];

    for (final FunkoEvent event in FunkoEvent.values) {
      if (!event.isKnown) {
        continue;
      }

      entries.add(
        AtlasRegistryEntry(
          id: event.code,
          domain: AtlasRegistryDomain.event,
          displayName: event.displayName,
          aliases: event.aliases,
        ),
      );
    }

    return List<AtlasRegistryEntry>.unmodifiable(entries);
  }
}
