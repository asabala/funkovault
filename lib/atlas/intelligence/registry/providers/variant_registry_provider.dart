import '../../variant/atlas_variant_normalizer.dart';
import '../../variant/atlas_variant_type.dart';
import '../atlas_registry_domain.dart';
import '../atlas_registry_entry.dart';
import '../atlas_registry_provider.dart';

// Supplies Variant entries for the Atlas Registry.
final class VariantRegistryProvider implements AtlasRegistryProvider {
  VariantRegistryProvider({AtlasVariantNormalizer? normalizer})
    : _normalizer = normalizer ?? const AtlasVariantNormalizer();

  final AtlasVariantNormalizer _normalizer;

  @override
  Iterable<AtlasRegistryEntry> buildEntries() {
    final List<AtlasRegistryEntry> entries = <AtlasRegistryEntry>[];

    for (final entry in _normalizer.aliases.entries) {
      final AtlasVariantType variant = entry.key;

      if (!variant.isSpecial) {
        continue;
      }

      entries.add(
        AtlasRegistryEntry(
          id: variant.code,
          domain: AtlasRegistryDomain.variant,
          displayName: variant.displayName,
          aliases: entry.value,
        ),
      );
    }

    return List<AtlasRegistryEntry>.unmodifiable(entries);
  }
}
