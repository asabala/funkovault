class AtlasMemory {
  // Favorite franchises
  final List<String> favoriteFranchises;

  // Favorite characters
  final List<String> favoriteCharacters;

  // Favorite series
  final List<String> favoriteSeries;

  // Favorite retailers
  final List<String> favoriteRetailers;

  // Frequently scanned UPCs
  final List<String> recentBarcodes;

  // Recently searched terms
  final List<String> recentSearches;

  // Preferred collection
  final String? favoriteCollection;

  // Total scans
  final int totalScans;

  // Total searches
  final int totalSearches;

  // Total barcode matches
  final int successfulMatches;

  // Last scan
  final DateTime? lastScan;

  // Last search
  final DateTime? lastSearch;

  const AtlasMemory({
    this.favoriteFranchises = const [],
    this.favoriteCharacters = const [],
    this.favoriteSeries = const [],
    this.favoriteRetailers = const [],
    this.recentBarcodes = const [],
    this.recentSearches = const [],
    this.favoriteCollection,
    this.totalScans = 0,
    this.totalSearches = 0,
    this.successfulMatches = 0,
    this.lastScan,
    this.lastSearch,
  });

  AtlasMemory copyWith({
    List<String>? favoriteFranchises,
    List<String>? favoriteCharacters,
    List<String>? favoriteSeries,
    List<String>? favoriteRetailers,
    List<String>? recentBarcodes,
    List<String>? recentSearches,
    String? favoriteCollection,
    int? totalScans,
    int? totalSearches,
    int? successfulMatches,
    DateTime? lastScan,
    DateTime? lastSearch,
  }) {
    return AtlasMemory(
      favoriteFranchises:
      favoriteFranchises ?? this.favoriteFranchises,
      favoriteCharacters:
      favoriteCharacters ?? this.favoriteCharacters,
      favoriteSeries:
      favoriteSeries ?? this.favoriteSeries,
      favoriteRetailers:
      favoriteRetailers ?? this.favoriteRetailers,
      recentBarcodes:
      recentBarcodes ?? this.recentBarcodes,
      recentSearches:
      recentSearches ?? this.recentSearches,
      favoriteCollection:
      favoriteCollection ?? this.favoriteCollection,
      totalScans:
      totalScans ?? this.totalScans,
      totalSearches:
      totalSearches ?? this.totalSearches,
      successfulMatches:
      successfulMatches ?? this.successfulMatches,
      lastScan:
      lastScan ?? this.lastScan,
      lastSearch:
      lastSearch ?? this.lastSearch,
    );
  }
}