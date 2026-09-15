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

  test('scoped add targets only the requested collection', () async {
    final state = AppState();

    expect(
      await state.addPop(
        pop(id: 'scoped-add'),
        collectionName: ' arthur collection ',
      ),
      isTrue,
    );
    expect(
      state.popsForCollection('Arthur Collection').single.id,
      'scoped-add',
    );
    expect(state.popsForCollection('Entire Family Collection'), isEmpty);
  });

  test('explicit missing add target fails without fallback', () async {
    final state = AppState();

    expect(
      await state.addPop(pop(id: 'missing-add'), collectionName: 'Missing'),
      isFalse,
    );
    expect(state.totalPops, 0);
  });

  test('scoped update changes only the requested collection', () async {
    final state = AppState();
    final familyPop = pop(id: 'shared-id');
    final arthurPop = pop(id: 'shared-id', variant: 'Chase');
    await state.addPop(familyPop);
    await state.addPop(arthurPop, collectionName: 'Arthur Collection');

    final persisted = await state.updatePop(
      arthurPop.copyWith(name: 'Updated Chase'),
      collectionName: 'Arthur Collection',
      existingRecordKey: arthurPop.collectionRecordKey,
    );

    expect(persisted?.name, 'Updated Chase');
    expect(
      state.popsForCollection('Arthur Collection').single.name,
      'Updated Chase',
    );
    expect(
      state.popsForCollection('Entire Family Collection').single.name,
      'Batman',
    );
  });

  test('identity-changing update uses the original record key', () async {
    final state = AppState();
    final original = pop(id: 'identity-edit');
    await state.addPop(original, collectionName: 'Arthur Collection');

    final persisted = await state.updatePop(
      original.copyWith(variant: 'Metallic Chase'),
      collectionName: 'Arthur Collection',
      existingRecordKey: original.collectionRecordKey,
    );

    expect(persisted?.variant, 'Metallic Chase');
    expect(state.popsForCollection('Arthur Collection'), hasLength(1));
  });

  test('unscoped unique update succeeds', () async {
    final state = AppState();
    final original = pop(id: 'unique-update');
    await state.addPop(original, collectionName: 'Arthur Collection');

    final persisted = await state.updatePop(
      original.copyWith(quantity: 2),
      existingRecordKey: original.collectionRecordKey,
    );

    expect(persisted?.quantity, 2);
  });

  test('ambiguous and wrong-collection updates are blocked', () async {
    final state = AppState();
    final repeated = pop(id: 'ambiguous-update');
    await state.addPop(repeated);
    await state.addPop(repeated, collectionName: 'Arthur Collection');

    expect(
      await state.updatePop(
        repeated.copyWith(quantity: 2),
        existingRecordKey: repeated.collectionRecordKey,
      ),
      isNull,
    );
    expect(
      await state.updatePop(
        repeated.copyWith(quantity: 2),
        collectionName: 'Missing',
        existingRecordKey: repeated.collectionRecordKey,
      ),
      isNull,
    );
    expect(
      state.collections.values
          .expand((items) => items)
          .every((item) => item.quantity == 1),
      isTrue,
    );
  });

  test('scoped delete removes exactly one repeated ID record', () async {
    final state = AppState();
    final common = pop(id: 'repeated-delete');
    final chase = pop(id: 'repeated-delete', variant: 'Chase');
    state.collections['Arthur Collection']!.addAll([common, chase]);

    expect(
      await state.deletePop(
        common.id,
        collectionName: 'Arthur Collection',
        recordKey: common.collectionRecordKey,
      ),
      isTrue,
    );
    expect(state.popsForCollection('Arthur Collection'), hasLength(1));
    expect(
      state.popsForCollection('Arthur Collection').single.variant,
      'Chase',
    );
  });

  test('wrong, missing, and globally ambiguous deletes are blocked', () async {
    final state = AppState();
    final repeated = pop(id: 'ambiguous-delete');
    await state.addPop(repeated);
    await state.addPop(repeated, collectionName: 'Arthur Collection');

    expect(
      await state.deletePop(
        repeated.id,
        collectionName: 'Missing',
        recordKey: repeated.collectionRecordKey,
      ),
      isFalse,
    );
    expect(await state.deletePop('missing-id'), isFalse);
    expect(
      await state.deletePop(
        repeated.id,
        recordKey: repeated.collectionRecordKey,
      ),
      isFalse,
    );
    expect(state.totalPops, 2);
  });
  test('scoped owner assignment changes only requested collection', () async {
    final state = AppState();

    expect(state.selectedCollection, 'Entire Family Collection');

    final familyPop = pop(id: 'shared-owner-id');

    final arthurPop = pop(id: 'shared-owner-id', variant: 'Chase');

    await state.addPop(familyPop);

    await state.addPop(arthurPop, collectionName: 'Arthur Collection');

    await state.updateOwnerForPops(
      <String>[arthurPop.id],
      'Arthur',
      collectionName: 'Arthur Collection',
    );

    expect(state.selectedCollection, 'Entire Family Collection');

    expect(state.popsForCollection('Arthur Collection').single.owner, 'Arthur');

    expect(
      state.popsForCollection('Entire Family Collection').single.owner,
      familyPop.owner,
    );
  });
  test(
    'scoped duplicate consolidation changes only requested collection',
    () async {
      final state = AppState();

      final first = pop(id: 'duplicate-a');

      final second = pop(id: 'duplicate-b');

      state.collections['Arthur Collection']!.addAll([first, second]);

      final unrelated = pop(id: 'unrelated');

      state.collections['Entire Family Collection']!.add(unrelated);

      final bool succeeded = await state.consolidateDuplicateGroup(<String>[
        first.id,
        second.id,
      ], collectionName: 'Arthur Collection');

      expect(succeeded, isTrue);

      expect(state.popsForCollection('Arthur Collection'), hasLength(1));

      expect(state.popsForCollection('Arthur Collection').single.quantity, 2);

      expect(state.popsForCollection('Entire Family Collection'), hasLength(1));

      expect(
        state.popsForCollection('Entire Family Collection').single.id,
        'unrelated',
      );
    },
  );

  test('duplicate consolidation rejects wrong explicit collection', () async {
    final state = AppState();

    final first = pop(id: 'wrong-scope-a');

    final second = pop(id: 'wrong-scope-b');

    state.collections['Arthur Collection']!.addAll([first, second]);

    final bool succeeded = await state.consolidateDuplicateGroup(<String>[
      first.id,
      second.id,
    ], collectionName: 'Entire Family Collection');

    expect(succeeded, isFalse);

    expect(state.popsForCollection('Arthur Collection'), hasLength(2));
  });

  test('unscoped ambiguous duplicate consolidation is blocked', () async {
    final state = AppState();

    final first = pop(id: 'ambiguous-a');

    final second = pop(id: 'ambiguous-b');

    state.collections['Entire Family Collection']!.addAll([first, second]);

    state.collections['Arthur Collection']!.addAll([first, second]);

    final bool succeeded = await state.consolidateDuplicateGroup(<String>[
      first.id,
      second.id,
    ]);

    expect(succeeded, isFalse);

    expect(state.popsForCollection('Entire Family Collection'), hasLength(2));

    expect(state.popsForCollection('Arthur Collection'), hasLength(2));
  });

  test(
    'duplicate consolidation rejects different collectible identities',
    () async {
      final state = AppState();

      final common = pop(id: 'identity-common');

      final chase = pop(id: 'identity-chase', variant: 'Chase');

      state.collections['Arthur Collection']!.addAll([common, chase]);

      final bool succeeded = await state.consolidateDuplicateGroup(<String>[
        common.id,
        chase.id,
      ], collectionName: 'Arthur Collection');

      expect(succeeded, isFalse);

      expect(state.popsForCollection('Arthur Collection'), hasLength(2));
    },
  );
  test('scoped merge duplicates changes only requested collection', () async {
    final state = AppState();

    final arthurFirst = pop(id: 'arthur-merge-a').copyWith(number: '77');

    final arthurSecond = pop(id: 'arthur-merge-b').copyWith(number: '77');

    final familyFirst = pop(id: 'family-merge-a').copyWith(number: '88');

    final familySecond = pop(id: 'family-merge-b').copyWith(number: '88');

    state.collections['Arthur Collection']!.addAll([arthurFirst, arthurSecond]);

    state.collections['Entire Family Collection']!.addAll([
      familyFirst,
      familySecond,
    ]);

    final bool merged = await state.mergeDuplicates(
      collectionName: 'Arthur Collection',
    );

    expect(merged, isTrue);

    expect(state.popsForCollection('Arthur Collection'), hasLength(1));

    expect(state.popsForCollection('Arthur Collection').single.quantity, 2);

    expect(state.popsForCollection('Entire Family Collection'), hasLength(2));
  });

  test('explicit missing merge target fails without fallback', () async {
    final state = AppState();

    final first = pop(id: 'missing-merge-a').copyWith(number: '99');

    final second = pop(id: 'missing-merge-b').copyWith(number: '99');

    state.collections['Arthur Collection']!.addAll([first, second]);

    final bool merged = await state.mergeDuplicates(
      collectionName: 'Missing Collection',
    );

    expect(merged, isFalse);

    expect(state.popsForCollection('Arthur Collection'), hasLength(2));
  });

  test('unscoped merge preserves selected collection behavior', () async {
    final state = AppState();

    final first = pop(id: 'legacy-merge-a').copyWith(number: '44');

    final second = pop(id: 'legacy-merge-b').copyWith(number: '44');

    state.collections['Arthur Collection']!.addAll([first, second]);

    await state.setSelectedCollection('Arthur Collection');

    final bool merged = await state.mergeDuplicates();

    expect(merged, isTrue);

    expect(state.popsForCollection('Arthur Collection'), hasLength(1));

    expect(state.popsForCollection('Arthur Collection').single.quantity, 2);
  });
}
