class AcademyCategory {
  const AcademyCategory({
    required this.id,
    required this.trackId,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.lessonIds,
  });

  final String id;
  final String trackId;
  final String title;
  final String subtitle;
  final String icon;
  final List<String> lessonIds;
}
