import '../../sticker/funko_sticker_normalizer.dart';
import '../../sticker/funko_sticker_type.dart';
import '../atlas_registry_domain.dart';
import '../atlas_registry_entry.dart';
import '../atlas_registry_provider.dart';

// Supplies Sticker entries for the Atlas Registry.
final class StickerRegistryProvider
    implements AtlasRegistryProvider {
  StickerRegistryProvider({
    FunkoStickerNormalizer? normalizer,
  }) : _normalizer =
      normalizer ??
          const FunkoStickerNormalizer();

  final FunkoStickerNormalizer _normalizer;

  @override
  Iterable<AtlasRegistryEntry> buildEntries() {
    final List<AtlasRegistryEntry> entries =
    <AtlasRegistryEntry>[];

    for (final entry
    in _normalizer.aliases.entries) {
      final FunkoStickerType sticker =
          entry.key;

      if (sticker == FunkoStickerType.none ||
          sticker == FunkoStickerType.unknown) {
        continue;
      }

      entries.add(
        AtlasRegistryEntry(
          id: sticker.code,
          domain: AtlasRegistryDomain.sticker,
          displayName: sticker.displayName,
          aliases: entry.value,
        ),
      );
    }

    return List<AtlasRegistryEntry>.unmodifiable(
      entries,
    );
  }
}