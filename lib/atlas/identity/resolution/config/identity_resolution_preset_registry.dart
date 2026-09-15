import '../../../core/registry/atlas_registry.dart';
import 'identity_resolution_preset.dart';

// Registry containing reusable identity resolution presets.
//
// Presets define complete identity resolution configurations for a
// particular domain or workflow. The registry allows Atlas to locate
// presets without hard-coded switch statements.
class IdentityResolutionPresetRegistry
    extends AtlasRegistry<IdentityResolutionPreset> {
  const IdentityResolutionPresetRegistry({
    List<IdentityResolutionPreset> presets = const <IdentityResolutionPreset>[],
  }) : super(presets);

  // Creates an empty registry.
  factory IdentityResolutionPresetRegistry.empty() {
    return const IdentityResolutionPresetRegistry();
  }

  // Creates a registry from a collection of presets.
  factory IdentityResolutionPresetRegistry.fromPresets(
    Iterable<IdentityResolutionPreset> presets,
  ) {
    return IdentityResolutionPresetRegistry(
      presets: List<IdentityResolutionPreset>.unmodifiable(presets),
    );
  }

  // Returns the preset with the supplied identifier.
  IdentityResolutionPreset? presetById(String id) {
    return byId(id);
  }

  // Returns true when a preset exists.
  bool containsPreset(String id) {
    return contains(id);
  }

  // Returns all registered presets.
  List<IdentityResolutionPreset> get presets {
    return modules;
  }
}
