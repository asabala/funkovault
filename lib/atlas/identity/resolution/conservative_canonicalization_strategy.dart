import '../comparison/identity_comparison_result.dart';
import '../profile/identity_profile.dart';
import 'canonicalization_strategy.dart';

// Default Atlas canonicalization strategy.
//
// This implementation never attempts to merge profiles.
// Only unique candidate identities are preserved.
//
// Future strategies may merge compatible profiles once
// Atlas has stronger conflict-resolution policies.
class ConservativeCanonicalizationStrategy implements CanonicalizationStrategy {
  @override
  String get id => 'atlas.conservative_canonicalization';

  @override
  String get name => 'Conservative Canonicalization';

  @override
  String get version => '1.0.0';

  @override
  List<IdentityProfile> canonicalize({
    required List<IdentityProfile> candidates,
    required List<IdentityComparisonResult> comparisons,
  }) {
    return List<IdentityProfile>.unmodifiable(candidates);
  }
}
