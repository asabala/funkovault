final class AtlasLiveSnifferNativeBarcode {
  const AtlasLiveSnifferNativeBarcode({
    required this.rawValue,
    required this.format,
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  final String rawValue;
  final String format;
  final double left;
  final double top;
  final double right;
  final double bottom;
}

final class AtlasLiveSnifferNativeTextBlock {
  const AtlasLiveSnifferNativeTextBlock({
    required this.text,
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  final String text;
  final double left;
  final double top;
  final double right;
  final double bottom;

  double get centerX => (left + right) / 2;
  double get centerY => (top + bottom) / 2;
}

final class AtlasLiveSnifferNativeFrame {
  const AtlasLiveSnifferNativeFrame({
    required this.capturedAt,
    required this.barcodes,
    this.textBlocks = const <AtlasLiveSnifferNativeTextBlock>[],
    this.recognizedText = '',
  });

  final DateTime capturedAt;
  final List<AtlasLiveSnifferNativeBarcode> barcodes;
  final List<AtlasLiveSnifferNativeTextBlock> textBlocks;
  final String recognizedText;

  factory AtlasLiveSnifferNativeFrame.fromMap(Map<Object?, Object?> map) {
    final int micros = _readInt(map['capturedAtMicros']);
    final List<AtlasLiveSnifferNativeBarcode> parsedBarcodes =
        <AtlasLiveSnifferNativeBarcode>[];
    final Object? rawBarcodes = map['barcodes'];

    if (rawBarcodes is List) {
      for (final Object? rawBarcode in rawBarcodes) {
        if (rawBarcode is! Map) continue;
        final Map<Object?, Object?> barcodeMap = Map<Object?, Object?>.from(
          rawBarcode,
        );
        final String rawValue = barcodeMap['rawValue']?.toString().trim() ?? '';
        if (rawValue.isEmpty) continue;

        parsedBarcodes.add(
          AtlasLiveSnifferNativeBarcode(
            rawValue: rawValue,
            format: barcodeMap['format']?.toString().trim() ?? 'UNKNOWN',
            left: _readUnitDouble(barcodeMap['left']),
            top: _readUnitDouble(barcodeMap['top']),
            right: _readUnitDouble(barcodeMap['right']),
            bottom: _readUnitDouble(barcodeMap['bottom']),
          ),
        );
      }
    }

    final List<AtlasLiveSnifferNativeTextBlock> parsedTextBlocks =
        <AtlasLiveSnifferNativeTextBlock>[];
    final Object? rawTextBlocks = map['textBlocks'];

    if (rawTextBlocks is List) {
      for (final Object? rawBlock in rawTextBlocks) {
        if (rawBlock is! Map) continue;
        final Map<Object?, Object?> blockMap = Map<Object?, Object?>.from(
          rawBlock,
        );
        final String text = blockMap['text']?.toString().trim() ?? '';
        if (text.isEmpty) continue;
        parsedTextBlocks.add(
          AtlasLiveSnifferNativeTextBlock(
            text: text,
            left: _readUnitDouble(blockMap['left']),
            top: _readUnitDouble(blockMap['top']),
            right: _readUnitDouble(blockMap['right']),
            bottom: _readUnitDouble(blockMap['bottom']),
          ),
        );
      }
    }

    return AtlasLiveSnifferNativeFrame(
      capturedAt: micros > 0
          ? DateTime.fromMicrosecondsSinceEpoch(micros, isUtc: true)
          : DateTime.now().toUtc(),
      barcodes: List<AtlasLiveSnifferNativeBarcode>.unmodifiable(
        parsedBarcodes,
      ),
      textBlocks: List<AtlasLiveSnifferNativeTextBlock>.unmodifiable(
        parsedTextBlocks,
      ),
      recognizedText: map['recognizedText']?.toString().trim() ?? '',
    );
  }

  static int _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _readUnitDouble(Object? value) {
    final double parsed;
    if (value is num) {
      parsed = value.toDouble();
    } else {
      parsed = double.tryParse(value?.toString() ?? '') ?? 0;
    }
    return parsed.clamp(0.0, 1.0).toDouble();
  }
}
