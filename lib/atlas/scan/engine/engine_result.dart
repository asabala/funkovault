import '../models/scan_session.dart';
import 'engine_execution_metadata.dart';
import 'engine_failure.dart';
import 'engine_status.dart';

// Immutable result returned by one Atlas scan engine.
//
// EngineResult separates execution information from the collector
// intelligence stored in ScanSession.
class EngineResult {
  factory EngineResult({
    required ScanSession session,
    required EngineStatus status,
    List<String> warnings = const <String>[],
    String? skipReason,
    EngineFailure? failure,
    EngineExecutionMetadata? metadata,
    Map<String, Object?> attributes = const <String, Object?>{},
  }) {
    assert(
      status != EngineStatus.failed || failure != null,
      'A failed EngineResult must include an EngineFailure.',
    );

    assert(
      status == EngineStatus.failed || failure == null,
      'Only a failed EngineResult may include an EngineFailure.',
    );

    return EngineResult._(
      session: session,
      status: status,
      warnings: List<String>.unmodifiable(
        warnings
            .map((String warning) => warning.trim())
            .where((String warning) => warning.isNotEmpty),
      ),
      skipReason: skipReason?.trim(),
      failure: failure,
      metadata: metadata,
      attributes: Map<String, Object?>.unmodifiable(attributes),
    );
  }

  const EngineResult._({
    required this.session,
    required this.status,
    required this.warnings,
    required this.skipReason,
    required this.failure,
    required this.metadata,
    required this.attributes,
  });

  factory EngineResult.success({
    required ScanSession session,
    List<String> warnings = const <String>[],
    Map<String, Object?> attributes = const <String, Object?>{},
  }) {
    return EngineResult(
      session: session,
      status: warnings.isEmpty
          ? EngineStatus.succeeded
          : EngineStatus.completedWithWarnings,
      warnings: warnings,
      attributes: attributes,
    );
  }

  factory EngineResult.skipped({
    required ScanSession session,
    required String reason,
    Map<String, Object?> attributes = const <String, Object?>{},
  }) {
    return EngineResult(
      session: session,
      status: EngineStatus.skipped,
      skipReason: reason,
      attributes: attributes,
    );
  }

  factory EngineResult.failed({
    required ScanSession session,
    required EngineFailure failure,
    List<String> warnings = const <String>[],
    Map<String, Object?> attributes = const <String, Object?>{},
  }) {
    return EngineResult(
      session: session,
      status: EngineStatus.failed,
      warnings: warnings,
      failure: failure,
      attributes: attributes,
    );
  }

  final ScanSession session;

  final EngineStatus status;

  final List<String> warnings;

  final String? skipReason;

  final EngineFailure? failure;

  final EngineExecutionMetadata? metadata;

  final Map<String, Object?> attributes;

  bool get isSuccessful {
    return status.isSuccessful;
  }

  bool get hasWarnings {
    return warnings.isNotEmpty || status.hasWarnings;
  }

  bool get wasSkipped {
    return status.wasSkipped;
  }

  bool get hasFailed {
    return status.hasFailed;
  }

  bool get shouldContinue {
    return status.shouldContinue;
  }

  bool get hasMetadata {
    return metadata != null;
  }

  T? attribute<T>(String key) {
    final Object? value = attributes[key];

    if (value is T) {
      return value;
    }

    return null;
  }

  EngineResult withMetadata(EngineExecutionMetadata value) {
    return EngineResult(
      session: session,
      status: status,
      warnings: warnings,
      skipReason: skipReason,
      failure: failure,
      metadata: value,
      attributes: attributes,
    );
  }

  @override
  String toString() {
    return 'EngineResult('
        'status: ${status.name}, '
        'warnings: ${warnings.length}, '
        'hasFailure: ${failure != null}, '
        'hasMetadata: $hasMetadata'
        ')';
  }
}
