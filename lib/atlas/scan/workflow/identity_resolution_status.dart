// Describes the current state of product identity resolution.
enum IdentityResolutionStatus {
  notStarted,
  resolving,
  resolvedLocal,
  resolvedRemote,
  pendingSync,
  ambiguous,
  unresolved,
  failed,
}

// Helpers for controlling the scan workflow from resolution state.
extension IdentityResolutionStatusX on IdentityResolutionStatus {
  bool get isResolved {
    return this == IdentityResolutionStatus.resolvedLocal ||
        this == IdentityResolutionStatus.resolvedRemote;
  }

  bool get requiresNetwork {
    return this == IdentityResolutionStatus.pendingSync;
  }

  bool get requiresUserReview {
    return this == IdentityResolutionStatus.ambiguous ||
        this == IdentityResolutionStatus.unresolved;
  }

  bool get isTerminal {
    return isResolved ||
        this == IdentityResolutionStatus.pendingSync ||
        this == IdentityResolutionStatus.ambiguous ||
        this == IdentityResolutionStatus.unresolved ||
        this == IdentityResolutionStatus.failed;
  }
}
