import 'package:flutter/material.dart';

import 'package:funkovault2/atlas/timeline/models/atlas_timeline_event.dart';
import 'package:funkovault2/widgets/atlas/atlas_glass_card.dart';

import 'atlas_timeline_list.dart';

class AtlasTimelineCard extends StatelessWidget {
  const AtlasTimelineCard({
    super.key,
    required this.events,
  });

  final List<AtlasTimelineEvent> events;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: AtlasTimelineList(
        events: events,
      ),
    );
  }
}