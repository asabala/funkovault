// Controls how much real-time analysis runs during a scan session.
enum ScanPerformanceMode {
  fastBarcodeOnly,
  fullAnalysis,
  lowLight,
  batterySaver,
}

// Runtime capability helpers for scan performance modes.
extension ScanPerformanceModeX on ScanPerformanceMode {
  bool get usesBarcodeDetection => true;

  bool get usesQrDetection => true;

  bool get usesOcr {
    return this == ScanPerformanceMode.fullAnalysis ||
        this == ScanPerformanceMode.lowLight;
  }

  bool get usesVisualAnalysis {
    return this == ScanPerformanceMode.fullAnalysis ||
        this == ScanPerformanceMode.lowLight;
  }

  bool get usesLiveImageHashing {
    return this == ScanPerformanceMode.fullAnalysis;
  }

  bool get prefersReducedFrameRate {
    return this == ScanPerformanceMode.batterySaver ||
        this == ScanPerformanceMode.lowLight;
  }

  String get label {
    switch (this) {
      case ScanPerformanceMode.fastBarcodeOnly:
        return 'Fast Scan';
      case ScanPerformanceMode.fullAnalysis:
        return 'Full Analysis';
      case ScanPerformanceMode.lowLight:
        return 'Low Light';
      case ScanPerformanceMode.batterySaver:
        return 'Battery Saver';
    }
  }
}
