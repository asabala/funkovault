import 'package:flutter/foundation.dart';

/// Immutable context tracking active target lifecycle, concurrency, and target generation.
@immutable
class RuntimeState {
  const RuntimeState({
    required this.targetLocked,
    required this.recognitionRunning,
    this.selectionGeneration = 0,
  });

  /// True when a tracked candidate has reached confirmation threshold and is locked.
  final bool targetLocked;

  /// True when an asynchronous evaluation pipeline is currently active.
  final bool recognitionRunning;

  /// Fencing token to detect when user selection or target tracking resets.
  final int selectionGeneration;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RuntimeState &&
          runtimeType == other.runtimeType &&
          targetLocked == other.targetLocked &&
          recognitionRunning == other.recognitionRunning &&
          selectionGeneration == other.selectionGeneration;

  @override
  int get hashCode =>
      targetLocked.hashCode ^
      recognitionRunning.hashCode ^
      selectionGeneration.hashCode;

  @override
  String toString() =>
      'RuntimeState(locked: $targetLocked, busy: $recognitionRunning, gen: $selectionGeneration)';
}
