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

    final newRecordKey = pop.collectionRecordKey;

    final existingIndex = newRecordKey.isEmpty
        ? -1
        : pops.indexWhere(
          (existingPop) =>
      existingPop.collectionRecordKey == newRecordKey,
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

    final indexesByRecordKey = <String, int>{};

    for (var index = 0; index < currentPops.length; index++) {
      final key = currentPops[index].collectionRecordKey;

      if (key.isNotEmpty) {
        indexesByRecordKey[key] = index;
      }
    }

    final now = DateTime.now().toIso8601String();

    var added = 0;
    var consolidated = 0;

    for (final importedPop in importedPops) {
      final key = importedPop.collectionRecordKey;
      final existingIndex =
      key.isEmpty ? null : indexesByRecordKey[key];

      if (existingIndex != null) {
        final existingPop = currentPops[existingIndex];

        currentPops[existingIndex] = existingPop.copyWith(
          quantity: existingPop.quantity + importedPop.quantity,
          value: existingPop.value > 0
              ? existingPop.value
              : importedPop.value,
          pricePaid: existingPop.pricePaid > 0
              ? existingPop.pricePaid
              : importedPop.pricePaid,
          imageUrl: existingPop.imageUrl.trim().isNotEmpty
              ? existingPop.imageUrl
              : importedPop.imageUrl,
          lastUpdated: now,
        );

        consolidated++;
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

      if (key.isNotEmpty) {
        indexesByRecordKey[key] = currentPops.length - 1;
      }

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
        details:
        'CSV import complete: $added records added, '
            '$consolidated matching copies consolidated',
        timestamp: DateTime.now(),
      ),
    );

    await _saveData();

    notifyListeners();

    return PopImportResult(
      attempted: importedPops.length,
      added: added,
      skipped: consolidated,
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

  Future<bool> consolidateDuplicateGroup(
      List<String> popIds,
      ) async {
    if (popIds.length < 2) {
      return false;
    }

    List<Pop>? matchingCollection;
    final matchingPops = <Pop>[];

    for (final collection in _collections.values) {
      final foundPops = collection
          .where(
            (pop) => popIds.contains(pop.id),
      )
          .toList();

      if (foundPops.length == popIds.length) {
        matchingCollection = collection;
        matchingPops.addAll(foundPops);
        break;
      }
    }

    if (matchingCollection == null || matchingPops.length < 2) {
      return false;
    }

    final identityKeys = matchingPops
        .map(
          (pop) => pop.collectionRecordKey,
    )
        .where(
          (key) => key.isNotEmpty,
    )
        .toSet();

    if (identityKeys.length != 1) {
      return false;
    }

    final now = DateTime.now().toIso8601String();
    final primaryPop = matchingPops.first;

    final totalQuantity = matchingPops.fold<int>(
      0,
          (total, pop) => total + pop.quantity,
    );

    final bestValue = matchingPops.fold<double>(
      0,
          (highest, pop) => pop.value > highest
          ? pop.value
          : highest,
    );

    final bestPricePaid = matchingPops.fold<double>(
      0,
          (highest, pop) => pop.pricePaid > highest
          ? pop.pricePaid
          : highest,
    );

    final bestImageUrl = matchingPops
        .map(
          (pop) => pop.imageUrl.trim(),
    )
        .firstWhere(
          (value) => value.isNotEmpty,
      orElse: () => primaryPop.imageUrl,
    );

    final earliestDateAdded = _earliestSavedDate(
      matchingPops.map(
            (pop) => pop.dateAdded,
      ),
    );

    final consolidatedPop = primaryPop.copyWith(
      quantity: totalQuantity,
      value: bestValue,
      pricePaid: bestPricePaid,
      imageUrl: bestImageUrl,
      dateAdded: earliestDateAdded.isEmpty
          ? primaryPop.dateAdded
          : earliestDateAdded,
      lastUpdated: now,
    );

    final primaryIndex = matchingCollection.indexWhere(
          (pop) => pop.id == primaryPop.id,
    );

    if (primaryIndex == -1) {
      return false;
    }

    matchingCollection[primaryIndex] = consolidatedPop;

    final removedIds = matchingPops
        .skip(1)
        .map(
          (pop) => pop.id,
    )
        .toSet();

    matchingCollection.removeWhere(
          (pop) => removedIds.contains(pop.id),
    );

    _activities.add(
      Activity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        action: 'duplicates_consolidated',
        popName: consolidatedPop.name,
        popNumber: consolidatedPop.number,
        owner: consolidatedPop.owner,
        actor: _collectorProfile.displayName,
        details:
        '${matchingPops.length} matching records consolidated into '
            'quantity $totalQuantity',
        timestamp: DateTime.now(),
      ),
    );

    if (_activities.length > 500) {
      _activities.removeAt(0);
    }

    await _saveData();

    notifyListeners();

    return true;
  }

  String _earliestSavedDate(
      Iterable<String> values,
      ) {
    DateTime? earliestDate;
    var earliestValue = '';

    for (final value in values) {
      final cleaned = value.trim();
      final parsed = DateTime.tryParse(cleaned);

      if (parsed == null) {
        continue;
      }

      if (earliestDate == null || parsed.isBefore(earliestDate)) {
        earliestDate = parsed;
        earliestValue = cleaned;
      }
    }

    return earliestValue;
  }

  Future<void> mergeDuplicates() async {
    final pops = _collections[_selectedCollection];

    if (pops == null) {
      return;
    }

    final now = DateTime.now().toIso8601String();
    final merged = <String, Pop>{};

    for (final pop in pops) {
      final key = pop.collectionRecordKey;

      if (key.isEmpty) {
        merged[pop.id] = pop;
        continue;
      }

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