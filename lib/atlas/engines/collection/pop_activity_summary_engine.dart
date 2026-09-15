import '../../../atlas/timeline/models/atlas_timeline_event.dart';
import '../../../models/activity.dart';

class PopActivitySummary {
  const PopActivitySummary({
    required this.title,
    required this.summary,
    required this.activityCount,
    required this.latestActivity,
    this.timelineEventCount = 0,
    this.legacyActivityCount = 0,
  });

  final String title;
  final String summary;
  final int activityCount;
  final DateTime? latestActivity;

  /// Number of events read from the collectible Timeline.
  final int timelineEventCount;

  /// Number of legacy Activity records included in the summary.
  final int legacyActivityCount;

  bool get hasActivity => activityCount > 0;

  bool get hasTimelineEvents => timelineEventCount > 0;

  bool get hasLegacyActivities => legacyActivityCount > 0;
}

class PopActivitySummaryEngine {
  const PopActivitySummaryEngine();

  PopActivitySummary build({
    required String popId,
    required String popName,
    required String popNumber,
    required List<Activity> activities,
    List<AtlasTimelineEvent> timeline = const <AtlasTimelineEvent>[],
  }) {
    final matchingActivities =
        activities
            .where(
              (activity) => _matchesPop(
                activity: activity,
                popId: popId,
                popName: popName,
                popNumber: popNumber,
              ),
            )
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final matchingTimeline = timeline.where((event) {
      final eventPopId = event.popId.trim();
      final cleanPopId = popId.trim();

      if (eventPopId.isEmpty || cleanPopId.isEmpty) {
        return true;
      }

      return eventPopId == cleanPopId;
    }).toList()..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));

    if (matchingActivities.isEmpty && matchingTimeline.isEmpty) {
      return const PopActivitySummary(
        title: 'No History Yet',
        summary: 'Atlas has not recorded any changes for this collectible yet.',
        activityCount: 0,
        latestActivity: null,
      );
    }

    final summaryParts = <String>[];

    final timelineValueUpdates = matchingTimeline
        .where((event) => event.type == AtlasTimelineEventType.valueUpdated)
        .length;

    final legacyValueUpdates = matchingActivities
        .where((activity) => activity.action == 'value_updated')
        .length;

    // Timeline is authoritative for value updates whenever
    // Timeline value events exist. This prevents double counting
    // the same update in both history systems.
    final valueUpdates = timelineValueUpdates > 0
        ? timelineValueUpdates
        : legacyValueUpdates;

    final quantityUpdates = matchingActivities
        .where(
          (activity) =>
              activity.action == 'quantity_updated' ||
              activity.action == 'quantity_increased',
        )
        .length;

    final movedToWishlist = matchingActivities.any(
      (activity) => activity.action == 'wishlist_added',
    );

    final movedToOwned = matchingActivities.any(
      (activity) => activity.action == 'wishlist_removed',
    );

    final detailUpdates = matchingActivities
        .where((activity) => activity.action == 'pop_updated')
        .length;

    final addedToVaultEvents = matchingTimeline
        .where((event) => event.type == AtlasTimelineEventType.addedToVault)
        .length;

    final collectorMoments = matchingTimeline
        .where((event) => event.type == AtlasTimelineEventType.collectorMoment)
        .length;

    final atlasInsights = matchingTimeline
        .where((event) => event.type == AtlasTimelineEventType.aiInsight)
        .length;

    if (addedToVaultEvents > 0) {
      summaryParts.add(
        'Atlas has recorded when this collectible entered your Vault.',
      );
    }

    if (valueUpdates == 1) {
      summaryParts.add('The estimated value was updated once.');
    } else if (valueUpdates > 1) {
      summaryParts.add('The estimated value was updated $valueUpdates times.');
    }

    if (quantityUpdates == 1) {
      summaryParts.add('The quantity was adjusted once.');
    } else if (quantityUpdates > 1) {
      summaryParts.add('The quantity was adjusted $quantityUpdates times.');
    }

    if (movedToWishlist && movedToOwned) {
      summaryParts.add('It moved between the wishlist and owned collection.');
    } else if (movedToWishlist) {
      summaryParts.add('It was moved to the wishlist.');
    } else if (movedToOwned) {
      summaryParts.add('It was moved to the owned collection.');
    }

    if (detailUpdates == 1) {
      summaryParts.add('Collector details were updated once.');
    } else if (detailUpdates > 1) {
      summaryParts.add('Collector details were updated $detailUpdates times.');
    }

    if (collectorMoments == 1) {
      summaryParts.add('One collector moment is part of its history.');
    } else if (collectorMoments > 1) {
      summaryParts.add(
        '$collectorMoments collector moments are part of its history.',
      );
    }

    if (atlasInsights == 1) {
      summaryParts.add('Atlas has generated one intelligence insight.');
    } else if (atlasInsights > 1) {
      summaryParts.add(
        'Atlas has generated $atlasInsights intelligence insights.',
      );
    }

    final includedLegacyActivities = matchingActivities.where((activity) {
      if (activity.action == 'value_updated' && timelineValueUpdates > 0) {
        return false;
      }

      return true;
    }).toList();

    final totalHistoryEvents =
        matchingTimeline.length + includedLegacyActivities.length;

    if (summaryParts.isEmpty) {
      summaryParts.add(
        'Atlas recorded $totalHistoryEvents '
        '${totalHistoryEvents == 1 ? 'event' : 'events'} '
        'for this collectible.',
      );
    }

    return PopActivitySummary(
      title: 'Atlas History Summary',
      summary: summaryParts.join(' '),
      activityCount: totalHistoryEvents,
      latestActivity: _latestActivity(
        timeline: matchingTimeline,
        activities: includedLegacyActivities,
      ),
      timelineEventCount: matchingTimeline.length,
      legacyActivityCount: includedLegacyActivities.length,
    );
  }

  DateTime? _latestActivity({
    required List<AtlasTimelineEvent> timeline,
    required List<Activity> activities,
  }) {
    DateTime? latest;

    if (timeline.isNotEmpty) {
      latest = timeline.first.occurredAt;
    }

    if (activities.isNotEmpty) {
      final latestLegacy = activities.first.timestamp;

      if (latest == null || latestLegacy.isAfter(latest)) {
        latest = latestLegacy;
      }
    }

    return latest;
  }

  bool _matchesPop({
    required Activity activity,
    required String popId,
    required String popName,
    required String popNumber,
  }) {
    final cleanActivityPopId = activity.popId.trim();
    final cleanPopId = popId.trim();

    if (cleanActivityPopId.isNotEmpty && cleanPopId.isNotEmpty) {
      return cleanActivityPopId == cleanPopId;
    }

    final cleanActivityName = activity.popName.trim().toLowerCase();
    final cleanPopName = popName.trim().toLowerCase();

    if (cleanActivityName != cleanPopName) {
      return false;
    }

    final cleanActivityNumber = activity.popNumber.trim().toLowerCase();
    final cleanPopNumber = popNumber.trim().toLowerCase();

    if (cleanActivityNumber.isEmpty || cleanPopNumber.isEmpty) {
      return true;
    }

    return cleanActivityNumber == cleanPopNumber;
  }
}
