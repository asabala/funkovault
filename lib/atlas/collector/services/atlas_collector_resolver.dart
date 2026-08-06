import 'package:funkovault2/atlas/catalog/converters/atlas_catalog_converter.dart';
import 'package:funkovault2/atlas/catalog/models/atlas_catalog_product.dart';
import 'package:funkovault2/atlas/collection/engine/atlas_collector_state_engine.dart';
import 'package:funkovault2/atlas/collection/models/atlas_collector_state.dart';
import 'package:funkovault2/atlas/collector/models/atlas_resolved_product.dart';
import 'package:funkovault2/atlas/intelligence/engines/atlas_collector_insight_engine.dart';
import 'package:funkovault2/atlas/intelligence/models/atlas_collector_insight.dart';
import 'package:funkovault2/atlas/taxonomy/models/atlas_taxonomy.dart';
import 'package:funkovault2/atlas/taxonomy/services/atlas_taxonomy_service.dart';
import 'package:funkovault2/models/pop.dart';

final class AtlasCollectorResolver {
  AtlasCollectorResolver({
    AtlasCollectorStateEngine? collectorStateEngine,
    AtlasCollectorInsightEngine? collectorInsightEngine,
    AtlasTaxonomyService? taxonomyService,
  })  : _collectorStateEngine =
      collectorStateEngine ??
          const AtlasCollectorStateEngine(),
        _collectorInsightEngine =
            collectorInsightEngine ??
                const AtlasCollectorInsightEngine(),
        _taxonomyService =
            taxonomyService ??
                AtlasTaxonomyService.instance;

  static final AtlasCollectorResolver instance =
  AtlasCollectorResolver();

  final AtlasCollectorStateEngine
  _collectorStateEngine;

  final AtlasCollectorInsightEngine
  _collectorInsightEngine;

  final AtlasTaxonomyService
  _taxonomyService;

  AtlasResolvedProduct resolve({
    required AtlasCatalogProduct catalogProduct,
    required List<Pop> collectionPops,
    Set<String> ownedWishlistIdentityKeys =
    const <String>{},
    String collectionName =
    'All Atlas Collections',
    String source =
    'Atlas Collector Resolver',
    String scannedBarcode = '',
    DateTime? conversionTimestamp,
  }) {
    final Pop catalogPop =
    AtlasCatalogConverter.toPop(
      catalogProduct,
      owner: 'Atlas Catalog',
      quantity: 1,
      timestamp: conversionTimestamp,
    );

    final AtlasCollectorState collectorState =
    _collectorStateEngine.evaluate(
      product: catalogPop,
      collectionPops: collectionPops,
      scannedBarcode: scannedBarcode,
      ownedWishlistIdentityKeys:
      ownedWishlistIdentityKeys,
    );

    final AtlasTaxonomy taxonomy =
    _taxonomyService.resolve(
      catalogProduct,
    );

    final AtlasCollectorInsight insight =
    _collectorInsightEngine.evaluateProduct(
      product: catalogPop,
      collectionPops: collectionPops,
      collectionName: collectionName,
      ownedWishlistIdentityKeys:
      ownedWishlistIdentityKeys,
      source: source,
    );

    return AtlasResolvedProduct(
      catalogProduct: catalogProduct,
      catalogPop: catalogPop,
      collectorState: collectorState,
      taxonomy: taxonomy,
      insight: insight,
    );
  }

  List<AtlasResolvedProduct> resolveAll({
    required Iterable<AtlasCatalogProduct>
    catalogProducts,
    required List<Pop> collectionPops,
    Set<String> ownedWishlistIdentityKeys =
    const <String>{},
    String collectionName =
    'All Atlas Collections',
    String source =
    'Atlas Collector Resolver',
  }) {
    final DateTime batchTimestamp =
    DateTime.now();

    final List<AtlasResolvedProduct>
    resolvedProducts =
    <AtlasResolvedProduct>[];

    int productIndex = 0;

    for (final AtlasCatalogProduct catalogProduct
    in catalogProducts) {
      resolvedProducts.add(
        resolve(
          catalogProduct: catalogProduct,
          collectionPops: collectionPops,
          ownedWishlistIdentityKeys:
          ownedWishlistIdentityKeys,
          collectionName: collectionName,
          source: source,
          conversionTimestamp:
          batchTimestamp.add(
            Duration(
              microseconds: productIndex,
            ),
          ),
        ),
      );

      productIndex++;
    }

    return List<AtlasResolvedProduct>.unmodifiable(
      resolvedProducts,
    );
  }

  AtlasResolvedProduct resolveForBarcode({
    required AtlasCatalogProduct catalogProduct,
    required String scannedBarcode,
    required List<Pop> collectionPops,
    Set<String> ownedWishlistIdentityKeys =
    const <String>{},
    String collectionName =
    'All Atlas Collections',
    String source =
    'Atlas Barcode Resolver',
  }) {
    return resolve(
      catalogProduct: catalogProduct,
      collectionPops: collectionPops,
      ownedWishlistIdentityKeys:
      ownedWishlistIdentityKeys,
      collectionName: collectionName,
      source: source,
      scannedBarcode: scannedBarcode,
    );
  }
}