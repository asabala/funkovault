class AcademyCategory {
  const AcademyCategory({
    required this.id,
    required this.track,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.lessonIds,
  });

  final String id;
  final String track;
  final String title;
  final String subtitle;
  final String icon;
  final List<String> lessonIds;
}