import 'dart:collection';

import 'atlas_identity_phrase.dart';
import 'atlas_identity_token.dart';

// Builds multi-word phrases from normalized identity tokens.
//
// This tokenizer produces both single-word and multi-word phrases so
// downstream intelligence engines (retailer, variant, sticker,
// convention, etc.) can recognize collector terminology without
// rebuilding phrases themselves.
final class AtlasIdentityPhraseTokenizer {
  const AtlasIdentityPhraseTokenizer({this.maxPhraseLength = 4});

  final int maxPhraseLength;

  List<AtlasIdentityPhrase> tokenize(List<AtlasIdentityToken> tokens) {
    if (tokens.isEmpty) {
      return const <AtlasIdentityPhrase>[];
    }

    final LinkedHashMap<String, AtlasIdentityPhrase> phrases =
        LinkedHashMap<String, AtlasIdentityPhrase>();

    for (int start = 0; start < tokens.length; start++) {
      for (
        int length = 1;
        length <= maxPhraseLength && start + length <= tokens.length;
        length++
      ) {
        final List<AtlasIdentityToken> slice = tokens.sublist(
          start,
          start + length,
        );

        final String text = slice.map((token) => token.text).join(' ');

        final String normalized = slice
            .map((token) => token.normalizedText)
            .join(' ');

        phrases.putIfAbsent(
          normalized,
          () => AtlasIdentityPhrase(
            text: text,
            normalizedText: normalized,
            tokens: List<AtlasIdentityToken>.unmodifiable(slice),
          ),
        );
      }
    }

    return List<AtlasIdentityPhrase>.unmodifiable(phrases.values);
  }
}
