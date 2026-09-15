import '../models/scan_code.dart';
import 'abstract_recognition_contribution.dart';

// Structured recognition evidence produced from one detected barcode or
// QR code.
//
// BarcodeContribution references the original immutable ScanCode rather than
// duplicating its captured value, format, source, timestamp, validation, and
// confidence data.
final class BarcodeContribution extends AbstractRecognitionContribution {
  BarcodeContribution({
    required super.contributionId,
    required super.sourceEngineId,
    required super.createdAt,
    required this.code,
    required this.isPrimaryCandidate,
    required super.passedValidation,
    super.validationMessage,
    super.confidence,
    super.attributes,
  });

  // Original barcode or QR evidence captured during the scan.
  final ScanCode code;

  // Indicates that this is the preferred barcode evidence produced by the
  // barcode engine. Final product identity remains the responsibility of
  // downstream identity and resolution engines.
  final bool isPrimaryCandidate;

  bool get isProductBarcode {
    return code.isProductBarcode;
  }

  bool get isQrCode {
    return code.isQrCode;
  }

  bool get isValid {
    return passedValidation && code.isValid;
  }

  bool get isUsableForIdentity {
    return isValid &&
        isProductBarcode &&
        code.normalizedValue.trim().isNotEmpty;
  }

  @override
  String toString() {
    return 'BarcodeContribution('
        'contributionId: $contributionId, '
        'format: ${code.format.name}, '
        'isPrimaryCandidate: $isPrimaryCandidate, '
        'passedValidation: $passedValidation, '
        'confidence: $confidence'
        ')';
  }
}
