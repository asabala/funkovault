// Atlas Knowledge
//
// Atlas doesn't just store information.
//
// Atlas understands relationships.
//
// Everything eventually becomes connected.
//
// Batman
//     ↓
// DC
//     ↓
// Justice League
//     ↓
// Gotham
//     ↓
// Joker
//     ↓
// Harley Quinn
//
// Atlas can then answer questions naturally.

class AtlasKnowledge {
  // Unique identifier
  final String id;

  // Display name
  final String name;

  // Type of knowledge
  //
  // Character
  // Franchise
  // Series
  // Retailer
  // Movie
  // Game
  // Collection
  final String type;

  // Connected knowledge
  final List<String> related;

  // Optional metadata
  final Map<String, dynamic> metadata;

  const AtlasKnowledge({
    required this.id,
    required this.name,
    required this.type,
    this.related = const [],
    this.metadata = const {},
  });

  AtlasKnowledge copyWith({
    String? id,
    String? name,
    String? type,
    List<String>? related,
    Map<String, dynamic>? metadata,
  }) {
    return AtlasKnowledge(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      related: related ?? this.related,
      metadata: metadata ?? this.metadata,
    );
  }
}