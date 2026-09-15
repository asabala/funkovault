import '../../identity/resolution/config/identity_resolution_preset.dart';
import '../../identity/resolution/config/identity_resolution_preset_registry.dart';
import '../../identity/resolution/identity_resolver.dart';
import '../../identity/resolution/identity_resolver_factory.dart';
import 'atlas_engine_configuration.dart';

// Top-level entry point for Atlas platform services.
//
// AtlasEngine exposes configured platform capabilities without requiring
// application code to manually assemble engines or dependency graphs.
class AtlasEngine {
  const AtlasEngine({required this.configuration});

  // Platform configuration.
  final AtlasEngineConfiguration configuration;

  // Returns all configured identity resolution presets.
  IdentityResolutionPresetRegistry get identityResolutionPresets {
    return configuration.identityResolutionPresets;
  }

  // Returns the configured default identity resolution preset.
  IdentityResolutionPreset get defaultIdentityResolutionPreset {
    final IdentityResolutionPreset? preset =
        configuration.defaultIdentityResolutionPreset;

    if (preset == null) {
      throw StateError(
        'No default identity resolution preset has been configured.',
      );
    }

    return preset;
  }

  // Creates a resolver using the configured default preset.
  IdentityResolver createIdentityResolver() {
    return IdentityResolverFactory.fromPreset(
      preset: defaultIdentityResolutionPreset,
    );
  }

  // Creates a resolver using a specific preset identifier.
  IdentityResolver createIdentityResolverByPreset(String presetId) {
    final IdentityResolutionPreset? preset = configuration
        .identityResolutionPresetById(presetId);

    if (preset == null) {
      throw StateError('Unknown identity resolution preset: $presetId');
    }

    return IdentityResolverFactory.fromPreset(preset: preset);
  }

  @override
  String toString() {
    return 'AtlasEngine('
        'identityResolutionPresets: '
        '${identityResolutionPresets.length}'
        ')';
  }
}
