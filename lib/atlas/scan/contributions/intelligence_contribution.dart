import 'contribution_category.dart';

// Shared contract for immutable intelligence produced by an Atlas engine.
//
// Concrete contribution models own their domain-specific fields while this
// contract provides the common information needed for discovery, diagnostics,
// conflict handling, and downstream intelligence processing.
abstract interface class IntelligenceContribution {
  String get contributionId;

  ContributionCategory get category;

  String get sourceEngineId;

  DateTime get createdAt;

  double? get confidence;

  Map<String, Object?> get attributes;
}

// Shared validation helpers for concrete contribution implementations.
abstract final class IntelligenceContributionValidation {
  static String requireIdentifier(String value, {required String fieldName}) {
    final String normalized = value.trim();

    if (normalized.isEmpty) {
      throw ArgumentError.value(
        value,
        fieldName,
        '$fieldName cannot be empty.',
      );
    }

    return normalized;
  }

  static double? normalizeConfidence(double? value) {
    if (value == null) {
      return null;
    }

    if (value.isNaN || value.isInfinite || value < 0 || value > 1) {
      throw ArgumentError.value(
        value,
        'confidence',
        'Confidence must be between 0 and 1.',
      );
    }

    return value;
  }

  static Map<String, Object?> immutableAttributes(Map<String, Object?> values) {
    return Map<String, Object?>.unmodifiable(values);
  }
}
