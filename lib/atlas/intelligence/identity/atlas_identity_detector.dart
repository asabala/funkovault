import 'atlas_identity_analysis.dart';
import 'atlas_identity_phrase.dart';

// Base contract implemented by all Atlas identity detectors.
//
// Each detector contributes information to an existing analysis object
// rather than creating its own pipeline.
abstract interface class AtlasIdentityDetector {
  const AtlasIdentityDetector();

  AtlasIdentityAnalysis detect({
    required List<AtlasIdentityPhrase> phrases,
    required AtlasIdentityAnalysis analysis,
  });
}
