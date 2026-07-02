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

      if (category.isEmpty) continue;

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

    final wishlistCount = pops.where((pop) => pop.isWishlist).length;
    final highValueCount = pops.where((pop) => pop.value >= 50).length;
    final categoryCount = pops.map((pop) => pop.category).toSet().length;

    if (wishlistCount >= 10) {
      return 'Hunter';
    }

    if (highValueCount >= 5) {
      return 'Investor';
    }

    if (categoryCount <= 2 && pops.length >= 10) {
      return 'Completionist';
    }

    if (categoryCount >= 5) {
      return 'Explorer';
    }

    return 'Curator';
  }

  double getCollectorConfidence(List<Pop> pops) {
    if (pops.isEmpty) {
      return 100;
    }

    final missingValues = pops.where((pop) => pop.value <= 0).length;
    final missingCategories =
        pops.where((pop) => pop.category.trim().isEmpty).length;

    final issueCount = missingValues + missingCategories;
    final score = 100 - ((issueCount / pops.length) * 100);

    return score.clamp(0, 100);
  }

  String getTodayMission(List<Pop> pops) {
    if (pops.isEmpty) {
      return 'Add your first collectible to begin building your Vault intelligence.';
    }

    final missingValues = pops.where((pop) => pop.value <= 0).length;

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

    return 'Atlas sees you as a $collectorType collector with a strong focus on $favoriteCategory.';
  }
}