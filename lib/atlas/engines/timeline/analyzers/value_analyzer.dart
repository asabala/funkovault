import '../../../market/models/value_history_entry.dart';
import '../models/value_analysis.dart';

class ValueAnalyzer {
  const ValueAnalyzer();

  ValueAnalysis analyze({
    required double currentValue,
    required List<ValueHistoryEntry> valueHistory,
  }) {
    final validEntries =
        valueHistory
            .where(
              (entry) =>
                  entry.value > 0 &&
                  entry.recordedAt.millisecondsSinceEpoch > 0,
            )
            .toList(growable: false)
          ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

    if (validEntries.isEmpty) {
      return ValueAnalysis(
        currentValue: currentValue > 0 ? currentValue : 0,
        firstValue: 0,
        latestValue: currentValue > 0 ? currentValue : 0,
        highestValue: currentValue > 0 ? currentValue : 0,
        lowestValue: currentValue > 0 ? currentValue : 0,
        totalChange: 0,
        percentageChange: 0,
        largestIncrease: 0,
        largestDecrease: 0,
        valueEventCount: 0,
        firstRecordedAt: null,
        latestRecordedAt: null,
        hasIncreased: false,
        hasDecreased: false,
      );
    }

    final firstEntry = validEntries.first;
    final latestEntry = validEntries.last;

    var highestValue = firstEntry.value;
    var lowestValue = firstEntry.value;
    var largestIncrease = 0.0;
    var largestDecrease = 0.0;

    for (var index = 0; index < validEntries.length; index++) {
      final entry = validEntries[index];

      if (entry.value > highestValue) {
        highestValue = entry.value;
      }

      if (entry.value < lowestValue) {
        lowestValue = entry.value;
      }

      if (index == 0) {
        continue;
      }

      final previousEntry = validEntries[index - 1];
      final change = entry.value - previousEntry.value;

      if (change > largestIncrease) {
        largestIncrease = change;
      }

      if (change < 0) {
        final decreaseMagnitude = change.abs();

        if (decreaseMagnitude > largestDecrease) {
          largestDecrease = decreaseMagnitude;
        }
      }
    }

    final totalChange = latestEntry.value - firstEntry.value;

    final percentageChange = firstEntry.value > 0
        ? (totalChange / firstEntry.value) * 100
        : 0.0;

    return ValueAnalysis(
      currentValue: currentValue > 0 ? currentValue : latestEntry.value,
      firstValue: firstEntry.value,
      latestValue: latestEntry.value,
      highestValue: highestValue,
      lowestValue: lowestValue,
      totalChange: totalChange,
      percentageChange: percentageChange,
      largestIncrease: largestIncrease,
      largestDecrease: largestDecrease,
      valueEventCount: validEntries.length,
      firstRecordedAt: firstEntry.recordedAt,
      latestRecordedAt: latestEntry.recordedAt,
      hasIncreased: totalChange > 0,
      hasDecreased: totalChange < 0,
    );
  }
}
