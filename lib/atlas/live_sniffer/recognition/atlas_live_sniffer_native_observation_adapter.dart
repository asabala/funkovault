import '../../scan/models/scan_code.dart';
import '../../scan/tracking/atlas_scan_observation.dart';
import '../models/atlas_live_sniffer_native_frame.dart';

abstract final class AtlasLiveSnifferNativeObservationAdapter {
  static List<AtlasScanObservation> fromFrame(
    AtlasLiveSnifferNativeFrame frame,
  ) {
    final List<AtlasScanObservation> observations = <AtlasScanObservation>[];

    for (int index = 0; index < frame.barcodes.length; index++) {
      final AtlasLiveSnifferNativeBarcode barcode = frame.barcodes[index];
      final ScanCodeFormat format = _mapFormat(barcode.format);
      final ScanCode code = ScanCode(
        rawValue: barcode.rawValue,
        normalizedValue: barcode.rawValue.trim(),
        format: format,
        source: ScanCodeSource.camera,
        capturedAt: frame.capturedAt,
        isValid: format != ScanCodeFormat.unknown,
        confidence: 1.0,
      );

      observations.add(
        AtlasScanObservation(
          observationId:
              'live_${frame.capturedAt.microsecondsSinceEpoch}_${index}_${barcode.rawValue.hashCode.abs()}',
          capturedAt: frame.capturedAt,
          code: code,
          confidence: 1.0,
          cornerPoints: <AtlasNormalizedPoint>[
            AtlasNormalizedPoint(x: barcode.left, y: barcode.top),
            AtlasNormalizedPoint(x: barcode.right, y: barcode.top),
            AtlasNormalizedPoint(x: barcode.right, y: barcode.bottom),
            AtlasNormalizedPoint(x: barcode.left, y: barcode.bottom),
          ],
        ),
      );
    }

    return List<AtlasScanObservation>.unmodifiable(observations);
  }

  static ScanCodeFormat _mapFormat(String value) {
    return switch (value.trim().toUpperCase()) {
      'UPC_A' => ScanCodeFormat.upcA,
      'UPC_E' => ScanCodeFormat.upcE,
      'EAN_8' => ScanCodeFormat.ean8,
      'EAN_13' => ScanCodeFormat.ean13,
      'QR_CODE' => ScanCodeFormat.qrCode,
      _ => ScanCodeFormat.unknown,
    };
  }
}
