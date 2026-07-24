import '../contributions/barcode_contribution.dart';
import '../contributions/ocr_contribution.dart';

// Immutable recognition evidence extracted from one scan.
//
// RecognitionEvidence provides strongly typed access to recognition
// contributions without requiring downstream engines to repeatedly filter
// the ContributionCollection.
final class RecognitionEvidence {
  const RecognitionEvidence({
    this.barcodes = const <BarcodeContribution>[],
    this.ocr = const <OCRContribution>[],
  });

  final List<BarcodeContribution> barcodes;

  final List<OCRContribution> ocr;

  bool get hasBarcodes => barcodes.isNotEmpty;

  bool get hasOcr => ocr.isNotEmpty;

  bool get hasRecognition {
    return hasBarcodes || hasOcr;
  }
  bool get hasIdentityEvidence {
    return identityText.isNotEmpty;
  }

  bool get hasVariantEvidence {
    return variantText.isNotEmpty;
  }

  int get recognitionCount {
    return barcodes.length + ocr.length;
  }

  Iterable<OCRContribution> get identityText {
    return ocr.where(
          (OCRContribution value) =>
      value.isIdentityEvidence,
    );
  }

  Iterable<OCRContribution> get variantText {
    return ocr.where(
          (OCRContribution value) =>
      value.isVariantEvidence,
    );
  }

  BarcodeContribution? get primaryBarcode {
    for (final BarcodeContribution barcode
    in barcodes) {
      if (barcode.isPrimaryCandidate) {
        return barcode;
      }
    }

    return null;
  }

  @override
  String toString() {
    return 'RecognitionEvidence('
        'barcodes: ${barcodes.length}, '
        'ocr: ${ocr.length}'
        ')';
  }
}