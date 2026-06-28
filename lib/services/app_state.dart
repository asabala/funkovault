import 'package:flutter/material.dart';

import '../models/pop.dart';
import 'hive_service.dart';
import '../models/activity.dart';

class AppState extends ChangeNotifier {
  String _selectedCollection = 'Entire Family Collection';
  final List<Activity> _activities = [];
  final Map<String, List<Pop>> _collections = {
    'Entire Family Collection': [],
    'Arthur Collection': [],
  };
  List<Activity> get activities => _activities;

  List<Activity> get recentActivities {
    final list = List<Activity>.from(
      _activities,
    );

    list.sort(
          (a, b) =>
          b.timestamp.compareTo(
            a.timestamp,
          ),
    );

    return list.take(10).toList();
  }
  String get selectedCollection => _selectedCollection;

  Map<String, List<Pop>> get collections => _collections;

  List<String> get collectionNames =>
      _collections.keys.toList();

  List<Pop> get selectedCollectionPops =>
      _collections[_selectedCollection] ?? [];

  Future<void> loadData() async {
    final data = HiveService.loadData(
      'vault_data',
    );

    if (data != null) {
      _selectedCollection =
          data['selectedCollection'] ??
              'Entire Family Collection';

      _collections.clear();
      _activities.clear();

      final activitiesData =
      data['activities'];

      if (activitiesData != null) {
        _activities.addAll(
          (activitiesData as List)
              .map(
                (item) =>
                Activity.fromJson(
                  Map<String, dynamic>.from(
                    item,
                  ),
                ),
          )
              .toList(),
        );
      }

      final collectionsData =
      data['collections']
      as Map<String, dynamic>;

      collectionsData.forEach(
            (key, value) {
          _collections[key] =
              (value as List)
                  .map(
                    (item) => Pop.fromJson(
                  Map<String, dynamic>.from(
                    item,
                  ),
                ),
              )
                  .toList();
        },
      );
    }

    notifyListeners();
  }

  Future<void> _saveData() async {
    final collectionsJson =
    <String, dynamic>{};

    _collections.forEach(
          (key, value) {
        collectionsJson[key] =
            value
                .map(
                  (pop) => pop.toJson(),
            )
                .toList();
      },
    );

    await HiveService.saveData(
      'vault_data',
      {
        'selectedCollection':
        _selectedCollection,
        'collections':
        collectionsJson,
        'activities':
        _activities
            .map(
              (activity) =>
              activity.toJson(),
        )
            .toList(),
      },
    );
  }

  Future<void> setSelectedCollection(
      String value,
      ) async {
    _selectedCollection = value;

    await _saveData();

    notifyListeners();
  }

  Future<void> addCollection(
      String name,
      ) async {
    if (name.trim().isEmpty) return;

    if (!_collections.containsKey(name)) {
      _collections[name] = [];

      await _saveData();

      notifyListeners();
    }
  }

  Future<void> deleteCollection(
      String name,
      ) async {
    if (_collections.length <= 1) return;

    _collections.remove(name);

    if (_selectedCollection == name) {
      _selectedCollection =
          _collections.keys.first;
    }

    await _saveData();

    notifyListeners();
  }

  Future<void> addPop(Pop pop) async {
    final pops =
    _collections[_selectedCollection];

    if (pops == null) return;

    final existingIndex = pops.indexWhere(
          (p) =>
      p.name.toLowerCase() ==
          pop.name.toLowerCase() &&
          p.number == pop.number &&
          p.owner == pop.owner,
    );

    if (existingIndex != -1) {
      final existingPop =
      pops[existingIndex];

      pops[existingIndex] = Pop(
        id: existingPop.id,
        name: existingPop.name,
        number: existingPop.number,
        category: existingPop.category,
        series: existingPop.series,
        edition: 'Common',
        value: existingPop.value,
        pricePaid:
        existingPop.pricePaid,
        quantity:
        existingPop.quantity + 1,
        itemCondition:
        existingPop.itemCondition,
        boxCondition:
        existingPop.boxCondition,
        imageUrl:
        existingPop.imageUrl,
        owner: existingPop.owner,
        isWishlist:
        existingPop.isWishlist,
      );

      await addActivity(
        Activity(
          id: DateTime.now()
              .millisecondsSinceEpoch
              .toString(),
          action: 'quantity_increased',
          popName: pop.name,
          popNumber: pop.number,
          owner: pop.owner,
          actor: pop.owner,
          details:
          '${pop.name} quantity increased',
          timestamp: DateTime.now(),
        ),
      );
    } else {
      pops.add(pop);

      await addActivity(
        Activity(
          id: DateTime.now()
              .millisecondsSinceEpoch
              .toString(),
          action: 'pop_added',
          popName: pop.name,
          popNumber: pop.number,
          owner: pop.owner,
          actor: pop.owner,
          details:
          '${pop.name} added',
          timestamp: DateTime.now(),
        ),
      );
    }

    await _saveData();

    notifyListeners();
  }
  Future<void> importPops(
      List<Pop> pops,
      ) async {
    _collections[_selectedCollection] =
    List<Pop>.from(pops);

    await _saveData();

    notifyListeners();
  }

