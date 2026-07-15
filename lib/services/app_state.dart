import 'package:flutter/material.dart';

import '../models/activity.dart';
import '../models/collector_profile.dart';
import '../models/pop.dart';
import 'hive_service.dart';

class PopImportResult {
  const PopImportResult({
    required this.attempted,
    required this.added,
    required this.skipped,
  });

  final int attempted;
  final int added;
  final int skipped;
}

class AppState extends ChangeNotifier {
  String _selectedCollection = 'Entire Family Collection';
  final List<Activity> _activities = [];

  CollectorProfile _collectorProfile = const CollectorProfile(
    id: 'default',
    displayName: 'Arthur',
    collectorTitle: 'Atlas Collector',
    bio: 'Collector. Curator. Explorer.',
    favoriteCategory: 'Marvel',
    collectorLevel: 'Rookie',
    joinYear: 2026,
    isPremium: false,
    atlasId: 'ATL-000001',
    collectorMotto: 'Collector. Curator. Explorer.',
    favoriteFranchise: 'Spider-Man',
    dreamGrail: 'Planet Arlia Vegeta',
    country: 'United States',
    countryCode: 'US',
    countryFlag: '🇺🇸',
    avatarUrl: '',
    bannerUrl: '',
  );

  final Map<String, List<Pop>> _collections = {
    'Entire Family Collection': [],
    'Arthur Collection': [],
  };

  List<Activity> get activities => _activities;

  CollectorProfile get collectorProfile => _collectorProfile;

  List<Activity> get recentActivities {
    final list = List<Activity>.from(
      _activities,
    );

    list.sort(
          (a, b) => b.timestamp.compareTo(
        a.timestamp,
      ),
    );

    return list.take(10).toList();
  }

  String get selectedCollection => _selectedCollection;

  Map<String, List<Pop>> get collections => _collections;

  List<String> get collectionNames => _collections.keys.toList();

  List<Pop> get selectedCollectionPops => _collections[_selectedCollection] ?? [];

