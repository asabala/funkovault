class AtlasCollectorScoreEngine {
  const AtlasCollectorScoreEngine();

  int calculateScore({
    required int totalPops,
    required double collectionValue,
    required int uniqueCategories,
  }) {
    int score = 0;

    score += totalPops * 3;
    score += (collectionValue / 20).round();
    score += uniqueCategories * 25;

    return score.clamp(0, 1000);
  }

  String collectorTitleForScore(int score) {
    if (score >= 950) return 'Vault Legend';
    if (score >= 850) return 'Elite Curator';
    if (score >= 700) return 'Master Collector';
    if (score >= 550) return 'Dedicated Collector';
    if (score >= 350) return 'Casual Collector';
    return 'Rookie Collector';
  }
}