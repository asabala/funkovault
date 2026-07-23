// Identifies where an identity observation originated.
//
// Atlas uses source types to reason about confidence,
// traceability, and future conflict resolution.
enum IdentitySourceType {
  user,
  import,
  scanner,
  marketplace,
  catalog,
  ai,
  system;

  // Stable value used for persistence.
  String get serializedValue {
    switch (this) {
      case IdentitySourceType.user:
        return 'user';

      case IdentitySourceType.import:
        return 'import';

      case IdentitySourceType.scanner:
        return 'scanner';

      case IdentitySourceType.marketplace:
        return 'marketplace';

      case IdentitySourceType.catalog:
        return 'catalog';

      case IdentitySourceType.ai:
        return 'ai';

      case IdentitySourceType.system:
        return 'system';
    }
  }

  // Restores an IdentitySourceType from persisted data.
  static IdentitySourceType fromSerializedValue(String value) {
    switch (value.trim().toLowerCase()) {
      case 'user':
        return IdentitySourceType.user;

      case 'import':
        return IdentitySourceType.import;

      case 'scanner':
        return IdentitySourceType.scanner;

      case 'marketplace':
        return IdentitySourceType.marketplace;

      case 'catalog':
        return IdentitySourceType.catalog;

      case 'ai':
        return IdentitySourceType.ai;

      case 'system':
        return IdentitySourceType.system;

      default:
        throw ArgumentError.value(
          value,
          'value',
          'Unknown IdentitySourceType.',
        );
    }
  }

  // True when the observation originated from a person.
  bool get isHumanGenerated {
    return this == IdentitySourceType.user;
  }

  // True when the observation came from an automated process.
  bool get isAutomated {
    return !isHumanGenerated;
  }

  // True when the source is considered internal to Atlas.
  bool get isInternal {
    return this == IdentitySourceType.ai ||
        this == IdentitySourceType.system;
  }

  // True when the source originated outside Atlas.
  bool get isExternal {
    return !isInternal;
  }
}