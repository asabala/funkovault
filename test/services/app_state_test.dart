import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/atlas/market/models/value_history_entry.dart';
import 'package:funkovault2/atlas/timeline/models/atlas_timeline_event.dart';
import 'package:funkovault2/models/pop.dart';
import 'package:funkovault2/services/app_state.dart';
import 'package:funkovault2/services/hive_service.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory hiveDirectory;

  setUpAll(() async {
    hiveDirectory = await Directory.systemTemp.createTemp('app_state_test_');
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

  Pop storedPop({
    double value = 25,
    List<ValueHistoryEntry> valueHistory = const [],
    List<AtlasTimelineEvent> timeline = const [],
  }) {
    return Pop(
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
      sourceCollectibleId: 'source-123',
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
      value: value,
      pricePaid: 10,
      valueHistory: valueHistory,
      timeline: timeline,
      quantity: 1,
      itemCondition: 'Mint',
      boxCondition: 'Near Mint',
      imageUrl: 'https://images.example/batman.png',
      owner: 'Imported Owner',
      isWishlist: false,
      dateAdded: '2026-01-01T00:00:00.000Z',
      lastUpdated: '2026-02-01T00:00:00.000Z',
    );
  }

  AppState stateWith(Pop pop) {
    final state = AppState();
    state.collections[state.selectedCollection]!.add(pop);
    return state;
  }

  test('returns persisted record and preserves unedited metadata', () async {
    final original = storedPop();
    final state = stateWith(original);

    final persisted = await state.updatePop(
      original.copyWith(name: 'Batman Updated'),
    );

    expect(persisted, isNotNull);
    expect(persisted, same(state.selectedCollectionPops.single));
    expect(persisted!.name, 'Batman Updated');
    expect(persisted.id, original.id);
    expect(persisted.edition, original.edition);
    expect(persisted.sourceCatalogId, original.sourceCatalogId);
    expect(persisted.sourceCollectibleId, original.sourceCollectibleId);
    expect(persisted.sourceUpc, original.sourceUpc);
    expect(persisted.productionStatus, original.productionStatus);
    expect(persisted.finish, original.finish);
    expect(persisted.packagingType, original.packagingType);
    expect(persisted.authenticationProvider, original.authenticationProvider);
    expect(persisted.dateAdded, original.dateAdded);
    expect(persisted.lastUpdated, isNot(original.lastUpdated));
    expect(persisted.valueHistory, same(original.valueHistory));
    expect(persisted.timeline, isEmpty);
  });

  test(
    'positive value change adds legacy baseline and one manual entry',
    () async {
      final original = storedPop(value: 25);
      final state = stateWith(original);

      final persisted = await state.updatePop(original.copyWith(value: 40));

      expect(persisted!.valueHistory, hasLength(2));
      expect(persisted.valueHistory[0].value, 25);
      expect(
        persisted.valueHistory[0].source,
        ValueHistoryEntry.legacyValueSource,
      );
      expect(persisted.valueHistory[1].value, 40);
      expect(persisted.valueHistory[1].source, ValueHistoryEntry.manualSource);
      expect(
        persisted.valueHistory[1].recordedAt.toIso8601String(),
        persisted.lastUpdated,
      );
      expect(
        persisted.timeline.where(
          (event) => event.type == AtlasTimelineEventType.valueUpdated,
        ),
        hasLength(1),
      );
      expect(
        () => persisted.valueHistory.add(persisted.valueHistory.last),
        throwsUnsupportedError,
      );
    },
  );

  test('existing history is preserved and receives one new entry', () async {
    final priorEntry = ValueHistoryEntry(
      value: 20,
      recordedAt: DateTime.utc(2026, 1),
      source: ValueHistoryEntry.atlasCatalogSource,
    );
    final original = storedPop(value: 25, valueHistory: [priorEntry]);
    final state = stateWith(original);

    final persisted = await state.updatePop(original.copyWith(value: 30));

    expect(persisted!.valueHistory, hasLength(2));
    expect(persisted.valueHistory.first, same(priorEntry));
    expect(persisted.valueHistory.last.value, 30);
  });

  test('unchanged value creates no history or timeline entry', () async {
    final priorEntry = ValueHistoryEntry(
      value: 25,
      recordedAt: DateTime.utc(2026, 1),
    );
    final original = storedPop(valueHistory: [priorEntry]);
    final state = stateWith(original);

    final persisted = await state.updatePop(original.copyWith(quantity: 2));

    expect(persisted!.valueHistory, same(original.valueHistory));
    expect(persisted.timeline, isEmpty);
  });

  test(
    'clearing value preserves positive history without adding zero',
    () async {
      final priorEntry = ValueHistoryEntry(
        value: 25,
        recordedAt: DateTime.utc(2026, 1),
      );
      final original = storedPop(valueHistory: [priorEntry]);
      final state = stateWith(original);

      final persisted = await state.updatePop(original.copyWith(value: 0));

      expect(persisted!.valueHistory, hasLength(1));
      expect(persisted.valueHistory.single.value, 25);
      expect(
        persisted.valueHistory.where((entry) => entry.value == 0),
        isEmpty,
      );
      expect(
        persisted.timeline.where(
          (event) => event.type == AtlasTimelineEventType.valueUpdated,
        ),
        hasLength(1),
      );
    },
  );

  test('missing stable ID returns null and makes no change', () async {
    final original = storedPop();
    final state = stateWith(original);

    final persisted = await state.updatePop(
      original.copyWith(id: 'missing-id', name: 'Wrong'),
    );

    expect(persisted, isNull);
    expect(state.selectedCollectionPops.single, same(original));
  });

  Pop importedPop({required String id, String name = 'Imported Pop'}) {
    return Pop(
      id: id,
      name: name,
      number: id,
      category: 'Heroes',
      series: 'Import Test',
      edition: 'Common',
      variant: 'Common',
      retailExclusive: 'None',
      eventSticker: 'None',
      limitedEdition: 'None',
      signature: 'Unsigned',
      sourceCatalogId: 'catalog-$id',
      sourceCollectibleId: 'collectible-$id',
      sourceUpc: '',
      productionStatus: '',
      releaseDate: '',
      gradingCompany: '',
      authenticityNumber: '',
      value: 20,
      pricePaid: 10,
      quantity: 1,
      itemCondition: 'Mint',
      boxCondition: 'Mint',
      imageUrl: '',
      owner: 'Imported Owner',
      isWishlist: false,
    );
  }

  test(
    'explicit import targets requested collection instead of selected collection',
    () async {
      final state = AppState();

      expect(
        await state.addCollection('Import Target'),
        CollectionOperationResult.success,
      );

      expect(
        await state.addCollection('Other Collection'),
        CollectionOperationResult.success,
      );

      expect(
        await state.setSelectedCollection('Other Collection'),
        CollectionOperationResult.success,
      );

      final result = await state.importPopsSafely(<Pop>[
        importedPop(id: 'explicit-import'),
      ], collectionName: 'Import Target');

      expect(result.attempted, 1);
      expect(result.added, 1);
      expect(result.skipped, 0);

      expect(state.popsForCollection('Import Target'), hasLength(1));

      expect(
        state.popsForCollection('Import Target').single.id,
        'explicit-import',
      );

      expect(state.popsForCollection('Other Collection'), isEmpty);

      expect(state.selectedCollection, 'Other Collection');
    },
  );

  test(
    'changing selected collection does not redirect explicit import',
    () async {
      final state = AppState();

      expect(
        await state.addCollection('Captured Import'),
        CollectionOperationResult.success,
      );

      expect(
        await state.addCollection('Later Selection'),
        CollectionOperationResult.success,
      );

      final String capturedCollection = 'Captured Import';

      expect(
        await state.setSelectedCollection('Later Selection'),
        CollectionOperationResult.success,
      );

      final result = await state.importPopsSafely(<Pop>[
        importedPop(id: 'captured-import'),
      ], collectionName: capturedCollection);

      expect(result.added, 1);

      expect(state.popsForCollection('Captured Import'), hasLength(1));

      expect(state.popsForCollection('Later Selection'), isEmpty);
    },
  );

  test(
    'missing explicit import collection fails safely without fallback',
    () async {
      final state = AppState();

      final String selectedBefore = state.selectedCollection;

      final int selectedCountBefore = state
          .popsForCollection(selectedBefore)
          .length;

      final result = await state.importPopsSafely(<Pop>[
        importedPop(id: 'missing-target'),
      ], collectionName: 'Missing Collection');

      expect(result.attempted, 1);
      expect(result.added, 0);
      expect(result.skipped, 1);

      expect(state.selectedCollection, selectedBefore);

      expect(
        state.popsForCollection(selectedBefore),
        hasLength(selectedCountBefore),
      );
    },
  );

  test(
    'null import collection preserves selected-collection behavior',
    () async {
      final state = AppState();

      expect(
        await state.addCollection('Legacy Import'),
        CollectionOperationResult.success,
      );

      expect(
        await state.setSelectedCollection('Legacy Import'),
        CollectionOperationResult.success,
      );

      final result = await state.importPopsSafely(<Pop>[
        importedPop(id: 'legacy-import'),
      ]);

      expect(result.added, 1);

      expect(state.popsForCollection('Legacy Import'), hasLength(1));

      expect(
        state.popsForCollection('Legacy Import').single.id,
        'legacy-import',
      );
    },
  );

  test('clearCollection clears only requested collection', () async {
    final state = AppState();

    expect(
      await state.addCollection('Clear Target'),
      CollectionOperationResult.success,
    );

    expect(
      await state.addCollection('Keep Collection'),
      CollectionOperationResult.success,
    );

    state.collections['Clear Target']!.add(importedPop(id: 'remove-me'));

    state.collections['Keep Collection']!.add(importedPop(id: 'keep-me'));

    expect(
      await state.setSelectedCollection('Keep Collection'),
      CollectionOperationResult.success,
    );

    final bool cleared = await state.clearCollection('Clear Target');

    expect(cleared, isTrue);

    expect(state.popsForCollection('Clear Target'), isEmpty);

    expect(state.popsForCollection('Keep Collection'), hasLength(1));

    expect(state.popsForCollection('Keep Collection').single.id, 'keep-me');

    expect(state.selectedCollection, 'Keep Collection');
  });

  test(
    'clearCollection missing target returns false and changes nothing',
    () async {
      final state = AppState();

      expect(
        await state.addCollection('Safe Collection'),
        CollectionOperationResult.success,
      );

      state.collections['Safe Collection']!.add(importedPop(id: 'stay-safe'));

      final bool cleared = await state.clearCollection('Missing Collection');

      expect(cleared, isFalse);

      expect(state.popsForCollection('Safe Collection'), hasLength(1));

      expect(state.popsForCollection('Safe Collection').single.id, 'stay-safe');
    },
  );

  test(
    'clearSelectedCollection preserves legacy selected-collection behavior',
    () async {
      final state = AppState();

      expect(
        await state.addCollection('Legacy Clear'),
        CollectionOperationResult.success,
      );

      expect(
        await state.addCollection('Untouched Collection'),
        CollectionOperationResult.success,
      );

      state.collections['Legacy Clear']!.add(importedPop(id: 'legacy-clear'));

      state.collections['Untouched Collection']!.add(
        importedPop(id: 'untouched'),
      );

      expect(
        await state.setSelectedCollection('Legacy Clear'),
        CollectionOperationResult.success,
      );

      await state.clearSelectedCollection();

      expect(state.popsForCollection('Legacy Clear'), isEmpty);

      expect(state.popsForCollection('Untouched Collection'), hasLength(1));
    },
  );
}
