import 'package:flutter/material.dart';

import '../../../academy/models/academy_topic.dart';
import '../../../theme/atlas_spacing.dart';
import '../../atlas/components/atlas_section_header.dart';
import 'academy_roadmap_topic_preview_launcher.dart';
import 'academy_topic_roadmap_card.dart';

class FunkoAcademyRoadmapSection extends StatelessWidget {
  const FunkoAcademyRoadmapSection({
    super.key,
    required this.topics,
  });

  final List<AcademyTopic> topics;

  @override
  Widget build(BuildContext context) {
    if (topics.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AtlasSectionHeader(
          title: 'Funko Academy Roadmap',
          subtitle:
          'Upcoming lessons Atlas Academy is being built to support.',
          icon: Icons.route_rounded,
        ),
        const SizedBox(
          height: AtlasSpacing.md,
        ),
        for (
        int index = 0;
        index < topics.length;
        index++
        ) ...[
          AcademyTopicRoadmapCard(
            topic: topics[index],
            onTap: () {
              final AcademyTopic topic =
              topics[index];

              AcademyRoadmapTopicPreviewLauncher.show(
                context: context,
                title: topic.title,
                subtitle: topic.subtitle,
                isPremium: topic.isPremium,
              );
            },
          ),
          if (index != topics.length - 1)
            const SizedBox(
              height: AtlasSpacing.sm,
            ),
        ],
      ],
    );
  }
}