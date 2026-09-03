import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/atlas/scan/acquisition/atlas_guided_inspection_capture_plan.dart';
import 'package:funkovault2/atlas/scan/authenticity/models/atlas_authenticity_evidence.dart';
import 'package:funkovault2/atlas/scan/authenticity/models/atlas_visual_inspection.dart';
import 'package:funkovault2/atlas/scan/models/scan_image.dart';

void main() {
  test('guided inspection plan exposes the six Scanner 5B capture areas', () {
    expect(
      AtlasGuidedInspectionCapturePlan.steps,
      const <AtlasGuidedInspectionStep>[
        AtlasGuidedInspectionStep.frontBox,
        AtlasGuidedInspectionStep.stickerWindow,
        AtlasGuidedInspectionStep.bottomStamp,
        AtlasGuidedInspectionStep.packagingCopyright,
        AtlasGuidedInspectionStep.autograph,
        AtlasGuidedInspectionStep.coa,
      ],
    );

    expect(
      AtlasGuidedInspectionCapturePlan.steps
          .map((AtlasGuidedInspectionStep step) => step.imageType)
          .toSet(),
      <ScanImageType>{
        ScanImageType.frontBox,
        ScanImageType.sticker,
        ScanImageType.bottomBox,
        ScanImageType.backBox,
        ScanImageType.autograph,
        ScanImageType.certification,
      },
    );

    expect(
      AtlasGuidedInspectionCapturePlan.steps
          .map((AtlasGuidedInspectionStep step) => step.inspectionArea)
          .toSet(),
      AtlasInspectionArea.values.toSet(),
    );
  });

  test(
    'condition capture remains outside Scanner 5B authenticity workflow',
    () {
      expect(
        AtlasGuidedInspectionCapturePlan.steps.any(
          (AtlasGuidedInspectionStep step) =>
              step.imageType == ScanImageType.condition,
        ),
        isFalse,
      );
    },
  );

  test('OCR is limited to text-bearing guided capture steps', () {
    expect(AtlasGuidedInspectionStep.frontBox.supportsTextRecognition, isFalse);
    expect(
      AtlasGuidedInspectionStep.stickerWindow.supportsTextRecognition,
      isTrue,
    );
    expect(
      AtlasGuidedInspectionStep.bottomStamp.supportsTextRecognition,
      isTrue,
    );
    expect(
      AtlasGuidedInspectionStep.packagingCopyright.supportsTextRecognition,
      isTrue,
    );
    expect(
      AtlasGuidedInspectionStep.autograph.supportsTextRecognition,
      isFalse,
    );
    expect(AtlasGuidedInspectionStep.coa.supportsTextRecognition, isTrue);
  });

  test('image-only captures mark their inspection areas as inspected', () {
    final DateTime capturedAt = DateTime.utc(2026, 9, 3, 17);
    final AtlasVisualInspection inspection = AtlasVisualInspection(
      images: <ScanImage>[
        ScanImage(
          imageId: 'front',
          type: ScanImageType.frontBox,
          status: ScanImageStatus.captured,
          capturedAt: capturedAt,
          localPath: 'front.jpg',
        ),
        ScanImage(
          imageId: 'sticker',
          type: ScanImageType.sticker,
          status: ScanImageStatus.captured,
          capturedAt: capturedAt,
          localPath: 'sticker.jpg',
        ),
        ScanImage(
          imageId: 'bottom',
          type: ScanImageType.bottomBox,
          status: ScanImageStatus.captured,
          capturedAt: capturedAt,
          localPath: 'bottom.jpg',
        ),
        ScanImage(
          imageId: 'packaging',
          type: ScanImageType.backBox,
          status: ScanImageStatus.captured,
          capturedAt: capturedAt,
          localPath: 'back.jpg',
        ),
        ScanImage(
          imageId: 'autograph',
          type: ScanImageType.autograph,
          status: ScanImageStatus.captured,
          capturedAt: capturedAt,
          localPath: 'autograph.jpg',
        ),
        ScanImage(
          imageId: 'coa',
          type: ScanImageType.certification,
          status: ScanImageStatus.captured,
          capturedAt: capturedAt,
          localPath: 'coa.jpg',
        ),
      ],
    );

    expect(inspection.inspectedAreas, AtlasInspectionArea.values.toSet());
    expect(inspection.resolvedEvidenceConfidence, 0.85);
  });
}
