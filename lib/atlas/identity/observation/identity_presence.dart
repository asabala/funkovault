// Indicates whether an identity value is known, unknown,
// intentionally not applicable, or currently conflicting.
enum IdentityPresence {
  known,
  unknown,
  notApplicable,
  conflicting;

  // True when the attribute has a trusted value.
  bool get isKnown => this == IdentityPresence.known;

  // True when Atlas has not yet determined the value.
  bool get isUnknown => this == IdentityPresence.unknown;

  // True when the value does not apply to this collectible.
  bool get isNotApplicable => this == IdentityPresence.notApplicable;

  // True when multiple credible observations disagree.
  bool get isConflicting => this == IdentityPresence.conflicting;

  // Stable value used for persistence.
  String get serializedValue {
    switch (this) {
      case IdentityPresence.known:
        return 'known';
      case IdentityPresence.unknown:
        return 'unknown';
      case IdentityPresence.notApplicable:
        return 'not_applicable';
      case IdentityPresence.conflicting:
        return 'conflicting';
    }
  }

  // Restores an IdentityPresence from persisted data.
  static IdentityPresence fromSerializedValue(String value) {
    switch (value.trim().toLowerCase()) {
      case 'known':
        return IdentityPresence.known;
      case 'unknown':
        return IdentityPresence.unknown;
      case 'not_applicable':
        return IdentityPresence.notApplicable;
      case 'conflicting':
        return IdentityPresence.conflicting;
      default:
        return IdentityPresence.unknown;
    }
  }
}
