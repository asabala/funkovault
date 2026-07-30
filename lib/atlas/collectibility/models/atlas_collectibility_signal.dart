class AtlasCollectibilitySignal {
  const AtlasCollectibilitySignal({
    required this.id,
    required this.label,
    required this.description,
    required this.category,
    required this.points,
  });

  final String id;
  final String label;
  final String description;
  final String category;
  final int points;

  bool get isStrongSignal => points >= 10;
}