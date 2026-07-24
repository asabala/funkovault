import '../../../models/activity.dart';

class PopActivitySummary {
  const PopActivitySummary({
    required this.title,
    required this.summary,
    required this.activityCount,
    required this.latestActivity,
  });

  final String title;
  final String summary;
  final int activityCount;
  final DateTime? latestActivity;

  bool get hasActivity => activityCount > 0;
}

class PopActivitySummaryEngine {
  const PopActivitySummaryEngine();

  PopActivitySummary build({
    required String popId,
    required String popName,
    required String popNumber,
    required List<Activity> activities,
  }) {
    final matchingActivities = activities
        .where(
          (activity) => _matchesPop(
        activity: activity,
        popId: popId,
        popName: popName,
        popNumber: popNumber,
      ),
    )
        .toList()
      ..sort(
            (a, b) => b.timestamp.compareTo(a.timestamp),
      );

    if (matchingActivities.isEmpty) {
      return const PopActivitySummary(
        title: 'No Activity Yet',
        summary:
        'Atlas has not recorded any changes for this collectible yet.',
        activityCount: 0,
        latestActivity: null,
      );
    }

    final summaryParts = <String>[];

    final valueUpdates = matchingActivities
        .where(
          (activity) => activity.action == 'value_updated',
    )
        .length;

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
        .where(
          (activity) => activity.action == 'pop_updated',
    )
        .length;

    if (valueUpdates == 1) {
      summaryParts.add('The estimated value was updated once.');
    } else if (valueUpdates > 1) {
      summaryParts.add(
        'The estimated value was updated $valueUpdates times.',
      );
    }

    if (quantityUpdates == 1) {
      summaryParts.add('The quantity was adjusted once.');
    } else if (quantityUpdates > 1) {
      summaryParts.add(
        'The quantity was adjusted $quantityUpdates times.',
      );
    }

    if (movedToWishlist && movedToOwned) {
      summaryParts.add(
        'It moved between the wishlist and owned collection.',
      );
    } else if (movedToWishlist) {
      summaryParts.add('It was moved to the wishlist.');
    } else if (movedToOwned) {
      summaryParts.add('It was moved to the owned collection.');
    }

    if (detailUpdates == 1) {
      summaryParts.add('Collector details were updated once.');
    } else if (detailUpdates > 1) {
      summaryParts.add(
        'Collector details were updated $detailUpdates times.',
      );
    }

    if (summaryParts.isEmpty) {
      summaryParts.add(
        'Atlas recorded ${matchingActivities.length} Vault '
            '${matchingActivities.length == 1 ? 'event' : 'events'} '
            'for this collectible.',
      );
    }

    return PopActivitySummary(
      title: 'Atlas Activity Summary',
      summary: summaryParts.join(' '),
      activityCount: matchingActivities.length,
      latestActivity: matchingActivities.first.timestamp,
    );
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

    final cleanActivityNumber =
    activity.popNumber.trim().toLowerCase();
    final cleanPopNumber = popNumber.trim().toLowerCase();

    if (cleanActivityNumber.isEmpty || cleanPopNumber.isEmpty) {
      return true;
    }

    return cleanActivityNumber == cleanPopNumber;
  }
}