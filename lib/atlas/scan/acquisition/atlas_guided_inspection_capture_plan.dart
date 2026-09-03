import '../authenticity/models/atlas_authenticity_evidence.dart';
import '../models/scan_image.dart';

enum AtlasGuidedInspectionStep {
  frontBox,
  stickerWindow,
  bottomStamp,
  packagingCopyright,
  autograph,
  coa,
}

extension AtlasGuidedInspectionStepX on AtlasGuidedInspectionStep {
  String get title => switch (this) {
    AtlasGuidedInspectionStep.frontBox => '📦 Front of Box',
    AtlasGuidedInspectionStep.stickerWindow => '🏷️ Sticker / Window',
    AtlasGuidedInspectionStep.bottomStamp => '🔢 Bottom Production Stamp',
    AtlasGuidedInspectionStep.packagingCopyright => '📋 Packaging / Copyright',
    AtlasGuidedInspectionStep.autograph => '✍️ Autograph',
    AtlasGuidedInspectionStep.coa => '📜 COA',
  };

  String get guidance => switch (this) {
    AtlasGuidedInspectionStep.frontBox =>
      'Capture the full front panel with the figure, box number, and window visible.',
    AtlasGuidedInspectionStep.stickerWindow =>
      'Capture the sticker and nearby window area clearly enough to compare placement and print.',
    AtlasGuidedInspectionStep.bottomStamp =>
      'Capture the bottom-box production code straight on with the entire stamp visible.',
    AtlasGuidedInspectionStep.packagingCopyright =>
      'Capture the packaging panel that shows copyright, release, and manufacturing text.',
    AtlasGuidedInspectionStep.autograph =>
      'Capture the signature and surrounding item area without cropping away context.',
    AtlasGuidedInspectionStep.coa =>
      'Capture the COA, certification label, QR code, or certificate number if present.',
  };

  ScanImageType get imageType => switch (this) {
    AtlasGuidedInspectionStep.frontBox => ScanImageType.frontBox,
    AtlasGuidedInspectionStep.stickerWindow => ScanImageType.sticker,
    AtlasGuidedInspectionStep.bottomStamp => ScanImageType.bottomBox,
    AtlasGuidedInspectionStep.packagingCopyright => ScanImageType.backBox,
    AtlasGuidedInspectionStep.autograph => ScanImageType.autograph,
    AtlasGuidedInspectionStep.coa => ScanImageType.certification,
  };

  AtlasInspectionArea get inspectionArea => switch (this) {
    AtlasGuidedInspectionStep.frontBox => AtlasInspectionArea.frontBox,
    AtlasGuidedInspectionStep.stickerWindow =>
      AtlasInspectionArea.windowSticker,
    AtlasGuidedInspectionStep.bottomStamp => AtlasInspectionArea.bottomStamp,
    AtlasGuidedInspectionStep.packagingCopyright =>
      AtlasInspectionArea.packagingCopyright,
    AtlasGuidedInspectionStep.autograph => AtlasInspectionArea.autograph,
    AtlasGuidedInspectionStep.coa => AtlasInspectionArea.coa,
  };

  bool get supportsTextRecognition => switch (this) {
    AtlasGuidedInspectionStep.stickerWindow ||
    AtlasGuidedInspectionStep.bottomStamp ||
    AtlasGuidedInspectionStep.packagingCopyright ||
    AtlasGuidedInspectionStep.coa => true,
    _ => false,
  };
}

abstract final class AtlasGuidedInspectionCapturePlan {
  static const List<AtlasGuidedInspectionStep> steps =
      <AtlasGuidedInspectionStep>[
        AtlasGuidedInspectionStep.frontBox,
        AtlasGuidedInspectionStep.stickerWindow,
        AtlasGuidedInspectionStep.bottomStamp,
        AtlasGuidedInspectionStep.packagingCopyright,
        AtlasGuidedInspectionStep.autograph,
        AtlasGuidedInspectionStep.coa,
      ];
}
