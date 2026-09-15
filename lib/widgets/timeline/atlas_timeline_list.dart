import 'package:flutter/material.dart';

import 'package:funkovault2/atlas/timeline/engine/atlas_timeline_engine.dart';
import 'package:funkovault2/atlas/timeline/models/atlas_timeline_event.dart';

import 'atlas_timeline_header.dart';
import 'atlas_timeline_tile.dart';

class AtlasTimelineList extends StatelessWidget {
  const AtlasTimelineList({super.key, required this.events});

  final List<AtlasTimelineEvent> events;

  @override
  Widget build(BuildContext context) {
    const engine = AtlasTimelineEngine();

    final chronological = engine.chronological(events);

    final summary = engine.buildSummary(chronological);

    if (chronological.isEmpty) {
      return AtlasTimelineHeader(summary: summary);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AtlasTimelineHeader(summary: summary),
        const SizedBox(height: 20),
        ...List.generate(chronological.length, (index) {
          final event = chronological[index];

          return AtlasTimelineTile(
            event: event,
            showConnector: index != chronological.length - 1,
          );
        }),
      ],
    );
  }
}
