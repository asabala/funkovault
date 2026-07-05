import '../../services/app_state.dart';
import '../engines/atlas_achievement_engine.dart';
import '../engines/atlas_collector_dna_engine.dart';
import '../engines/atlas_collector_score_engine.dart';
import '../engines/atlas_confidence_engine.dart';
import '../engines/atlas_memory_engine.dart';
import 'atlas_dashboard_model.dart';

class AtlasDashboard {
  const AtlasDashboard();

  AtlasDashboardModel build(AppState appState) {
    final pops = appState.selectedCollectionPops;

    final totalPops = pops.length;

    final totalValue = pops.fold<double>(
      0,
          (sum, pop) => sum + pop.value,
    );

    final uniqueCategories = pops
        .map((pop) => pop.category.trim())
        .where((category) => category.isNotEmpty)
        .toSet()
        .length;

    final grailCount =
        pops.where((pop) => pop.value >= 100).length;

    final wishlistCount =
        pops.where((pop) => pop.isWishlist).length;

    final missingValueCount =
        pops.where((pop) => pop.value <= 0).length;

    final duplicates = <String, int>{};

    for (final pop in pops) {
      duplicates[pop.collectorIdentity] =
          (duplicates[pop.collectorIdentity] ?? 0) + 1;
    }

    final duplicateGroupCount =
        duplicates.values.where((count) => count > 1).length;

    final double vaultHealth = totalPops == 0
        ? 100.0
        : (100.0 -
        (((duplicateGroupCount + missingValueCount) / totalPops) * 100))
        .clamp(0.0, 100.0)
        .toDouble();

    const scoreEngine = AtlasCollectorScoreEngine();
    const dnaEngine = AtlasCollectorDNAEngine();
    const confidenceEngine = AtlasConfidenceEngine();
    const achievementEngine = AtlasAchievementEngine();
    const memoryEngine = AtlasMemoryEngine();

    return AtlasDashboardModel(
      pops: pops,
      totalPops: totalPops,
      totalValue: totalValue,
      uniqueCategories: uniqueCategories,
      grailCount: grailCount,
      wishlistCount: wishlistCount,
      missingValueCount: missingValueCount,
      duplicateGroupCount: duplicateGroupCount,
      vaultHealth: vaultHealth,
      score: scoreEngine.calculate(
        totalPops: totalPops,
        collectionValue: totalValue,
        uniqueCategories: uniqueCategories,
      ),
      dna: dnaEngine.analyze(pops),
      confidence: confidenceEngine.calculate(pops),
      achievements: achievementEngine.evaluate(pops),
      memory: memoryEngine.remember(
        pops: pops,
      ),
    );
  }
}