enum AtlasAuthenticitySignalLevel { support, caution, warning, unknown }

final class AtlasAuthenticitySignal {
  const AtlasAuthenticitySignal({
    required this.id,
    required this.title,
    required this.message,
    required this.level,
    required this.weight,
  });

  final String id;
  final String title;
  final String message;
  final AtlasAuthenticitySignalLevel level;
  final int weight;

  bool get isWarning => level == AtlasAuthenticitySignalLevel.warning;
}
