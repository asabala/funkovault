import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/atlas/scan/continuous/atlas_frame_triage_gate.dart';
import 'package:funkovault2/atlas/scan/continuous/models/atlas_frame_quality_assessment.dart';

void main() {
  group('AtlasFrameTriageGate', () {
    test(
      'accepts a frame when supplied metrics pass configured thresholds',
      () {
        final AtlasFrameQualityAssessment result = AtlasFrameTriageGate()
            .evaluate(
              AtlasFrameQualitySample(
                sharpnessScore: 0.80,
                glareRatio: 0.10,
                motionScore: 0.15,
              ),
            );

        expect(result.isAccepted, isTrue);
        expect(result.issues, isEmpty);
        expect(result.hasCompleteQualityMetrics, isTrue);
      },
    );

    test('rejects blur glare and motion independently', () {
      final AtlasFrameQualityAssessment result = AtlasFrameTriageGate()
          .evaluate(
            AtlasFrameQualitySample(
              sharpnessScore: 0.10,
              glareRatio: 0.80,
              motionScore: 0.90,
            ),
          );

      expect(result.isRejected, isTrue);
      expect(
        result.issues,
        containsAll(<AtlasFrameQualityIssue>[
          AtlasFrameQualityIssue.blur,
          AtlasFrameQualityIssue.glare,
          AtlasFrameQualityIssue.motion,
        ]),
      );
    });

    test(
      'can preserve current scanner compatibility when metrics are absent',
      () {
        final AtlasFrameQualityAssessment result = AtlasFrameTriageGate()
            .evaluate(AtlasFrameQualitySample());

        expect(result.isAccepted, isTrue);
        expect(result.hasQualityMetrics, isFalse);
      },
    );

    test(
      'can require at least one metric for future strict ingestion paths',
      () {
        final AtlasFrameQualityAssessment result = AtlasFrameTriageGate(
          config: const AtlasFrameTriageConfig(requireAtLeastOneMetric: true),
        ).evaluate(AtlasFrameQualitySample());

        expect(result.isRejected, isTrue);
        expect(result.issues, contains(AtlasFrameQualityIssue.missingMetrics));
      },
    );
  });
}
