import 'atlas_collectibility_signal.dart';

/// Immutable analysis describing why a collectible stands out.
///
/// This model contains intelligence only. It does not contain widgets,
/// icons, colors, navigation, or other presentation-specific behavior.
class AtlasCollectibilitySummary {
  const AtlasCollectibilitySummary({
    required this.score,
    required this.tier,
    required this.confidence,
    required this.headline,
    required this.explanation,
    required this.strengths,
    required this.opportunities,
    required this.signals,
    required this.isDisplayPiece,
    required this.shouldReviewForInsurance,
    required this.marketReadiness,
  });

  final int score;
  final String tier;
  final String confidence;

  final String headline;
  final String explanation;

  final List<String> strengths;
  final List<String> opportunities;
  final List<AtlasCollectibilitySignal> signals;

  final bool isDisplayPiece;

  /// This is intentionally a review recommendation.
  ///
  /// Atlas does not claim that an item is insured or determine whether
  /// insurance is financially appropriate.
  final bool shouldReviewForInsurance;

  final String marketReadiness;

  bool get hasSignals => signals.isNotEmpty;

  bool get hasStrengths => strengths.isNotEmpty;

  bool get hasOpportunities => opportunities.isNotEmpty;

  bool get hasHighConfidence => confidence == 'High';

  bool get isMarketReady => marketReadiness == 'Ready';

  bool get needsMarketDetails =>
      marketReadiness == 'Needs Details';

  AtlasCollectibilitySummary copyWith({
    int? score,
    String? tier,
    String? confidence,
    String? headline,
    String? explanation,
    List<String>? strengths,
    List<String>? opportunities,
    List<AtlasCollectibilitySignal>? signals,
    bool? isDisplayPiece,
    bool? shouldReviewForInsurance,
    String? marketReadiness,
  }) {
    return AtlasCollectibilitySummary(
      score: score ?? this.score,
      tier: tier ?? this.tier,
      confidence: confidence ?? this.confidence,
      headline: headline ?? this.headline,
      explanation: explanation ?? this.explanation,
      strengths: strengths ?? this.strengths,
      opportunities: opportunities ?? this.opportunities,
      signals: signals ?? this.signals,
      isDisplayPiece: isDisplayPiece ?? this.isDisplayPiece,
      shouldReviewForInsurance:
      shouldReviewForInsurance ?? this.shouldReviewForInsurance,
      marketReadiness: marketReadiness ?? this.marketReadiness,
    );
  }
}