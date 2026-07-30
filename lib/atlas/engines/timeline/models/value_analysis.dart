class ValueAnalysis {
  const ValueAnalysis({
    required this.currentValue,
    required this.firstValue,
    required this.latestValue,
    required this.highestValue,
    required this.lowestValue,
    required this.totalChange,
    required this.percentageChange,
    required this.largestIncrease,
    required this.largestDecrease,
    required this.valueEventCount,
    required this.firstRecordedAt,
    required this.latestRecordedAt,
    required this.hasIncreased,
    required this.hasDecreased,
  });

  /// Current estimated market value of the collectible.
  final double currentValue;

  /// First valid value recorded in the value history.
  final double firstValue;

  /// Most recent valid value recorded in the value history.
  final double latestValue;

  /// Highest valid value recorded.
  final double highestValue;

  /// Lowest valid value recorded.
  final double lowestValue;

  /// Difference between the first and latest recorded values.
  ///
  /// A positive number represents growth.
  /// A negative number represents a decline.
  final double totalChange;

  /// Percentage difference between the first and latest values.
  ///
  /// Example:
  ///
  /// First value: $20.00
  /// Latest value: $30.00
  /// Percentage change: 50.0
  final double percentageChange;

  /// Largest increase between two consecutive value records.
  final double largestIncrease;

  /// Largest decrease between two consecutive value records.
  ///
  /// Stored as a positive magnitude.
  ///
  /// Example:
  ///
  /// $40.00 to $30.00 produces a largest decrease of $10.00.
  final double largestDecrease;

  /// Number of valid value history records analyzed.
  final int valueEventCount;

  /// Date of the first valid value record.
  final DateTime? firstRecordedAt;

  /// Date of the latest valid value record.
  final DateTime? latestRecordedAt;

  /// True when the latest value is greater than the first value.
  final bool hasIncreased;

  /// True when the latest value is lower than the first value.
  final bool hasDecreased;

  bool get hasValue => currentValue > 0;

  bool get hasValueHistory => valueEventCount > 0;

  bool get hasMultipleValueRecords => valueEventCount > 1;

  bool get isUnchanged =>
      hasValueHistory &&
          !hasIncreased &&
          !hasDecreased;

  bool get hasPositiveGrowth => totalChange > 0;

  bool get hasNegativeGrowth => totalChange < 0;

  bool get hasLargestIncrease => largestIncrease > 0;

  bool get hasLargestDecrease => largestDecrease > 0;

  String get directionLabel {
    if (!hasValueHistory) {
      return 'No Value History';
    }

    if (hasIncreased) {
      return 'Increased';
    }

    if (hasDecreased) {
      return 'Decreased';
    }

    return 'Unchanged';
  }

  ValueAnalysis copyWith({
    double? currentValue,
    double? firstValue,
    double? latestValue,
    double? highestValue,
    double? lowestValue,
    double? totalChange,
    double? percentageChange,
    double? largestIncrease,
    double? largestDecrease,
    int? valueEventCount,
    DateTime? firstRecordedAt,
    bool clearFirstRecordedAt = false,
    DateTime? latestRecordedAt,
    bool clearLatestRecordedAt = false,
    bool? hasIncreased,
    bool? hasDecreased,
  }) {
    return ValueAnalysis(
      currentValue: currentValue ?? this.currentValue,
      firstValue: firstValue ?? this.firstValue,
      latestValue: latestValue ?? this.latestValue,
      highestValue: highestValue ?? this.highestValue,
      lowestValue: lowestValue ?? this.lowestValue,
      totalChange: totalChange ?? this.totalChange,
      percentageChange:
      percentageChange ?? this.percentageChange,
      largestIncrease:
      largestIncrease ?? this.largestIncrease,
      largestDecrease:
      largestDecrease ?? this.largestDecrease,
      valueEventCount:
      valueEventCount ?? this.valueEventCount,
      firstRecordedAt: clearFirstRecordedAt
          ? null
          : firstRecordedAt ?? this.firstRecordedAt,
      latestRecordedAt: clearLatestRecordedAt
          ? null
          : latestRecordedAt ?? this.latestRecordedAt,
      hasIncreased: hasIncreased ?? this.hasIncreased,
      hasDecreased: hasDecreased ?? this.hasDecreased,
    );
  }

  @override
  String toString() {
    return 'ValueAnalysis('
        'currentValue: $currentValue, '
        'firstValue: $firstValue, '
        'latestValue: $latestValue, '
        'highestValue: $highestValue, '
        'lowestValue: $lowestValue, '
        'totalChange: $totalChange, '
        'percentageChange: $percentageChange, '
        'largestIncrease: $largestIncrease, '
        'largestDecrease: $largestDecrease, '
        'valueEventCount: $valueEventCount, '
        'firstRecordedAt: $firstRecordedAt, '
        'latestRecordedAt: $latestRecordedAt, '
        'hasIncreased: $hasIncreased, '
        'hasDecreased: $hasDecreased'
        ')';
  }
}