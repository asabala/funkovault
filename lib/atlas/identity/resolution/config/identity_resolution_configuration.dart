import '../../policy/identity_policy.dart';
import '../canonicalization_strategy.dart';
import 'identity_resolution_options.dart';

// Describes how an identity resolution run should execute.
//
// This object bundles together the policy, canonicalization strategy,
// and orchestration options used by the resolver. Future releases can
// extend this configuration with AI settings, merge behavior,
// marketplace rules, and category-specific defaults without changing
// the resolver API.
class IdentityResolutionConfiguration {
  const IdentityResolutionConfiguration({
    required this.policy,
    required this.canonicalizationStrategy,
    this.options = IdentityResolutionOptions.standard,
  });

  // Determines how identity comparisons are evaluated.
  final IdentityPolicy policy;

  // Produces the final canonical identity profiles.
  final CanonicalizationStrategy canonicalizationStrategy;

  // Controls resolver orchestration behavior.
  final IdentityResolutionOptions options;

  IdentityResolutionConfiguration copyWith({
    IdentityPolicy? policy,
    CanonicalizationStrategy? canonicalizationStrategy,
    IdentityResolutionOptions? options,
  }) {
    return IdentityResolutionConfiguration(
      policy: policy ?? this.policy,
      canonicalizationStrategy:
          canonicalizationStrategy ?? this.canonicalizationStrategy,
      options: options ?? this.options,
    );
  }

  Map<String, Object> toMap() {
    return <String, Object>{
      'policyVersion': policy.version,
      'canonicalizationStrategyId': canonicalizationStrategy.id,
      'canonicalizationStrategyVersion': canonicalizationStrategy.version,
      'options': options.toMap(),
    };
  }

  @override
  String toString() {
    return 'IdentityResolutionConfiguration('
        'policy: ${policy.name}, '
        'strategy: ${canonicalizationStrategy.name}, '
        'options: $options'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is IdentityResolutionConfiguration &&
            runtimeType == other.runtimeType &&
            policy == other.policy &&
            canonicalizationStrategy == other.canonicalizationStrategy &&
            options == other.options;
  }

  @override
  int get hashCode {
    return Object.hash(policy, canonicalizationStrategy, options);
  }
}
