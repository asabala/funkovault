import '../../models/pop.dart';

class AtlasConfidenceResult {
  const AtlasConfidenceResult({
    required this.score,
    required this.message,
  });

  final double score;
  final String message;
}

class AtlasConfidenceEngine {
  const AtlasConfidenceEngine();

  AtlasConfidenceResult calculate(
      List<Pop> pops,
      ) {
    if (pops.isEmpty) {
      return const AtlasConfidenceResult(
        score: 100,
        message: 'Atlas is ready to learn from your collection.',
      );
    }

    int completedFields = 0;
    int possibleFields = 0;

    for (final pop in pops) {
      possibleFields += 7;

      if (pop.value > 0) completedFields++;
      if (pop.pricePaid > 0) completedFields++;
      if (pop.imageUrl.isNotEmpty) completedFields++;
      if (pop.variant != 'Common') completedFields++;
      if (pop.retailExclusive != 'None') completedFields++;
      if (pop.eventSticker != 'None') completedFields++;
      if (pop.signature != 'Unsigned') completedFields++;
    }

    final score =
        (completedFields / possibleFields) * 100;

    String message;

    if (score >= 90) {
      message =
      'High confidence. Atlas can make reliable recommendations.';
    } else if (score >= 75) {
      message =
      'Good confidence. A little more information will improve Atlas.';
    } else if (score >= 50) {
      message =
      'Medium confidence. Completing collector details will improve analysis.';
    } else {
      message =
      'Low confidence. Atlas recommends completing your collection data.';
    }

    return AtlasConfidenceResult(
      score: score,
      message: message,
    );
  }
}