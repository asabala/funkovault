import '../models/vault_report.dart';

class VaultIntelligence {
  const VaultIntelligence();

  VaultReport generatePlaceholderReport() {
    return const VaultReport(
      totalPops: 0,
      totalCollections: 0,
      duplicateCount: 0,
      missingValueCount: 0,
      missingPurchaseDateCount: 0,
      collectionHealthScore: 100,
      largestCollectionName: '',
      largestCollectionCount: 0,
      reportTitle: 'Vault Intelligence Online',
      reportMessage:
      'Atlas is ready to analyze your collection once collection data is connected.',
    );
  }

  VaultReport generateReport({
    required int totalPops,
    required int totalCollections,
    required int duplicateCount,
    required int missingValueCount,
    required int missingPurchaseDateCount,
    required String largestCollectionName,
    required int largestCollectionCount,
  }) {
    final healthScore = _calculateHealthScore(
      totalPops: totalPops,
      duplicateCount: duplicateCount,
      missingValueCount: missingValueCount,
      missingPurchaseDateCount: missingPurchaseDateCount,
    );

    return VaultReport(
      totalPops: totalPops,
      totalCollections: totalCollections,
      duplicateCount: duplicateCount,
      missingValueCount: missingValueCount,
      missingPurchaseDateCount: missingPurchaseDateCount,
      collectionHealthScore: healthScore,
      largestCollectionName: largestCollectionName,
      largestCollectionCount: largestCollectionCount,
      reportTitle: _buildReportTitle(
        totalPops: totalPops,
        duplicateCount: duplicateCount,
        missingValueCount: missingValueCount,
        missingPurchaseDateCount: missingPurchaseDateCount,
      ),
      reportMessage: _buildReportMessage(
        totalPops: totalPops,
        duplicateCount: duplicateCount,
        missingValueCount: missingValueCount,
        missingPurchaseDateCount: missingPurchaseDateCount,
        largestCollectionName: largestCollectionName,
        largestCollectionCount: largestCollectionCount,
      ),
    );
  }

  double _calculateHealthScore({
    required int totalPops,
    required int duplicateCount,
    required int missingValueCount,
    required int missingPurchaseDateCount,
  }) {
    if (totalPops == 0) {
      return 100;
    }

    final issueCount =
        duplicateCount + missingValueCount + missingPurchaseDateCount;

    final score =
        100 - ((issueCount / totalPops) * 100);

    return score.clamp(0, 100);
  }

  String _buildReportTitle({
    required int totalPops,
    required int duplicateCount,
    required int missingValueCount,
    required int missingPurchaseDateCount,
  }) {
    if (totalPops == 0) {
      return 'Vault Ready';
    }

    if (duplicateCount > 0) {
      return 'Duplicates Found';
    }

    if (missingValueCount > 0 ||
        missingPurchaseDateCount > 0) {
      return 'Vault Needs Review';
    }

    return 'Vault Looks Strong';
  }

  String _buildReportMessage({
    required int totalPops,
    required int duplicateCount,
    required int missingValueCount,
    required int missingPurchaseDateCount,
    required String largestCollectionName,
    required int largestCollectionCount,
  }) {
    if (totalPops == 0) {
      return 'Start adding Pops to unlock Vault Intelligence.';
    }

    if (duplicateCount > 0) {
      return 'Atlas found $duplicateCount possible duplicate Pops in your Vault.';
    }

    if (missingValueCount > 0) {
      return '$missingValueCount Pops are missing values. Updating them will improve your Vault Health.';
    }

    if (missingPurchaseDateCount > 0) {
      return '$missingPurchaseDateCount Pops are missing purchase dates.';
    }

    if (largestCollectionName.trim().isNotEmpty &&
        largestCollectionCount > 0) {
      return '$largestCollectionName is currently your largest collection with $largestCollectionCount Pops.';
    }

    return 'Your Vault is organized and ready.';
  }
}