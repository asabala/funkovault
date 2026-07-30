import 'package:funkovault2/atlas/timeline/engine/atlas_timeline_engine.dart';
import 'package:funkovault2/atlas/timeline/models/atlas_timeline_event.dart';
import 'package:funkovault2/atlas/timeline/models/atlas_timeline_summary.dart';

class AtlasTimelineService {
  AtlasTimelineService({
    AtlasTimelineEngine? engine,
  }) : _engine = engine ?? const AtlasTimelineEngine();

  final AtlasTimelineEngine _engine;

  List<AtlasTimelineEvent> chronological(
      List<AtlasTimelineEvent> events,
      ) {
    return _engine.chronological(events);
  }

  List<AtlasTimelineEvent> newestFirst(
      List<AtlasTimelineEvent> events,
      ) {
    return _engine.newestFirst(events);
  }

  AtlasTimelineSummary buildSummary(
      List<AtlasTimelineEvent> events,
      ) {
    return _engine.buildSummary(events);
  }
}