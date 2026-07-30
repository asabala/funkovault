enum AtlasRecommendationPriority {
  low,
  medium,
  high,
  critical,
}

extension AtlasRecommendationPriorityX
on AtlasRecommendationPriority {
  String get label {
    switch (this) {
      case AtlasRecommendationPriority.low:
        return 'Low';
      case AtlasRecommendationPriority.medium:
        return 'Medium';
      case AtlasRecommendationPriority.high:
        return 'High';
      case AtlasRecommendationPriority.critical:
        return 'Critical';
    }
  }

  int get weight {
    switch (this) {
      case AtlasRecommendationPriority.low:
        return 1;
      case AtlasRecommendationPriority.medium:
        return 2;
      case AtlasRecommendationPriority.high:
        return 3;
      case AtlasRecommendationPriority.critical:
        return 4;
    }
  }
}