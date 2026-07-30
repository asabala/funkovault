import 'package:funkovault2/atlas/market/models/value_history_entry.dart';

class AtlasValueHistorySummary {
  const AtlasValueHistorySummary({
    required this.currentValue,
    required this.previousValue,
    required this.changeAmount,
    required this.changePercent,
    required this.highestValue,
    required this.lowestValue,
    required this.averageValue,
    required this.trend,
    required this.historyCount,
    required this.lastUpdated,
  });

  final double currentValue;
  final double? previousValue;
  final double changeAmount;
  final double changePercent;
  final double highestValue;
  final double lowestValue;
  final double averageValue;
  final AtlasValueTrend trend;
  final int historyCount;
  final DateTime? lastUpdated;

  bool get hasHistory => historyCount > 1;

  bool get hasCurrentValue => currentValue > 0;
}

enum AtlasValueTrend {
  up,
  down,
  unchanged,
  none,
}

class AtlasValueHistoryEngine {
  const AtlasValueHistoryEngine();

  AtlasValueHistorySummary build(
      List<ValueHistoryEntry> history,
      ) {
    if (history.isEmpty) {
      return const AtlasValueHistorySummary(
        currentValue: 0,
        previousValue: null,
        changeAmount: 0,
        changePercent: 0,
        highestValue: 0,
        lowestValue: 0,
        averageValue: 0,
        trend: AtlasValueTrend.none,
        historyCount: 0,
        lastUpdated: null,
      );
    }

    final sorted = [...history]
      ..sort(
            (a, b) => a.recordedAt.compareTo(
          b.recordedAt,
        ),
      );

    final current = sorted.last;

    final previous =
    sorted.length > 1 ? sorted[sorted.length - 2] : null;

    final highest = sorted
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b);

    final lowest = sorted
        .map((e) => e.value)
        .reduce((a, b) => a < b ? a : b);

    final average = sorted
        .map((e) => e.value)
        .reduce((a, b) => a + b) /
        sorted.length;

    double change = 0;
    double percent = 0;
    AtlasValueTrend trend = AtlasValueTrend.none;

    if (previous != null) {
      change = current.value - previous.value;

      if (previous.value > 0) {
        percent =
            (change / previous.value) * 100;
      }

      if (change > 0) {
        trend = AtlasValueTrend.up;
      } else if (change < 0) {
        trend = AtlasValueTrend.down;
      } else {
        trend = AtlasValueTrend.unchanged;
      }
    }

    return AtlasValueHistorySummary(
      currentValue: current.value,
      previousValue: previous?.value,
      changeAmount: change,
      changePercent: percent,
      highestValue: highest,
      lowestValue: lowest,
      averageValue: average,
      trend: trend,
      historyCount: sorted.length,
      lastUpdated: current.recordedAt,
    );
  }
}