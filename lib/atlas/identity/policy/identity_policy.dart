import '../attribute/identity_classification.dart';
import '../attribute/identity_role.dart';

// Defines the rules used when comparing two identity profiles.
//
// Policies allow Atlas to adjust comparison behavior without changing
// the comparison engine itself.
class IdentityPolicy {
  IdentityPolicy({
    required this.name,
    required this.version,
    this.requiredRoles = const <IdentityRole>{},
    this.optionalRoles = const <IdentityRole>{},
    this.requiredClassifications = const <IdentityClassification>{},
    this.minimumConfidence = 0.90,
    this.allowPartialMatches = false,
  }) : assert(
         minimumConfidence >= 0.0 && minimumConfidence <= 1.0,
         'Minimum confidence must be between 0.0 and 1.0.',
       );

  // Human-readable policy name.
  final String name;

  // Policy version.
  final String version;

  // Roles that must match.
  final Set<IdentityRole> requiredRoles;

  // Roles that strengthen a comparison but are optional.
  final Set<IdentityRole> optionalRoles;

  // Attribute classifications that participate in comparison.
  final Set<IdentityClassification> requiredClassifications;

  // Minimum confidence required for a successful match.
  final double minimumConfidence;

  // Whether incomplete profiles may still match.
  final bool allowPartialMatches;

  bool requiresRole(IdentityRole role) {
    return requiredRoles.contains(role);
  }

  bool isOptionalRole(IdentityRole role) {
    return optionalRoles.contains(role);
  }

  bool includesClassification(IdentityClassification classification) {
    return requiredClassifications.contains(classification);
  }

  IdentityPolicy copyWith({
    String? name,
    String? version,
    Set<IdentityRole>? requiredRoles,
    Set<IdentityRole>? optionalRoles,
    Set<IdentityClassification>? requiredClassifications,
    double? minimumConfidence,
    bool? allowPartialMatches,
  }) {
    return IdentityPolicy(
      name: name ?? this.name,
      version: version ?? this.version,
      requiredRoles: requiredRoles ?? this.requiredRoles,
      optionalRoles: optionalRoles ?? this.optionalRoles,
      requiredClassifications:
          requiredClassifications ?? this.requiredClassifications,
      minimumConfidence: minimumConfidence ?? this.minimumConfidence,
      allowPartialMatches: allowPartialMatches ?? this.allowPartialMatches,
    );
  }

  @override
  String toString() {
    return 'IdentityPolicy('
        'name: $name, '
        'version: $version, '
        'requiredRoles: ${requiredRoles.length}, '
        'optionalRoles: ${optionalRoles.length}, '
        'minimumConfidence: $minimumConfidence'
        ')';
  }
}
