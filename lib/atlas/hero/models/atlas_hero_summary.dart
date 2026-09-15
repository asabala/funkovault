class AtlasHeroSummary {
  const AtlasHeroSummary({
    required this.collectorScore,
    required this.classification,
    required this.headline,
    required this.summary,
    required this.primaryEmoji,
    required this.scoreReasons,
    required this.improvementSuggestions,
  });

  /// Transparent collector-quality score from 0–100.
  final int collectorScore;

  /// High-level classification such as:
  /// Standard Collectible, Notable Collectible, Premium Collectible, or Grail.
  final String classification;

  /// Short display headline for the hero section.
  final String headline;

  /// Human-readable explanation generated from trusted Atlas rules.
  final String summary;

  /// Emoji representing the strongest classification.
  final String primaryEmoji;

  /// Positive reasons explaining how the score was earned.
  final List<String> scoreReasons;

  /// Missing information or actions that could improve the record.
  final List<String> improvementSuggestions;

  int get normalizedScore => collectorScore.clamp(0, 100);

  bool get isGrail => normalizedScore >= 90;

  bool get isPremium => normalizedScore >= 75;

  bool get isNotable => normalizedScore >= 55;

  bool get hasScoreReasons => scoreReasons.isNotEmpty;

  bool get hasImprovementSuggestions => improvementSuggestions.isNotEmpty;

  String get scoreLabel {
    if (normalizedScore >= 90) {
      return 'Exceptional';
    }

    if (normalizedScore >= 75) {
      return 'Excellent';
    }

    if (normalizedScore >= 55) {
      return 'Strong';
    }

    if (normalizedScore >= 35) {
      return 'Developing';
    }

    return 'Foundation';
  }
}
