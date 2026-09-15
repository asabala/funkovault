// Describes the workflow Atlas should start after identifying an item.
enum ScanIntent {
  addToVault,
  identifyProduct,
  catalogSubmission,
  marketplaceListing,
  verifyOwnership,
  search,
}

// Presentation helpers for scan-driven workflows.
extension ScanIntentX on ScanIntent {
  String get label {
    switch (this) {
      case ScanIntent.addToVault:
        return 'Add to Vault';
      case ScanIntent.identifyProduct:
        return 'Identify Product';
      case ScanIntent.catalogSubmission:
        return 'Catalog Submission';
      case ScanIntent.marketplaceListing:
        return 'Marketplace Listing';
      case ScanIntent.verifyOwnership:
        return 'Verify Ownership';
      case ScanIntent.search:
        return 'Search';
    }
  }

  bool get canCreateCatalogSubmission {
    return this == ScanIntent.catalogSubmission ||
        this == ScanIntent.addToVault;
  }

  bool get requiresResolvedProduct {
    return this == ScanIntent.addToVault ||
        this == ScanIntent.marketplaceListing ||
        this == ScanIntent.verifyOwnership;
  }
}
