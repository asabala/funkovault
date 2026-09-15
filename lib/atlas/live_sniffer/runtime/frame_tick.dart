import 'package:flutter/foundation.dart';
import 'runtime_state.dart';

/// Represents a single observation cycle evaluated by the runtime scheduler.
/// Immutable and carries timing plus runtime lifecycle state for pure decision-making.
@immutable
class FrameTick {
  const FrameTick({
    required this.sequence,
    required this.timestampMs,
    required this.lastEvaluationTimestampMs,
    required this.runtime,
  });

  /// Monotonically increasing frame sequence index from native capture.
  final int sequence;

  /// Hardware capture timestamp in epoch milliseconds.
  final int timestampMs;

  /// The timestamp (in ms) when candidate evaluation was last invoked.
  final int lastEvaluationTimestampMs;

  /// The active lifecycle and concurrency state of the sniffer.
  final RuntimeState runtime;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FrameTick &&
          runtimeType == other.runtimeType &&
          sequence == other.sequence &&
          timestampMs == other.timestampMs &&
          lastEvaluationTimestampMs == other.lastEvaluationTimestampMs &&
          runtime == other.runtime;

  @override
  int get hashCode =>
      sequence.hashCode ^
      timestampMs.hashCode ^
      lastEvaluationTimestampMs.hashCode ^
      runtime.hashCode;

  @override
  String toString() =>
      'FrameTick(seq: $sequence, ts: ${timestampMs}ms, lastEval: ${lastEvaluationTimestampMs}ms, runtime: $runtime)';
}
