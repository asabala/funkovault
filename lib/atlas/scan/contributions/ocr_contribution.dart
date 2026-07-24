import '../models/ocr_recognition_type.dart';
import '../models/recognition_region.dart';
import 'abstract_recognition_contribution.dart';

// Structured OCR intelligence produced by Atlas.
//
// OCRContribution represents one semantic piece of text recognized from a
// collectible. The contribution intentionally stores normalized collector
// knowledge rather than raw OCR engine output.
final class OCRContribution
    extends AbstractRecognitionContribution {
  OCRContribution({
    required super.contributionId,
    required super.sourceEngineId,
    required super.createdAt,
    required this.text,
    required this.normalizedText,
    required this.region,
    required this.recognitionType,
    super.confidence,
    super.attributes,
    super.passedValidation,
    super.validationMessage,
  });

  // Original text recognized by OCR.
  final String text;

  // Normalized text used by downstream identity engines.
  final String normalizedText;

  // Semantic location where the text was recognized.
  final RecognitionRegion region;

  // Atlas interpretation of what the text represents.
  final OCRRecognitionType recognitionType;

  bool get hasText {
    return text.trim().isNotEmpty;
  }

  bool get hasNormalizedText {
    return normalizedText.trim().isNotEmpty;
  }

  bool get isIdentityEvidence {
    return recognitionType.isIdentity;
  }

  bool get isVariantEvidence {
    return recognitionType.isVariant;
  }

  bool get hasUsefulEvidence {
    return hasNormalizedText &&
        (isIdentityEvidence || isVariantEvidence);
  }

  bool get isStickerRecognition {
    return region == RecognitionRegion.sticker;
  }

  bool get isBarcodeRecognition {
    return region == RecognitionRegion.barcode;
  }

  bool get isQrRecognition {
    return region == RecognitionRegion.qrCode;
  }

  @override
  String toString() {
    return 'OCRContribution('
        'text: $text, '
        'normalizedText: $normalizedText, '
        'type: ${recognitionType.name}, '
        'region: ${region.name}, '
        'confidence: $confidence'
        ')';
  }
}