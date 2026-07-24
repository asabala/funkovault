import '../../models/pop.dart';

import '../engines/collection/atlas_collector_dna_engine.dart';
import '../engines/collection/atlas_collector_score_engine.dart';
import '../engines/intelligence/atlas_confidence_engine.dart';
import '../engines/intelligence/atlas_memory_engine.dart';
import '../models/atlas_achievement.dart';

class AtlasDashboardModel {
  const AtlasDashboardModel({
    required this.pops,
    required this.totalPops,
    required this.totalValue,
    required this.uniqueCategories,
    required this.grailCount,
    required this.wishlistCount,
    required this.missingValueCount,
    required this.duplicateGroupCount,
    required this.vaultHealth,
    required this.score,
    required this.dna,
    required this.confidence,
    required this.achievements,
    required this.memory,
  });

  final List<Pop> pops;

  final int totalPops;
  final double totalValue;
  final int uniqueCategories;
  final int grailCount;
  final int wishlistCount;
  final int missingValueCount;
  final int duplicateGroupCount;
  final double vaultHealth;

  final AtlasCollectorScoreResult score;
  final AtlasCollectorDNA dna;
  final AtlasConfidenceResult confidence;
  final List<AtlasAchievement> achievements;
  final AtlasMemory memory;
}