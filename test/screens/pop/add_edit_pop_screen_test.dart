import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/atlas/catalog/models/atlas_catalog_attribute_keys.dart';
import 'package:funkovault2/atlas/catalog/models/atlas_catalog_product.dart';
import 'package:funkovault2/atlas/identity/product/atlas_product_id.dart';
import 'package:funkovault2/atlas/scan/authenticity/models/atlas_visual_inspection.dart';
import 'package:funkovault2/models/activity.dart';
import 'package:funkovault2/models/pop.dart';
import 'package:funkovault2/screens/pop/add_pop_screen.dart';
import 'package:funkovault2/screens/pop/edit_pop_screen.dart';
import 'package:funkovault2/services/app_state.dart';
import 'package:funkovault2/widgets/atlas/components/atlas_form_field.dart';
import 'package:provider/provider.dart';

class _TestAppState extends AppState {
  Pop? addedPop;
  Pop? updatedPop;
  String? addedCollectionName;
  String? updatedCollectionName;
  String? updatedExistingRecordKey;
  bool addResult = true;

  @override
  Future<bool> addPop(Pop pop, {String? collectionName}) async {
    addedPop = pop;
    addedCollectionName = collectionName;

    return addResult;
  }

  @override
  Future<Pop?> updatePop(
    Pop pop, {
    String? collectionName,
    String? existingRecordKey,
  }) async {
    updatedPop = pop.copyWith(lastUpdated: '2026-08-18T12:00:00.000Z');
    updatedCollectionName = collectionName;
    updatedExistingRecordKey = existingRecordKey;

    return updatedPop;
  }

  @override
  Future<void> addActivity(Activity activity) async {}
}

