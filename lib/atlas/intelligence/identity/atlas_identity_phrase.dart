import 'atlas_identity_token.dart';

// Represents a recognized phrase composed of one or more identity tokens.
//
// Examples:
//
// "Funko Shop"
// "Entertainment Earth"
// "Glow in the Dark"
// "Special Edition"
final class AtlasIdentityPhrase {
  const AtlasIdentityPhrase({
    required this.text,
    required this.normalizedText,
    required this.tokens,
  });

  final String text;

  final String normalizedText;

  final List<AtlasIdentityToken> tokens;

  bool get isSingleWord => tokens.length == 1;

  bool get isMultiWord => tokens.length > 1;

  int get wordCount => tokens.length;

  @override
  String toString() => text;
}