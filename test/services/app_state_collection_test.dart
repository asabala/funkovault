import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/models/pop.dart';
import 'package:funkovault2/services/app_state.dart';
import 'package:funkovault2/services/hive_service.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory hiveDirectory;

  setUpAll(() async {
    hiveDirectory = await Directory.systemTemp.createTemp(
      'app_state_collection_test_',
    );
    Hive.init(hiveDirectory.path);
    await Hive.openBox(HiveService.boxName);
  });

  setUp(() async {
    await Hive.box(HiveService.boxName).clear();
  });

  tearDownAll(() async {
    await Hive.close();
    await hiveDirectory.delete(recursive: true);
  });

  Pop pop({
    String id = 'pop-1',
    String name = 'Batman',
    String variant = 'Common',
    String owner = 'Shared',
  }) {
    return Pop(
      id: id,
      name: name,
      number: '01',
      category: 'Heroes',
      series: 'Batman',
      variant: variant,
      value: 25,
      pricePaid: 10,
      quantity: 1,
      itemCondition: 'Mint',
      boxCondition: 'Near Mint',
      imageUrl: '',
      owner: owner,
      isWishlist: false,
    );
  }

  test('creation trims names and rejects invalid or duplicate names', () async {
    final state = AppState();

    expect(
      await state.addCollection('  Display Room  '),
      CollectionOperationResult.success,
    );
    expect(state.collectionNames, contains('Display Room'));
    expect(
      await state.addCollection('   '),
      CollectionOperationResult.invalidName,
    );
    expect(
      await state.addCollection('display room'),
      CollectionOperationResult.duplicateName,
    );
  });

  test('valid selection persists and invalid selection is rejected', () async {
    final state = AppState();
    await state.addCollection('Display Room');

    expect(
      await state.setSelectedCollection(' display room '),
      CollectionOperationResult.success,
    );
    expect(state.selectedCollection, 'Display Room');

    expect(
      await state.setSelectedCollection('Missing Room'),
      CollectionOperationResult.notFound,
    );
    expect(state.selectedCollection, 'Display Room');

    final reloadedState = AppState();
    await reloadedState.loadData();

    expect(reloadedState.selectedCollection, 'Display Room');
  });

  test('deletion is explicit and always preserves one collection', () async {
    final state = AppState();

    expect(
      await state.deleteCollection('Missing Room'),
      CollectionOperationResult.notFound,
    );
    expect(
      await state.deleteCollection('Arthur Collection'),
      CollectionOperationResult.success,
    );
    expect(
      await state.deleteCollection('Entire Family Collection'),
      CollectionOperationResult.lastCollection,
    );
    expect(state.collectionNames, ['Entire Family Collection']);
  });

  test(
    'deleting the active collection selects a remaining collection',
    () async {
      final state = AppState();
      await state.setSelectedCollection('Arthur Collection');

      expect(
        await state.deleteCollection('Arthur Collection'),
        CollectionOperationResult.success,
      );
      expect(state.selectedCollection, 'Entire Family Collection');
      expect(state.hasCollection('Arthur Collection'), isFalse);
    },
  );

  test('rename migrates Pops, overlay, order, and active selection', () async {
    final state = AppState();
    final storedPop = pop();
    await state.addPop(storedPop);
    await state.addOwnedPopToWishlist(storedPop);
    final persistedBeforeRename = state.selectedCollectionPops.single;

    expect(
      await state.renameCollection(
        'Entire Family Collection',
        '  Family Vault  ',
      ),
      CollectionOperationResult.success,
    );

    expect(state.collectionNames, ['Family Vault', 'Arthur Collection']);
    expect(state.selectedCollection, 'Family Vault');
    expect(
      state.popsForCollection('Family Vault').single,
      same(persistedBeforeRename),
    );
    expect(
      state.selectedOwnedWishlistIdentityKeys,
      contains(storedPop.collectibleIdentityKey),
    );
    expect(state.hasCollection('Entire Family Collection'), isFalse);
  });

  test('rename rejects invalid source and duplicate destination', () async {
    final state = AppState();
    final originalNames = List<String>.from(state.collectionNames);

    expect(
      await state.renameCollection('Missing', 'New Name'),
      CollectionOperationResult.notFound,
    );
    expect(
      await state.renameCollection('Arthur Collection', '  '),
      CollectionOperationResult.invalidName,
    );
    expect(
      await state.renameCollection(
        'Arthur Collection',
        'entire family collection',
      ),
      CollectionOperationResult.duplicateName,
    );
    expect(state.collectionNames, originalNames);
  });

  test(
    'case-only rename updates the display name without losing data',
    () async {
      final state = AppState();
      await state.setSelectedCollection('Arthur Collection');
      final storedPop = pop();
      await state.addPop(storedPop);
      final persistedBeforeRename = state.selectedCollectionPops.single;

      expect(
        await state.renameCollection('Arthur Collection', 'ARTHUR COLLECTION'),
        CollectionOperationResult.success,
      );
      expect(state.selectedCollection, 'ARTHUR COLLECTION');
      expect(
        state.popsForCollection('arthur collection').single,
        same(persistedBeforeRename),
      );
    },
  );

  test('named collection reads are scoped and unmodifiable', () async {
    final state = AppState();
    final familyPop = pop(id: 'family-pop');
    await state.addPop(familyPop);
    await state.setSelectedCollection('Arthur Collection');
    final arthurPop = pop(id: 'arthur-pop', name: 'Superman');
    await state.addPop(arthurPop);

    final familyPops = state.popsForCollection('entire family collection');

    expect(familyPops.map((item) => item.id), ['family-pop']);
    expect(familyPops.map((item) => item.id), isNot(contains('arthur-pop')));
    expect(state.popsForCollection('Missing'), isEmpty);
    expect(() => familyPops.add(arthurPop), throwsUnsupportedError);
  });

  test(
    'Pop ID location lookup returns zero, one, and multiple matches',
    () async {
      final state = AppState();

      expect(state.collectionNamesContainingPopId('missing'), isEmpty);

      await state.addPop(pop(id: 'shared-id'));
      expect(state.collectionNamesContainingPopId('shared-id'), [
        'Entire Family Collection',
      ]);

      await state.setSelectedCollection('Arthur Collection');
      await state.addPop(pop(id: 'shared-id', variant: 'Chase'));

      expect(state.collectionNamesContainingPopId('shared-id'), [
        'Entire Family Collection',
        'Arthur Collection',
      ]);
    },
  );

  test('Pop location refines same IDs by stored record identity', () async {
    final state = AppState();
    final common = pop(id: 'shared-id');
    final chase = pop(id: 'shared-id', variant: 'Chase');
    await state.addPop(common);
    await state.setSelectedCollection('Arthur Collection');
    await state.addPop(chase);

    expect(state.collectionNamesContainingPop(common), [
      'Entire Family Collection',
    ]);
    expect(state.collectionNamesContainingPop(chase), ['Arthur Collection']);
    expect(state.collectionNamesContainingPop(pop(id: 'missing')), isEmpty);
  });

  test('exact repeated records preserve explicit location ambiguity', () async {
    final state = AppState();
    final firstCopy = pop(id: 'shared-id');
    final secondCopy = pop(id: 'shared-id');
    await state.addPop(firstCopy);
    await state.setSelectedCollection('Arthur Collection');
    await state.addPop(secondCopy);

    expect(state.collectionNamesContainingPop(firstCopy), [
      'Entire Family Collection',
      'Arthur Collection',
    ]);
  });
}
