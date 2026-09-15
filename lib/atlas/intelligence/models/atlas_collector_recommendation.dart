import 'package:flutter/foundation.dart';

enum AtlasCollectorRecommendationType {
  alreadyOwned,
  reviewVariant,
  marketValueUnavailable,
  newToVault,
}

enum AtlasCollectorRecommendationCategory {
  ownership,
  variant,
  market,
  wishlist,
  identity,
  collection,
}

enum AtlasCollectorRecommendationSeverity {
  informational,
  positive,
  caution,
  warning,
  critical,
}

@immutable
class AtlasCollectorRecommendation {
  const AtlasCollectorRecommendation({
    required this.type,
    required this.category,
    required this.severity,
    required this.title,
    required this.message,
    required this.priority,
    this.details = const <String>[],
  });

  final AtlasCollectorRecommendationType type;
  final AtlasCollectorRecommendationCategory category;
  final AtlasCollectorRecommendationSeverity severity;

  final String title;
  final String message;

  /// Lower numbers represent more important recommendations.
  final int priority;

  final List<String> details;

  bool get hasDetails {
    return details.isNotEmpty;
  }

  bool get isImportant {
    return severity == AtlasCollectorRecommendationSeverity.warning ||
        severity == AtlasCollectorRecommendationSeverity.critical;
  }

  String get categoryLabel {
    switch (category) {
      case AtlasCollectorRecommendationCategory.ownership:
        return 'Ownership';

      case AtlasCollectorRecommendationCategory.variant:
        return 'Variant';

      case AtlasCollectorRecommendationCategory.market:
        return 'Market';

      case AtlasCollectorRecommendationCategory.wishlist:
        return 'Wishlist';

      case AtlasCollectorRecommendationCategory.identity:
        return 'Identity';

      case AtlasCollectorRecommendationCategory.collection:
        return 'Collection';
    }
  }

  AtlasCollectorRecommendation copyWith({
    AtlasCollectorRecommendationType? type,
    AtlasCollectorRecommendationCategory? category,
    AtlasCollectorRecommendationSeverity? severity,
    String? title,
    String? message,
    int? priority,
    List<String>? details,
  }) {
    return AtlasCollectorRecommendation(
      type: type ?? this.type,
      category: category ?? this.category,
      severity: severity ?? this.severity,
      title: title ?? this.title,
      message: message ?? this.message,
      priority: priority ?? this.priority,
      details: details ?? this.details,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AtlasCollectorRecommendation &&
            runtimeType == other.runtimeType &&
            type == other.type &&
            category == other.category &&
            severity == other.severity &&
            title == other.title &&
            message == other.message &&
            priority == other.priority &&
            listEquals(details, other.details);
  }

  @override
  int get hashCode {
    return Object.hash(
      type,
      category,
      severity,
      title,
      message,
      priority,
      Object.hashAll(details),
    );
  }

  @override
  String toString() {
    return 'AtlasCollectorRecommendation('
        'type: ${type.name}, '
        'category: ${category.name}, '
        'severity: ${severity.name}, '
        'priority: $priority, '
        'title: $title'
        ')';
  }
}
