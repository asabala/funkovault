import 'package:image_picker/image_picker.dart';

import '../models/scan_image.dart';

enum AtlasInspectionImageSource { camera, gallery }

abstract interface class AtlasInspectionImageCapture {
  Future<ScanImage?> capture({
    required AtlasInspectionImageSource source,
    required ScanImageType type,
  });
}

final class AtlasInspectionImageCaptureService
    implements AtlasInspectionImageCapture {
  AtlasInspectionImageCaptureService({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<ScanImage?> capture({
    required AtlasInspectionImageSource source,
    required ScanImageType type,
  }) async {
    final file = await _picker.pickImage(
      source: source == AtlasInspectionImageSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      imageQuality: 92,
    );
    if (file == null) return null;
    final capturedAt = DateTime.now().toUtc();
    return ScanImage(
      imageId: 'inspection_${capturedAt.microsecondsSinceEpoch}_${type.name}',
      type: type,
      status: ScanImageStatus.captured,
      capturedAt: capturedAt,
      localPath: file.path,
      mimeType: file.mimeType,
      byteSize: await file.length(),
    );
  }
}
