// Describes whether an Atlas engine should execute.
//
// A decision keeps the execution state and explanation together so an
// engine cannot report that it should run while also providing a skip reason.
class EngineExecutionDecision {
  factory EngineExecutionDecision.run({
    Map<String, Object?> attributes =
    const <String, Object?>{},
  }) {
    return EngineExecutionDecision._(
      shouldRun: true,
      reason: null,
      attributes: Map<String, Object?>.unmodifiable(
        attributes,
      ),
    );
  }

  factory EngineExecutionDecision.skip({
    required String reason,
    Map<String, Object?> attributes =
    const <String, Object?>{},
  }) {
    final String normalizedReason = reason.trim();

    if (normalizedReason.isEmpty) {
      throw ArgumentError.value(
        reason,
        'reason',
        'A skipped engine must provide a reason.',
      );
    }

    return EngineExecutionDecision._(
      shouldRun: false,
      reason: normalizedReason,
      attributes: Map<String, Object?>.unmodifiable(
        attributes,
      ),
    );
  }

  const EngineExecutionDecision._({
    required this.shouldRun,
    required this.reason,
    required this.attributes,
  });

  final bool shouldRun;

  final String? reason;

  final Map<String, Object?> attributes;

  bool get shouldSkip {
    return !shouldRun;
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
    return 'EngineExecutionDecision('
        'shouldRun: $shouldRun, '
        'reason: $reason'
        ')';
  }
}