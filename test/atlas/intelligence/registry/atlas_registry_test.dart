import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/atlas/intelligence/registry/atlas_registry_bootstrap.dart';
import 'package:funkovault2/atlas/intelligence/registry/atlas_registry_domain.dart';

void main() {
  test(
    'Registry bootstrap builds successfully',
        () {
      const bootstrap = AtlasRegistryBootstrap();

      final registry = bootstrap.build();

      expect(
        registry.entries,
        isNotEmpty,
      );

      expect(
        registry.contains(
          AtlasRegistryDomain.retailer,
          'hot topic',
        ),
        isTrue,
      );

      expect(
        registry.contains(
          AtlasRegistryDomain.sticker,
          'special edition',
        ),
        isTrue,
      );

      expect(
        registry.contains(
          AtlasRegistryDomain.variant,
          'glow',
        ),
        isTrue,
      );
      expect(
        registry.contains(
          AtlasRegistryDomain.event,
          'sdcc',
        ),
        isTrue,
      );

    },
  );
}