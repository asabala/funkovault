import 'atlas_recommendation.dart';
import 'atlas_recommendation_priority.dart';
import 'atlas_recommendation_type.dart';

/// Immutable set of next-step recommendations for one collectible.
class AtlasRecommendationSummary {
  const AtlasRecommendationSummary({
    required this.recommendations,
  });

  final List<AtlasRecommendation> recommendations;

  bool get hasRecommendations => recommendations.isNotEmpty;

  int get count => recommendations.length;

  List<AtlasRecommendation> get highPriorityRecommendations =>
      recommendations
          .where((recommendation) => recommendation.isHighPriority)
          .toList(growable: false);

  AtlasRecommendation? get primaryRecommendation {
    if (recommendations.isEmpty) {
      return null;
    }

    return recommendations.first;
  }

  bool containsType(AtlasRecommendationType type) {
    return recommendations.any(
          (recommendation) => recommendation.type == type,
    );
  }

  int countByPriority(AtlasRecommendationPriority priority) {
    return recommendations
        .where(
          (recommendation) =>
      recommendation.priority == priority,
    )
        .length;
  }

  AtlasRecommendationSummary copyWith({
    List<AtlasRecommendation>? recommendations,
  }) {
    return AtlasRecommendationSummary(
      recommendations:
      recommendations ?? this.recommendations,
    );
  }
}