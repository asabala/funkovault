import 'dart:math' as math;

import '../../scan/models/scan_code.dart';

class AtlasNormalizedPoint {
  AtlasNormalizedPoint({required this.x, required this.y}) {
    _validateCoordinate(x, 'x');
    _validateCoordinate(y, 'y');
  }

  final double x;
  final double y;

  double distanceTo(AtlasNormalizedPoint other) {
    final double dx = x - other.x;
    final double dy = y - other.y;
    return math.sqrt((dx * dx) + (dy * dy));
  }

  static void _validateCoordinate(double value, String fieldName) {
    if (!value.isFinite || value < 0.0 || value > 1.0) {
      throw ArgumentError.value(
        value,
        fieldName,
        '$fieldName must be between 0.0 and 1.0.',
      );
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AtlasNormalizedPoint &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => Object.hash(x, y);
}

class AtlasNormalizedBounds {
  AtlasNormalizedBounds({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  }) {
    AtlasNormalizedPoint._validateCoordinate(left, 'left');
    AtlasNormalizedPoint._validateCoordinate(top, 'top');
    AtlasNormalizedPoint._validateCoordinate(right, 'right');
    AtlasNormalizedPoint._validateCoordinate(bottom, 'bottom');

    if (right < left) {
      throw ArgumentError.value(
        right,
        'right',
        'right cannot be less than left.',
      );
    }
    if (bottom < top) {
      throw ArgumentError.value(
        bottom,
        'bottom',
        'bottom cannot be less than top.',
      );
    }
  }

  final double left;
  final double top;
  final double right;
  final double bottom;

  double get width => right - left;
  double get height => bottom - top;

  AtlasNormalizedPoint get centroid =>
      AtlasNormalizedPoint(x: left + (width / 2), y: top + (height / 2));
}

class AtlasScanObservation {
  AtlasScanObservation({
    required this.observationId,
    required this.capturedAt,
    this.code,
    List<AtlasNormalizedPoint> cornerPoints = const <AtlasNormalizedPoint>[],
    this.confidence = 1.0,
  }) : cornerPoints = List<AtlasNormalizedPoint>.unmodifiable(cornerPoints) {
    if (observationId.trim().isEmpty) {
      throw ArgumentError.value(
        observationId,
        'observationId',
        'observationId cannot be empty.',
      );
    }

    if (!confidence.isFinite || confidence < 0.0 || confidence > 1.0) {
      throw ArgumentError.value(
        confidence,
        'confidence',
        'confidence must be between 0.0 and 1.0.',
      );
    }
  }

  final String observationId;
  final DateTime capturedAt;
  final ScanCode? code;
  final List<AtlasNormalizedPoint> cornerPoints;
  final double confidence;

  bool get hasGeometry => cornerPoints.isNotEmpty;
  bool get hasCode => code != null;

  bool get hasUsableProductBarcode {
    final ScanCode? observedCode = code;
    return observedCode != null &&
        observedCode.isValid &&
        observedCode.isProductBarcode &&
        observedCode.normalizedValue.trim().isNotEmpty;
  }

  AtlasNormalizedPoint? get centroid {
    if (cornerPoints.isEmpty) return null;

    double sumX = 0.0;
    double sumY = 0.0;

    for (final AtlasNormalizedPoint point in cornerPoints) {
      sumX += point.x;
      sumY += point.y;
    }

    return AtlasNormalizedPoint(
      x: sumX / cornerPoints.length,
      y: sumY / cornerPoints.length,
    );
  }

  AtlasNormalizedBounds? get normalizedBounds {
    if (cornerPoints.isEmpty) return null;

    double minX = cornerPoints.first.x;
    double maxX = cornerPoints.first.x;
    double minY = cornerPoints.first.y;
    double maxY = cornerPoints.first.y;

    for (final AtlasNormalizedPoint point in cornerPoints.skip(1)) {
      minX = math.min(minX, point.x);
      maxX = math.max(maxX, point.x);
      minY = math.min(minY, point.y);
      maxY = math.max(maxY, point.y);
    }

    return AtlasNormalizedBounds(
      left: minX,
      top: minY,
      right: maxX,
      bottom: maxY,
    );
  }
}
