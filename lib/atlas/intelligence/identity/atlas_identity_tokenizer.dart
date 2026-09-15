import 'atlas_identity_token.dart';

// Splits collector text into normalized identity tokens.
//
// This tokenizer is shared by every Atlas intelligence detector so text
// normalization occurs exactly once.
final class AtlasIdentityTokenizer {
  const AtlasIdentityTokenizer();

  List<AtlasIdentityToken> tokenize(String? text) {
    if (text == null || text.trim().isEmpty) {
      return const <AtlasIdentityToken>[];
    }

    final List<AtlasIdentityToken> tokens = <AtlasIdentityToken>[];

    final RegExp expression = RegExp(r"[A-Za-z0-9#&'-]+");

    for (final Match match in expression.allMatches(text)) {
      final String raw = match.group(0)!;

      tokens.add(
        AtlasIdentityToken(
          text: raw,
          normalizedText: _normalize(raw),
          startIndex: match.start,
          endIndex: match.end,
        ),
      );
    }

    return List<AtlasIdentityToken>.unmodifiable(tokens);
  }

  String normalize(String? value) {
    return _normalize(value);
  }

  static String _normalize(String? value) {
    return value
            ?.trim()
            .toLowerCase()
            .replaceAll('&', ' and ')
            .replaceAll('_', ' ')
            .replaceAll(RegExp(r'[^a-z0-9#\s-]'), '')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim() ??
        '';
  }
}
