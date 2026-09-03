import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/atlas/scan/authenticity/engines/atlas_autograph_coa_inspection_engine.dart';
import 'package:funkovault2/atlas/scan/authenticity/engines/atlas_high_signal_inspection_pipeline.dart';
import 'package:funkovault2/atlas/scan/authenticity/models/atlas_authenticity_evidence.dart';
import 'package:funkovault2/atlas/scan/authenticity/models/atlas_visual_inspection.dart';
import 'package:funkovault2/atlas/scan/authenticity/providers/atlas_authentication_evidence_interpreter.dart';
import 'package:funkovault2/atlas/scan/authenticity/providers/atlas_authentication_provider.dart';

void main() {
  final DateTime observedAt = DateTime.utc(2026, 9, 3, 18);

  group('AtlasAuthenticationEvidenceInterpreter', () {
    test(
      'recognizes common provider aliases without claiming verification',
      () {
        final interpretation = AtlasAuthenticationEvidenceInterpreter.interpret(
          certificationText: 'James Spence Authentication Cert #AB12345',
          hasCoa: true,
        );

        expect(
          interpretation.providerKind,
          AtlasAuthenticationProviderKind.jsa,
        );
        expect(interpretation.providerDisplayName, 'JSA');
        expect(interpretation.certificateNumber, 'AB12345');
        expect(
          interpretation.documentationState,
          AtlasAuthenticationDocumentationState.supported,
        );
      },
    );

    test('recognizes PSA/DNA and Beckett provider text', () {
      final psa = AtlasAuthenticationEvidenceInterpreter.interpret(
        certificationText: 'PSA/DNA Certification No. 12345678',
      );
      final beckett = AtlasAuthenticationEvidenceInterpreter.interpret(
        certificationText: 'Beckett Authentication Services Cert #BAS-7788',
      );

      expect(psa.providerKind, AtlasAuthenticationProviderKind.psaDna);
      expect(beckett.providerKind, AtlasAuthenticationProviderKind.beckett);
    });

    test('missing COA or provider data is not an inconsistency', () {
      final interpretation = AtlasAuthenticationEvidenceInterpreter.interpret(
        hasCoa: false,
      );

      expect(interpretation.hasInternalMismatch, isFalse);
      expect(
        interpretation.documentationState,
        AtlasAuthenticationDocumentationState.observed,
      );
    });

    test(
      'different explicit and observed provider is an internal mismatch',
      () {
        final interpretation = AtlasAuthenticationEvidenceInterpreter.interpret(
          provider: 'JSA',
          certificationText: 'PSA/DNA Cert #12345678',
          hasCoa: true,
        );

        expect(interpretation.providerFieldMismatch, isTrue);
        expect(interpretation.hasInternalMismatch, isTrue);
        expect(
          interpretation.documentationState,
          AtlasAuthenticationDocumentationState.inconsistent,
        );
      },
    );

    test(
      'different explicit and observed certificate number is a mismatch',
      () {
        final interpretation = AtlasAuthenticationEvidenceInterpreter.interpret(
          provider: 'JSA',
          certificateNumber: 'ABC123',
          certificationText: 'JSA Certificate No. XYZ789',
          hasCoa: true,
        );

        expect(interpretation.certificateNumberMismatch, isTrue);
        expect(interpretation.hasInternalMismatch, isTrue);
      },
    );
  });

  group('AtlasAutographCoaInspectionEngine', () {
    test('structured COA evidence remains provider-unverified by default', () {
      final observations = const AtlasAutographCoaInspectionEngine().inspect(
        sessionId: 'session-5e-1',
        inspection: AtlasVisualInspection(
          hasCoa: true,
          certificationText: 'JSA Cert #AB12345',
          evidenceConfidence: 0.90,
        ),
        observedAt: observedAt,
      );

      expect(observations, hasLength(1));
      final observation = observations.single;
      expect(observation.category, AtlasEvidenceCategory.autographCoa);
      expect(observation.attributes['provider'], 'JSA');
      expect(observation.attributes['certificateNumber'], 'AB12345');
      expect(observation.attributes['providerVerified'], isFalse);
      expect(observation.attributes['verificationState'], 'notAttempted');
      expect(observation.attributes['internalMismatch'], isFalse);
    });

    test('internal provider mismatch is preserved as review evidence', () {
      final observations = const AtlasAutographCoaInspectionEngine().inspect(
        sessionId: 'session-5e-2',
        inspection: AtlasVisualInspection(
          hasCoa: true,
          authenticationProvider: 'JSA',
          certificationText: 'PSA/DNA Cert #12345678',
          evidenceConfidence: 0.90,
        ),
        observedAt: observedAt,
      );

      expect(observations.single.attributes['internalMismatch'], isTrue);
      expect(observations.single.attributes['providerFieldMismatch'], isTrue);
      expect(observations.single.attributes['providerVerified'], isFalse);
    });

    test('autograph without COA never becomes counterfeit evidence', () {
      final observations = const AtlasAutographCoaInspectionEngine().inspect(
        sessionId: 'session-5e-3',
        inspection: AtlasVisualInspection(
          signature: 'Jane Doe',
          hasAutograph: true,
          hasCoa: false,
          evidenceConfidence: 0.90,
        ),
        observedAt: observedAt,
      );

      expect(observations, hasLength(2));
      expect(
        observations.every(
          (observation) =>
              observation.attributes['providerVerified'] == false &&
              observation.attributes['criticalReferenceMismatch'] != true,
        ),
        isTrue,
      );
    });
  });

  test('high-signal pipeline preserves raw certification OCR text', () {
    final inspection = const AtlasHighSignalInspectionPipeline().enrich(
      sessionId: 'session-5e-4',
      inspection: AtlasVisualInspection(
        hasCoa: true,
        certificationText: 'Beckett Cert #BAS-7788',
      ),
      observedAt: observedAt,
    );

    expect(inspection.certificationText, 'Beckett Cert #BAS-7788');
    expect(
      inspection.observations.any(
        (observation) =>
            observation.category == AtlasEvidenceCategory.autographCoa,
      ),
      isTrue,
    );
  });
}
