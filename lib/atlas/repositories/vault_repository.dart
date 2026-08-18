import '../../models/pop.dart';
import '../../services/app_state.dart';
import '../../vault/duplicate_review/duplicate_review_engine.dart';

class VaultRepository {
  const VaultRepository();

  static const DuplicateReviewEngine _duplicateReviewEngine =
      DuplicateReviewEngine();

  List<Pop> pops(AppState appState, {String? collectionName}) {
    if (collectionName == null) {
      return allPops(appState);
    }

    return List<Pop>.from(appState.popsForCollection(collectionName));
  }

  int totalPops(AppState appState, {String? collectionName}) =>
      pops(appState, collectionName: collectionName).length;

  double totalValue(AppState appState, {String? collectionName}) {
    if (collectionName == null) {
      return appState.totalValue;
    }

    return pops(
      appState,
      collectionName: collectionName,
    ).fold<double>(0, (total, pop) => total + pop.value);
  }

  List<Pop> allPops(AppState appState) {
    return appState.collections.values
        .expand((collection) => collection)
        .toList();
  }

  Map<String, int> ownerCounts(AppState appState, {String? collectionName}) {
    final counts = <String, int>{};

    for (final pop in pops(appState, collectionName: collectionName)) {
      counts[pop.owner] = (counts[pop.owner] ?? 0) + 1;
    }

    return counts;
  }

  Map<String, double> ownerValues(AppState appState, {String? collectionName}) {
    final values = <String, double>{};

    for (final pop in pops(appState, collectionName: collectionName)) {
      values[pop.owner] = (values[pop.owner] ?? 0) + pop.value;
    }

    return values;
  }

  List<MapEntry<String, double>> ownerLeaderboard(
    AppState appState, {
    String? collectionName,
  }) {
    final leaderboard = ownerValues(
      appState,
      collectionName: collectionName,
    ).entries.toList();

    leaderboard.sort((a, b) => b.value.compareTo(a.value));

    return leaderboard;
  }

  Map<String, int> categoryCounts(AppState appState, {String? collectionName}) {
    final categories = <String, int>{};

    for (final pop in pops(appState, collectionName: collectionName)) {
      final category = pop.category.isEmpty ? 'Uncategorized' : pop.category;

      categories[category] = (categories[category] ?? 0) + 1;
    }

    return categories;
  }

  Map<String, double> categoryValues(
    AppState appState, {
    String? collectionName,
  }) {
    final values = <String, double>{};

    for (final pop in pops(appState, collectionName: collectionName)) {
      final category = pop.category.isEmpty ? 'Uncategorized' : pop.category;

      values[category] = (values[category] ?? 0) + pop.value;
    }

    return values;
  }

  List<Pop> mostValuablePops(AppState appState, {String? collectionName}) {
    final scopedPops = pops(appState, collectionName: collectionName);

    scopedPops.sort((a, b) => b.value.compareTo(a.value));

    return scopedPops;
  }

  List<DuplicateReviewGroup> duplicateReviewGroups(
    AppState appState, {
    String? collectionName,
  }) {
    return _duplicateReviewEngine.buildGroups(
      pops(appState, collectionName: collectionName),
    );
  }

  int duplicateReviewGroupCount(AppState appState, {String? collectionName}) {
    return _duplicateReviewEngine.countGroups(
      pops(appState, collectionName: collectionName),
    );
  }

  List<List<Pop>> duplicatePopGroups(
    AppState appState, {
    String? collectionName,
  }) {
    return duplicateReviewGroups(
      appState,
      collectionName: collectionName,
    ).map((group) => group.pops).toList();
  }
}
