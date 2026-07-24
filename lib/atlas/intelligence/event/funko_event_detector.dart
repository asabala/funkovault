import '../identity/atlas_identity_analysis.dart';
import '../identity/atlas_identity_detector.dart';
import '../identity/atlas_identity_phrase.dart';
import 'funko_event.dart';
import 'funko_event_detection_result.dart';
import 'funko_event_evidence.dart';
import 'funko_event_evidence_source.dart';
import 'funko_event_normalizer.dart';

// Detects events and contributes them to the shared identity analysis.
final class FunkoEventDetector
    implements AtlasIdentityDetector {
  const FunkoEventDetector({
    FunkoEventNormalizer? normalizer,
  }) : _normalizer =
      normalizer ??
          const FunkoEventNormalizer();

  final FunkoEventNormalizer _normalizer;

  @override
  AtlasIdentityAnalysis detect({
    required List<AtlasIdentityPhrase> phrases,
    required AtlasIdentityAnalysis analysis,
  }) {
    final Map<FunkoEvent, FunkoEventEvidence>
    evidence =
    <FunkoEvent, FunkoEventEvidence>{};

    for (final AtlasIdentityPhrase phrase
    in phrases) {
      final FunkoEvent event =
      _normalizer.normalize(
        phrase.normalizedText,
      );

      if (event == FunkoEvent.unknown) {
        continue;
      }

      evidence.putIfAbsent(
        event,
            () => FunkoEventEvidence(
          event: event,
          matchedText: phrase.text,
          source:
          FunkoEventEvidenceSource.phrase,
        ),
      );
    }

    return analysis.copyWith(
      eventResult:
      FunkoEventDetectionResult(
        evidence:
        List<FunkoEventEvidence>.unmodifiable(
          evidence.values,
        ),
      ),
    );
  }
}