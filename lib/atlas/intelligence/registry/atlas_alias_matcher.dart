import 'atlas_registry.dart';
import 'atlas_registry_domain.dart';
import 'atlas_registry_entry.dart';

// Performs alias lookups against the Atlas registry.
final class AtlasAliasMatcher {
  const AtlasAliasMatcher({required this._registry});

  final AtlasRegistry _registry;

  List<AtlasRegistryEntry> match(String value) {
    return _registry.find(value);
  }

  List<AtlasRegistryEntry> matchDomain({
    required AtlasRegistryDomain domain,
    required String value,
  }) {
    return _registry.findByDomain(domain, value);
  }

  AtlasRegistryEntry? firstMatch({
    required AtlasRegistryDomain domain,
    required String value,
  }) {
    final matches = matchDomain(domain: domain, value: value);

    if (matches.isEmpty) {
      return null;
    }

    return matches.first;
  }

  bool contains({required AtlasRegistryDomain domain, required String value}) {
    return firstMatch(domain: domain, value: value) != null;
  }
}
