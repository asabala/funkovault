import '../../identity/resolution/config/identity_resolution_preset.dart';
import '../../identity/resolution/config/identity_resolution_preset_registry.dart';

// Defines the modules and defaults available to the top-level Atlas Engine.
//
// This configuration keeps module selection outside screens and feature
// classes. Future Atlas systems can be added here without changing the
// public construction pattern used by the application.
class AtlasEngineConfiguration {
  const AtlasEngineConfiguration({
    required this.identityResolutionPresets,
    required this.defaultIdentityResolutionPresetId,
  });

  // Contains the available identity resolution presets.
  final IdentityResolutionPresetRegistry identityResolutionPresets;

  // Identifies the preset used when callers do not explicitly select one.
  final String defaultIdentityResolutionPresetId;

  // Returns the configured default identity resolution preset.
  IdentityResolutionPreset? get defaultIdentityResolutionPreset {
    return identityResolutionPresets.presetById(
      defaultIdentityResolutionPresetId,
    );
  }

  // Returns whether the configured default preset exists.
  bool get hasDefaultIdentityResolutionPreset {
    return defaultIdentityResolutionPreset != null;
  }

  // Returns whether the configuration contains any resolution presets.
  bool get hasIdentityResolutionPresets {
    return identityResolutionPresets.isNotEmpty;
  }

  // Returns the preset matching the supplied stable identifier.
  IdentityResolutionPreset? identityResolutionPresetById(
      String id,
      ) {
    return identityResolutionPresets.presetById(id);
  }

  AtlasEngineConfiguration copyWith({
    IdentityResolutionPresetRegistry? identityResolutionPresets,
    String? defaultIdentityResolutionPresetId,
  }) {
    return AtlasEngineConfiguration(
      identityResolutionPresets:
      identityResolutionPresets ??
          this.identityResolutionPresets,
      defaultIdentityResolutionPresetId:
      defaultIdentityResolutionPresetId ??
          this.defaultIdentityResolutionPresetId,
    );
  }

  Map<String, Object> toMap() {
    return <String, Object>{
      'defaultIdentityResolutionPresetId':
      defaultIdentityResolutionPresetId,
      'identityResolutionPresetIds':
      identityResolutionPresets.ids.toList(
        growable: false,
      ),
      'identityResolutionPresetVersions':
      identityResolutionPresets.versions,
    };
  }

  @override
  String toString() {
    return 'AtlasEngineConfiguration('
        'defaultIdentityResolutionPresetId: '
        '$defaultIdentityResolutionPresetId, '
        'identityResolutionPresetCount: '
        '${identityResolutionPresets.length}'
        ')';
  }
}