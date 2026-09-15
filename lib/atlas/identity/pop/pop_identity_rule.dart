enum PopIdentityScope {
  variant,
  retailExclusive,
  eventSticker,
  limitedEdition,
  signature,
  collectorLabel,
}

class PopIdentityRule {
  const PopIdentityRule({
    required this.id,
    required this.emoji,
    required this.label,
    required this.keywords,
    required this.targetScopes,
  });

  final String id;
  final String emoji;
  final String label;
  final List<String> keywords;
  final Set<PopIdentityScope> targetScopes;

  bool matches(String text) {
    final String normalizedText = _normalizeText(text);

    if (normalizedText.isEmpty) {
      return false;
    }

    return keywords.any((String keyword) {
      final String normalizedKeyword = _normalizeText(keyword);

      if (normalizedKeyword.isEmpty) {
        return false;
      }

      return normalizedText.contains(normalizedKeyword);
    });
  }

  bool targets(PopIdentityScope scope) {
    return targetScopes.contains(scope);
  }

  static String _normalizeText(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[-_]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}

class PopIdentityBadgeData {
  const PopIdentityBadgeData({
    required this.id,
    required this.emoji,
    required this.label,
  });

  final String id;
  final String emoji;
  final String label;

  String get displayLabel {
    return '$emoji $label';
  }
}
