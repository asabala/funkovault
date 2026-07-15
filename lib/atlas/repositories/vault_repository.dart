import '../../models/pop.dart';
import '../../services/app_state.dart';
import '../../vault/duplicate_review/duplicate_review_engine.dart';

class VaultRepository {
  const VaultRepository();

  static const DuplicateReviewEngine _duplicateReviewEngine =
  DuplicateReviewEngine();

  int totalPops(AppState appState) => appState.totalPops;

  double totalValue(AppState appState) => appState.totalValue;

  List<Pop> allPops(AppState appState) {
    return appState.collections.values
        .expand((collection) => collection)
        .toList();
  }

  Map<String, int> ownerCounts(AppState appState) {
    final counts = <String, int>{};

    for (final pop in allPops(appState)) {
      counts[pop.owner] = (counts[pop.owner] ?? 0) + 1;
    }

    return counts;
  }

  Map<String, double> ownerValues(AppState appState) {
    final values = <String, double>{};

    for (final pop in allPops(appState)) {
      values[pop.owner] = (values[pop.owner] ?? 0) + pop.value;
    }

    return values;
  }

  List<MapEntry<String, double>> ownerLeaderboard(
      AppState appState,
      ) {
    final leaderboard = ownerValues(appState).entries.toList();

    leaderboard.sort(
          (a, b) => b.value.compareTo(a.value),
    );

    return leaderboard;
  }

  Map<String, int> categoryCounts(AppState appState) {
    final categories = <String, int>{};

    for (final pop in allPops(appState)) {
      final category =
      pop.category.isEmpty ? 'Uncategorized' : pop.category;

      categories[category] = (categories[category] ?? 0) + 1;
    }

    return categories;
  }

  Map<String, double> categoryValues(
      AppState appState,
      ) {
    final values = <String, double>{};

    for (final pop in allPops(appState)) {
      final category =
      pop.category.isEmpty ? 'Uncategorized' : pop.category;

      values[category] = (values[category] ?? 0) + pop.value;
    }

    return values;
  }

  List<Pop> mostValuablePops(
      AppState appState,
      ) {
    final pops = allPops(appState);

    pops.sort(
          (a, b) => b.value.compareTo(a.value),
    );

    return pops;
  }

  List<DuplicateReviewGroup> duplicateReviewGroups(
      AppState appState,
      ) {
    return _duplicateReviewEngine.buildGroups(
      allPops(appState),
    );
  }

  int duplicateReviewGroupCount(
      AppState appState,
      ) {
    return _duplicateReviewEngine.countGroups(
      allPops(appState),
    );
  }

  List<List<Pop>> duplicatePopGroups(
      AppState appState,
      ) {
    return duplicateReviewGroups(appState)
        .map((group) => group.pops)
        .toList();
  }
}