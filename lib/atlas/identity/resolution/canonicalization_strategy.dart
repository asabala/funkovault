import '../../core/registry/atlas_module.dart';
import '../comparison/identity_comparison_result.dart';
import '../profile/identity_profile.dart';

// Defines how Atlas converts candidate identity profiles into
// canonical identity profiles after comparison.
abstract interface class CanonicalizationStrategy
    implements AtlasModule {
  // Produces canonical identity profiles from candidate profiles.
  List<IdentityProfile> canonicalize({
    required List<IdentityProfile> candidates,
    required List<IdentityComparisonResult> comparisons,
  });
}