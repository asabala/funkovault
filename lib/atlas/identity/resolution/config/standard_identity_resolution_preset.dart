import '../../policy/identity_policy.dart';
import '../conservative_canonicalization_strategy.dart';
import 'identity_resolution_configuration.dart';
import 'identity_resolution_options.dart';
import 'identity_resolution_preset.dart';

// Default Atlas identity resolution preset.
//
// This preset provides a conservative, domain-agnostic configuration
// suitable for most identity resolution scenarios. Domain-specific
// presets (Funko, Pokémon, Sports Cards, etc.) can build upon this
// configuration or replace individual components.
class StandardIdentityResolutionPreset
    implements IdentityResolutionPreset {
  const StandardIdentityResolutionPreset({
    required this.policy,
  });

  final IdentityPolicy policy;

  @override
  String get id => 'atlas.standard_resolution';

  @override
  String get name => 'Standard Identity Resolution';

  @override
  String get version => '1.0.0';

  @override
  IdentityResolutionConfiguration get configuration {
    return IdentityResolutionConfiguration(
      policy: policy,
      canonicalizationStrategy:
      ConservativeCanonicalizationStrategy(),
      options: IdentityResolutionOptions.standard,
    );
  }
}