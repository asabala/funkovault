import 'package:funkovault2/atlas/timeline/models/atlas_timeline_event.dart';
import 'package:funkovault2/atlas/timeline/models/atlas_timeline_summary.dart';
import 'package:funkovault2/atlas/timeline/utils/atlas_timeline_factory.dart';
import 'package:funkovault2/models/pop.dart';

class AtlasTimelineEngine {
  const AtlasTimelineEngine();

  /// Returns events sorted from oldest to newest.
  List<AtlasTimelineEvent> chronological(List<AtlasTimelineEvent> events) {
    final sorted = List<AtlasTimelineEvent>.from(events);

    sorted.sort((a, b) => a.occurredAt.compareTo(b.occurredAt));

    return List<AtlasTimelineEvent>.unmodifiable(sorted);
  }

  /// Returns newest events first.
  List<AtlasTimelineEvent> newestFirst(List<AtlasTimelineEvent> events) {
    final sorted = chronological(events);

    return List<AtlasTimelineEvent>.unmodifiable(sorted.reversed.toList());
  }

  /// Compares the previous and updated versions of a Pop and returns
  /// system-created Timeline events for supported changes.
  ///
  /// This first checkpoint detects value changes only. Additional change
  /// types can be added here later without placing comparison logic inside
  /// AppState.
  List<AtlasTimelineEvent> comparePopChanges({
    required Pop previousPop,
    required Pop updatedPop,
    required DateTime occurredAt,
    String source = 'Manual',
  }) {
    final events = <AtlasTimelineEvent>[];

    if (previousPop.value != updatedPop.value) {
      events.add(
        AtlasTimelineFactory.valueUpdated(
          id: 'value-${updatedPop.id}-${occurredAt.microsecondsSinceEpoch}',
          popId: updatedPop.id,
          occurredAt: occurredAt,
          previousValue: previousPop.value,
          newValue: updatedPop.value,
          source: source,
        ),
      );
    }

    return List<AtlasTimelineEvent>.unmodifiable(chronological(events));
  }

  AtlasTimelineSummary buildSummary(List<AtlasTimelineEvent> events) {
    if (events.isEmpty) {
      return const AtlasTimelineSummary(
        totalEvents: 0,
        firstEvent: null,
        latestEvent: null,
        yearsActive: 0,
        purchaseCount: 0,
        saleCount: 0,
        valueUpdateCount: 0,
        collectorMomentCount: 0,
        aiInsightCount: 0,
      );
    }

    final sorted = chronological(events);

    final first = sorted.first;
    final latest = sorted.last;

    final years = latest.occurredAt.year - first.occurredAt.year + 1;

    return AtlasTimelineSummary(
      totalEvents: sorted.length,
      firstEvent: first,
      latestEvent: latest,
      yearsActive: years,
      purchaseCount: _count(sorted, AtlasTimelineEventType.purchased),
      saleCount: _count(sorted, AtlasTimelineEventType.sold),
      valueUpdateCount: _count(sorted, AtlasTimelineEventType.valueUpdated),
      collectorMomentCount: _count(
        sorted,
        AtlasTimelineEventType.collectorMoment,
      ),
      aiInsightCount: _count(sorted, AtlasTimelineEventType.aiInsight),
    );
  }

  int _count(List<AtlasTimelineEvent> events, AtlasTimelineEventType type) {
    return events.where((event) => event.type == type).length;
  }
}
