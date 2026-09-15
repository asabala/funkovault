class AtlasRecommendation {
  const AtlasRecommendation({
    required this.title,
    required this.message,
    required this.priority,
  });

  final String title;
  final String message;
  final int priority;
}

class AtlasRecommendationEngine {
  const AtlasRecommendationEngine();

  AtlasRecommendation? buildCollectorIdentityRecommendation({
    required String variant,
    required String retailExclusive,
    required String eventSticker,
    required String limitedEdition,
    required String signature,
    required double value,
    required double pricePaid,
  }) {
    final recommendations = <AtlasRecommendation>[];

    if (variant != 'Common' && value <= 0) {
      recommendations.add(
        const AtlasRecommendation(
          title: 'Verify Estimated Value',
          message:
              'This variant may have a different value than the Common version. Add an estimated value when available.',
          priority: 90,
        ),
      );
    }

    if (limitedEdition != 'None' && pricePaid <= 0) {
      recommendations.add(
        const AtlasRecommendation(
          title: 'Record Purchase Details',
          message:
              'Limited Edition Pops are easier to track when purchase history is recorded.',
          priority: 85,
        ),
      );
    }

    if (signature != 'Unsigned') {
      recommendations.add(
        const AtlasRecommendation(
          title: 'Save Authentication Info Later',
          message:
              'Signed collectibles may need authentication details, certificate numbers, or proof photos in a future update.',
          priority: 80,
        ),
      );
    }

    if (eventSticker != 'None') {
      recommendations.add(
        const AtlasRecommendation(
          title: 'Confirm Sticker Type',
          message:
              'Event and shared stickers can affect identity and value. Confirm the sticker before saving.',
          priority: 75,
        ),
      );
    }

    if (retailExclusive != 'None') {
      recommendations.add(
        const AtlasRecommendation(
          title: 'Exclusive Detected',
          message:
              'Retail exclusives are tracked separately so Atlas can prevent false duplicates.',
          priority: 70,
        ),
      );
    }

    if (recommendations.isEmpty) {
      return null;
    }

    recommendations.sort((a, b) => b.priority.compareTo(a.priority));

    return recommendations.first;
  }
}
