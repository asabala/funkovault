import '../../retailer/funko_retailer.dart';
import '../../retailer/funko_retailer_normalizer.dart';
import '../atlas_registry_domain.dart';
import '../atlas_registry_entry.dart';
import '../atlas_registry_provider.dart';

// Supplies Retailer entries for the Atlas Registry.
final class RetailerRegistryProvider implements AtlasRegistryProvider {
  RetailerRegistryProvider({FunkoRetailerNormalizer? normalizer})
    : _normalizer = normalizer ?? const FunkoRetailerNormalizer();

  final FunkoRetailerNormalizer _normalizer;

  @override
  Iterable<AtlasRegistryEntry> buildEntries() {
    final List<AtlasRegistryEntry> entries = <AtlasRegistryEntry>[];

    for (final entry in _normalizer.aliases.entries) {
      final FunkoRetailer retailer = entry.key;

      if (retailer == FunkoRetailer.unknown) {
        continue;
      }

      entries.add(
        AtlasRegistryEntry(
          id: retailer.code,
          domain: AtlasRegistryDomain.retailer,
          displayName: retailer.displayName,
          aliases: entry.value,
        ),
      );
    }

    return List<AtlasRegistryEntry>.unmodifiable(entries);
  }
}
