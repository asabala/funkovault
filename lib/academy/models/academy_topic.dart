class AcademyTopic {
  const AcademyTopic({
    required this.id,
    required this.trackId,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.isAvailable,
    required this.isPremium,
    required this.searchKeywords,
  });

  final String id;
  final String trackId;
  final String title;
  final String subtitle;
  final String category;
  final bool isAvailable;
  final bool isPremium;
  final List<String> searchKeywords;
}