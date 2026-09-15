enum AtlasScanBriefingPriority { success, information, warning, critical }

class AtlasScanBriefing {
  const AtlasScanBriefing({
    required this.priority,
    required this.title,
    required this.summary,
    required this.highlights,
    required this.recommendation,
  });

  final AtlasScanBriefingPriority priority;

  final String title;

  final String summary;

  final List<String> highlights;

  final String recommendation;

  bool get hasHighlights {
    return highlights.isNotEmpty;
  }
}
