import 'package:flutter/material.dart';

import 'academy_track_coming_soon_card.dart';
import '../../../academy/models/academy_track_selector_item.dart';

class AcademyComingSoonTrackSection extends StatelessWidget {
  const AcademyComingSoonTrackSection({
    super.key,
    required this.track,
    required this.onNotifyTap,
  });

  final AcademyTrackSelectorItem track;
  final VoidCallback onNotifyTap;

  @override
  Widget build(BuildContext context) {
    return AcademyTrackComingSoonCard(
      title: '${track.title} Academy is coming soon',
      subtitle:
      '${track.title} lessons are planned for a future Atlas Academy expansion. This track will eventually include beginner terms, collector strategy, condition guidance, value education, and smarter vault decisions.',
      icon: track.icon,
      onNotifyTap: onNotifyTap,
    );
  }
}