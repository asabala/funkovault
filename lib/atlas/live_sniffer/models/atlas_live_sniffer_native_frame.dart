import 'atlas_live_sniffer_target_state.dart';
import 'atlas_live_sniffer_track.dart';

final class AtlasLiveSnifferNativeBarcode {
  const AtlasLiveSnifferNativeBarcode({
    required this.rawValue,
    required this.format,
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
    this.trackId,
  });

  final String rawValue;
  final String format;
  final double left;
  final double top;
  final double right;
  final double bottom;
  final int? trackId;
}

final class AtlasLiveSnifferNativeTextBlock {
  const AtlasLiveSnifferNativeTextBlock({
    required this.text,
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
    this.trackId,
  });

  final String text;
  final double left;
  final double top;
  final double right;
  final double bottom;
  final int? trackId;

  double get centerX => (left + right) / 2;
  double get centerY => (top + bottom) / 2;
}

final class AtlasLiveSnifferNativeFrame {
  const AtlasLiveSnifferNativeFrame({
    required this.capturedAt,
    required this.barcodes,
    this.frameSequence = 0,
    this.selectionGeneration = 0,
    this.nativeTimestampMs = 0,
    this.targetState = AtlasLiveSnifferTargetState.none,
    this.lockedTrackId,
    this.trackedBoundingBox,
    this.activeTracks = const <AtlasLiveSnifferTrack>[],
    this.textBlocks = const <AtlasLiveSnifferNativeTextBlock>[],
    this.recognizedText = '',
  });

  final DateTime capturedAt;
  final List<AtlasLiveSnifferNativeBarcode> barcodes;
  final List<AtlasLiveSnifferNativeTextBlock> textBlocks;
  final String recognizedText;
  final int frameSequence;
  final int selectionGeneration;
  final int nativeTimestampMs;
  final int? lockedTrackId;
  final AtlasLiveSnifferTargetState targetState;
  final AtlasLiveSnifferNormalizedRect? trackedBoundingBox;
  final List<AtlasLiveSnifferTrack> activeTracks;

  bool get isSingleTargetFrame => targetState.isSingleTargetLifecycle;

  AtlasLiveSnifferNativeFrame scopedToLockedTrack() {
    final int? trackId = lockedTrackId;
    if (trackId == null) return this;
    return AtlasLiveSnifferNativeFrame(
      capturedAt: capturedAt,
      barcodes: barcodes
          .where(
            (AtlasLiveSnifferNativeBarcode item) => item.trackId == trackId,
          )
          .toList(growable: false),
      textBlocks: textBlocks
          .where(
            (AtlasLiveSnifferNativeTextBlock item) => item.trackId == trackId,
          )
          .toList(growable: false),
      recognizedText: recognizedText,
      frameSequence: frameSequence,
      selectionGeneration: selectionGeneration,
      nativeTimestampMs: nativeTimestampMs,
      lockedTrackId: lockedTrackId,
      targetState: targetState,
      trackedBoundingBox: trackedBoundingBox,
      activeTracks: activeTracks,
    );
  }

  factory AtlasLiveSnifferNativeFrame.fromMap(Map<Object?, Object?> map) {
    final int micros = _readInt(map['capturedAtMicros']);
    final int nativeTimestampMs = _readInt(map['nativeTimestampMs']);
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
            trackId: _readNullableInt(barcodeMap['trackId']),
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
            trackId: _readNullableInt(blockMap['trackId']),
          ),
        );
      }
    }

    AtlasLiveSnifferNormalizedRect? trackedBoundingBox;
    final Object? rawTrackedBox = map['trackedBoundingBox'];
    if (rawTrackedBox is Map) {
      trackedBoundingBox = AtlasLiveSnifferNormalizedRect.fromMap(
        Map<Object?, Object?>.from(rawTrackedBox),
      );
    }

    final List<AtlasLiveSnifferTrack> activeTracks = <AtlasLiveSnifferTrack>[];
    final Object? rawTracks = map['activeTracks'];
    if (rawTracks is List) {
      for (final Object? rawTrack in rawTracks) {
        if (rawTrack is! Map) continue;
        activeTracks.add(
          AtlasLiveSnifferTrack.fromMap(Map<Object?, Object?>.from(rawTrack)),
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
      frameSequence: _readInt(map['frameSequence']),
      selectionGeneration: _readInt(map['selectionGeneration']),
      nativeTimestampMs: nativeTimestampMs,
      lockedTrackId: _readNullableInt(map['lockedTrackId']),
      targetState: atlasLiveSnifferTargetStateFromWire(
        map['targetState']?.toString() ?? '',
      ),
      trackedBoundingBox: trackedBoundingBox,
      activeTracks: List<AtlasLiveSnifferTrack>.unmodifiable(activeTracks),
    );
  }

  static int _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _readNullableInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
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
