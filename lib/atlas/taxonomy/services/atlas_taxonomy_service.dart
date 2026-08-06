import 'package:funkovault2/atlas/catalog/models/atlas_catalog_product.dart';
import 'package:funkovault2/atlas/taxonomy/engines/atlas_taxonomy_engine.dart';
import 'package:funkovault2/atlas/taxonomy/models/atlas_taxonomy.dart';

final class AtlasTaxonomyService {
  AtlasTaxonomyService({
    AtlasTaxonomyEngine? engine,
  }) : _engine =
      engine ?? const AtlasTaxonomyEngine();

  static final AtlasTaxonomyService instance =
  AtlasTaxonomyService();

  final AtlasTaxonomyEngine _engine;

  final Map<String, AtlasTaxonomy>
  _taxonomyByProductId =
  <String, AtlasTaxonomy>{};

  AtlasTaxonomy resolve(
      AtlasCatalogProduct product,
      ) {
    final String productId =
    product.productId.value.trim();

    if (productId.isEmpty) {
      return _engine.resolve(
        product,
      );
    }

    return _taxonomyByProductId.putIfAbsent(
      productId,
          () {
        return _engine.resolve(
          product,
        );
      },
    );
  }

  List<AtlasTaxonomy> resolveAll(
      Iterable<AtlasCatalogProduct> products,
      ) {
    return List<AtlasTaxonomy>.unmodifiable(
      products.map(
        resolve,
      ),
    );
  }

  bool containsProduct(
      String productId,
      ) {
    final String normalizedId =
    productId.trim();

    if (normalizedId.isEmpty) {
      return false;
    }

    return _taxonomyByProductId.containsKey(
      normalizedId,
    );
  }

  AtlasTaxonomy? cachedTaxonomyFor(
      String productId,
      ) {
    final String normalizedId =
    productId.trim();

    if (normalizedId.isEmpty) {
      return null;
    }

    return _taxonomyByProductId[
    normalizedId];
  }

  int get cachedProductCount {
    return _taxonomyByProductId.length;
  }

  void clearCache() {
    _taxonomyByProductId.clear();
  }

  void removeFromCache(
      String productId,
      ) {
    final String normalizedId =
    productId.trim();

    if (normalizedId.isEmpty) {
      return;
    }

    _taxonomyByProductId.remove(
      normalizedId,
    );
  }
}