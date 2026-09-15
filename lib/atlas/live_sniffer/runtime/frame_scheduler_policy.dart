import 'package:flutter/foundation.dart';

/// Tunable throttling policy for [FrameScheduler].
@immutable
class FrameSchedulerPolicy {
  const FrameSchedulerPolicy({
    this.minimumRecognitionInterval = const Duration(milliseconds: 250),
  });

  /// The minimum time that must elapse between candidate evaluation passes.
  final Duration minimumRecognitionInterval;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FrameSchedulerPolicy &&
          runtimeType == other.runtimeType &&
          minimumRecognitionInterval == other.minimumRecognitionInterval;

  @override
  int get hashCode => minimumRecognitionInterval.hashCode;
}
