import '../../models/pop.dart';

class AtlasIntelligence {
  const AtlasIntelligence();

  String getFavoriteCategory(List<Pop> pops) {
    if (pops.isEmpty) {
      return 'Unknown';
    }

    final counts = <String, int>{};

    for (final pop in pops) {
      final category = pop.category.trim();

      if (category.isEmpty) {
        continue;
      }

      counts[category] = (counts[category] ?? 0) + 1;
    }

    if (counts.isEmpty) {
      return 'Unknown';
    }

    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.first.key;
  }

  String getCollectorType(List<Pop> pops) {
    if (pops.isEmpty) {
      return 'Explorer';
    }

    final ownedPops = pops.where((pop) => !pop.isWishlist).toList();
    final collectionSize = ownedPops.length;
    final wishlistCount = pops.where((pop) => pop.isWishlist).length;
    final highValueCount = ownedPops.where((pop) => pop.value >= 50).length;

    final categoryCount = ownedPops
        .map((pop) => pop.category.trim())
        .where((category) => category.isNotEmpty)
        .toSet()
        .length;

    final highValueRatio = collectionSize == 0
        ? 0
        : highValueCount / collectionSize;

    if (wishlistCount >= 10 && wishlistCount >= collectionSize * 0.20) {
      return 'Hunter';
    }

    if (collectionSize >= 25 && categoryCount <= 2) {
      return 'Completionist';
    }

    if (collectionSize >= 20 && categoryCount >= 5) {
      return 'Curator';
    }

    if (collectionSize >= 10 && highValueRatio >= 0.35) {
      return 'Investor';
    }

    if (categoryCount >= 5) {
      return 'Explorer';
    }

    return 'Collector';
  }

  double getCollectorConfidence(List<Pop> pops) {
    if (pops.isEmpty) {
      return 100;
    }

    final missingValues = pops.where((pop) => pop.value <= 0).length;
    final missingCategories = pops
        .where((pop) => pop.category.trim().isEmpty)
        .length;

    final valueScore = 100 - ((missingValues / pops.length) * 70);
    final categoryScore = 100 - ((missingCategories / pops.length) * 30);

    final score = (valueScore * 0.65) + (categoryScore * 0.35);

    return score.clamp(10, 100);
  }

  String getTodayMission(List<Pop> pops) {
    if (pops.isEmpty) {
      return 'Add your first collectible to begin building your Vault intelligence.';
    }

    final missingValues = pops.where((pop) => pop.value <= 0).length;
    final missingCategories = pops
        .where((pop) => pop.category.trim().isEmpty)
        .length;

    if (missingCategories > 0) {
      return 'Add missing categories so Atlas can organize your Vault Rooms better.';
    }

    if (missingValues > 0) {
      return 'Update missing values to improve your Vault accuracy.';
    }

    final favoriteCategory = getFavoriteCategory(pops);

    return 'Review your $favoriteCategory room and keep your collection momentum going.';
  }

  String getRecommendation(List<Pop> pops) {
    if (pops.isEmpty) {
      return 'Start your Vault by adding your first Pop.';
    }

    final collectorType = getCollectorType(pops);
    final favoriteCategory = getFavoriteCategory(pops);

    if (favoriteCategory == 'Unknown') {
      return 'Atlas is learning your collection. Add categories to unlock better recommendations.';
    }

    return 'Atlas sees you as a $collectorType with a strong focus on $favoriteCategory.';
  }
}
