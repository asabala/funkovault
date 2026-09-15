import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/atlas/live_sniffer/runtime/frame_scheduler.dart';
import 'package:funkovault2/atlas/live_sniffer/runtime/frame_scheduler_policy.dart';
import 'package:funkovault2/atlas/live_sniffer/runtime/frame_tick.dart';
import 'package:funkovault2/atlas/live_sniffer/runtime/runtime_state.dart';
import 'package:funkovault2/atlas/live_sniffer/runtime/scheduler_decision.dart';

void main() {
  group('Stateless FrameScheduler Tests', () {
    const scheduler = FrameScheduler(
      policy: FrameSchedulerPolicy(
        minimumRecognitionInterval: Duration(milliseconds: 250),
      ),
    );

    test('Initial tick with lastEvaluation = 0 yields evaluateCandidate', () {
      const tick = FrameTick(
        sequence: 1,
        timestampMs: 1000,
        lastEvaluationTimestampMs: 0,
        runtime: RuntimeState(targetLocked: false, recognitionRunning: false),
      );

      expect(
        scheduler.decide(tick),
        equals(SchedulerDecision.evaluateCandidate),
      );
    });

    test('Tick inside interval returns trackOnly', () {
      const tick = FrameTick(
        sequence: 2,
        timestampMs: 1100,
        lastEvaluationTimestampMs: 1000, // 100ms delta (< 250ms)
        runtime: RuntimeState(targetLocked: false, recognitionRunning: false),
      );

      expect(scheduler.decide(tick), equals(SchedulerDecision.trackOnly));
    });

    test('Tick meeting or exceeding interval returns evaluateCandidate', () {
      const tick = FrameTick(
        sequence: 3,
        timestampMs: 1250,
        lastEvaluationTimestampMs: 1000, // Exactly 250ms
        runtime: RuntimeState(targetLocked: false, recognitionRunning: false),
      );

      expect(
        scheduler.decide(tick),
        equals(SchedulerDecision.evaluateCandidate),
      );
    });

    test('Precedence: targetLocked overrides elapsed interval', () {
      const tick = FrameTick(
        sequence: 4,
        timestampMs: 5000,
        lastEvaluationTimestampMs: 1000,
        runtime: RuntimeState(targetLocked: true, recognitionRunning: false),
      );

      expect(scheduler.decide(tick), equals(SchedulerDecision.trackOnly));
    });

    test(
      'Precedence: targetLocked AND recognitionRunning both true yields trackOnly',
      () {
        const tick = FrameTick(
          sequence: 5,
          timestampMs: 5000,
          lastEvaluationTimestampMs: 1000,
          runtime: RuntimeState(targetLocked: true, recognitionRunning: true),
        );

        expect(scheduler.decide(tick), equals(SchedulerDecision.trackOnly));
      },
    );

    test('Precedence: recognitionRunning overrides elapsed interval', () {
      const tick = FrameTick(
        sequence: 6,
        timestampMs: 5000,
        lastEvaluationTimestampMs: 1000,
        runtime: RuntimeState(targetLocked: false, recognitionRunning: true),
      );

      expect(scheduler.decide(tick), equals(SchedulerDecision.trackOnly));
    });

    test(
      'selectionGeneration does not affect cadence decision (ownership boundary)',
      () {
        const tickGen1 = FrameTick(
          sequence: 7,
          timestampMs: 1250,
          lastEvaluationTimestampMs: 1000,
          runtime: RuntimeState(
            targetLocked: false,
            recognitionRunning: false,
            selectionGeneration: 1,
          ),
        );

        const tickGen2 = FrameTick(
          sequence: 8,
          timestampMs: 1250,
          lastEvaluationTimestampMs: 1000,
          runtime: RuntimeState(
            targetLocked: false,
            recognitionRunning: false,
            selectionGeneration: 2,
          ),
        );

        expect(
          scheduler.decide(tickGen1),
          equals(SchedulerDecision.evaluateCandidate),
        );
        expect(
          scheduler.decide(tickGen2),
          equals(SchedulerDecision.evaluateCandidate),
        );
      },
    );
  });
}
