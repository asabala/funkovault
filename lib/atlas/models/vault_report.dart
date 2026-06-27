class VaultReport {
  const VaultReport({
    required this.totalPops,
    required this.totalCollections,
    required this.duplicateCount,
    required this.missingValueCount,
    required this.missingPurchaseDateCount,
    required this.collectionHealthScore,
    required this.largestCollectionName,
    required this.largestCollectionCount,
    required this.reportTitle,
    required this.reportMessage,
  });

  final int totalPops;
  final int totalCollections;
  final int duplicateCount;
  final int missingValueCount;
  final int missingPurchaseDateCount;
  final double collectionHealthScore;
  final String largestCollectionName;
  final int largestCollectionCount;
  final String reportTitle;
  final String reportMessage;

  bool get hasDuplicates => duplicateCount > 0;

  bool get hasMissingValues => missingValueCount > 0;

  bool get hasMissingPurchaseDates =>
      missingPurchaseDateCount > 0;

  bool get hasLargestCollection =>
      largestCollectionName.trim().isNotEmpty &&
          largestCollectionCount > 0;

  String get healthLabel {
    if (collectionHealthScore >= 95) {
      return 'Excellent';
    }

    if (collectionHealthScore >= 85) {
      return 'Strong';
    }

    if (collectionHealthScore >= 70) {
      return 'Good';
    }

    if (collectionHealthScore >= 50) {
      return 'Needs Attention';
    }

    return 'Needs Work';
  }

  String get formattedHealthScore {
    return '${collectionHealthScore.toStringAsFixed(0)}%';
  }

  factory VaultReport.empty() {
    return const VaultReport(
      totalPops: 0,
      totalCollections: 0,
      duplicateCount: 0,
      missingValueCount: 0,
      missingPurchaseDateCount: 0,
      collectionHealthScore: 100,
      largestCollectionName: '',
      largestCollectionCount: 0,
      reportTitle: 'Vault Ready',
      reportMessage:
      'Your Vault is ready. Start adding Pops to unlock Atlas intelligence.',
    );
  }
}