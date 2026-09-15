import 'atlas_registry.dart';
import 'atlas_registry_entry.dart';

// Builds an immutable Atlas registry.
final class AtlasRegistryBuilder {
  AtlasRegistryBuilder();

  final List<AtlasRegistryEntry> _entries = <AtlasRegistryEntry>[];

  void add(AtlasRegistryEntry entry) {
    _entries.add(entry);
  }

  void addAll(Iterable<AtlasRegistryEntry> entries) {
    _entries.addAll(entries);
  }

  AtlasRegistry build() {
    return AtlasRegistry(entries: _entries);
  }
}
