import '../../models/scan_image.dart';
import 'atlas_authenticity_evidence.dart';
import 'atlas_inspection_reference.dart';

final class AtlasVisualInspection {
  AtlasVisualInspection({
    this.stickerText = '',
    this.productionStampText = '',
    this.copyrightText = '',
    this.signature = '',
    this.authenticationProvider = '',
    this.authenticityNumber = '',
    this.typographyConsistent,
    this.borderConsistent,
    this.stickerPrintClear,
    this.stickerCutEven,
    this.hasAutograph,
    this.hasCoa,
    this.notes = '',
    this.referenceCriteria,
    double? evidenceConfidence,
    List<AtlasVisualEvidenceObservation> observations =
        const <AtlasVisualEvidenceObservation>[],
    List<ScanImage> images = const <ScanImage>[],
  }) : evidenceConfidence = _normalizeOptionalConfidence(evidenceConfidence),
       observations = List<AtlasVisualEvidenceObservation>.unmodifiable(
         observations,
       ),
       images = List<ScanImage>.unmodifiable(images);

  final String stickerText;
  final String productionStampText;
  final String copyrightText;
  final String signature;
  final String authenticationProvider;
  final String authenticityNumber;
  final bool? typographyConsistent;
  final bool? borderConsistent;
  final bool? stickerPrintClear;
  final bool? stickerCutEven;
  final bool? hasAutograph;
  final bool? hasCoa;
  final String notes;
  final AtlasInspectionReferenceCriteria? referenceCriteria;
  final double? evidenceConfidence;
  final List<AtlasVisualEvidenceObservation> observations;
  final List<ScanImage> images;

  bool get hasStickerEvidence => stickerText.trim().isNotEmpty;
  bool get hasProductionEvidence => productionStampText.trim().isNotEmpty;
  bool get hasCopyrightEvidence => copyrightText.trim().isNotEmpty;
  bool get hasAuthenticationEvidence =>
      authenticationProvider.trim().isNotEmpty ||
      authenticityNumber.trim().isNotEmpty ||
      hasCoa != null;

  bool get hasStructuredObservations => observations.isNotEmpty;

  double get resolvedEvidenceConfidence {
    if (evidenceConfidence != null) {
      return evidenceConfidence!;
    }
    if (observations.isNotEmpty) {
      final double total = observations.fold<double>(
        0.0,
        (double sum, AtlasVisualEvidenceObservation observation) =>
            sum + observation.confidence,
      );
      return total / observations.length;
    }
    if (images.isNotEmpty) {
      return 0.85;
    }
    if (hasAnyLegacyEvidence) {
      return 0.65;
    }
    return 0.0;
  }

  bool get hasAnyLegacyEvidence {
    return hasStickerEvidence ||
        hasProductionEvidence ||
        hasCopyrightEvidence ||
        signature.trim().isNotEmpty ||
        authenticationProvider.trim().isNotEmpty ||
        authenticityNumber.trim().isNotEmpty ||
        typographyConsistent != null ||
        borderConsistent != null ||
        stickerPrintClear != null ||
        stickerCutEven != null ||
        hasAutograph != null ||
        hasCoa != null;
  }

  Set<AtlasInspectionArea> get inspectedAreas {
    final Set<AtlasInspectionArea> result = observations
        .map((AtlasVisualEvidenceObservation value) => value.area)
        .toSet();

    if (hasStickerEvidence ||
        stickerPrintClear != null ||
        stickerCutEven != null) {
      result.add(AtlasInspectionArea.windowSticker);
    }
    if (hasProductionEvidence) {
      result.add(AtlasInspectionArea.bottomStamp);
    }
    if (hasCopyrightEvidence ||
        typographyConsistent != null ||
        borderConsistent != null) {
      result.add(AtlasInspectionArea.packagingCopyright);
    }
    if (hasAutograph != null || signature.trim().isNotEmpty) {
      result.add(AtlasInspectionArea.autograph);
    }
    if (hasCoa != null || hasAuthenticationEvidence) {
      result.add(AtlasInspectionArea.coa);
    }

    return Set<AtlasInspectionArea>.unmodifiable(result);
  }

  static double? _normalizeOptionalConfidence(double? value) {
    if (value == null) {
      return null;
    }
    if (!value.isFinite || value < 0.0 || value > 1.0) {
      throw ArgumentError.value(
        value,
        'evidenceConfidence',
        'Evidence confidence must be between 0.0 and 1.0.',
      );
    }
    return value;
  }
}
