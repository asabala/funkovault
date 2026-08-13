import 'package:flutter/material.dart';

import '../../../academy/models/academy_track.dart';
import 'academy_track_coming_soon_card.dart';
import 'academy_track_icon_mapper.dart';

class AcademyComingSoonTrackSection extends StatelessWidget {
  const AcademyComingSoonTrackSection({
    super.key,
    required this.track,
    required this.onNotifyTap,
  });

  final AcademyTrack track;
  final VoidCallback onNotifyTap;

  @override
  Widget build(BuildContext context) {
    return AcademyTrackComingSoonCard(
      title: '${track.title} Academy is coming soon',
      subtitle: track.description,
      status: track.status,
      icon: AcademyTrackIconMapper.iconFor(track.id),
      onNotifyTap: onNotifyTap,
    );
  }
}
