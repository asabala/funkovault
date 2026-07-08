import 'package:flutter/material.dart';
import 'academy_topic_roadmap_card.dart';
import 'academy_roadmap_topic_preview_launcher.dart';

import '../shared/academy_section_header.dart';
import '../../../academy/models/academy_topic.dart';

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
        const AcademySectionHeader(
          title: 'Funko Academy Roadmap',
          subtitle: 'Upcoming lessons Atlas Academy is being built to support.',
        ),
        const SizedBox(height: 14),
        for (final topic in topics) ...[
          AcademyTopicRoadmapCard(
            topic: topic,
            onTap: () {
              AcademyRoadmapTopicPreviewLauncher.show(
                context: context,
                title: topic.title,
                subtitle: topic.subtitle,
                isPremium: topic.isPremium,
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}