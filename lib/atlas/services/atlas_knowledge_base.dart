import '../models/atlas_knowledge.dart';

// Atlas Knowledge Base
//
// The Atlas Knowledge Base stores relationships.
//
// It does not replace Hive or Supabase.
//
// It is Atlas' understanding of the world.
//
// Atlas should eventually learn from:
//
// • Barcodes
// • Catalog
// • Community
// • AI Vision
// • User Corrections
// • Imports
// • Marketplace Data

class AtlasKnowledgeBase {
  AtlasKnowledgeBase._();

  static final AtlasKnowledgeBase instance =
  AtlasKnowledgeBase._();

  final Map<String, AtlasKnowledge> _knowledge = {};

  int get totalKnowledge =>
      _knowledge.length;

  List<AtlasKnowledge> get allKnowledge =>
      _knowledge.values.toList();

  AtlasKnowledge? getKnowledge(
      String id,
      ) {
    return _knowledge[id];
  }

  void addKnowledge(
      AtlasKnowledge knowledge,
      ) {
    _knowledge[knowledge.id] = knowledge;
  }

  bool contains(
      String id,
      ) {
    return _knowledge.containsKey(id);
  }

  void clear() {
    _knowledge.clear();
  }

  List<AtlasKnowledge> search(
      String query,
      ) {
    final lower =
    query.toLowerCase();

    return _knowledge.values.where((item) {
      return item.name
          .toLowerCase()
          .contains(lower);
    }).toList();
  }
}