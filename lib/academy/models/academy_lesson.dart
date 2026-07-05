class AcademyLesson {
  const AcademyLesson({
    required this.id,
    required this.track,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.readingTimeMinutes,
    required this.difficulty,
    required this.quickAnswer,
    required this.deepAnswer,
    required this.analogy,
    required this.collectorWarning,
    required this.sections,
    required this.atlasTips,
    required this.searchKeywords,
    required this.relatedLessonIds,
  });

  final String id;
  final String track;
  final String category;
  final String title;
  final String subtitle;
  final int readingTimeMinutes;
  final String difficulty;

  /// Short answer Atlas can use when a collector asks:
  /// "What is this?"
  final String quickAnswer;

  /// More detailed answer Atlas can use for deeper explanations.
  final String deepAnswer;

  /// Simple comparison that helps newer collectors understand the idea.
  final String analogy;

  /// Helpful warning or reminder for collectors.
  final String collectorWarning;

  /// Sections used by the full Academy lesson screen.
  final List<AcademyLessonSection> sections;

  /// Short Atlas tips shown inside lessons or explanations.
  final List<String> atlasTips;

  /// Words Atlas can use later for search and question matching.
  final List<String> searchKeywords;

  /// Related lessons Atlas can recommend after this lesson.
  final List<String> relatedLessonIds;
}

class AcademyLessonSection {
  const AcademyLessonSection({
    required this.heading,
    required this.body,
  });

  final String heading;
  final String body;
}