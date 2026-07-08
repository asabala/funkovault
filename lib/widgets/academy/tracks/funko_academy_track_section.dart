import 'package:flutter/material.dart';

import '../../../academy/models/academy_category.dart';
import '../../../academy/models/academy_topic.dart';
import '../shared/academy_category_card.dart';
import '../shared/academy_learning_path_card.dart';
import '../shared/academy_topic_request_card.dart';
import 'academy_track_banner.dart';
import '../ask_atlas/ask_atlas_card.dart';
import '../roadmap/funko_academy_roadmap_section.dart';

class FunkoAcademyTrackSection extends StatelessWidget {
  const FunkoAcademyTrackSection({
    super.key,
    required this.categories,
    required this.roadmapTopics,
    required this.askAtlasSuggestions,
    required this.onAskAtlasQuestion,
    required this.onOpenCategory,
    required this.onTopicRequestSubmitted,
    required this.collectorBasicsLessonCount,
  });

  final List<AcademyCategory> categories;
  final List<AcademyTopic> roadmapTopics;
  final List<String> askAtlasSuggestions;
  final ValueChanged<String> onAskAtlasQuestion;
  final ValueChanged<AcademyCategory> onOpenCategory;
  final ValueChanged<String> onTopicRequestSubmitted;
  final int collectorBasicsLessonCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AskAtlasCard(
          suggestions: askAtlasSuggestions,
          onAsk: onAskAtlasQuestion,
        ),
        const SizedBox(height: 22),
        const AcademyTrackBanner(
          emoji: '🎓',
          title: 'First track: Funko Collecting',
          subtitle:
          'Atlas Academy is built to teach collectible knowledge one approved track at a time.',
        ),
        const SizedBox(height: 20),
        AcademyLearningPathCard(
          title: 'Collector Basics',
          subtitle: 'Start here to learn the foundation terms collectors use.',
          lessonCount: collectorBasicsLessonCount,
          onTap: () {
            if (categories.isEmpty) {
              return;
            }

            onOpenCategory(categories.first);
          },
        ),
        const SizedBox(height: 20),
        for (final category in categories) ...[
          AcademyCategoryCard(
            category: category,
            onTap: () => onOpenCategory(category),
          ),
          const SizedBox(height: 12),
        ],
        if (roadmapTopics.isNotEmpty) ...[
          const SizedBox(height: 18),
          FunkoAcademyRoadmapSection(
            topics: roadmapTopics,
          ),
        ],
        const SizedBox(height: 18),
        AcademyTopicRequestCard(
          onSubmit: onTopicRequestSubmitted,
        ),
      ],
    );
  }
}