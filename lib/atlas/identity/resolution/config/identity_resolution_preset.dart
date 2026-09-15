import '../../../core/registry/atlas_module.dart';
import 'identity_resolution_configuration.dart';

// Defines a reusable identity resolution configuration preset.
//
// Presets package a complete resolution configuration for a specific
// domain, workflow, or matching mode without changing resolver logic.
abstract interface class IdentityResolutionPreset implements AtlasModule {
  IdentityResolutionConfiguration get configuration;
}
