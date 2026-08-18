import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/atlas/repositories/vault_repository.dart';
import 'package:funkovault2/models/pop.dart';
import 'package:funkovault2/services/app_state.dart';

void main() {
  const repository = VaultRepository();

  Pop pop({
    required String id,
    required String name,
    required double value,
    String category = 'Heroes',
    String owner = 'Shared',
    String variant = 'Common',
  }) {
    return Pop(
      id: id,
      name: name,
      number: '01',
      category: category,
      series: category,
      variant: variant,
      value: value,
      pricePaid: 0,
      quantity: 1,
      itemCondition: 'Mint',
      boxCondition: 'Mint',
      imageUrl: '',
      owner: owner,
      isWishlist: false,
    );
  }

  AppState populatedState() {
    final state = AppState();
    state.collections['Entire Family Collection']!.addAll([
      pop(id: 'family-1', name: 'Batman', value: 20, owner: 'Arthur'),
      pop(id: 'family-2', name: 'Superman', value: 30, owner: 'Arthur'),
    ]);
    state.collections['Arthur Collection']!.addAll([
      pop(
        id: 'arthur-1',
        name: 'Batman',
        value: 50,
        category: 'Movies',
        variant: 'Chase',
      ),
    ]);
    return state;
  }

  test('global reads and statistics remain unchanged without a scope', () {
    final state = populatedState();

    expect(repository.allPops(state), hasLength(3));
    expect(repository.pops(state), hasLength(3));
    expect(repository.totalPops(state), 3);
    expect(repository.totalValue(state), 100);
    expect(repository.ownerCounts(state), {'Arthur': 2, 'Shared': 1});
    expect(repository.categoryCounts(state), {'Heroes': 2, 'Movies': 1});
  });

  test('scoped reads return only the requested collection', () {
    final state = populatedState();

    final scopedPops = repository.pops(
      state,
      collectionName: 'Arthur Collection',
    );

    expect(scopedPops.map((item) => item.id), ['arthur-1']);
    expect(repository.totalPops(state, collectionName: 'Arthur Collection'), 1);
    expect(
      repository.totalValue(state, collectionName: 'Arthur Collection'),
      50,
    );
    expect(
      repository.categoryCounts(state, collectionName: 'Arthur Collection'),
      {'Movies': 1},
    );
  });

  test('missing collection scope returns defined empty results', () {
    final state = populatedState();

    expect(
      repository.pops(state, collectionName: 'Missing Collection'),
      isEmpty,
    );
    expect(
      repository.totalPops(state, collectionName: 'Missing Collection'),
      0,
    );
    expect(
      repository.totalValue(state, collectionName: 'Missing Collection'),
      0,
    );
    expect(
      repository.ownerCounts(state, collectionName: 'Missing Collection'),
      isEmpty,
    );
  });

  test('repository snapshots do not mutate AppState collection order', () {
    final state = populatedState();

    final sorted = repository.mostValuablePops(
      state,
      collectionName: 'Entire Family Collection',
    );

    expect(sorted.map((item) => item.id), ['family-2', 'family-1']);
    expect(
      state
          .popsForCollection('Entire Family Collection')
          .map((item) => item.id),
      ['family-1', 'family-2'],
    );
  });
}
