import 'package:flutter/foundation.dart';

import 'package:funkovault2/models/pop.dart';

@immutable
class AtlasCollectorState {
  AtlasCollectorState({
    required List<Pop> ownedMatches,
    required List<Pop> wishlistMatches,
    required List<Pop> relatedMatches,
    this.isOwnedWishlisted = false,
  }) : ownedMatches = List<Pop>.unmodifiable(ownedMatches),
       wishlistMatches = List<Pop>.unmodifiable(wishlistMatches),
       relatedMatches = List<Pop>.unmodifiable(relatedMatches);

  factory AtlasCollectorState.empty() {
    return AtlasCollectorState(
      ownedMatches: const <Pop>[],
      wishlistMatches: const <Pop>[],
      relatedMatches: const <Pop>[],
    );
  }

  final List<Pop> ownedMatches;
  final List<Pop> wishlistMatches;
  final List<Pop> relatedMatches;

  /// True when an owned collectible is also tracked through the
  /// AppState Wishlist overlay.
  final bool isOwnedWishlisted;

  bool get isOwned {
    return ownedMatches.isNotEmpty;
  }

  bool get hasWishlistRecord {
    return wishlistMatches.isNotEmpty;
  }

  bool get isWishlisted {
    return isOwnedWishlisted || hasWishlistRecord;
  }

  bool get hasRelatedMatches {
    return relatedMatches.isNotEmpty;
  }

  int get ownedQuantity {
    return ownedMatches.fold<int>(0, (int total, Pop pop) {
      return total + pop.quantity;
    });
  }

  Pop? get primaryOwnedMatch {
    if (ownedMatches.isEmpty) {
      return null;
    }

    return ownedMatches.first;
  }

  Pop? get primaryWishlistMatch {
    if (wishlistMatches.isEmpty) {
      return null;
    }

    return wishlistMatches.first;
  }

  Pop? get bestExistingMatch {
    return primaryOwnedMatch ?? primaryWishlistMatch;
  }

  List<Pop> get allExactMatches {
    return List<Pop>.unmodifiable(<Pop>[...ownedMatches, ...wishlistMatches]);
  }

  AtlasCollectorState copyWith({
    List<Pop>? ownedMatches,
    List<Pop>? wishlistMatches,
    List<Pop>? relatedMatches,
    bool? isOwnedWishlisted,
  }) {
    return AtlasCollectorState(
      ownedMatches: ownedMatches ?? this.ownedMatches,
      wishlistMatches: wishlistMatches ?? this.wishlistMatches,
      relatedMatches: relatedMatches ?? this.relatedMatches,
      isOwnedWishlisted: isOwnedWishlisted ?? this.isOwnedWishlisted,
    );
  }

  @override
  String toString() {
    return 'AtlasCollectorState('
        'owned: ${ownedMatches.length}, '
        'ownedQuantity: $ownedQuantity, '
        'wishlistRecords: ${wishlistMatches.length}, '
        'ownedWishlisted: $isOwnedWishlisted, '
        'related: ${relatedMatches.length}'
        ')';
  }
}
