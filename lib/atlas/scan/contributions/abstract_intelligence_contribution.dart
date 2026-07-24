import 'contribution_category.dart';
import 'intelligence_contribution.dart';

// Reusable immutable base for intelligence produced by Atlas engines.
//
// Concrete contribution classes inherit the common identity, source,
// timestamp, confidence, and attribute behavior while defining only their
// domain-specific fields and category.
abstract base class AbstractIntelligenceContribution
    implements IntelligenceContribution {
  AbstractIntelligenceContribution({
    required String contributionId,
    required String sourceEngineId,
    required this.createdAt,
    double? confidence,
    Map<String, Object?> attributes =
    const <String, Object?>{},
  })  : contributionId =
  IntelligenceContributionValidation.requireIdentifier(
    contributionId,
    fieldName: 'contributionId',
  ),
        sourceEngineId =
        IntelligenceContributionValidation.requireIdentifier(
          sourceEngineId,
          fieldName: 'sourceEngineId',
        ),
        confidence =
        IntelligenceContributionValidation.normalizeConfidence(
          confidence,
        ),
        attributes =
        IntelligenceContributionValidation.immutableAttributes(
          attributes,
        );

  @override
  final String contributionId;

  @override
  final String sourceEngineId;

  @override
  final DateTime createdAt;

  @override
  final double? confidence;

  @override
  final Map<String, Object?> attributes;

  @override
  ContributionCategory get category;

  bool get hasConfidence {
    return confidence != null;
  }

  bool get hasAttributes {
    return attributes.isNotEmpty;
  }

  bool get hasNoAttributes {
    return attributes.isEmpty;
  }

  bool wasProducedBy(
      String engineId,
      ) {
    final String normalized = engineId.trim();

    return normalized.isNotEmpty &&
        sourceEngineId == normalized;
  }

  T? attribute<T>(
      String key,
      ) {
    final Object? value = attributes[key];

    if (value is T) {
      return value;
    }

    return null;
  }

  bool hasAttribute(
      String key,
      ) {
    final String normalized = key.trim();

    return normalized.isNotEmpty &&
        attributes.containsKey(normalized);
  }

  @override
  String toString() {
    return '$runtimeType('
        'contributionId: $contributionId, '
        'category: ${category.name}, '
        'sourceEngineId: $sourceEngineId, '
        'confidence: $confidence'
        ')';
  }
}