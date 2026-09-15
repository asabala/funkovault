import '../../../models/pop.dart';
import 'atlas_confidence_engine.dart';

class AtlasSmartRecommendation {
  const AtlasSmartRecommendation({
    required this.title,
    required this.message,
    required this.priority,
    required this.severity,
    required this.estimatedImpact,
  });

  final String title;
  final String message;
  final int priority;
  final String severity;
  final String estimatedImpact;
}

class AtlasRecommendationEngineV2 {
  const AtlasRecommendationEngineV2();

  List<AtlasSmartRecommendation> analyze({
    required List<Pop> pops,
    required int duplicateCount,
    required int missingValueCount,
  }) {
    final recommendations = <AtlasSmartRecommendation>[];

    const confidenceEngine = AtlasConfidenceEngine();
    final confidence = confidenceEngine.calculate(pops);

    if (duplicateCount > 0) {
      recommendations.add(
        AtlasSmartRecommendation(
          title: 'Review Duplicate Groups',
          message:
              'Atlas found $duplicateCount possible duplicate group${duplicateCount == 1 ? '' : 's'}.',
          priority: 100,
          severity: 'High',
          estimatedImpact: 'Improves Vault Health',
        ),
      );
    }

    if (missingValueCount > 0) {
      recommendations.add(
        AtlasSmartRecommendation(
          title: 'Complete Missing Values',
          message:
              '$missingValueCount Pop${missingValueCount == 1 ? '' : 's'} need estimated values.',
          priority: 90,
          severity: 'Medium',
          estimatedImpact: 'Improves Atlas accuracy',
        ),
      );
    }

    final missingImages = pops.where((pop) => pop.imageUrl.isEmpty).length;

    if (missingImages > 0) {
      recommendations.add(
        AtlasSmartRecommendation(
          title: 'Add Missing Images',
          message:
              '$missingImages Pop${missingImages == 1 ? '' : 's'} are missing images.',
          priority: 60,
          severity: 'Low',
          estimatedImpact: 'Improves collection browsing',
        ),
      );
    }

    final incompleteIdentity = pops.where((pop) {
      return pop.variant == 'Common' &&
          pop.retailExclusive == 'None' &&
          pop.eventSticker == 'None' &&
          pop.limitedEdition == 'None' &&
          pop.signature == 'Unsigned';
    }).length;

    if (incompleteIdentity > 0) {
      recommendations.add(
        AtlasSmartRecommendation(
          title: 'Review Collector Identity',
          message:
              '$incompleteIdentity Pop${incompleteIdentity == 1 ? '' : 's'} may need collector identity details.',
          priority: confidence.score < 75 ? 85 : 50,
          severity: confidence.score < 75 ? 'Medium' : 'Low',
          estimatedImpact: 'Improves Atlas Confidence',
        ),
      );
    }

    recommendations.sort((a, b) => b.priority.compareTo(a.priority));

    return recommendations;
  }
}
