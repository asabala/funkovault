import '../identity/atlas_identity_analysis.dart';
import '../identity/atlas_identity_detector.dart';
import '../identity/atlas_identity_phrase.dart';
import 'funko_sticker_detection_result.dart';
import 'funko_sticker_evidence.dart';
import '../sticker/funko_sticker_evidence_source.dart';
import '../sticker/funko_sticker_normalizer.dart';
import 'funko_sticker_type.dart';

// Detects sticker classifications and contributes them to the shared
// Atlas identity analysis.
final class FunkoStickerDetector
    implements AtlasIdentityDetector {
  const FunkoStickerDetector({
    FunkoStickerNormalizer? normalizer,
  }) : _normalizer =
      normalizer ??
          const FunkoStickerNormalizer();

  final FunkoStickerNormalizer _normalizer;

  @override
  AtlasIdentityAnalysis detect({
    required List<AtlasIdentityPhrase> phrases,
    required AtlasIdentityAnalysis analysis,
  }) {
    final Map<FunkoStickerType, FunkoStickerEvidence>
    evidence =
    <FunkoStickerType, FunkoStickerEvidence>{};

    for (final AtlasIdentityPhrase phrase
    in phrases) {
      final FunkoStickerType sticker =
      _normalizer.normalize(
        phrase.normalizedText,
      );

      if (sticker == FunkoStickerType.unknown) {
        continue;
      }

      evidence.putIfAbsent(
        sticker,
            () => FunkoStickerEvidence(
          sticker: sticker,
          confidence: 1.0,
          source:
          FunkoStickerEvidenceSource.rule,
          rawValue: phrase.text,
          normalizedValue:
          phrase.normalizedText,
        ),
      );
    }

    return analysis.copyWith(
      stickerResult:
      FunkoStickerDetectionResult(
        evidence:
        List<FunkoStickerEvidence>.unmodifiable(
          evidence.values,
        ),
      ),
    );
  }
}