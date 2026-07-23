// Represents the universal role an identity attribute plays.
//
// Roles provide a category-neutral language that every collectible
// adapter maps into before identity comparison begins.
enum IdentityRole {
  category,
  maker,
  entityAnchor,
  catalogIndex,
  primaryDescriptor,
  temporalMarker,
  releaseContext,
  variantModifier;

  // Stable value used for persistence.
  String get serializedValue {
    switch (this) {
      case IdentityRole.category:
        return 'category';

      case IdentityRole.maker:
        return 'maker';

      case IdentityRole.entityAnchor:
        return 'entity_anchor';

      case IdentityRole.catalogIndex:
        return 'catalog_index';

      case IdentityRole.primaryDescriptor:
        return 'primary_descriptor';

      case IdentityRole.temporalMarker:
        return 'temporal_marker';

      case IdentityRole.releaseContext:
        return 'release_context';

      case IdentityRole.variantModifier:
        return 'variant_modifier';
    }
  }

  // Restores an IdentityRole from persisted data.
  static IdentityRole fromSerializedValue(String value) {
    switch (value.trim().toLowerCase()) {
      case 'category':
        return IdentityRole.category;

      case 'maker':
        return IdentityRole.maker;

      case 'entity_anchor':
        return IdentityRole.entityAnchor;

      case 'catalog_index':
        return IdentityRole.catalogIndex;

      case 'primary_descriptor':
        return IdentityRole.primaryDescriptor;

      case 'temporal_marker':
        return IdentityRole.temporalMarker;

      case 'release_context':
        return IdentityRole.releaseContext;

      case 'variant_modifier':
        return IdentityRole.variantModifier;

      default:
        throw ArgumentError.value(
          value,
          'value',
          'Unknown IdentityRole.',
        );
    }
  }

  // Indicates whether this role contributes directly to canonical identity.
  bool get contributesToIdentity {
    switch (this) {
      case IdentityRole.category:
      case IdentityRole.maker:
      case IdentityRole.entityAnchor:
      case IdentityRole.catalogIndex:
      case IdentityRole.primaryDescriptor:
      case IdentityRole.temporalMarker:
      case IdentityRole.releaseContext:
      case IdentityRole.variantModifier:
        return true;
    }
  }
}