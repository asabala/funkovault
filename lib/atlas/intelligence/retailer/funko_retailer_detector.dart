import '../identity/atlas_identity_analysis.dart';
import '../identity/atlas_identity_detector.dart';
import '../identity/atlas_identity_phrase.dart';
import 'funko_retailer.dart';
import 'funko_retailer_detection_result.dart';
import 'funko_retailer_evidence.dart';
import 'funko_retailer_evidence_source.dart';
import 'funko_retailer_normalizer.dart';

// Detects retailers and contributes them to the shared identity analysis.
final class FunkoRetailerDetector
    implements AtlasIdentityDetector {
  const FunkoRetailerDetector({
    FunkoRetailerNormalizer? normalizer,
  }) : _normalizer =
      normalizer ??
          const FunkoRetailerNormalizer();

  final FunkoRetailerNormalizer _normalizer;

  @override
  AtlasIdentityAnalysis detect({
    required List<AtlasIdentityPhrase> phrases,
    required AtlasIdentityAnalysis analysis,
  }) {
    final Map<FunkoRetailer, FunkoRetailerEvidence>
    evidence =
    <FunkoRetailer, FunkoRetailerEvidence>{};

    for (final AtlasIdentityPhrase phrase
    in phrases) {
      final FunkoRetailer retailer =
      _normalizer.normalize(
        phrase.normalizedText,
      );

      if (retailer == FunkoRetailer.unknown) {
        continue;
      }

      evidence.putIfAbsent(
        retailer,
            () => FunkoRetailerEvidence(
          retailer: retailer,
          confidence: 1.0,
          source:
          FunkoRetailerEvidenceSource.rule,
          rawValue: phrase.text,
          normalizedValue:
          phrase.normalizedText,
        ),
      );
    }

    return analysis.copyWith(
      retailerResult:
      FunkoRetailerDetectionResult(
        evidence:
        List<FunkoRetailerEvidence>.unmodifiable(
          evidence.values,
        ),
      ),
    );
  }
}