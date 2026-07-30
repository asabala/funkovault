import 'package:funkovault2/atlas/timeline/models/atlas_timeline_event.dart';

class AtlasTimelineSummary {
  const AtlasTimelineSummary({
    required this.totalEvents,
    required this.firstEvent,
    required this.latestEvent,
    required this.yearsActive,
    required this.purchaseCount,
    required this.saleCount,
    required this.valueUpdateCount,
    required this.collectorMomentCount,
    required this.aiInsightCount,
  });

  final int totalEvents;

  final AtlasTimelineEvent? firstEvent;

  final AtlasTimelineEvent? latestEvent;

  final int yearsActive;

  final int purchaseCount;

  final int saleCount;

  final int valueUpdateCount;

  final int collectorMomentCount;

  final int aiInsightCount;

  bool get hasEvents => totalEvents > 0;

  bool get hasPurchases => purchaseCount > 0;

  bool get hasSales => saleCount > 0;

  bool get hasValueUpdates => valueUpdateCount > 0;

  bool get hasCollectorMoments => collectorMomentCount > 0;

  bool get hasAiInsights => aiInsightCount > 0;

  DateTime? get firstEventDate => firstEvent?.occurredAt;

  DateTime? get latestEventDate => latestEvent?.occurredAt;
}