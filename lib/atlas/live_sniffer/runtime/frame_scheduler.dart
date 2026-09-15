import 'frame_scheduler_policy.dart';
import 'frame_tick.dart';
import 'scheduler_decision.dart';

/// Pure, stateless decision coordinator for frame recognition pacing.
class FrameScheduler {
  const FrameScheduler({this.policy = const FrameSchedulerPolicy()});

  final FrameSchedulerPolicy policy;

  /// Pure deterministic evaluation function.
  /// Precedence Order:
  /// 1. Target Locked (Identified) -> trackOnly
  /// 2. Concurrency Guard (In-flight) -> trackOnly
  /// 3. Cadence Throttling (< interval) -> trackOnly
  /// 4. Eligible Candidate -> evaluateCandidate
  SchedulerDecision decide(FrameTick tick) {
    // 1. Lock & Freeze: If the target is confirmed, stop expensive evaluation.
    if (tick.runtime.targetLocked) {
      return SchedulerDecision.trackOnly;
    }

    // 2. Concurrency Guard: If an asynchronous inspection is running, track only.
    if (tick.runtime.recognitionRunning) {
      return SchedulerDecision.trackOnly;
    }

    // 3. Cadence Throttling: Enforce minimum interval between evaluations.
    final intervalMs = policy.minimumRecognitionInterval.inMilliseconds;
    if (tick.timestampMs - tick.lastEvaluationTimestampMs < intervalMs) {
      return SchedulerDecision.trackOnly;
    }

    return SchedulerDecision.evaluateCandidate;
  }
}
