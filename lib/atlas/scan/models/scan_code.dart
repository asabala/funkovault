// Supported barcode and QR code formats recognized by Atlas.
enum ScanCodeFormat { upcA, upcE, ean8, ean13, qrCode, unknown }

// Identifies where a scan code entered the Atlas platform.
enum ScanCodeSource { camera, manualEntry, importedData, externalProvider }

// Immutable barcode or QR code captured or supplied to Atlas.
class ScanCode {
  const ScanCode({
    required this.rawValue,
    required this.normalizedValue,
    required this.format,
    required this.source,
    required this.capturedAt,
    required this.isValid,
    this.confidence = 0.0,
  });

  final String rawValue;

  final String normalizedValue;

  final ScanCodeFormat format;

  final ScanCodeSource source;

  final DateTime capturedAt;

  final bool isValid;

  final double confidence;

  bool get isEmpty => normalizedValue.isEmpty;

  bool get isNotEmpty => normalizedValue.isNotEmpty;

  bool get isUpc {
    return format == ScanCodeFormat.upcA || format == ScanCodeFormat.upcE;
  }

  bool get isEan {
    return format == ScanCodeFormat.ean8 || format == ScanCodeFormat.ean13;
  }

  bool get isQrCode {
    return format == ScanCodeFormat.qrCode;
  }

  bool get isProductBarcode {
    return isUpc || isEan;
  }

  bool get containsNumericValue {
    return RegExp(r'^\d+$').hasMatch(normalizedValue);
  }

  int get characterCount => normalizedValue.length;

  int? get digitCount {
    if (!containsNumericValue) {
      return null;
    }

    return normalizedValue.length;
  }

  ScanCode copyWith({
    String? rawValue,
    String? normalizedValue,
    ScanCodeFormat? format,
    ScanCodeSource? source,
    DateTime? capturedAt,
    bool? isValid,
    double? confidence,
  }) {
    return ScanCode(
      rawValue: rawValue ?? this.rawValue,
      normalizedValue: normalizedValue ?? this.normalizedValue,
      format: format ?? this.format,
      source: source ?? this.source,
      capturedAt: capturedAt ?? this.capturedAt,
      isValid: isValid ?? this.isValid,
      confidence: confidence ?? this.confidence,
    );
  }

  Map<String, Object> toMap() {
    return <String, Object>{
      'rawValue': rawValue,
      'normalizedValue': normalizedValue,
      'format': format.name,
      'source': source.name,
      'capturedAt': capturedAt.toIso8601String(),
      'isValid': isValid,
      'confidence': confidence,
    };
  }

  factory ScanCode.fromMap(Map<String, Object?> map) {
    return ScanCode(
      rawValue: map['rawValue'] as String? ?? '',
      normalizedValue: map['normalizedValue'] as String? ?? '',
      format: _formatFromName(map['format'] as String?),
      source: _sourceFromName(map['source'] as String?),
      capturedAt:
          DateTime.tryParse(map['capturedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      isValid: map['isValid'] as bool? ?? false,
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static ScanCodeFormat _formatFromName(String? name) {
    for (final ScanCodeFormat format in ScanCodeFormat.values) {
      if (format.name == name) {
        return format;
      }
    }

    return ScanCodeFormat.unknown;
  }

  static ScanCodeSource _sourceFromName(String? name) {
    for (final ScanCodeSource source in ScanCodeSource.values) {
      if (source.name == name) {
        return source;
      }
    }

    return ScanCodeSource.camera;
  }

  @override
  String toString() {
    return 'ScanCode('
        'normalizedValue: $normalizedValue, '
        'format: ${format.name}, '
        'source: ${source.name}, '
        'isValid: $isValid, '
        'confidence: $confidence'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ScanCode &&
            runtimeType == other.runtimeType &&
            rawValue == other.rawValue &&
            normalizedValue == other.normalizedValue &&
            format == other.format &&
            source == other.source &&
            capturedAt == other.capturedAt &&
            isValid == other.isValid &&
            confidence == other.confidence;
  }

  @override
  int get hashCode {
    return Object.hash(
      rawValue,
      normalizedValue,
      format,
      source,
      capturedAt,
      isValid,
      confidence,
    );
  }
}
