import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/atlas/catalog/models/atlas_catalog_attribute_keys.dart';
import 'package:funkovault2/atlas/catalog/models/atlas_catalog_product.dart';
import 'package:funkovault2/atlas/catalog/services/atlas_pop_factory.dart';
import 'package:funkovault2/atlas/identity/product/atlas_product_id.dart';

void main() {
  final timestamp = DateTime.utc(2026, 8, 18, 12);

  AtlasCatalogProduct catalogProduct({int id = 1}) {
    return AtlasCatalogProduct(
      productId: AtlasProductId.funko(numericId: id),
      displayName: 'Batman',
      categoryCode: 'FNK',
      productLine: 'Pop! Heroes',
      series: 'Batman',
      productNumber: '01',
      variantName: 'Metallic',
      barcodes: const ['889698000001'],
      attributes: const {
        AtlasCatalogAttributeKeys.imageUrl: 'https://images.example/batman.png',
        AtlasCatalogAttributeKeys.retailer: 'Target',
        AtlasCatalogAttributeKeys.eventName: 'SDCC',
        AtlasCatalogAttributeKeys.rarity: 'Limited Edition 1000',
        AtlasCatalogAttributeKeys.sourceProductId: 'source-123',
        AtlasCatalogAttributeKeys.productionStatus: 'Vaulted',
        AtlasCatalogAttributeKeys.releaseDate: '2010-01-01',
      },
    );
  }

  test('manual creation preserves condition and image inputs', () {
    final pop = AtlasPopFactory.createManual(
      name: ' Batman ',
      number: ' 01 ',
      category: ' Heroes ',
      series: ' Batman ',
      itemCondition: ' Mint ',
      boxCondition: ' Near Mint ',
      imageUrl: ' https://images.example/manual.png ',
      timestamp: timestamp,
    );

    expect(pop.itemCondition, 'Mint');
    expect(pop.boxCondition, 'Near Mint');
    expect(pop.imageUrl, 'https://images.example/manual.png');
  });

  test('catalog creation preserves converted metadata when omitted', () {
    final product = catalogProduct();
    final pop = AtlasPopFactory.createFromCatalog(
      product: product,
      timestamp: timestamp,
    );

    expect(pop.imageUrl, 'https://images.example/batman.png');
    expect(pop.retailExclusive, 'Target');
    expect(pop.eventSticker, 'SDCC');
    expect(pop.signature, 'Unsigned');
    expect(pop.sourceCatalogId, product.productId.value);
    expect(pop.sourceCollectibleId, 'source-123');
    expect(pop.sourceUpc, '889698000001');
    expect(pop.productionStatus, 'Vaulted');
    expect(pop.releaseDate, '2010-01-01');
    expect(pop.limitedEdition, 'Limited Edition 1000');
  });

  test('explicit catalog form overrides change only intended fields', () {
    final product = catalogProduct();
    final pop = AtlasPopFactory.createFromCatalog(
      product: product,
      retailExclusive: 'Hot Topic',
      eventSticker: 'NYCC',
      signature: 'Signed',
      imageUrl: 'https://images.example/custom.png',
      itemCondition: 'Excellent',
      boxCondition: 'Good',
      timestamp: timestamp,
    );

    expect(pop.retailExclusive, 'Hot Topic');
    expect(pop.eventSticker, 'NYCC');
    expect(pop.signature, 'Signed');
    expect(pop.imageUrl, 'https://images.example/custom.png');
    expect(pop.itemCondition, 'Excellent');
    expect(pop.boxCondition, 'Good');
    expect(pop.sourceCatalogId, product.productId.value);
    expect(pop.sourceCollectibleId, 'source-123');
    expect(pop.productionStatus, 'Vaulted');
  });

  test('same name and number do not collapse distinct catalog identity', () {
    final common = AtlasPopFactory.createFromCatalog(
      product: catalogProduct(id: 1),
      variant: 'Common',
      timestamp: timestamp,
    );
    final chase = AtlasPopFactory.createFromCatalog(
      product: catalogProduct(id: 2),
      variant: 'Chase',
      timestamp: timestamp.add(const Duration(microseconds: 1)),
    );

    expect(common.name, chase.name);
    expect(common.number, chase.number);
    expect(common.collectibleIdentityKey, isNot(chase.collectibleIdentityKey));
  });
}
