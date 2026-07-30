class PopIdentityRule {
  const PopIdentityRule({
    required this.id,
    required this.emoji,
    required this.label,
    required this.keywords,
  });

  final String id;
  final String emoji;
  final String label;
  final List<String> keywords;

  bool matches(String text) {
    final normalizedText = text.trim().toLowerCase();

    if (normalizedText.isEmpty) {
      return false;
    }

    return keywords.any(
          (keyword) => normalizedText.contains(keyword.toLowerCase()),
    );
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

  String get displayLabel => '$emoji $label';
}