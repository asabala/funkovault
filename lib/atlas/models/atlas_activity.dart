class AtlasActivity {
  const AtlasActivity({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
  });

  final String title;
  final String description;
  final DateTime timestamp;
  final String type;
}