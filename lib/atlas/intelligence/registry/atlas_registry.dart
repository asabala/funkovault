import 'atlas_registry_domain.dart';
import 'atlas_registry_entry.dart';

// Shared registry used by Atlas Intelligence.
final class AtlasRegistry {
  AtlasRegistry({
    Iterable<AtlasRegistryEntry> entries = const <AtlasRegistryEntry>[],
  }) : _entries = List<AtlasRegistryEntry>.unmodifiable(entries),
       _aliasIndex = _buildAliasIndex(entries);

  final List<AtlasRegistryEntry> _entries;

  final Map<String, List<AtlasRegistryEntry>> _aliasIndex;

  List<AtlasRegistryEntry> get entries => _entries;

  List<AtlasRegistryEntry> find(String value) {
    return _aliasIndex[AtlasRegistryEntry.normalizeAlias(value)] ??
        const <AtlasRegistryEntry>[];
  }

  List<AtlasRegistryEntry> findByDomain(
    AtlasRegistryDomain domain,
    String value,
  ) {
    return find(
      value,
    ).where((entry) => entry.domain == domain).toList(growable: false);
  }

  AtlasRegistryEntry? firstByDomain(AtlasRegistryDomain domain, String value) {
    final List<AtlasRegistryEntry> matches = findByDomain(domain, value);

    if (matches.isEmpty) {
      return null;
    }

    return matches.first;
  }

  bool contains(AtlasRegistryDomain domain, String value) {
    return firstByDomain(domain, value) != null;
  }

  static Map<String, List<AtlasRegistryEntry>> _buildAliasIndex(
    Iterable<AtlasRegistryEntry> entries,
  ) {
    final Map<String, List<AtlasRegistryEntry>> index =
        <String, List<AtlasRegistryEntry>>{};

    for (final AtlasRegistryEntry entry in entries) {
      for (final String alias in entry.aliases) {
        index.putIfAbsent(alias, () => <AtlasRegistryEntry>[]);

        index[alias]!.add(entry);
      }
    }

    return Map<String, List<AtlasRegistryEntry>>.unmodifiable(
      index.map(
        (key, value) =>
            MapEntry(key, List<AtlasRegistryEntry>.unmodifiable(value)),
      ),
    );
  }
}
