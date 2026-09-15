import '../attribute/identity_attribute.dart';
import '../attribute/identity_role.dart';

// Represents the resolved identity of a collectible.
//
// A profile contains all resolved identity attributes for a collectible
// while preserving the evidence used to determine those values.
class IdentityProfile {
  IdentityProfile({required this.attributes});

  // All identity attributes.
  final List<IdentityAttribute> attributes;

  // Returns true when no attributes exist.
  bool get isEmpty => attributes.isEmpty;

  // Returns true when at least one attribute exists.
  bool get isNotEmpty => attributes.isNotEmpty;

  // Returns only attributes that contribute to identity.
  List<IdentityAttribute> get identityAttributes {
    return List<IdentityAttribute>.unmodifiable(
      attributes.where(
        (IdentityAttribute attribute) => attribute.contributesToIdentity,
      ),
    );
  }

  // Returns all attributes with resolved values.
  List<IdentityAttribute> get resolvedAttributes {
    return List<IdentityAttribute>.unmodifiable(
      attributes.where(
        (IdentityAttribute attribute) => attribute.hasResolvedValue,
      ),
    );
  }

  // Looks up an attribute by its category-specific key.
  IdentityAttribute? attributeByKey(String key) {
    for (final attribute in attributes) {
      if (attribute.key == key) {
        return attribute;
      }
    }

    return null;
  }

  // Looks up an attribute by its universal role.
  IdentityAttribute? attributeByRole(IdentityRole role) {
    for (final attribute in attributes) {
      if (attribute.role == role) {
        return attribute;
      }
    }

    return null;
  }

  List<IdentityAttribute> attributesByRole(IdentityRole role) {
    return attributes
        .where((attribute) => attribute.role == role)
        .toList(growable: false);
  }

  // Creates a modified copy.
  IdentityProfile copyWith({List<IdentityAttribute>? attributes}) {
    return IdentityProfile(
      attributes: List<IdentityAttribute>.unmodifiable(
        attributes ?? this.attributes,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'attributes': attributes
          .map((IdentityAttribute attribute) => attribute.toJson())
          .toList(growable: false),
    };
  }

  factory IdentityProfile.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawAttributes =
        json['attributes'] as List<dynamic>? ?? const <dynamic>[];

    return IdentityProfile(
      attributes: List<IdentityAttribute>.unmodifiable(
        rawAttributes.map(
          (dynamic attribute) => IdentityAttribute.fromJson(
            Map<String, dynamic>.from(attribute as Map<dynamic, dynamic>),
          ),
        ),
      ),
    );
  }

  @override
  String toString() {
    return 'IdentityProfile('
        'attributes: ${attributes.length}'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is IdentityProfile && _listsEqual(attributes, other.attributes);
  }

  @override
  int get hashCode => Object.hashAll(attributes);

  static bool _listsEqual<T>(List<T> first, List<T> second) {
    if (identical(first, second)) {
      return true;
    }

    if (first.length != second.length) {
      return false;
    }

    for (int index = 0; index < first.length; index++) {
      if (first[index] != second[index]) {
        return false;
      }
    }

    return true;
  }
}
