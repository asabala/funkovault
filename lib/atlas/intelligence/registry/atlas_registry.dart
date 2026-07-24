import 'atlas_registry_entry.dart';
import 'atlas_registry_domain.dart';

// Shared registry used by Atlas Intelligence.
final class AtlasRegistry {
  AtlasRegistry({
    Iterable<AtlasRegistryEntry> entries =
    const <AtlasRegistryEntry>[],
  }) : _entries = List<AtlasRegistryEntry>.unmodifiable(
    entries,
  );

  final List<AtlasRegistryEntry> _entries;

  List<AtlasRegistryEntry> get entries => _entries;

  List<AtlasRegistryEntry> find(
      String value,
      ) {
    return _entries
        .where(
          (entry) => entry.matches(value),
    )
        .toList(growable: false);
  }

  List<AtlasRegistryEntry> findByDomain(
      AtlasRegistryDomain domain,
      String value,
      ) {
    return _entries
        .where(
          (entry) =>
      entry.domain == domain &&
          entry.matches(value),
    )
        .toList(growable: false);
  }

  bool contains(
      AtlasRegistryDomain domain,
      String value,
      ) {
    return findByDomain(
      domain,
      value,
    ).isNotEmpty;
  }
}