  Future<void> loadData() async {
    final data = HiveService.loadData(
      'vault_data',
    );

    if (data != null) {
      _selectedCollection =
          data['selectedCollection'] ?? 'Entire Family Collection';

      _collections.clear();
      _activities.clear();

      final activitiesData = data['activities'];
      final profileData = data['collectorProfile'];

      if (profileData != null) {
        _collectorProfile = CollectorProfile.fromJson(
          Map<String, dynamic>.from(profileData),
        );
      }

      if (activitiesData != null) {
        _activities.addAll(
          (activitiesData as List)
              .map(
                (item) => Activity.fromJson(
              Map<String, dynamic>.from(
                item,
              ),
            ),
          )
              .toList(),
        );
      }

      final collectionsData = data['collections'] as Map<String, dynamic>;

      collectionsData.forEach(
            (key, value) {
          _collections[key] = (value as List)
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
    final collectionsJson = <String, dynamic>{};

    _collections.forEach(
          (key, value) {
        collectionsJson[key] = value
            .map(
              (pop) => pop.toJson(),
        )
            .toList();
      },
    );

    await HiveService.saveData(
      'vault_data',
      {
        'selectedCollection': _selectedCollection,
        'collections': collectionsJson,
        'activities': _activities
            .map(
              (activity) => activity.toJson(),
        )
            .toList(),
        'collectorProfile': _collectorProfile.toJson(),
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
    if (name.trim().isEmpty) {
      return;
    }

    if (!_collections.containsKey(name)) {
      _collections[name] = [];

      await _saveData();

      notifyListeners();
    }
  }

  Future<void> deleteCollection(
      String name,
      ) async {
    if (_collections.length <= 1) {
      return;
    }

    _collections.remove(name);

    if (_selectedCollection == name) {
      _selectedCollection = _collections.keys.first;
    }

    await _saveData();

    notifyListeners();
  }

  Future<void> addPop(Pop pop) async {
    final pops = _collections[_selectedCollection];

    if (pops == null) {
      return;
    }

    final now = DateTime.now().toIso8601String();

    final existingIndex = pops.indexWhere(
          (existingPop) => existingPop.duplicateKey == pop.duplicateKey,
    );

    if (existingIndex != -1) {
      final existingPop = pops[existingIndex];

      pops[existingIndex] = existingPop.copyWith(
        quantity: existingPop.quantity + pop.quantity,
        lastUpdated: now,
      );

      await addActivity(
        Activity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          action: 'quantity_increased',
          popName: pop.name,
          popNumber: pop.number,
          owner: pop.owner,
          actor: pop.owner,
          details: '${pop.name} quantity increased',
          timestamp: DateTime.now(),
        ),
      );
    } else {
      final datedPop = pop.copyWith(
        dateAdded: pop.dateAdded.trim().isEmpty ? now : pop.dateAdded,
        lastUpdated: pop.lastUpdated.trim().isEmpty ? now : pop.lastUpdated,
      );

      pops.add(datedPop);

      await addActivity(
        Activity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          action: 'pop_added',
          popName: datedPop.name,
          popNumber: datedPop.number,
          owner: datedPop.owner,
          actor: datedPop.owner,
          details: '${datedPop.name} added',
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
    await importPopsSafely(pops);
  }

  Future<PopImportResult> importPopsSafely(
      List<Pop> importedPops,
      ) async {
    final currentPops = _collections[_selectedCollection];

    if (currentPops == null) {
      return PopImportResult(
        attempted: importedPops.length,
        added: 0,
        skipped: importedPops.length,
      );
    }

    final existingKeys = currentPops
        .map(
          (pop) => pop.csvImportKey,
    )
        .toSet();

    final now = DateTime.now().toIso8601String();

    var added = 0;
    var skipped = 0;

    for (final importedPop in importedPops) {
      final key = importedPop.csvImportKey;

      if (existingKeys.contains(key)) {
        skipped++;
        continue;
      }

      final datedPop = importedPop.copyWith(
        dateAdded: importedPop.dateAdded.trim().isEmpty
            ? now
            : importedPop.dateAdded,
        lastUpdated: importedPop.lastUpdated.trim().isEmpty
            ? now
            : importedPop.lastUpdated,
      );

      currentPops.add(datedPop);
      existingKeys.add(key);
      added++;
    }

    await addActivity(
      Activity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        action: 'csv_import',
        popName: 'CSV Import',
        popNumber: '',
        owner: _selectedCollection,
        actor: _collectorProfile.displayName,
        details: 'CSV import complete: $added added, $skipped skipped',
        timestamp: DateTime.now(),
      ),
    );

    await _saveData();

    notifyListeners();

    return PopImportResult(
      attempted: importedPops.length,
      added: added,
      skipped: skipped,
    );
  }

  Future<void> deletePop(
      String popId,
      ) async {
    final pops = _collections[_selectedCollection];

    if (pops == null) {
      return;
    }

    final pop = pops.firstWhere(
          (p) => p.id == popId,
    );

    await addActivity(
      Activity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        action: 'pop_deleted',
        popName: pop.name,
        popNumber: pop.number,
        owner: pop.owner,
        actor: pop.owner,
        details: '${pop.name} deleted',
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
    List<Pop>? matchingCollection;
    var matchingIndex = -1;

    for (final collection in _collections.values) {
      final index = collection.indexWhere(
            (pop) => pop.id == updatedPop.id,
      );

      if (index != -1) {
        matchingCollection = collection;
        matchingIndex = index;
        break;
      }
    }

    if (matchingCollection == null || matchingIndex == -1) {
      return;
    }

    final existingPop = matchingCollection[matchingIndex];
    final now = DateTime.now().toIso8601String();

    matchingCollection[matchingIndex] = updatedPop.copyWith(
      dateAdded: updatedPop.dateAdded.trim().isEmpty
          ? existingPop.dateAdded
          : updatedPop.dateAdded,
      lastUpdated: updatedPop.lastUpdated.trim().isEmpty
          ? now
          : updatedPop.lastUpdated,
    );

    await _saveData();

    notifyListeners();
  }

  Future<void> updateOwnerForPops(
      List<String> popIds,
      String owner,
      ) async {
    final pops = _collections[_selectedCollection];

    if (pops == null) {
      return;
    }

    final now = DateTime.now().toIso8601String();

    for (var i = 0; i < pops.length; i++) {
      if (popIds.contains(pops[i].id)) {
        final oldPop = pops[i];

        pops[i] = oldPop.copyWith(
          owner: owner,
          lastUpdated: now,
        );

        await addActivity(
          Activity(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            action: 'owner_changed',
            popName: oldPop.name,
            popNumber: oldPop.number,
            owner: owner,
            actor: owner,
            details: '${oldPop.name} assigned to $owner',
            timestamp: DateTime.now(),
          ),
        );
      }
    }

    await _saveData();

    notifyListeners();
  }

  Future<void> clearSelectedCollection() async {
    final pops = _collections[_selectedCollection];

    if (pops == null) {
      return;
    }

    final removedCount = pops.length;

    pops.clear();

    await addActivity(
      Activity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        action: 'collection_cleared',
        popName: 'Collection Cleared',
        popNumber: '',
        owner: _selectedCollection,
        actor: _collectorProfile.displayName,
        details: 'Cleared $removedCount Pops from $_selectedCollection',
        timestamp: DateTime.now(),
      ),
    );

    await _saveData();

    notifyListeners();
  }

  Future<void> mergeDuplicates() async {
    final pops = _collections[_selectedCollection];

    if (pops == null) {
      return;
    }

    final now = DateTime.now().toIso8601String();
    final merged = <String, Pop>{};

    for (final pop in pops) {
      final key = pop.duplicateKey;

      if (merged.containsKey(key)) {
        final existing = merged[key]!;

        merged[key] = existing.copyWith(
          quantity: existing.quantity + pop.quantity,
          lastUpdated: now,
        );
      } else {
        merged[key] = pop;
      }
    }

    _collections[_selectedCollection] = merged.values.toList();

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
          (total, pops) => total + pops.length,
    );
  }

  int get wishlistCount {
    var total = 0;

    for (final collection in _collections.values) {
      for (final pop in collection) {
        if (pop.isWishlist) {
          total++;
        }
      }
    }

    return total;
  }

  double get totalValue {
    var total = 0.0;

    for (final collection in _collections.values) {
      for (final pop in collection) {
        total += pop.value;
      }
    }

    return total;
  }

  int collectionPopCount(
      String collectionName,
      ) {
    return _collections[collectionName]?.length ?? 0;
  }

  double collectionValue(
      String collectionName,
      ) {
    final pops = _collections[collectionName] ?? [];

    return pops.fold(
      0.0,
          (total, pop) => total + pop.value,
    );
  }

  Future<void> updateCollectorProfile(
      CollectorProfile profile,
      ) async {
    _collectorProfile = profile;

    await _saveData();

    notifyListeners();
  }
}