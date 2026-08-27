import 'dart:ui';

import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/scan_code.dart';
import '../tracking/atlas_scan_observation.dart';

/// Adapts mobile_scanner capture data into Atlas acquisition observations.
///
/// This is intentionally the plugin boundary. The tracking domain remains
/// independent from Flutter camera/plugin geometry.
abstract final class AtlasMobileScannerObservationAdapter {
  static List<AtlasScanObservation> fromCapture(
    BarcodeCapture capture, {
    required DateTime capturedAt,
  }) {
    final List<AtlasScanObservation> observations = <AtlasScanObservation>[];

    final Size captureSize = capture.size;
    final bool hasUsableCaptureSize =
        captureSize.width.isFinite &&
        captureSize.height.isFinite &&
        captureSize.width > 0.0 &&
        captureSize.height > 0.0;

    int observationSequence = 0;

    for (final Barcode barcode in capture.barcodes) {
      final String rawValue = barcode.rawValue?.trim() ?? '';

      if (rawValue.isEmpty) {
        continue;
      }

      final ScanCodeFormat format = _mapBarcodeFormat(barcode.format);

      final ScanCode scanCode = ScanCode(
        rawValue: rawValue,
        normalizedValue: _normalizeCodeValue(rawValue),
        format: format,
        source: ScanCodeSource.camera,
        capturedAt: capturedAt,
        isValid: format != ScanCodeFormat.unknown,
        confidence: 1.0,
      );

      final List<AtlasNormalizedPoint> normalizedCorners = hasUsableCaptureSize
          ? _normalizeCorners(barcode.corners, captureSize)
          : const <AtlasNormalizedPoint>[];

      observations.add(
        AtlasScanObservation(
          observationId: _createObservationId(
            capturedAt: capturedAt,
            sequence: observationSequence,
            code: scanCode,
          ),
          capturedAt: capturedAt,
          code: scanCode,
          cornerPoints: normalizedCorners,
          confidence: scanCode.confidence,
        ),
      );

      observationSequence++;
    }

    return List<AtlasScanObservation>.unmodifiable(observations);
  }

  static List<AtlasNormalizedPoint> _normalizeCorners(
    List<Offset> corners,
    Size captureSize,
  ) {
    if (corners.isEmpty) {
      return const <AtlasNormalizedPoint>[];
    }

    final List<AtlasNormalizedPoint> normalized = <AtlasNormalizedPoint>[];

    for (final Offset corner in corners) {
      if (!corner.dx.isFinite || !corner.dy.isFinite) {
        continue;
      }

      normalized.add(
        AtlasNormalizedPoint(
          x: _normalizeCoordinate(corner.dx, captureSize.width),
          y: _normalizeCoordinate(corner.dy, captureSize.height),
        ),
      );
    }

    return List<AtlasNormalizedPoint>.unmodifiable(normalized);
  }

  static double _normalizeCoordinate(double value, double extent) {
    if (!value.isFinite || !extent.isFinite || extent <= 0.0) {
      return 0.0;
    }

    return (value / extent).clamp(0.0, 1.0).toDouble();
  }

  static ScanCodeFormat _mapBarcodeFormat(BarcodeFormat format) {
    return switch (format) {
      BarcodeFormat.upcA => ScanCodeFormat.upcA,
      BarcodeFormat.upcE => ScanCodeFormat.upcE,
      BarcodeFormat.ean8 => ScanCodeFormat.ean8,
      BarcodeFormat.ean13 => ScanCodeFormat.ean13,
      BarcodeFormat.qrCode => ScanCodeFormat.qrCode,
      _ => ScanCodeFormat.unknown,
    };
  }

  static String _normalizeCodeValue(String rawValue) {
    return rawValue.trim();
  }

  static String _createObservationId({
    required DateTime capturedAt,
    required int sequence,
    required ScanCode code,
  }) {
    final int codeHash = code.normalizedValue.hashCode.abs();

    return 'obs_'
        '${capturedAt.microsecondsSinceEpoch}_'
        '${sequence}_'
        '$codeHash';
  }
}
