// Represents a normalized token extracted from collector text.
//
// Tokens are produced once and then reused by all intelligence
// detectors (variant, retailer, convention, sticker, etc.).
final class AtlasIdentityToken {
  const AtlasIdentityToken({
    required this.text,
    required this.normalizedText,
    this.startIndex,
    this.endIndex,
  });

  final String text;

  final String normalizedText;

  final int? startIndex;

  final int? endIndex;

  bool get hasLocation {
    return startIndex != null && endIndex != null;
  }

  int? get length {
    if (!hasLocation) {
      return null;
    }

    return endIndex! - startIndex!;
  }

  @override
  String toString() {
    return normalizedText;
  }
}
