class AtlasHeroScoreResult {
  const AtlasHeroScoreResult({
    required this.ruleId,
    required this.points,
    required this.reason,
    this.improvementSuggestion,
  });

  /// Stable identifier for the rule that produced this result.
  ///
  /// Examples:
  /// signed
  /// limited_edition
  /// current_value
  /// missing_purchase_price
  final String ruleId;

  /// Positive values increase the collector score.
  /// Negative values reduce the collector score.
  final int points;

  /// Human-readable explanation displayed by Atlas.
  final String reason;

  /// Optional action the collector can take to improve the record.
  final String? improvementSuggestion;

  bool get isPositive => points > 0;

  bool get isNegative => points < 0;

  bool get isNeutral => points == 0;

  bool get hasImprovementSuggestion =>
      improvementSuggestion?.trim().isNotEmpty ?? false;

  AtlasHeroScoreResult copyWith({
    String? ruleId,
    int? points,
    String? reason,
    String? improvementSuggestion,
    bool clearImprovementSuggestion = false,
  }) {
    return AtlasHeroScoreResult(
      ruleId: ruleId ?? this.ruleId,
      points: points ?? this.points,
      reason: reason ?? this.reason,
      improvementSuggestion: clearImprovementSuggestion
          ? null
          : improvementSuggestion ?? this.improvementSuggestion,
    );
  }
}
