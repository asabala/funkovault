class CollectorMemory {
  const CollectorMemory({
    required this.favoriteCategory,
    required this.favoriteSeries,
    required this.totalCollectionGrowth,
    required this.lastRecommendation,
    required this.collectorConfidence,
  });

  final String favoriteCategory;
  final String favoriteSeries;
  final int totalCollectionGrowth;
  final String lastRecommendation;
  final double collectorConfidence;

  CollectorMemory copyWith({
    String? favoriteCategory,
    String? favoriteSeries,
    int? totalCollectionGrowth,
    String? lastRecommendation,
    double? collectorConfidence,
  }) {
    return CollectorMemory(
      favoriteCategory:
      favoriteCategory ?? this.favoriteCategory,
      favoriteSeries:
      favoriteSeries ?? this.favoriteSeries,
      totalCollectionGrowth:
      totalCollectionGrowth ??
          this.totalCollectionGrowth,
      lastRecommendation:
      lastRecommendation ??
          this.lastRecommendation,
      collectorConfidence:
      collectorConfidence ??
          this.collectorConfidence,
    );
  }
}