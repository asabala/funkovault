import 'atlas_execution_metadata.dart';
import 'atlas_result_status.dart';

// Universal output returned by every Atlas Engine.
//
// AtlasResult separates expected domain outcomes from unexpected programming
// failures. Validation problems, missing data, conflicting evidence, and
// policy failures should normally be represented by a structured result.
class AtlasResult<T> {
  AtlasResult({
    required this.status,
    required this.metadata,
    this.output,
    this.errors = const <String>[],
    this.warnings = const <String>[],
  })  : assert(
  status.hasUsableOutput || output == null,
  'Failure results should not contain usable output.',
  ),
        assert(
        status.hasUsableOutput || errors.isNotEmpty,
        'Failure results should contain at least one error.',
        );

  // Overall outcome of the engine execution.
  final AtlasResultStatus status;

  // Output produced by the engine, when available.
  final T? output;

  // Human-readable errors that prevented successful execution.
  final List<String> errors;

  // Non-blocking warnings produced during execution.
  final List<String> warnings;

  // Metadata describing how and when the engine executed.
  final AtlasExecutionMetadata metadata;

  // Whether the engine completed successfully.
  bool get isSuccess => status.isSuccess;

  // Whether the result contains output that may be consumed.
  bool get hasUsableOutput => status.hasUsableOutput && output != null;

  // Whether the result represents a failure.
  bool get isFailure => status.isFailure;

  // Whether the result contains one or more errors.
  bool get hasErrors => errors.isNotEmpty;

  // Whether the result contains one or more warnings.
  bool get hasWarnings => warnings.isNotEmpty;

  // Whether the result should be reviewed before further action.
  bool get requiresReview => status.requiresReview || hasWarnings;

  // Returns the output or throws a StateError when no output is available.
  //
  // This helper should be used only when the caller has already established
  // that the result contains usable output.
  T requireOutput() {
    final T? currentOutput = output;

    if (currentOutput == null) {
      throw StateError(
        'AtlasResult does not contain output. '
            'Status: ${status.serializedValue}',
      );
    }

    return currentOutput;
  }

  AtlasResult<T> copyWith({
    AtlasResultStatus? status,
    T? output,
    bool clearOutput = false,
    List<String>? errors,
    List<String>? warnings,
    AtlasExecutionMetadata? metadata,
  }) {
    return AtlasResult<T>(
      status: status ?? this.status,
      output: clearOutput ? null : output ?? this.output,
      errors: List<String>.unmodifiable(errors ?? this.errors),
      warnings: List<String>.unmodifiable(warnings ?? this.warnings),
      metadata: metadata ?? this.metadata,
    );
  }

  // Creates a successful result containing usable output.
  factory AtlasResult.success({
    required T output,
    required AtlasExecutionMetadata metadata,
    List<String> warnings = const <String>[],
  }) {
    return AtlasResult<T>(
      status: AtlasResultStatus.success,
      output: output,
      warnings: List<String>.unmodifiable(warnings),
      metadata: metadata.copyWith(
        warningCount: warnings.length,
      ),
    );
  }

  // Creates a partially successful result containing usable output.
  factory AtlasResult.partialSuccess({
    required T output,
    required AtlasExecutionMetadata metadata,
    List<String> warnings = const <String>[],
    List<String> errors = const <String>[],
  }) {
    return AtlasResult<T>(
      status: AtlasResultStatus.partialSuccess,
      output: output,
      warnings: List<String>.unmodifiable(warnings),
      errors: List<String>.unmodifiable(errors),
      metadata: metadata.copyWith(
        warningCount: warnings.length,
      ),
    );
  }

  // Creates a validation failure.
  factory AtlasResult.validationFailure({
    required AtlasExecutionMetadata metadata,
    required List<String> errors,
    List<String> warnings = const <String>[],
  }) {
    return AtlasResult<T>(
      status: AtlasResultStatus.validationFailure,
      errors: List<String>.unmodifiable(errors),
      warnings: List<String>.unmodifiable(warnings),
      metadata: metadata.copyWith(
        warningCount: warnings.length,
      ),
    );
  }

  // Creates a policy failure.
  factory AtlasResult.policyFailure({
    required AtlasExecutionMetadata metadata,
    required List<String> errors,
    List<String> warnings = const <String>[],
  }) {
    return AtlasResult<T>(
      status: AtlasResultStatus.policyFailure,
      errors: List<String>.unmodifiable(errors),
      warnings: List<String>.unmodifiable(warnings),
      metadata: metadata.copyWith(
        warningCount: warnings.length,
      ),
    );
  }

  // Creates a missing-data result.
  factory AtlasResult.missingData({
    required AtlasExecutionMetadata metadata,
    required List<String> errors,
    List<String> warnings = const <String>[],
  }) {
    return AtlasResult<T>(
      status: AtlasResultStatus.missingData,
      errors: List<String>.unmodifiable(errors),
      warnings: List<String>.unmodifiable(warnings),
      metadata: metadata.copyWith(
        warningCount: warnings.length,
      ),
    );
  }

  // Creates a conflicting-evidence result.
  factory AtlasResult.conflictingEvidence({
    required AtlasExecutionMetadata metadata,
    required List<String> errors,
    List<String> warnings = const <String>[],
  }) {
    return AtlasResult<T>(
      status: AtlasResultStatus.conflictingEvidence,
      errors: List<String>.unmodifiable(errors),
      warnings: List<String>.unmodifiable(warnings),
      metadata: metadata.copyWith(
        warningCount: warnings.length,
      ),
    );
  }

  // Creates an unexpected execution failure.
  factory AtlasResult.executionFailure({
    required AtlasExecutionMetadata metadata,
    required List<String> errors,
    List<String> warnings = const <String>[],
  }) {
    return AtlasResult<T>(
      status: AtlasResultStatus.executionFailure,
      errors: List<String>.unmodifiable(errors),
      warnings: List<String>.unmodifiable(warnings),
      metadata: metadata.copyWith(
        warningCount: warnings.length,
      ),
    );
  }

  // Converts the result to JSON.
  //
  // Generic output requires a serializer supplied by the caller.
  Map<String, dynamic> toJson({
    required Object? Function(T output) outputToJson,
  }) {
    return <String, dynamic>{
      'status': status.serializedValue,
      'output': output == null ? null : outputToJson(output as T),
      'errors': errors,
      'warnings': warnings,
      'metadata': metadata.toJson(),
    };
  }

  // Restores a result from JSON.
  //
  // Generic output requires a parser supplied by the caller.
  factory AtlasResult.fromJson(
      Map<String, dynamic> json, {
        required T Function(Object? json) outputFromJson,
      }) {
    final Object? rawOutput = json['output'];

    return AtlasResult<T>(
      status: AtlasResultStatus.fromSerializedValue(
        json['status'] as String,
      ),
      output: rawOutput == null ? null : outputFromJson(rawOutput),
      errors: List<String>.unmodifiable(
        List<String>.from(
          json['errors'] as List<dynamic>? ?? const <String>[],
        ),
      ),
      warnings: List<String>.unmodifiable(
        List<String>.from(
          json['warnings'] as List<dynamic>? ?? const <String>[],
        ),
      ),
      metadata: AtlasExecutionMetadata.fromJson(
        Map<String, dynamic>.from(
          json['metadata'] as Map<dynamic, dynamic>,
        ),
      ),
    );
  }

  @override
  String toString() {
    return 'AtlasResult<$T>('
        'status: ${status.serializedValue}, '
        'hasOutput: ${output != null}, '
        'errors: ${errors.length}, '
        'warnings: ${warnings.length}, '
        'metadata: $metadata'
        ')';
  }
}