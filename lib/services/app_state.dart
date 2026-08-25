import 'package:flutter/material.dart';

import '../atlas/timeline/engine/atlas_timeline_engine.dart';
import '../atlas/timeline/models/atlas_timeline_event.dart';
import '../atlas/market/models/value_history_entry.dart';
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

enum CollectionOperationResult {
  success,
  invalidName,
  duplicateName,
  notFound,
  lastCollection,
  persistenceFailure,
}

typedef _StoredPopLocation = ({
  String collectionName,
  List<Pop> pops,
  int index,
});

class AppState extends ChangeNotifier {
  String _selectedCollection = 'Entire Family Collection';
  final List<Activity> _activities = [];

  final Map<String, Set<String>> _ownedWishlistIdentityKeysByCollection =
      <String, Set<String>>{};

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
    final list = List<Activity>.from(_activities);

    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return list.take(10).toList();
  }

  String get selectedCollection => _selectedCollection;

  Map<String, List<Pop>> get collections => _collections;

  List<String> get collectionNames => _collections.keys.toList();

  bool hasCollection(String collectionName) {
    return _matchingCollectionName(collectionName) != null;
  }

  List<Pop> popsForCollection(String collectionName) {
    final matchingName = _matchingCollectionName(collectionName);

    if (matchingName == null) {
      return const <Pop>[];
    }

    return List<Pop>.unmodifiable(_collections[matchingName]!);
  }

  List<String> collectionNamesContainingPopId(String popId) {
    final normalizedId = popId.trim();

    if (normalizedId.isEmpty) {
      return const <String>[];
    }

    return List<String>.unmodifiable(
      _collections.entries
          .where(
            (entry) => entry.value.any((pop) => pop.id.trim() == normalizedId),
          )
          .map((entry) => entry.key),
    );
  }

  List<String> collectionNamesContainingPop(Pop pop) {
    final normalizedId = pop.id.trim();

    if (normalizedId.isEmpty) {
      return const <String>[];
    }

    final recordKey = pop.collectionRecordKey;

    return List<String>.unmodifiable(
      _collections.entries
          .where(
            (entry) => entry.value.any(
              (storedPop) =>
                  storedPop.id.trim() == normalizedId &&
                  storedPop.collectionRecordKey == recordKey,
            ),
          )
          .map((entry) => entry.key),
    );
  }

  List<Pop> get selectedCollectionPops =>
      _collections[_selectedCollection] ?? [];
  List<Pop> get selectedCollectionWishlistPops {
    final List<Pop> collectionPops =
        _collections[_selectedCollection] ?? const <Pop>[];

    final Set<String> overlayIdentityKeys =
        _ownedWishlistIdentityKeysByCollection[_selectedCollection] ??
        const <String>{};

    return _buildWishlistPops(
      collectionPops: collectionPops,
      overlayIdentityKeys: overlayIdentityKeys,
    );
  }

  List<Pop> get wishlistPops {
    final List<Pop> results = <Pop>[];

    _collections.forEach((String collectionName, List<Pop> collectionPops) {
      final Set<String> overlayIdentityKeys =
          _ownedWishlistIdentityKeysByCollection[collectionName] ??
          const <String>{};

      results.addAll(
        _buildWishlistPops(
          collectionPops: collectionPops,
          overlayIdentityKeys: overlayIdentityKeys,
        ),
      );
    });

    return List<Pop>.unmodifiable(results);
  }

  List<Pop> _buildWishlistPops({
    required List<Pop> collectionPops,
    required Set<String> overlayIdentityKeys,
  }) {
    final List<Pop> results = <Pop>[];
    final Set<String> addedRecordIds = <String>{};
    final Set<String> wishlistRecordIdentityKeys = <String>{};

    for (final Pop pop in collectionPops) {
      if (!pop.isWishlist) {
        continue;
      }

      results.add(pop);

      addedRecordIds.add(pop.id);

      final String identityKey = pop.collectibleIdentityKey.trim();

      if (identityKey.isNotEmpty) {
        wishlistRecordIdentityKeys.add(identityKey);
      }
    }

    for (final Pop pop in collectionPops) {
      if (pop.isWishlist || addedRecordIds.contains(pop.id)) {
        continue;
      }

      final String identityKey = pop.collectibleIdentityKey.trim();

      if (identityKey.isEmpty || !overlayIdentityKeys.contains(identityKey)) {
        continue;
      }

      // Prevent an owned overlay and an old Wishlist-only
      // record from showing the same release twice.
      if (wishlistRecordIdentityKeys.contains(identityKey)) {
        continue;
      }

      results.add(pop);

      addedRecordIds.add(pop.id);
    }

    return List<Pop>.unmodifiable(results);
  }

  Future<void> loadData() async {
    final data = HiveService.loadData('vault_data');

    if (data != null) {
      _selectedCollection =
          data['selectedCollection'] ?? 'Entire Family Collection';

      _collections.clear();
      _activities.clear();

      final activitiesData = data['activities'];
      final profileData = data['collectorProfile'];
      final ownedWishlistData = data['ownedWishlistIdentityKeys'];

      if (profileData != null) {
        _collectorProfile = CollectorProfile.fromJson(
          Map<String, dynamic>.from(profileData),
        );
      }

      if (activitiesData != null) {
        _activities.addAll(
          (activitiesData as List)
              .map((item) => Activity.fromJson(Map<String, dynamic>.from(item)))
              .toList(),
        );
      }

      final collectionsData = data['collections'] as Map<String, dynamic>;

      collectionsData.forEach((key, value) {
        _collections[key] = (value as List)
            .map((item) => Pop.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      });
      _ownedWishlistIdentityKeysByCollection.clear();

      if (ownedWishlistData is Map) {
        ownedWishlistData.forEach((dynamic collectionName, dynamic rawKeys) {
          if (collectionName is! String || rawKeys is! List) {
            return;
          }

          _ownedWishlistIdentityKeysByCollection[collectionName] = rawKeys
              .map((dynamic value) => value.toString().trim())
              .where((String value) => value.isNotEmpty)
              .toSet();
        });
      }

      for (final String collectionName in _collections.keys) {
        _ownedWishlistIdentityKeysByCollection.putIfAbsent(
          collectionName,
          () => <String>{},
        );
      }
    }

    notifyListeners();
  }

  Future<void> _saveData({
    String? selectedCollection,
    Map<String, List<Pop>>? collections,
    Map<String, Set<String>>? ownedWishlistIdentityKeysByCollection,
  }) async {
    final collectionsToSave = collections ?? _collections;
    final wishlistKeysToSave =
        ownedWishlistIdentityKeysByCollection ??
        _ownedWishlistIdentityKeysByCollection;
    final collectionsJson = <String, dynamic>{};

    collectionsToSave.forEach((key, value) {
      collectionsJson[key] = value.map((pop) => pop.toJson()).toList();
    });
    final Map<String, dynamic> ownedWishlistIdentityJson = <String, dynamic>{};

    wishlistKeysToSave.forEach((
      String collectionName,
      Set<String> identityKeys,
    ) {
      ownedWishlistIdentityJson[collectionName] = identityKeys.toList(
        growable: false,
      );
    });
    await HiveService.saveData('vault_data', {
      'selectedCollection': selectedCollection ?? _selectedCollection,
      'collections': collectionsJson,
      'activities': _activities.map((activity) => activity.toJson()).toList(),
      'collectorProfile': _collectorProfile.toJson(),
      'ownedWishlistIdentityKeys': ownedWishlistIdentityJson,
    });
  }

  Future<CollectionOperationResult> setSelectedCollection(String value) async {
    final matchingName = _matchingCollectionName(value);

    if (matchingName == null) {
      return CollectionOperationResult.notFound;
    }

    if (_selectedCollection == matchingName) {
      return CollectionOperationResult.success;
    }

    try {
      await _saveData(selectedCollection: matchingName);
    } catch (_) {
      return CollectionOperationResult.persistenceFailure;
    }

    _selectedCollection = matchingName;
    notifyListeners();

    return CollectionOperationResult.success;
  }

  Future<CollectionOperationResult> addCollection(String name) async {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      return CollectionOperationResult.invalidName;
    }

    if (_matchingCollectionName(trimmedName) != null) {
      return CollectionOperationResult.duplicateName;
    }

    final updatedCollections = Map<String, List<Pop>>.from(_collections)
      ..[trimmedName] = <Pop>[];
    final updatedWishlistKeys = _copyWishlistKeys()..[trimmedName] = <String>{};

    try {
      await _saveData(
        collections: updatedCollections,
        ownedWishlistIdentityKeysByCollection: updatedWishlistKeys,
      );
    } catch (_) {
      return CollectionOperationResult.persistenceFailure;
    }

    _replaceCollections(updatedCollections);
    _replaceWishlistKeys(updatedWishlistKeys);
    notifyListeners();

    return CollectionOperationResult.success;
  }

  Future<CollectionOperationResult> renameCollection(
    String currentName,
    String newName,
  ) async {
    final existingName = _matchingCollectionName(currentName);
    final trimmedNewName = newName.trim();

    if (existingName == null) {
      return CollectionOperationResult.notFound;
    }

    if (trimmedNewName.isEmpty) {
      return CollectionOperationResult.invalidName;
    }

    final duplicateName = _matchingCollectionName(trimmedNewName);

    if (duplicateName != null && duplicateName != existingName) {
      return CollectionOperationResult.duplicateName;
    }

    if (trimmedNewName == existingName) {
      return CollectionOperationResult.success;
    }

    final updatedCollections = <String, List<Pop>>{};

    for (final entry in _collections.entries) {
      updatedCollections[entry.key == existingName
              ? trimmedNewName
              : entry.key] =
          entry.value;
    }

    final updatedWishlistKeys = <String, Set<String>>{};

    for (final entry in _ownedWishlistIdentityKeysByCollection.entries) {
      updatedWishlistKeys[entry.key == existingName
          ? trimmedNewName
          : entry.key] = Set<String>.from(
        entry.value,
      );
    }

    updatedWishlistKeys.putIfAbsent(trimmedNewName, () => <String>{});

    final updatedSelection = _selectedCollection == existingName
        ? trimmedNewName
        : _selectedCollection;

    try {
      await _saveData(
        selectedCollection: updatedSelection,
        collections: updatedCollections,
        ownedWishlistIdentityKeysByCollection: updatedWishlistKeys,
      );
    } catch (_) {
      return CollectionOperationResult.persistenceFailure;
    }

    _replaceCollections(updatedCollections);
    _replaceWishlistKeys(updatedWishlistKeys);
    _selectedCollection = updatedSelection;
    notifyListeners();

    return CollectionOperationResult.success;
  }

  Future<CollectionOperationResult> deleteCollection(String name) async {
    final matchingName = _matchingCollectionName(name);

    if (matchingName == null) {
      return CollectionOperationResult.notFound;
    }

    if (_collections.length <= 1) {
      return CollectionOperationResult.lastCollection;
    }

    final updatedCollections = Map<String, List<Pop>>.from(_collections)
      ..remove(matchingName);
    final updatedWishlistKeys = _copyWishlistKeys()..remove(matchingName);
    final updatedSelection = _selectedCollection == matchingName
        ? updatedCollections.keys.first
        : _selectedCollection;

    try {
      await _saveData(
        selectedCollection: updatedSelection,
        collections: updatedCollections,
        ownedWishlistIdentityKeysByCollection: updatedWishlistKeys,
      );
    } catch (_) {
      return CollectionOperationResult.persistenceFailure;
    }

    _replaceCollections(updatedCollections);
    _replaceWishlistKeys(updatedWishlistKeys);
    _selectedCollection = updatedSelection;
    notifyListeners();

    return CollectionOperationResult.success;
  }

  String? _matchingCollectionName(String value) {
    final normalizedName = value.trim().toLowerCase();

    if (normalizedName.isEmpty) {
      return null;
    }

    for (final collectionName in _collections.keys) {
      if (collectionName.trim().toLowerCase() == normalizedName) {
        return collectionName;
      }
    }

    return null;
  }

  Map<String, Set<String>> _copyWishlistKeys() {
    return _ownedWishlistIdentityKeysByCollection.map(
      (collectionName, identityKeys) =>
          MapEntry(collectionName, Set<String>.from(identityKeys)),
    );
  }

  void _replaceCollections(Map<String, List<Pop>> collections) {
    _collections
      ..clear()
      ..addAll(collections);
  }

  void _replaceWishlistKeys(Map<String, Set<String>> wishlistKeys) {
    _ownedWishlistIdentityKeysByCollection
      ..clear()
      ..addAll(wishlistKeys);
  }

  Set<String> get selectedOwnedWishlistIdentityKeys {
    return Set<String>.unmodifiable(
      _ownedWishlistIdentityKeysByCollection[_selectedCollection] ??
          const <String>{},
    );
  }

  Set<String> ownedWishlistIdentityKeysForCollection(String collectionName) {
    final String? matchingName = _matchingCollectionName(collectionName);

    if (matchingName == null) {
      return const <String>{};
    }

    return Set<String>.unmodifiable(
      _ownedWishlistIdentityKeysByCollection[matchingName] ?? const <String>{},
    );
  }

  Set<String> get allOwnedWishlistIdentityKeys {
    final Set<String> identityKeys = <String>{};

    for (final Set<String> collectionKeys
        in _ownedWishlistIdentityKeysByCollection.values) {
      identityKeys.addAll(collectionKeys);
    }

    return Set<String>.unmodifiable(identityKeys);
  }

  bool isOwnedPopWishlisted(Pop pop, {String? collectionName}) {
    final String identityKey = pop.collectibleIdentityKey.trim();

    if (identityKey.isEmpty) {
      return false;
    }

    final String? targetCollectionName = collectionName == null
        ? _selectedCollection
        : _matchingCollectionName(collectionName);

    if (targetCollectionName == null) {
      return false;
    }

    final Set<String> identityKeys =
        _ownedWishlistIdentityKeysByCollection[targetCollectionName] ??
        const <String>{};

    return identityKeys.contains(identityKey);
  }

  bool isCollectibleWishlisted(Pop pop, {String? collectionName}) {
    final String identityKey = pop.collectibleIdentityKey.trim();

    if (identityKey.isEmpty) {
      return false;
    }

    final String? targetCollectionName = collectionName == null
        ? _selectedCollection
        : _matchingCollectionName(collectionName);

    if (targetCollectionName == null) {
      return false;
    }

    if (isOwnedPopWishlisted(pop, collectionName: targetCollectionName)) {
      return true;
    }

    final List<Pop> pops = _collections[targetCollectionName] ?? const <Pop>[];

    return pops.any((Pop existingPop) {
      return existingPop.isWishlist &&
          existingPop.collectibleIdentityKey == identityKey;
    });
  }

  Future<void> addOwnedPopToWishlist(Pop pop, {String? collectionName}) async {
    final String identityKey = pop.collectibleIdentityKey.trim();

    if (identityKey.isEmpty) {
      return;
    }

    final String? targetCollectionName = collectionName == null
        ? _selectedCollection
        : _matchingCollectionName(collectionName);

    if (targetCollectionName == null) {
      return;
    }

    final Set<String> identityKeys = _ownedWishlistIdentityKeysByCollection
        .putIfAbsent(targetCollectionName, () => <String>{});

    if (!identityKeys.add(identityKey)) {
      return;
    }

    _activities.add(
      Activity(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        popId: pop.id,
        action: 'wishlist_added',
        popName: pop.name,
        popNumber: pop.number,
        owner: pop.owner,
        actor: _collectorProfile.displayName,
        details: '${pop.name} added to Wishlist',
        timestamp: DateTime.now(),
      ),
    );

    if (_activities.length > 500) {
      _activities.removeAt(0);
    }

    await _saveData();

    notifyListeners();
  }

  Future<void> removeOwnedPopFromWishlist(
    Pop pop, {
    String? collectionName,
  }) async {
    final String identityKey = pop.collectibleIdentityKey.trim();

    if (identityKey.isEmpty) {
      return;
    }

    final String? targetCollectionName = collectionName == null
        ? _selectedCollection
        : _matchingCollectionName(collectionName);

    if (targetCollectionName == null) {
      return;
    }

    final Set<String>? identityKeys =
        _ownedWishlistIdentityKeysByCollection[targetCollectionName];

    if (identityKeys == null || !identityKeys.remove(identityKey)) {
      return;
    }

    _activities.add(
      Activity(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        popId: pop.id,
        action: 'wishlist_removed',
        popName: pop.name,
        popNumber: pop.number,
        owner: pop.owner,
        actor: _collectorProfile.displayName,
        details: '${pop.name} removed from Wishlist',
        timestamp: DateTime.now(),
      ),
    );

    if (_activities.length > 500) {
      _activities.removeAt(0);
    }

    await _saveData();

    notifyListeners();
  }

  Future<bool> addPop(Pop pop, {String? collectionName}) async {
    final targetCollectionName = collectionName == null
        ? _selectedCollection
        : _matchingCollectionName(collectionName);
    final pops = targetCollectionName == null
        ? null
        : _collections[targetCollectionName];

    if (pops == null) {
      return false;
    }

    final now = DateTime.now().toIso8601String();

    final newRecordKey = pop.collectionRecordKey;

    final existingIndex = newRecordKey.isEmpty
        ? -1
        : pops.indexWhere(
            (existingPop) => existingPop.collectionRecordKey == newRecordKey,
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
          popId: existingPop.id,
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
      final addedAt =
          DateTime.tryParse(
            pop.dateAdded.trim().isEmpty ? now : pop.dateAdded,
          ) ??
          DateTime.now();

      final existingTimeline = List<AtlasTimelineEvent>.from(pop.timeline);
      final hasAddedEvent = existingTimeline.any(
        (event) => event.type == AtlasTimelineEventType.addedToVault,
      );

      if (!hasAddedEvent) {
        existingTimeline.add(
          AtlasTimelineEvent(
            id: 'added-${pop.id}-${addedAt.microsecondsSinceEpoch}',
            popId: pop.id,
            type: AtlasTimelineEventType.addedToVault,
            occurredAt: addedAt,
            title: 'Added to Vault',
            createdBy: AtlasTimelineEvent.systemCreatedBy,
            createdAt: addedAt,
          ),
        );
      }

      existingTimeline.sort((a, b) => a.occurredAt.compareTo(b.occurredAt));

      final datedPop = pop.copyWith(
        dateAdded: addedAt.toIso8601String(),
        lastUpdated: pop.lastUpdated.trim().isEmpty ? now : pop.lastUpdated,
        timeline: List<AtlasTimelineEvent>.unmodifiable(existingTimeline),
      );

      pops.add(datedPop);

      await addActivity(
        Activity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          popId: datedPop.id,
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

    return true;
  }

  Future<void> importPops(List<Pop> pops) async {
    await importPopsSafely(pops);
  }

  Future<PopImportResult> importPopsSafely(List<Pop> importedPops) async {
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
      final existingIndex = key.isEmpty ? null : indexesByRecordKey[key];

      if (existingIndex != null) {
        final existingPop = currentPops[existingIndex];

        currentPops[existingIndex] = existingPop.copyWith(
          quantity: existingPop.quantity + importedPop.quantity,
          value: existingPop.value > 0 ? existingPop.value : importedPop.value,
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

  Future<bool> deletePop(
    String popId, {
    String? collectionName,
    String? recordKey,
  }) async {
    final location = _resolveStoredPop(
      popId: popId,
      collectionName: collectionName,
      recordKey: recordKey,
    );

    if (location == null) {
      return false;
    }

    final pop = location.pops[location.index];

    await addActivity(
      Activity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        popId: pop.id,
        action: 'pop_deleted',
        popName: pop.name,
        popNumber: pop.number,
        owner: pop.owner,
        actor: pop.owner,
        details: '${pop.name} deleted',
        timestamp: DateTime.now(),
      ),
    );

    location.pops.removeAt(location.index);

    await _saveData();

    notifyListeners();

    return true;
  }

  Future<void> updateOwnerForPops(List<String> popIds, String owner) async {
    final pops = _collections[_selectedCollection];

    if (pops == null) {
      return;
    }

    final now = DateTime.now().toIso8601String();

    for (var i = 0; i < pops.length; i++) {
      if (popIds.contains(pops[i].id)) {
        final oldPop = pops[i];

        pops[i] = oldPop.copyWith(owner: owner, lastUpdated: now);

        await addActivity(
          Activity(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            popId: oldPop.id,
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

  Future<Pop?> updatePop(
    Pop updatedPop, {
    String? collectionName,
    String? existingRecordKey,
  }) async {
    final location = _resolveStoredPop(
      popId: updatedPop.id,
      collectionName: collectionName,
      recordKey: existingRecordKey,
    );

    if (location == null) {
      return null;
    }

    final existingPop = location.pops[location.index];
    final now = DateTime.now();
    final nowIso = now.toIso8601String();

    const timelineEngine = AtlasTimelineEngine();

    final detectedEvents = timelineEngine.comparePopChanges(
      previousPop: existingPop,
      updatedPop: updatedPop,
      occurredAt: now,
      source: 'Manual',
    );

    final timeline = <AtlasTimelineEvent>[
      ...existingPop.timeline,
      ...detectedEvents,
    ];

    final sortedTimeline = timelineEngine.chronological(timeline);

    final valueHistory = _updatedValueHistory(
      existingPop: existingPop,
      updatedPop: updatedPop,
      occurredAt: now,
    );

    final persistedPop = updatedPop.copyWith(
      dateAdded: existingPop.dateAdded,
      lastUpdated: nowIso,
      valueHistory: valueHistory,
      timeline: sortedTimeline,
    );

    location.pops[location.index] = persistedPop;

    await _saveData();

    notifyListeners();

    return persistedPop;
  }

  _StoredPopLocation? _resolveStoredPop({
    required String popId,
    String? collectionName,
    String? recordKey,
  }) {
    final normalizedId = popId.trim();

    if (normalizedId.isEmpty) {
      return null;
    }

    final Iterable<MapEntry<String, List<Pop>>> collectionsToSearch;

    if (collectionName != null) {
      final matchingName = _matchingCollectionName(collectionName);

      if (matchingName == null) {
        return null;
      }

      collectionsToSearch = <MapEntry<String, List<Pop>>>[
        MapEntry(matchingName, _collections[matchingName]!),
      ];
    } else {
      collectionsToSearch = _collections.entries;
    }

    final matches = <_StoredPopLocation>[];

    for (final collection in collectionsToSearch) {
      for (var index = 0; index < collection.value.length; index++) {
        final storedPop = collection.value[index];

        if (storedPop.id.trim() != normalizedId) {
          continue;
        }

        if (recordKey != null && storedPop.collectionRecordKey != recordKey) {
          continue;
        }

        matches.add((
          collectionName: collection.key,
          pops: collection.value,
          index: index,
        ));

        if (matches.length > 1) {
          return null;
        }
      }
    }

    return matches.singleOrNull;
  }

  List<ValueHistoryEntry> _updatedValueHistory({
    required Pop existingPop,
    required Pop updatedPop,
    required DateTime occurredAt,
  }) {
    if (existingPop.value == updatedPop.value) {
      return existingPop.valueHistory;
    }

    final entries = <ValueHistoryEntry>[...existingPop.valueHistory];

    if (entries.isEmpty && existingPop.value > 0) {
      entries.add(
        ValueHistoryEntry(
          value: existingPop.value,
          recordedAt:
              DateTime.tryParse(existingPop.lastUpdated) ??
              DateTime.tryParse(existingPop.dateAdded) ??
              occurredAt,
          source: ValueHistoryEntry.legacyValueSource,
        ),
      );
    }

    if (updatedPop.value > 0) {
      entries.add(
        ValueHistoryEntry(
          value: updatedPop.value,
          recordedAt: occurredAt,
          source: ValueHistoryEntry.manualSource,
        ),
      );
    }

    entries.sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

    return List<ValueHistoryEntry>.unmodifiable(entries);
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

  Future<bool> consolidateDuplicateGroup(List<String> popIds) async {
    if (popIds.length < 2) {
      return false;
    }

    List<Pop>? matchingCollection;
    final matchingPops = <Pop>[];

    for (final collection in _collections.values) {
      final foundPops = collection
          .where((pop) => popIds.contains(pop.id))
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
        .map((pop) => pop.collectionRecordKey)
        .where((key) => key.isNotEmpty)
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
      (highest, pop) => pop.value > highest ? pop.value : highest,
    );

    final bestPricePaid = matchingPops.fold<double>(
      0,
      (highest, pop) => pop.pricePaid > highest ? pop.pricePaid : highest,
    );

    final bestImageUrl = matchingPops
        .map((pop) => pop.imageUrl.trim())
        .firstWhere(
          (value) => value.isNotEmpty,
          orElse: () => primaryPop.imageUrl,
        );

    final earliestDateAdded = _earliestSavedDate(
      matchingPops.map((pop) => pop.dateAdded),
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

    final removedIds = matchingPops.skip(1).map((pop) => pop.id).toSet();

    matchingCollection.removeWhere((pop) => removedIds.contains(pop.id));

    _activities.add(
      Activity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        popId: consolidatedPop.id,
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

  String _earliestSavedDate(Iterable<String> values) {
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

  Future<void> addActivity(Activity activity) async {
    _activities.add(activity);

    if (_activities.length > 500) {
      _activities.removeAt(0);
    }

    await _saveData();

    notifyListeners();
  }

  int get totalPops {
    return _collections.values.fold(0, (total, pops) => total + pops.length);
  }

  int get wishlistCount {
    return wishlistPops.length;
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

  int collectionPopCount(String collectionName) {
    return _collections[collectionName]?.length ?? 0;
  }

  double collectionValue(String collectionName) {
    final pops = _collections[collectionName] ?? [];

    return pops.fold(0.0, (total, pop) => total + pop.value);
  }

  Future<void> updateCollectorProfile(CollectorProfile profile) async {
    _collectorProfile = profile;

    await _saveData();

    notifyListeners();
  }
}
