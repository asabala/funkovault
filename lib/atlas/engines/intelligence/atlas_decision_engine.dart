import '../intelligence/atlas_recommendation_engine_v2.dart';

class AtlasDecision {
  const AtlasDecision({
    required this.title,
    required this.message,
    required this.severity,
    required this.why,
  });

  final String title;
  final String message;
  final String severity;
  final String why;
}

class AtlasDecisionEngine {
  const AtlasDecisionEngine();

  AtlasDecision decide({
    required List<AtlasSmartRecommendation> recommendations,
  }) {
    if (recommendations.isEmpty) {
      return const AtlasDecision(
        title: 'No Mission Needed',
        message:
        'Atlas found no urgent action for today. Your Vault is in good shape.',
        severity: 'Low',
        why:
        'No high-priority recommendations were detected.',
      );
    }

    final topRecommendation = recommendations.first;

    return AtlasDecision(
      title: topRecommendation.title,
      message: topRecommendation.message,
      severity: topRecommendation.severity,
      why:
      'Atlas selected this because it has the highest priority score and the greatest expected impact: ${topRecommendation.estimatedImpact}.',
    );
  }
}