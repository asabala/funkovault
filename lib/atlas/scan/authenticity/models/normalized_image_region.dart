final class NormalizedImageRegion {
  NormalizedImageRegion({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  }) {
    _validateUnitValue('left', left, allowZero: true);
    _validateUnitValue('top', top, allowZero: true);
    _validateUnitValue('width', width, allowZero: false);
    _validateUnitValue('height', height, allowZero: false);

    if (left + width > 1.0) {
      throw ArgumentError.value(
        left + width,
        'left + width',
        'Normalized horizontal bounds cannot exceed 1.0.',
      );
    }

    if (top + height > 1.0) {
      throw ArgumentError.value(
        top + height,
        'top + height',
        'Normalized vertical bounds cannot exceed 1.0.',
      );
    }
  }

  final double left;
  final double top;
  final double width;
  final double height;

  List<double> toList() => <double>[left, top, width, height];

  Map<String, Object?> toJson() => <String, Object?>{
    'left': left,
    'top': top,
    'width': width,
    'height': height,
  };

  static NormalizedImageRegion? fromList(Object? value) {
    if (value is! List || value.length != 4) {
      return null;
    }

    try {
      return NormalizedImageRegion(
        left: (value[0] as num).toDouble(),
        top: (value[1] as num).toDouble(),
        width: (value[2] as num).toDouble(),
        height: (value[3] as num).toDouble(),
      );
    } catch (_) {
      return null;
    }
  }

  static NormalizedImageRegion? fromJson(Map<String, Object?> value) {
    try {
      return NormalizedImageRegion(
        left: (value['left'] as num).toDouble(),
        top: (value['top'] as num).toDouble(),
        width: (value['width'] as num).toDouble(),
        height: (value['height'] as num).toDouble(),
      );
    } catch (_) {
      return null;
    }
  }

  static void _validateUnitValue(
    String name,
    double value, {
    required bool allowZero,
  }) {
    final bool lowerBoundValid = allowZero ? value >= 0.0 : value > 0.0;
    if (!value.isFinite || !lowerBoundValid || value > 1.0) {
      throw ArgumentError.value(
        value,
        name,
        allowZero
            ? 'Must be a finite value between 0.0 and 1.0.'
            : 'Must be a finite value greater than 0.0 and at most 1.0.',
      );
    }
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is NormalizedImageRegion &&
            other.left == left &&
            other.top == top &&
            other.width == width &&
            other.height == height;
  }

  @override
  int get hashCode => Object.hash(left, top, width, height);

  @override
  String toString() {
    return 'NormalizedImageRegion('
        'left: $left, top: $top, width: $width, height: $height)';
  }
}
