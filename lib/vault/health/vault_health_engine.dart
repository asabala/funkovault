import '../../models/pop.dart';
import '../duplicate_review/duplicate_review_engine.dart';

class VaultHealthEngine {
  const VaultHealthEngine();

  static const DuplicateReviewEngine _duplicateReviewEngine =
  DuplicateReviewEngine();

  VaultHealthSnapshot calculate(List<Pop> pops) {
    final totalPops = pops.length;

    final totalValue = pops.fold<double>(
      0,
          (total, pop) => total + pop.value,
    );

    final needsValueCount = pops
        .where(
          (pop) => pop.value <= 0,
    )
        .length;

    final duplicateGroupCount =
    _duplicateReviewEngine.countGroups(pops);

    final healthScore = _calculateHealthScore(
      totalPops: totalPops,
      duplicateGroupCount: duplicateGroupCount,
      needsValueCount: needsValueCount,
    );

    final priority = _calculatePriority(
      needsValueCount: needsValueCount,
      duplicateGroupCount: duplicateGroupCount,
      healthScore: healthScore,
    );

    return VaultHealthSnapshot(
      totalPops: totalPops,
      totalValue: totalValue,
      needsValueCount: needsValueCount,
      duplicateGroupCount: duplicateGroupCount,
      healthScore: healthScore,
      priority: priority,
    );
  }

  double _calculateHealthScore({
    required int totalPops,
    required int duplicateGroupCount,
    required int needsValueCount,
  }) {
    if (totalPops == 0) {
      return 100;
    }

    final issueCount =
        duplicateGroupCount + needsValueCount;

    final score =
        100 - ((issueCount / totalPops) * 100);

    return score.clamp(0, 100);
  }

  String _calculatePriority({
    required int needsValueCount,
    required int duplicateGroupCount,
    required double healthScore,
  }) {
    final issueCount =
        needsValueCount + duplicateGroupCount;

    if (issueCount == 0 && healthScore >= 95) {
      return 'Clean';
    }

    if (healthScore >= 85 && issueCount <= 10) {
      return 'Low';
    }

    if (healthScore >= 65) {
      return 'Medium';
    }

    return 'High';
  }
}

class VaultHealthSnapshot {
  const VaultHealthSnapshot({
    required this.totalPops,
    required this.totalValue,
    required this.needsValueCount,
    required this.duplicateGroupCount,
    required this.healthScore,
    required this.priority,
  });

  final int totalPops;
  final double totalValue;
  final int needsValueCount;
  final int duplicateGroupCount;
  final double healthScore;
  final String priority;

  int get issueCount =>
      needsValueCount + duplicateGroupCount;

  bool get isClean =>
      issueCount == 0 && healthScore >= 95;
}