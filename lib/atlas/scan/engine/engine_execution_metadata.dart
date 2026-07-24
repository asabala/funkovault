// Immutable diagnostic information recorded by ScanPipeline.
//
// Engines do not create this object themselves. The pipeline records the
// execution timing and identifies which engine produced the result.
class EngineExecutionMetadata {
  factory EngineExecutionMetadata({
    required String engineId,
    required String engineDisplayName,
    required DateTime startedAt,
    required DateTime completedAt,
    required Duration duration,
    bool usedCache = false,
    Map<String, Object?> attributes =
    const <String, Object?>{},
  }) {
    return EngineExecutionMetadata._(
      engineId: engineId.trim(),
      engineDisplayName: engineDisplayName.trim(),
      startedAt: startedAt,
      completedAt: completedAt,
      duration: duration,
      usedCache: usedCache,
      attributes: Map<String, Object?>.unmodifiable(
        attributes,
      ),
    );
  }

  const EngineExecutionMetadata._({
    required this.engineId,
    required this.engineDisplayName,
    required this.startedAt,
    required this.completedAt,
    required this.duration,
    required this.usedCache,
    required this.attributes,
  });

  final String engineId;

  final String engineDisplayName;

  final DateTime startedAt;

  final DateTime completedAt;

  final Duration duration;

  final bool usedCache;

  final Map<String, Object?> attributes;

  int get durationMilliseconds {
    return duration.inMilliseconds;
  }

  T? attribute<T>(String key) {
    final Object? value = attributes[key];

    if (value is T) {
      return value;
    }

    return null;
  }

  @override
  String toString() {
    return 'EngineExecutionMetadata('
        'engineId: $engineId, '
        'durationMilliseconds: $durationMilliseconds, '
        'usedCache: $usedCache'
        ')';
  }
}