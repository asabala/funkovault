import '../event/funko_event_detector.dart';
import '../registry/atlas_registry_bootstrap.dart';
import '../retailer/funko_retailer_detector.dart';
import '../sticker/funko_sticker_detector.dart';
import '../variant/atlas_variant_detector.dart';
import 'atlas_identity_analysis.dart';
import 'atlas_identity_detector.dart';
import 'atlas_identity_lookup.dart';
import 'atlas_identity_phrase_tokenizer.dart';
import 'atlas_identity_tokenizer.dart';

// Coordinates the Atlas identity analysis pipeline.
//
// Raw Text
//   ↓
// Tokenizer
//   ↓
// Phrase Tokenizer
//   ↓
// Registered Detectors
//   ↓
// AtlasIdentityAnalysis
final class AtlasIdentityAnalysisEngine {
  AtlasIdentityAnalysisEngine({
    required AtlasIdentityLookup lookup,
    this.tokenizer = const AtlasIdentityTokenizer(),
    this.phraseTokenizer = const AtlasIdentityPhraseTokenizer(),
    List<AtlasIdentityDetector>? detectors,
  }) : lookup = lookup,
       detectors =
           detectors ??
           <AtlasIdentityDetector>[
             AtlasVariantDetector(lookup: lookup),
             FunkoRetailerDetector(lookup: lookup),
             FunkoStickerDetector(lookup: lookup),
             FunkoEventDetector(lookup: lookup),
           ];

  factory AtlasIdentityAnalysisEngine.create() {
    final registry = const AtlasRegistryBootstrap().build();

    final lookup = AtlasIdentityLookup(registry);

    return AtlasIdentityAnalysisEngine(lookup: lookup);
  }

  final AtlasIdentityLookup lookup;

  final AtlasIdentityTokenizer tokenizer;

  final AtlasIdentityPhraseTokenizer phraseTokenizer;

  final List<AtlasIdentityDetector> detectors;

  AtlasIdentityAnalysis analyze(String? text) {
    final tokens = tokenizer.tokenize(text);

    final phrases = phraseTokenizer.tokenize(tokens);

    AtlasIdentityAnalysis analysis = const AtlasIdentityAnalysis();

    for (final AtlasIdentityDetector detector in detectors) {
      analysis = detector.detect(phrases: phrases, analysis: analysis);
    }

    return analysis;
  }
}
