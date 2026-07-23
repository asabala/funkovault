import '../engine/identity_decision_engine.dart';
import 'config/identity_resolution_preset.dart';
import 'default_identity_resolver.dart';
import 'identity_resolver.dart';

// Creates identity resolvers from reusable resolution presets.
//
// The factory centralizes resolver construction so screens, services,
// and domain modules do not need to assemble engine dependencies.
class IdentityResolverFactory {
  const IdentityResolverFactory._();

  static IdentityResolver fromPreset({
    required IdentityResolutionPreset preset,
    IdentityDecisionEngine decisionEngine =
    const IdentityDecisionEngine(),
  }) {
    return DefaultIdentityResolver(
      decisionEngine: decisionEngine,
      configuration: preset.configuration,
    );
  }
}