  Future<void> deletePop(
      String popId,
      ) async {
    final pops =
    _collections[_selectedCollection];

    if (pops == null) return;

    final pop = pops.firstWhere(
          (p) => p.id == popId,
    );

    await addActivity(
      Activity(
        id: DateTime.now()
            .millisecondsSinceEpoch
            .toString(),
        action: 'pop_deleted',
        popName: pop.name,
        popNumber: pop.number,
        owner: pop.owner,
        actor: pop.owner,
        details:
        '${pop.name} deleted',
        timestamp: DateTime.now(),
      ),
    );

    pops.removeWhere(
          (p) => p.id == popId,
    );

    await _saveData();

    notifyListeners();
  }

  Future<void> updatePop(
      Pop updatedPop,
      ) async {
    final pops =
    _collections[_selectedCollection];

    if (pops == null) return;

    final index = pops.indexWhere(
          (pop) =>
      pop.id == updatedPop.id,
    );

    if (index != -1) {
      pops[index] = updatedPop;

      await _saveData();

      notifyListeners();
    }
  }
  Future<void> updateOwnerForPops(
      List<String> popIds,
      String owner,
      ) async {
    final pops =
    _collections[_selectedCollection];

    if (pops == null) return;

    for (int i = 0; i < pops.length; i++) {
      if (popIds.contains(pops[i].id)) {
        final oldPop = pops[i];

        pops[i] = Pop(
          id: oldPop.id,
          name: oldPop.name,
          number: oldPop.number,
          category: oldPop.category,
          series: oldPop.series,
          edition: 'Common',
          value: oldPop.value,
          pricePaid: oldPop.pricePaid,
          quantity: oldPop.quantity,
          itemCondition:
          oldPop.itemCondition,
          boxCondition:
          oldPop.boxCondition,
          imageUrl: oldPop.imageUrl,
          owner: owner,
          isWishlist: oldPop.isWishlist,
        );

        await addActivity(
          Activity(
            id: DateTime.now()
                .millisecondsSinceEpoch
                .toString(),
            action: 'owner_changed',
            popName: oldPop.name,
            popNumber: oldPop.number,
            owner: owner,
            actor: owner,
            details:
            '${oldPop.name} assigned to $owner',
            timestamp: DateTime.now(),
          ),
        );
      }
    }

    await _saveData();

    notifyListeners();
  }
  Future<void> mergeDuplicates() async {
    final pops =
    _collections[_selectedCollection];

    if (pops == null) return;

    final Map<String, Pop> merged = {};

    for (final pop in pops) {
      final key =
          '${pop.name.toLowerCase()}|'
          '${pop.number}|'
          '${pop.owner}';

      if (merged.containsKey(key)) {
        final existing = merged[key]!;

        merged[key] = Pop(
          id: existing.id,
          name: existing.name,
          number: existing.number,
          category: existing.category,
          series: existing.series,
          edition: 'Common',
          value: existing.value,
          pricePaid: existing.pricePaid,
          quantity:
          existing.quantity +
              pop.quantity,
          itemCondition:
          existing.itemCondition,
          boxCondition:
          existing.boxCondition,
          imageUrl: existing.imageUrl,
          owner: existing.owner,
          isWishlist:
          existing.isWishlist,
        );
      } else {
        merged[key] = pop;
      }
    }

    _collections[_selectedCollection] =
        merged.values.toList();

    await _saveData();

    notifyListeners();
  }
  Future<void> addActivity(
      Activity activity,
      ) async {
    _activities.add(activity);

    if (_activities.length > 500) {
      _activities.removeAt(0);
    }

    await _saveData();

    notifyListeners();
  }

  int get totalPops {
    return _collections.values.fold(
      0,
          (total, pops) =>
      total + pops.length,
    );
  }
  int get wishlistCount {
    int total = 0;

    for (final collection
    in _collections.values) {
      for (final pop in collection) {
        if (pop.isWishlist) {
          total++;
        }
      }
    }

    return total;
  }
  double get totalValue {
    double total = 0;

    for (final collection
    in _collections.values) {
      for (final pop
      in collection) {
        total += pop.value;
      }
    }

    return total;
  }

  int collectionPopCount(
      String collectionName,
      ) {
    return _collections[
    collectionName]
        ?.length ??
        0;
  }

  double collectionValue(
      String collectionName,
      ) {
    final pops =
        _collections[collectionName] ??
            [];

    return pops.fold(
      0.0,
          (total, pop) =>
      total + pop.value,
    );
  }
}