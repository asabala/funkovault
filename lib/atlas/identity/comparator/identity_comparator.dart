import '../../core/registry/atlas_module.dart';
import '../policy/identity_policy.dart';
import '../profile/identity_profile.dart';
import 'identity_comparator_result.dart';

// Defines one modular identity comparison strategy.
//
// Each comparator evaluates a specific part of identity, such as
// core anchors, variant modifiers, or release context.
abstract interface class IdentityComparator
    implements AtlasModule {
  // Determines whether this comparator should participate for the
  // supplied profiles and policy.
  bool supports({
    required IdentityProfile left,
    required IdentityProfile right,
    required IdentityPolicy policy,
  });

  // Compares the relevant identity attributes and returns structured
  // evidence without making the final platform-wide identity decision.
  IdentityComparatorResult compare({
    required IdentityProfile left,
    required IdentityProfile right,
    required IdentityPolicy policy,
  });
}