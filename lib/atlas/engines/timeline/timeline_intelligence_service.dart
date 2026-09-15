import '/models/pop.dart';
import 'atlas_timeline_intelligence_engine.dart';
import 'models/atlas_timeline_intelligence_report.dart';

class TimelineIntelligenceService {
  const TimelineIntelligenceService({
    this.engine = const AtlasTimelineIntelligenceEngine(),
  });

  final AtlasTimelineIntelligenceEngine engine;

  AtlasTimelineIntelligenceReport buildReport(Pop pop, {DateTime? now}) {
    return engine.analyze(
      timeline: pop.timeline,
      valueHistory: pop.valueHistory,
      currentValue: pop.value,
      now: now,
    );
  }
}
