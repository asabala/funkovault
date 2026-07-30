import '../../../models/activity.dart';
import '../../../models/pop.dart';
import '../../collectibility/engine/atlas_collectibility_engine.dart';
import '../../engines/collection/pop_activity_summary_engine.dart';
import '../../engines/timeline/timeline_intelligence_service.dart';
import '../../hero/engine/atlas_hero_engine.dart';
import '../../identity/pop/pop_identity_engine.dart';
import '../../recommendations/engine/atlas_recommendation_engine.dart';
import '../models/atlas_collection_intelligence.dart';

/// Coordinates Atlas intelligence engines for a single collectible.
///
/// This class contains orchestration only. Individual engines remain
/// responsible for their own business rules.
class AtlasCollectionEngine {
  const AtlasCollectionEngine({
    this.heroEngine = const AtlasHeroEngine(),
    this.timelineService =
    const TimelineIntelligenceService(),
    this.activitySummaryEngine =
    const PopActivitySummaryEngine(),
    this.identityEngine = const PopIdentityEngine(),
    this.collectibilityEngine =
    const AtlasCollectibilityEngine(),
    this.recommendationEngine =
    const AtlasRecommendationEngine(),
  });

  final AtlasHeroEngine heroEngine;
  final TimelineIntelligenceService timelineService;
  final PopActivitySummaryEngine activitySummaryEngine;
  final PopIdentityEngine identityEngine;
  final AtlasCollectibilityEngine collectibilityEngine;
  final AtlasRecommendationEngine recommendationEngine;

  AtlasCollectionIntelligence analyze({
    required Pop pop,
    required List<Activity> activities,
  }) {
    final heroSummary = heroEngine.build(pop);

    final timelineReport =
    timelineService.buildReport(pop);

    final activitySummary =
    activitySummaryEngine.build(
      popId: pop.id,
      popName: pop.name,
      popNumber: pop.number,
      activities: activities,
      timeline: pop.timeline,
    );

    final identityBadges =
    identityEngine.buildBadges(pop);

    final collectibilitySummary =
    collectibilityEngine.build(
      pop: pop,
      heroSummary: heroSummary,
      identityBadges: identityBadges,
    );

    final recommendationSummary =
    recommendationEngine.build(
      pop: pop,
      collectibilitySummary: collectibilitySummary,
    );

    return AtlasCollectionIntelligence(
      popId: pop.id,
      generatedAt: DateTime.now(),
      heroSummary: heroSummary,
      timelineReport: timelineReport,
      activitySummary: activitySummary,
      identityBadges: identityBadges,
      collectibilitySummary: collectibilitySummary,
      recommendationSummary: recommendationSummary,
    );
  }
}