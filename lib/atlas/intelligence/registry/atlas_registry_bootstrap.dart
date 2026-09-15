import 'atlas_registry.dart';
import 'atlas_registry_builder.dart';
import 'providers/variant_registry_provider.dart';
import 'providers/retailer_registry_provider.dart';
import 'providers/sticker_registry_provider.dart';
import 'providers/event_registry_provider.dart';

// Builds the default Atlas Intelligence registry.
final class AtlasRegistryBootstrap {
  const AtlasRegistryBootstrap();

  AtlasRegistry build() {
    final builder = AtlasRegistryBuilder();

    builder.addAll(VariantRegistryProvider().buildEntries());

    builder.addAll(RetailerRegistryProvider().buildEntries());

    builder.addAll(StickerRegistryProvider().buildEntries());

    builder.addAll(const EventRegistryProvider().buildEntries());

    return builder.build();
  }
}
