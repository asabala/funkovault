import '../../attribute/identity_classification.dart';
import '../../attribute/identity_role.dart';
import '../../policy/identity_policy.dart';

// Default identity policy for Funko collectibles.
//
// This policy defines what Atlas considers important when determining
// whether two Funko collectibles represent the same canonical item.
abstract final class FunkoIdentityPolicy {
  static IdentityPolicy create() {
    return IdentityPolicy(
      name: 'Funko Identity Policy',
      version: '1.0.0',

      // These roles must always agree.
      requiredRoles: const <IdentityRole>{
        IdentityRole.entityAnchor,
        IdentityRole.catalogIndex,
      },

      // These strengthen identity but may not always exist.
      optionalRoles: const <IdentityRole>{
        IdentityRole.variantModifier,
        IdentityRole.releaseContext,
        IdentityRole.temporalMarker,
      },

      // Only these classifications participate.
      requiredClassifications: const <IdentityClassification>{
        IdentityClassification.defining,
        IdentityClassification.influencing,
      },

      minimumConfidence: 0.95,

      // Missing optional information should not prevent a match.
      allowPartialMatches: true,
    );
  }
}
