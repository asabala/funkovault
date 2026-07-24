import '../contributions/barcode_contribution.dart';
import '../contributions/ocr_contribution.dart';
import '../contributions/contribution_collection.dart';
import '../models/scan_session.dart';
import 'recognition_evidence.dart';

// Builds RecognitionEvidence from a ScanSession or ContributionCollection.
//
// This isolates contribution filtering from downstream intelligence engines.
// Identity and later engines consume strongly typed evidence instead of
// querying the contribution collection directly.
abstract final class RecognitionEvidenceBuilder {
  static RecognitionEvidence fromSession(
      ScanSession session,
      ) {
    return fromContributions(
      session.contributions,
    );
  }

  static RecognitionEvidence fromContributions(
      ContributionCollection contributions,
      ) {
    return RecognitionEvidence(
      barcodes:
      contributions
          .ofType<BarcodeContribution>()
          .toList(growable: false),
      ocr:
      contributions
          .ofType<OCRContribution>()
          .toList(growable: false),
    );
  }
}