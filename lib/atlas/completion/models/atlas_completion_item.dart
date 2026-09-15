import 'package:funkovault2/atlas/catalog/models/atlas_catalog_product.dart';
import 'package:funkovault2/atlas/taxonomy/models/atlas_taxonomy.dart';
import 'package:funkovault2/models/pop.dart';

enum AtlasCompletionItemState { owned, wishlisted, missing }

final class AtlasCompletionItem {
  const AtlasCompletionItem({
    required this.catalogProduct,
    required this.taxonomy,
    required this.state,
    required this.ownedQuantity,
    required this.ownedMatches,
    required this.wishlistMatches,
    required this.isWishlistOverlayActive,
    required this.releaseWeight,
  });

  final AtlasCatalogProduct catalogProduct;

  final AtlasTaxonomy taxonomy;

  final AtlasCompletionItemState state;

  final int ownedQuantity;

  final List<Pop> ownedMatches;

  final List<Pop> wishlistMatches;

  /// True when this release is tracked through the AppState Wishlist overlay
  /// rather than through a separate Wishlist-only Pop record.
  final bool isWishlistOverlayActive;

  /// Reserved for future weighted completion calculations.
  ///
  /// Version 1.0 continues treating one exact catalog release as one
  /// completion unit.
  final double releaseWeight;

  bool get isOwned {
    return state == AtlasCompletionItemState.owned;
  }

  bool get isWishlisted {
    return state == AtlasCompletionItemState.wishlisted;
  }

  bool get isMissing {
    return state == AtlasCompletionItemState.missing;
  }

  bool get hasOwnedMatches {
    return ownedMatches.isNotEmpty;
  }

  bool get hasWishlistMatches {
    return wishlistMatches.isNotEmpty;
  }

  bool get hasAnyWishlistState {
    return isWishlistOverlayActive || hasWishlistMatches;
  }

  String get productId {
    return catalogProduct.productId.value;
  }

  String get displayName {
    return catalogProduct.displayName;
  }

  String? get productNumber {
    return catalogProduct.productNumber;
  }

  String? get variantName {
    return catalogProduct.variantName;
  }

  AtlasCompletionItem copyWith({
    AtlasCatalogProduct? catalogProduct,
    AtlasTaxonomy? taxonomy,
    AtlasCompletionItemState? state,
    int? ownedQuantity,
    List<Pop>? ownedMatches,
    List<Pop>? wishlistMatches,
    bool? isWishlistOverlayActive,
    double? releaseWeight,
  }) {
    return AtlasCompletionItem(
      catalogProduct: catalogProduct ?? this.catalogProduct,
      taxonomy: taxonomy ?? this.taxonomy,
      state: state ?? this.state,
      ownedQuantity: ownedQuantity ?? this.ownedQuantity,
      ownedMatches: List<Pop>.unmodifiable(ownedMatches ?? this.ownedMatches),
      wishlistMatches: List<Pop>.unmodifiable(
        wishlistMatches ?? this.wishlistMatches,
      ),
      isWishlistOverlayActive:
          isWishlistOverlayActive ?? this.isWishlistOverlayActive,
      releaseWeight: releaseWeight ?? this.releaseWeight,
    );
  }

  factory AtlasCompletionItem.build({
    required AtlasCatalogProduct catalogProduct,
    required AtlasTaxonomy taxonomy,
    required Iterable<Pop> ownedMatches,
    required Iterable<Pop> wishlistMatches,
    bool isWishlistOverlayActive = false,
    double releaseWeight = 1,
  }) {
    final List<Pop> normalizedOwnedMatches = List<Pop>.unmodifiable(
      ownedMatches,
    );

    final List<Pop> normalizedWishlistMatches = List<Pop>.unmodifiable(
      wishlistMatches,
    );

    final int ownedQuantity = normalizedOwnedMatches.fold<int>(0, (
      int total,
      Pop pop,
    ) {
      return total + pop.quantity;
    });

    final bool hasWishlistState =
        isWishlistOverlayActive || normalizedWishlistMatches.isNotEmpty;

    final AtlasCompletionItemState state;

    if (ownedQuantity > 0) {
      state = AtlasCompletionItemState.owned;
    } else if (hasWishlistState) {
      state = AtlasCompletionItemState.wishlisted;
    } else {
      state = AtlasCompletionItemState.missing;
    }

    return AtlasCompletionItem(
      catalogProduct: catalogProduct,
      taxonomy: taxonomy,
      state: state,
      ownedQuantity: ownedQuantity,
      ownedMatches: normalizedOwnedMatches,
      wishlistMatches: normalizedWishlistMatches,
      isWishlistOverlayActive: isWishlistOverlayActive,
      releaseWeight: releaseWeight <= 0 ? 1 : releaseWeight,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AtlasCompletionItem && productId == other.productId;
  }

  @override
  int get hashCode {
    return productId.hashCode;
  }

  @override
  String toString() {
    return '$displayName • ${state.name}';
  }
}
