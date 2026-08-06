import 'package:funkovault2/atlas/catalog/models/atlas_catalog_product.dart';
import 'package:funkovault2/atlas/collection/models/atlas_collector_state.dart';
import 'package:funkovault2/atlas/intelligence/models/atlas_collector_insight.dart';
import 'package:funkovault2/atlas/taxonomy/models/atlas_taxonomy.dart';
import 'package:funkovault2/models/pop.dart';

final class AtlasResolvedProduct {
  const AtlasResolvedProduct({
    required this.catalogProduct,
    required this.catalogPop,
    required this.collectorState,
    required this.taxonomy,
    required this.insight,
  });

  /// Canonical catalog record.
  final AtlasCatalogProduct catalogProduct;

  /// Temporary Pop generated from the catalog.
  ///
  /// Never written directly into the Vault.
  final Pop catalogPop;

  /// Ownership state.
  final AtlasCollectorState collectorState;

  /// Taxonomy hierarchy.
  final AtlasTaxonomy taxonomy;

  /// Collector recommendation.
  final AtlasCollectorInsight insight;

  bool get isOwned =>
      collectorState.isOwned;

  bool get isWishlisted =>
      collectorState.isWishlisted;

  bool get hasRelatedVariants =>
      collectorState.hasRelatedMatches;

  int get ownedQuantity =>
      collectorState.ownedQuantity;

  Pop? get primaryOwnedMatch =>
      collectorState.primaryOwnedMatch;

  Pop? get primaryWishlistMatch =>
      collectorState.primaryWishlistMatch;

  Pop get preferredDisplayPop {
    return primaryOwnedMatch ??
        primaryWishlistMatch ??
        catalogPop;
  }

  @override
  String toString() {
    return 'AtlasResolvedProduct('
        '${catalogProduct.displayName}, '
        'owned: $isOwned, '
        'wishlist: $isWishlisted, '
        'quantity: $ownedQuantity'
        ')';
  }
}