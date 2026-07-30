import '../../../timeline/models/atlas_timeline_event.dart';
import '../models/ownership_analysis.dart';

class OwnershipAnalyzer {
  const OwnershipAnalyzer();

  static const int recentAddedWindowDays = 30;
  static const int recentUpdatedWindowDays = 14;

  OwnershipAnalysis analyze({
    required List<AtlasTimelineEvent> timeline,
    DateTime? now,
  }) {
    final analysisTime = now ?? DateTime.now();

    final validEvents = timeline
        .where(
          (event) =>
      event.occurredAt.millisecondsSinceEpoch > 0,
    )
        .toList(growable: false)
      ..sort(
            (a, b) => a.occurredAt.compareTo(b.occurredAt),
      );

    final ownedSince = _findOwnedSince(validEvents);
    final lastActivityAt = validEvents.isEmpty
        ? null
        : validEvents.last.occurredAt;

    final daysOwned = _calculateDaysBetween(
      ownedSince,
      analysisTime,
    );

    final monthsOwned = _calculateCompletedMonths(
      ownedSince,
      analysisTime,
    );

    final yearsOwned = _calculateCompletedYears(
      ownedSince,
      analysisTime,
    );

    final isRecentlyAdded = _isWithinDays(
      ownedSince,
      analysisTime,
      recentAddedWindowDays,
    );

    final isRecentlyUpdated = _isWithinDays(
      lastActivityAt,
      analysisTime,
      recentUpdatedWindowDays,
    );

    return OwnershipAnalysis(
      ownedSince: ownedSince,
      daysOwned: daysOwned,
      monthsOwned: monthsOwned,
      yearsOwned: yearsOwned,
      lastActivityAt: lastActivityAt,
      isRecentlyAdded: isRecentlyAdded,
      isRecentlyUpdated: isRecentlyUpdated,
      status: _buildStatus(
        ownedSince: ownedSince,
        daysOwned: daysOwned,
        isRecentlyAdded: isRecentlyAdded,
        isRecentlyUpdated: isRecentlyUpdated,
      ),
    );
  }

  DateTime? _findOwnedSince(
      List<AtlasTimelineEvent> events,
      ) {
    for (final event in events) {
      if (event.type ==
          AtlasTimelineEventType.addedToVault) {
        return event.occurredAt;
      }
    }

    return events.isEmpty
        ? null
        : events.first.occurredAt;
  }

  int _calculateDaysBetween(
      DateTime? start,
      DateTime end,
      ) {
    if (start == null || start.isAfter(end)) {
      return 0;
    }

    final normalizedStart = DateTime(
      start.year,
      start.month,
      start.day,
    );

    final normalizedEnd = DateTime(
      end.year,
      end.month,
      end.day,
    );

    return normalizedEnd
        .difference(normalizedStart)
        .inDays;
  }

  int _calculateCompletedMonths(
      DateTime? start,
      DateTime end,
      ) {
    if (start == null || start.isAfter(end)) {
      return 0;
    }

    var months =
        (end.year - start.year) * 12 +
            end.month -
            start.month;

    if (end.day < start.day) {
      months--;
    }

    return months < 0 ? 0 : months;
  }

  int _calculateCompletedYears(
      DateTime? start,
      DateTime end,
      ) {
    if (start == null || start.isAfter(end)) {
      return 0;
    }

    var years = end.year - start.year;

    final anniversaryPassed =
        end.month > start.month ||
            (end.month == start.month &&
                end.day >= start.day);

    if (!anniversaryPassed) {
      years--;
    }

    return years < 0 ? 0 : years;
  }

  bool _isWithinDays(
      DateTime? date,
      DateTime now,
      int dayWindow,
      ) {
    if (date == null || date.isAfter(now)) {
      return false;
    }

    return now.difference(date).inDays <= dayWindow;
  }

  String _buildStatus({
    required DateTime? ownedSince,
    required int daysOwned,
    required bool isRecentlyAdded,
    required bool isRecentlyUpdated,
  }) {
    if (ownedSince == null) {
      return 'Unknown';
    }

    if (isRecentlyAdded) {
      return 'New';
    }

    if (daysOwned >= 365 * 3) {
      return 'Long-Term';
    }

    if (daysOwned >= 365) {
      return 'Established';
    }

    if (isRecentlyUpdated) {
      return 'Active';
    }

    return 'Owned';
  }
}