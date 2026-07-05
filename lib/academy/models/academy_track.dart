class AcademyTrack {
  const AcademyTrack({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.emoji,
    required this.status,
    required this.isAvailable,
    required this.categoryIds,
    required this.searchKeywords,
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String emoji;
  final String status;
  final bool isAvailable;
  final List<String> categoryIds;
  final List<String> searchKeywords;
}