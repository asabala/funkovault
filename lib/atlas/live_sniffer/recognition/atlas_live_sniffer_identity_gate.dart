enum AtlasLiveSnifferIdentityDecision { supported, insufficient, contradicted }

final class AtlasLiveSnifferIdentityEvidence {
  const AtlasLiveSnifferIdentityEvidence({
    required this.identityHits,
    required this.identityCoverage,
    required this.decision,
  });

  final int identityHits;
  final double identityCoverage;
  final AtlasLiveSnifferIdentityDecision decision;

  bool get validated => decision == AtlasLiveSnifferIdentityDecision.supported;
  bool get contradicted =>
      decision == AtlasLiveSnifferIdentityDecision.contradicted;
}

/// Verifies that OCR text from the selected physical Pop actually agrees with
/// the catalog identity that a product number points to.
///
/// Number is intentionally not part of this gate. A number narrows the catalog
/// partition; name / character / franchise text must authorize the identity.
final class AtlasLiveSnifferIdentityGate {
  const AtlasLiveSnifferIdentityGate._();

  static const Set<String> _nonIdentityTokens = <String>{
    // Generic Funko / packaging vocabulary.
    'pop',
    'funko',
    'vinyl',
    'figure',
    'figures',
    'animation',
    'heroes',
    'movies',
    'movie',
    'television',
    'games',
    'game',
    'rocks',
    'exclusive',
    'limited',
    'edition',
    'collectible',
    'collectibles',
    'warning',
    'ages',
    'made',
    'standard',
    'release',
    'special',
    'chase',
    'glow',
    'metallic',
    'flocked',
    'diamond',

    // Common language must never become catalog identity authority.
    'the',
    'and',
    'for',
    'with',
    'from',
    'this',
    'that',
    'these',
    'those',
    'into',
    'onto',
    'over',
    'under',
    'your',
    'you',
    'are',
    'was',
    'were',
    'has',
    'have',
    'his',
    'her',
    'its',
    'our',
    'their',
  };

  static const Set<String> _weakDescriptorTokens = <String>{
    'black',
    'white',
    'red',
    'blue',
    'green',
    'gold',
    'silver',
    'orange',
    'purple',
    'pink',
    'brown',
    'gray',
    'grey',
    'clear',
  };

  static AtlasLiveSnifferIdentityEvidence evaluate({
    required String rawOcr,
    required String displayName,
    String? characterName,
    String? series,
    String? productLine,
    String? variantName,
  }) {
    final Set<String> evidence = _identityTokens(rawOcr);

    final Set<String> displayTokens = _identityTokens(displayName);
    final Set<String> characterTokens = _identityTokens(characterName ?? '');
    final Set<String> seriesTokens = _identityTokens(series ?? '');
    final Set<String> lineTokens = _identityTokens(productLine ?? '');
    final Set<String> variantTokens = _identityTokens(variantName ?? '');

    final Set<String> productTokens = <String>{
      ...displayTokens,
      ...characterTokens,
      ...seriesTokens,
      ...lineTokens,
      ...variantTokens,
    };

    final Set<String> overlap = productTokens.intersection(evidence);
    final Set<String> characterHits = characterTokens.intersection(evidence);
    final Set<String> seriesHits = seriesTokens.intersection(evidence);
    final Set<String> displayHits = displayTokens.intersection(evidence);

    final bool hasDirectCharacterEvidence = characterHits.isNotEmpty;
    final bool hasDirectSeriesEvidence = seriesHits.isNotEmpty;
    final bool hasMultipleIdentityWords = overlap.length >= 2;
    final bool hasDistinctiveDisplayWord = displayHits.any(
      (String token) =>
          token.length >= 5 && !_weakDescriptorTokens.contains(token),
    );

    // One genuine character/franchise token is enough when the catalog exposes
    // that field explicitly. Otherwise require two meaningful title tokens, or
    // one long/distinctive title word (for single-name Pops like Shredder).
    final bool validated =
        hasDirectCharacterEvidence ||
        hasDirectSeriesEvidence ||
        hasMultipleIdentityWords ||
        hasDistinctiveDisplayWord;

    final double coverage = productTokens.isEmpty
        ? 0.0
        : (overlap.length / productTokens.length).clamp(0.0, 1.0).toDouble();

    final AtlasLiveSnifferIdentityDecision decision;
    if (validated) {
      decision = AtlasLiveSnifferIdentityDecision.supported;
    } else if (evidence.isNotEmpty &&
        productTokens.isNotEmpty &&
        overlap.isEmpty) {
      // Foreground identity words exist, but none belong to this catalog
      // candidate. Treat that as a hard contradiction rather than merely weak
      // evidence. Example: WOLVERINE / MARVEL must reject Cleo De Nile.
      decision = AtlasLiveSnifferIdentityDecision.contradicted;
    } else {
      decision = AtlasLiveSnifferIdentityDecision.insufficient;
    }

    return AtlasLiveSnifferIdentityEvidence(
      identityHits: overlap.length,
      identityCoverage: coverage,
      decision: decision,
    );
  }

  static Set<String> _identityTokens(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .split(' ')
        .map((String token) => token.trim())
        .where((String token) {
          if (token.length < 2) return false;
          if (_nonIdentityTokens.contains(token)) return false;
          if (RegExp(r'^\d+$').hasMatch(token)) return false;
          return true;
        })
        .toSet();
  }
}
