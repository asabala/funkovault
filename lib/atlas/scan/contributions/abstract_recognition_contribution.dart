import 'abstract_intelligence_contribution.dart';
import 'contribution_category.dart';

// Base class for recognition-based intelligence contributions.
//
// Recognition contributions represent evidence extracted from a collector
// item before identity or product resolution occurs. Examples include
// barcode recognition, OCR, vision analysis, logo detection, and sticker
// detection.
abstract base class AbstractRecognitionContribution
    extends AbstractIntelligenceContribution {
  AbstractRecognitionContribution({
    required super.contributionId,
    required super.sourceEngineId,
    required super.createdAt,
    super.confidence,
    super.attributes,
    this.passedValidation = true,
    String? validationMessage,
  }) : validationMessage =
  _normalizeValidationMessage(validationMessage);

  @override
  ContributionCategory get category {
    return ContributionCategory.evidence;
  }

  final bool passedValidation;

  final String? validationMessage;

  bool get failedValidation {
    return !passedValidation;
  }

  bool get hasValidationMessage {
    return validationMessage != null;
  }

  bool get isTrusted {
    final double? value = confidence;

    return passedValidation &&
        value != null &&
        value >= 0.75;
  }

  bool get isLowConfidence {
    final double? value = confidence;

    return value != null && value < 0.50;
  }

  bool get hasUnknownConfidence {
    return confidence == null;
  }

  bool get shouldReview {
    return failedValidation ||
        hasUnknownConfidence ||
        isLowConfidence;
  }

  static String? _normalizeValidationMessage(
      String? value,
      ) {
    final String? normalized = value?.trim();

    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    return normalized;
  }

  @override
  String toString() {
    return '$runtimeType('
        'confidence: $confidence, '
        'passedValidation: $passedValidation'
        ')';
  }
}