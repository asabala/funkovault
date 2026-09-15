// Immutable description of an engine failure.
//
// EngineFailure represents a platform-level failure without requiring
// callers to understand implementation-specific exception types.
class EngineFailure {
  factory EngineFailure({
    required String code,
    required String message,
    bool isRetryable = false,
    Map<String, Object?> details = const <String, Object?>{},
  }) {
    return EngineFailure._(
      code: code.trim(),
      message: message.trim(),
      isRetryable: isRetryable,
      details: Map<String, Object?>.unmodifiable(details),
    );
  }

  const EngineFailure._({
    required this.code,
    required this.message,
    required this.isRetryable,
    required this.details,
  });

  final String code;

  final String message;

  final bool isRetryable;

  final Map<String, Object?> details;

  T? detail<T>(String key) {
    final Object? value = details[key];

    if (value is T) {
      return value;
    }

    return null;
  }

  @override
  String toString() {
    return 'EngineFailure('
        'code: $code, '
        'message: $message, '
        'isRetryable: $isRetryable'
        ')';
  }
}
