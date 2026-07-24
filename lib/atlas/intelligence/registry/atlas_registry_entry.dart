import 'atlas_registry_domain.dart';

// Represents one normalized knowledge entry in the Atlas registry.
final class AtlasRegistryEntry {
  AtlasRegistryEntry({
    required this.id,
    required this.domain,
    required this.displayName,
    required Iterable<String> aliases,
    Map<String, String>? metadata,
  })  : aliases = Set<String>.unmodifiable(
    aliases.map(normalizeAlias),
  ),
        metadata = Map<String, String>.unmodifiable(
          metadata ?? const <String, String>{},
        );

  final String id;

  final AtlasRegistryDomain domain;

  final String displayName;

  final Set<String> aliases;

  final Map<String, String> metadata;

  bool matches(String value) {
    return aliases.contains(
      normalizeAlias(value),
    );
  }

  String? metadataValue(String key) {
    return metadata[key];
  }

  static String normalizeAlias(String value) {
    return value
        .toLowerCase()
        .replaceAll('-', ' ')
        .replaceAll(
      RegExp(r'\s+'),
      ' ',
    )
        .trim();
  }
}