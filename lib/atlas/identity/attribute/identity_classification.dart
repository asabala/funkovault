// Defines how an identity attribute contributes to determining
// the canonical identity of a collectible.
enum IdentityClassification {
  defining,
  influencing,
  contextual,
  instanceOnly,
  unknown;

  // True when the attribute directly defines identity.
  bool get isDefining => this == IdentityClassification.defining;

  // True when the attribute influences comparisons.
  bool get isInfluencing => this == IdentityClassification.influencing;

  // True when the attribute provides useful context but normally
  // does not determine identity.
  bool get isContextual => this == IdentityClassification.contextual;

  // True when the attribute belongs only to a physical copy.
  bool get isInstanceOnly => this == IdentityClassification.instanceOnly;

  // True when Atlas has not yet classified this attribute.
  bool get isUnknown => this == IdentityClassification.unknown;

  // True when the attribute contributes to canonical identity.
  bool get contributesToIdentity {
    return isDefining || isInfluencing;
  }

  // Stable value used for persistence.
  String get serializedValue {
    switch (this) {
      case IdentityClassification.defining:
        return 'defining';

      case IdentityClassification.influencing:
        return 'influencing';

      case IdentityClassification.contextual:
        return 'contextual';

      case IdentityClassification.instanceOnly:
        return 'instance_only';

      case IdentityClassification.unknown:
        return 'unknown';
    }
  }

  // Restores an IdentityClassification from persisted data.
  static IdentityClassification fromSerializedValue(String value) {
    switch (value.trim().toLowerCase()) {
      case 'defining':
        return IdentityClassification.defining;

      case 'influencing':
        return IdentityClassification.influencing;

      case 'contextual':
        return IdentityClassification.contextual;

      case 'instance_only':
        return IdentityClassification.instanceOnly;

      default:
        return IdentityClassification.unknown;
    }
  }
}
