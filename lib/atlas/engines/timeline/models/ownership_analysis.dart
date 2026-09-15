class OwnershipAnalysis {
  const OwnershipAnalysis({
    required this.ownedSince,
    required this.daysOwned,
    required this.monthsOwned,
    required this.yearsOwned,
    required this.lastActivityAt,
    required this.isRecentlyAdded,
    required this.isRecentlyUpdated,
    required this.status,
  });

  /// Date the collectible entered the collector's Vault.
  ///
  /// This normally comes from the earliest Added to Vault event.
  final DateTime? ownedSince;

  /// Total completed calendar days the collectible has been owned.
  final int daysOwned;

  /// Approximate number of completed months the collectible has been owned.
  ///
  /// This is intended for display and general intelligence summaries.
  final int monthsOwned;

  /// Approximate number of completed years the collectible has been owned.
  ///
  /// This is intended for display and general intelligence summaries.
  final int yearsOwned;

  /// Date of the most recent meaningful Timeline activity.
  final DateTime? lastActivityAt;

  /// True when the collectible was added recently.
  final bool isRecentlyAdded;

  /// True when the collectible has recent Timeline activity.
  final bool isRecentlyUpdated;

  /// Collector-facing ownership classification.
  ///
  /// Examples:
  /// - New
  /// - Active
  /// - Established
  /// - Long-Term
  /// - Unknown
  final String status;

  bool get hasOwnershipDate => ownedSince != null;

  bool get hasRecentActivity => lastActivityAt != null;

  bool get hasOwnershipHistory => daysOwned > 0 || ownedSince != null;

  String get durationLabel {
    if (!hasOwnershipDate) {
      return 'Ownership date unavailable';
    }

    if (yearsOwned > 0) {
      final yearLabel = yearsOwned == 1 ? 'year' : 'years';
      final remainingMonths = monthsOwned % 12;

      if (remainingMonths == 0) {
        return '$yearsOwned $yearLabel';
      }

      final monthLabel = remainingMonths == 1 ? 'month' : 'months';

      return '$yearsOwned $yearLabel, '
          '$remainingMonths $monthLabel';
    }

    if (monthsOwned > 0) {
      final monthLabel = monthsOwned == 1 ? 'month' : 'months';

      return '$monthsOwned $monthLabel';
    }

    final dayLabel = daysOwned == 1 ? 'day' : 'days';

    return '$daysOwned $dayLabel';
  }

  OwnershipAnalysis copyWith({
    DateTime? ownedSince,
    bool clearOwnedSince = false,
    int? daysOwned,
    int? monthsOwned,
    int? yearsOwned,
    DateTime? lastActivityAt,
    bool clearLastActivityAt = false,
    bool? isRecentlyAdded,
    bool? isRecentlyUpdated,
    String? status,
  }) {
    return OwnershipAnalysis(
      ownedSince: clearOwnedSince ? null : ownedSince ?? this.ownedSince,
      daysOwned: daysOwned ?? this.daysOwned,
      monthsOwned: monthsOwned ?? this.monthsOwned,
      yearsOwned: yearsOwned ?? this.yearsOwned,
      lastActivityAt: clearLastActivityAt
          ? null
          : lastActivityAt ?? this.lastActivityAt,
      isRecentlyAdded: isRecentlyAdded ?? this.isRecentlyAdded,
      isRecentlyUpdated: isRecentlyUpdated ?? this.isRecentlyUpdated,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'OwnershipAnalysis('
        'ownedSince: $ownedSince, '
        'daysOwned: $daysOwned, '
        'monthsOwned: $monthsOwned, '
        'yearsOwned: $yearsOwned, '
        'lastActivityAt: $lastActivityAt, '
        'isRecentlyAdded: $isRecentlyAdded, '
        'isRecentlyUpdated: $isRecentlyUpdated, '
        'status: $status'
        ')';
  }
}
