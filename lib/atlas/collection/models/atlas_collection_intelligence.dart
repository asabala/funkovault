import '../../collectibility/models/atlas_collectibility_summary.dart';
import '../../engines/collection/pop_activity_summary_engine.dart';
import '../../engines/timeline/models/atlas_timeline_intelligence_report.dart';
import '../../hero/models/atlas_hero_summary.dart';
import '../../identity/pop/pop_identity_rule.dart';
import '../../recommendations/models/atlas_recommendation.dart';
import '../../recommendations/models/atlas_recommendation_summary.dart';

/// Immutable intelligence snapshot generated for one collectible.
class AtlasCollectionIntelligence {
  const AtlasCollectionIntelligence({
    required this.popId,
    required this.generatedAt,
    required this.heroSummary,
    required this.timelineReport,
    required this.activitySummary,
    required this.identityBadges,
    required this.collectibilitySummary,
    required this.recommendationSummary,
  });

  final String popId;
  final DateTime generatedAt;

  final AtlasHeroSummary heroSummary;
  final AtlasTimelineIntelligenceReport timelineReport;
  final PopActivitySummary activitySummary;
  final List<PopIdentityBadgeData> identityBadges;
  final AtlasCollectibilitySummary collectibilitySummary;
  final AtlasRecommendationSummary recommendationSummary;

  int get collectorScore => collectibilitySummary.score;

  String get classification => collectibilitySummary.tier;

  String get headline => collectibilitySummary.headline;

  bool get hasScoreReasons => heroSummary.hasScoreReasons;

  bool get hasImprovementSuggestions => collectibilitySummary.hasOpportunities;

  bool get hasIdentityBadges => identityBadges.isNotEmpty;

  bool get hasCollectibilitySignals => collectibilitySummary.hasSignals;

  bool get isDisplayPiece => collectibilitySummary.isDisplayPiece;

  bool get shouldReviewForInsurance =>
      collectibilitySummary.shouldReviewForInsurance;

  bool get isMarketReady => collectibilitySummary.isMarketReady;

  bool get hasRecommendations => recommendationSummary.hasRecommendations;

  int get recommendationCount => recommendationSummary.count;

  AtlasRecommendation? get primaryRecommendation =>
      recommendationSummary.primaryRecommendation;

  AtlasCollectionIntelligence copyWith({
    String? popId,
    DateTime? generatedAt,
    AtlasHeroSummary? heroSummary,
    AtlasTimelineIntelligenceReport? timelineReport,
    PopActivitySummary? activitySummary,
    List<PopIdentityBadgeData>? identityBadges,
    AtlasCollectibilitySummary? collectibilitySummary,
    AtlasRecommendationSummary? recommendationSummary,
  }) {
    return AtlasCollectionIntelligence(
      popId: popId ?? this.popId,
      generatedAt: generatedAt ?? this.generatedAt,
      heroSummary: heroSummary ?? this.heroSummary,
      timelineReport: timelineReport ?? this.timelineReport,
      activitySummary: activitySummary ?? this.activitySummary,
      identityBadges: identityBadges ?? this.identityBadges,
      collectibilitySummary:
          collectibilitySummary ?? this.collectibilitySummary,
      recommendationSummary:
          recommendationSummary ?? this.recommendationSummary,
    );
  }
}
