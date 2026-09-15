// Describes the scanned product's relationship to the user's Vault.
enum CollectorItemRelationship {
  notInVault,
  owned,
  wishlisted,
  ownedAndWishlisted,
  unknown,
}

// Immutable user-specific status for a scanned collectible.
//
// This data belongs to the collector and must remain separate from the
// shared catalog product.
class CollectorItemStatus {
  const CollectorItemStatus({
    this.relationship = CollectorItemRelationship.unknown,
    this.ownedQuantity = 0,
    this.collectionNames = const [],
    this.possibleDuplicateCount = 0,
  });

  final CollectorItemRelationship relationship;

  final int ownedQuantity;

  final List<String> collectionNames;

  final int possibleDuplicateCount;

  bool get isOwned {
    return relationship == CollectorItemRelationship.owned ||
        relationship == CollectorItemRelationship.ownedAndWishlisted;
  }

  bool get isWishlisted {
    return relationship == CollectorItemRelationship.wishlisted ||
        relationship == CollectorItemRelationship.ownedAndWishlisted;
  }

  bool get isNotInVault {
    return relationship == CollectorItemRelationship.notInVault;
  }

  bool get hasPossibleDuplicates {
    return possibleDuplicateCount > 0;
  }

  CollectorItemStatus copyWith({
    CollectorItemRelationship? relationship,
    int? ownedQuantity,
    List<String>? collectionNames,
    int? possibleDuplicateCount,
  }) {
    return CollectorItemStatus(
      relationship: relationship ?? this.relationship,
      ownedQuantity: ownedQuantity ?? this.ownedQuantity,
      collectionNames: collectionNames ?? this.collectionNames,
      possibleDuplicateCount:
          possibleDuplicateCount ?? this.possibleDuplicateCount,
    );
  }
}
