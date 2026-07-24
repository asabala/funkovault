class AtlasCollectorScoreResult {
  const AtlasCollectorScoreResult({
    required this.score,
    required this.title,
    required this.progress,
    required this.pointsUntilVaultLegend,
  });

  final int score;
  final String title;
  final double progress;
  final int pointsUntilVaultLegend;
}

class AtlasCollectorScoreEngine {
  const AtlasCollectorScoreEngine();

  AtlasCollectorScoreResult calculate({
    required int totalPops,
    required double collectionValue,
    required int uniqueCategories,
  }) {
    int score = 0;

    score += totalPops * 3;
    score += (collectionValue / 20).round();
    score += uniqueCategories * 25;

    final safeScore = score.clamp(0, 1000);
    final progress = safeScore / 1000;
    final pointsUntilVaultLegend = (1000 - safeScore).clamp(0, 1000);

    return AtlasCollectorScoreResult(
      score: safeScore,
      title: _collectorTitleForScore(safeScore),
      progress: progress,
      pointsUntilVaultLegend: pointsUntilVaultLegend,
    );
  }

  String _collectorTitleForScore(int score) {
    if (score >= 950) return 'Vault Legend';
    if (score >= 850) return 'Elite Curator';
    if (score >= 700) return 'Master Collector';
    if (score >= 550) return 'Dedicated Collector';
    if (score >= 350) return 'Casual Collector';
    return 'Rookie Collector';
  }
}