void main() {
  Finder field(String label) {
    return find.descendant(
      of: find.byWidgetPredicate(
        (widget) => widget is AtlasFormField && widget.label == label,
      ),
      matching: find.byType(TextFormField),
    );
  }

  void useLargeTestSurface(WidgetTester tester) {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 8000);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
  }

  Future<void> enterField(
    WidgetTester tester,
    String label,
    String value,
  ) async {
    final finder = field(label);
    await tester.ensureVisible(finder);
    await tester.enterText(finder, value);
  }

  Future<void> tapSave(WidgetTester tester, String label) async {
    final button = find.widgetWithText(FilledButton, label);
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('Add rejects invalid required and numeric values', (
    tester,
  ) async {
    useLargeTestSurface(tester);
    final state = _TestAppState();

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: const MaterialApp(home: AddPopScreen()),
      ),
    );

    await enterField(tester, 'Estimated Value (\$)', '-1');
    await enterField(tester, 'Price Paid (\$)', 'invalid');
    await enterField(tester, 'Quantity', '0');
    await tapSave(tester, 'Save Pop');

    expect(find.text('Pop name is required.'), findsOneWidget);
    expect(state.addedPop, isNull);
  });

  testWidgets('Edit validates and preserves every unrepresented field', (
    tester,
  ) async {
    useLargeTestSurface(tester);
    final original = Pop(
      id: 'stable-id',
      name: 'Batman',
      number: '01',
      category: 'Heroes',
      series: 'Batman',
      edition: 'First Edition',
      variant: 'Metallic',
      retailExclusive: 'Target',
      eventSticker: 'SDCC',
      limitedEdition: 'LE 1000',
      signature: 'Signed',
      sourceCatalogId: 'ATLAS-FNK-000001',
      sourceCollectibleId: 'source-1',
      sourceUpc: '889698000001',
      productionStatus: 'Vaulted',
      releaseDate: '2010-01-01',
      gradingCompany: 'PSA',
      authenticityNumber: 'AUTH-1',
      finish: 'Metallic',
      size: '6 Inch',
      packagingType: 'Two Pack',
      boxVersion: 'International',
      copyrightYear: '2010',
      productionCode: 'PROD-1',
      stickerType: 'Convention',
      authenticationProvider: 'JSA',
      value: 25,
      pricePaid: 10,
      quantity: 1,
      itemCondition: 'Mint',
      boxCondition: 'Near Mint',
      imageUrl: '',
      owner: 'Imported Owner',
      isWishlist: true,
      dateAdded: '2026-01-01T00:00:00.000Z',
      lastUpdated: '2026-02-01T00:00:00.000Z',
    );
    final state = _TestAppState();
    Pop? result;

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                onPressed: () async {
                  result = await Navigator.push<Pop>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditPopScreen(
                        pop: original,
                        collectionName: 'Arthur Collection',
                      ),
                    ),
                  );
                },
                child: const Text('Open Edit'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Edit'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await enterField(tester, 'Quantity', '0');
    await tapSave(tester, 'Save Changes');

    expect(
      find.text('Enter a whole-number quantity of 1 or more.'),
      findsOneWidget,
    );
    expect(result, isNull);

    await enterField(tester, 'Pop Name', 'Batman Updated');
    await enterField(tester, 'Estimated Value (\$)', '40');
    await enterField(tester, 'Quantity', '2');
    await enterField(tester, 'Item Condition', 'Excellent');
    await enterField(tester, 'Box Condition', 'Good');
    await enterField(tester, 'Image URL', 'new-image');
    await tester.tap(find.text('Authenticity & Details'));
    await tester.pumpAndSettle();
    await enterField(tester, 'Production Code', 'FAC-NEW');
    await enterField(tester, 'Copyright Year', '2011');
    await enterField(tester, 'Sticker Type', 'Shared Convention');
    await enterField(tester, 'Signature Details', 'Kevin Conroy');
    await enterField(tester, 'Authentication Provider', 'Beckett');
    await enterField(tester, 'Authenticity Number', 'BAS-2');
    await tapSave(tester, 'Save Changes');

    expect(result, isNotNull);
    expect(result, same(state.updatedPop));
    expect(result!.name, 'Batman Updated');
    expect(result!.value, 40);
    expect(result!.quantity, 2);
    expect(result!.itemCondition, 'Excellent');
    expect(result!.boxCondition, 'Good');
    expect(result!.imageUrl, 'new-image');
    expect(result!.owner, 'Imported Owner');
    expect(result!.edition, original.edition);
    expect(result!.sourceCatalogId, original.sourceCatalogId);
    expect(result!.sourceCollectibleId, original.sourceCollectibleId);
    expect(result!.sourceUpc, original.sourceUpc);
    expect(result!.productionStatus, original.productionStatus);
    expect(result!.releaseDate, original.releaseDate);
    expect(result!.gradingCompany, original.gradingCompany);
    expect(result!.authenticityNumber, 'BAS-2');
    expect(result!.finish, original.finish);
    expect(result!.size, original.size);
    expect(result!.packagingType, original.packagingType);
    expect(result!.boxVersion, original.boxVersion);
    expect(result!.copyrightYear, '2011');
    expect(result!.productionCode, 'FAC-NEW');
    expect(result!.stickerType, 'Shared Convention');
    expect(result!.signature, 'Kevin Conroy');
    expect(result!.authenticationProvider, 'Beckett');
    expect(result!.isWishlist, isTrue);
    expect(result!.dateAdded, original.dateAdded);
    expect(state.updatedCollectionName, 'Arthur Collection');
    expect(state.updatedExistingRecordKey, original.collectionRecordKey);
  });

  testWidgets('catalog Add preserves converted metadata and image', (
    tester,
  ) async {
    useLargeTestSurface(tester);
    final state = _TestAppState();
    final product = AtlasCatalogProduct(
      productId: AtlasProductId.funko(numericId: 1),
      displayName: 'Batman',
      categoryCode: 'FNK',
      series: 'Batman',
      productNumber: '01',
      barcodes: const ['889698000001'],
      attributes: const {
        AtlasCatalogAttributeKeys.imageUrl: 'catalog-image',
        AtlasCatalogAttributeKeys.retailer: 'Target',
        AtlasCatalogAttributeKeys.eventName: 'SDCC',
        AtlasCatalogAttributeKeys.sourceProductId: 'source-1',
        AtlasCatalogAttributeKeys.productionStatus: 'Vaulted',
      },
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(
          home: AddPopScreen(
            atlasProduct: product,
            collectionName: 'Arthur Collection',
            visualInspection: AtlasVisualInspection(
              productionStampText: 'JJL 240815',
              copyrightText: '2024',
              stickerText: 'Special Edition',
              signature: 'Jane Doe',
              authenticationProvider: 'JSA',
              authenticityNumber: 'JSA-123',
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tapSave(tester, 'Save Pop');

    final saved = state.addedPop!;
    expect(saved.imageUrl, 'catalog-image');
    expect(saved.retailExclusive, 'Target');
    expect(saved.eventSticker, 'SDCC');
    expect(saved.sourceCatalogId, product.productId.value);
    expect(saved.sourceCollectibleId, 'source-1');
    expect(saved.sourceUpc, '889698000001');
    expect(saved.productionStatus, 'Vaulted');
    expect(saved.productionCode, 'JJL 240815');
    expect(saved.copyrightYear, '2024');
    expect(saved.stickerType, 'Special Edition');
    expect(saved.signature, 'Jane Doe');
    expect(saved.authenticationProvider, 'JSA');
    expect(saved.authenticityNumber, 'JSA-123');
    expect(state.addedCollectionName, 'Arthur Collection');
  });

  testWidgets('Add keeps the form open when the target collection is missing', (
    tester,
  ) async {
    useLargeTestSurface(tester);
    final state = _TestAppState()..addResult = false;

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: const MaterialApp(
          home: AddPopScreen(collectionName: 'Missing Collection'),
        ),
      ),
    );

    await enterField(tester, 'Pop Name', 'Batman');
    await tapSave(tester, 'Save Pop');

    expect(state.addedPop, isNotNull);
    expect(state.addedCollectionName, 'Missing Collection');
    expect(
      find.text('This collection could not be found. The Pop was not added.'),
      findsOneWidget,
    );
    expect(find.byType(AddPopScreen), findsOneWidget);
  });
}
