import '../../core/registry/atlas_registry.dart';
import '../policy/identity_policy.dart';
import '../profile/identity_profile.dart';
import 'core_anchor_comparator.dart';
import 'identity_comparator.dart';
import 'identity_comparator_result.dart';
import 'release_context_comparator.dart';
import 'variant_comparator.dart';

// Registry containing the available identity comparators.
//
// Generic registration and discovery behavior is delegated to
// AtlasRegistry while this class retains identity-specific execution.
class IdentityComparatorRegistry {
  IdentityComparatorRegistry(List<IdentityComparator> comparators)
    : _registry = AtlasRegistry<IdentityComparator>(comparators);

  // Creates the standard Atlas identity comparator registry.
  factory IdentityComparatorRegistry.standard() {
    return IdentityComparatorRegistry(const <IdentityComparator>[
      CoreAnchorComparator(),
      VariantComparator(),
      ReleaseContextComparator(),
    ]);
  }

  final AtlasRegistry<IdentityComparator> _registry;

  List<IdentityComparator> get comparators {
    return _registry.modules;
  }

  bool get isEmpty => _registry.isEmpty;

  bool get isNotEmpty => _registry.isNotEmpty;

  int get length => _registry.length;

  Set<String> get comparatorIds => _registry.ids;

  Map<String, String> get comparatorVersions {
    return _registry.versions;
  }

  // Returns a comparator by its stable identifier.
  IdentityComparator? byId(String id) {
    return _registry.byId(id);
  }

  // Returns whether a comparator with the supplied identifier exists.
  bool contains(String id) {
    return _registry.contains(id);
  }

  // Returns only the comparators that support the supplied comparison.
  List<IdentityComparator> supportedComparators({
    required IdentityProfile left,
    required IdentityProfile right,
    required IdentityPolicy policy,
  }) {
    return _registry.where((IdentityComparator comparator) {
      return comparator.supports(left: left, right: right, policy: policy);
    });
  }

  // Executes every supported comparator and returns structured results.
  //
  // The registry gathers specialist results but does not make the final
  // platform-wide identity decision.
  List<IdentityComparatorResult> compare({
    required IdentityProfile left,
    required IdentityProfile right,
    required IdentityPolicy policy,
  }) {
    final List<IdentityComparatorResult> results = <IdentityComparatorResult>[];

    final List<IdentityComparator> supported = supportedComparators(
      left: left,
      right: right,
      policy: policy,
    );

    for (final IdentityComparator comparator in supported) {
      results.add(comparator.compare(left: left, right: right, policy: policy));
    }

    return List<IdentityComparatorResult>.unmodifiable(results);
  }
}
