class AtlasAchievement {
  const AtlasAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
  });

  final String id;
  final String title;
  final String description;
  final String icon;
  final bool unlocked;
}