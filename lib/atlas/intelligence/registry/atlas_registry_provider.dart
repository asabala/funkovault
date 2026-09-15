import 'atlas_registry_entry.dart';

// Supplies registry entries for a specific intelligence domain.
abstract interface class AtlasRegistryProvider {
  Iterable<AtlasRegistryEntry> buildEntries();
}
