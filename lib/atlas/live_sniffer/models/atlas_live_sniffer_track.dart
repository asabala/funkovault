final class AtlasLiveSnifferNormalizedRect {
  const AtlasLiveSnifferNormalizedRect({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  final double left;
  final double top;
  final double right;
  final double bottom;

  double get centerX => (left + right) / 2;
  double get centerY => (top + bottom) / 2;
  double get width => (right - left).abs();
  double get height => (bottom - top).abs();

  factory AtlasLiveSnifferNormalizedRect.fromMap(Map<Object?, Object?> map) {
    return AtlasLiveSnifferNormalizedRect(
      left: _readUnitDouble(map['left']),
      top: _readUnitDouble(map['top']),
      right: _readUnitDouble(map['right']),
      bottom: _readUnitDouble(map['bottom']),
    );
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

final class AtlasLiveSnifferTrack {
  const AtlasLiveSnifferTrack({
    required this.trackId,
    required this.boundingBox,
  });

  final int? trackId;
  final AtlasLiveSnifferNormalizedRect boundingBox;

  factory AtlasLiveSnifferTrack.fromMap(Map<Object?, Object?> map) {
    final Object? rawBox = map['boundingBox'];
    final Map<Object?, Object?> box = rawBox is Map
        ? Map<Object?, Object?>.from(rawBox)
        : const <Object?, Object?>{};
    return AtlasLiveSnifferTrack(
      trackId: _readNullableInt(map['trackId']),
      boundingBox: AtlasLiveSnifferNormalizedRect.fromMap(box),
    );
  }

  static int? _readNullableInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
