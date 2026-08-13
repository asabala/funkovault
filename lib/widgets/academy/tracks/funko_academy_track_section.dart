import 'package:flutter/material.dart';

import '../../../academy/academy_ids.dart';
import '../../../academy/models/academy_category.dart';
import '../../../academy/models/academy_request_submission_result.dart';
import '../../../academy/models/academy_topic.dart';
import '../../../academy/models/academy_track.dart';
import '../../../theme/atlas_spacing.dart';
import '../ask_atlas/ask_atlas_card.dart';
import '../roadmap/funko_academy_roadmap_section.dart';
import '../shared/academy_category_card.dart';
import '../shared/academy_learning_path_card.dart';
import '../shared/academy_topic_request_card.dart';
import 'academy_track_banner.dart';

class FunkoAcademyTrackSection extends StatelessWidget {
  const FunkoAcademyTrackSection({
    super.key,
    required this.track,
    required this.categories,
    required this.roadmapTopics,
    required this.askAtlasSuggestions,
    required this.onAskAtlasQuestion,
    required this.onOpenCategory,
    required this.requestStorageBehavior,
    this.onTopicRequestSubmitted,
    required this.collectorBasicsLessonCount,
  });

  final AcademyTrack track;
  final List<AcademyCategory> categories;
  final List<AcademyTopic> roadmapTopics;
  final List<String> askAtlasSuggestions;
  final ValueChanged<String> onAskAtlasQuestion;
  final ValueChanged<AcademyCategory> onOpenCategory;
  final AcademyRequestStorageBehavior requestStorageBehavior;
  final Future<bool> Function(String topic)? onTopicRequestSubmitted;
  final int collectorBasicsLessonCount;

  AcademyCategory? get _collectorBasicsCategory {
    for (final AcademyCategory category in categories) {
      if (category.id == AcademyCategoryIds.funkoCollectorBasics) {
        return category;
      }
    }

    return categories.isEmpty ? null : categories.first;
  }

  @override
  Widget build(BuildContext context) {
    final AcademyCategory? collectorBasicsCategory = _collectorBasicsCategory;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AskAtlasCard(
          suggestions: askAtlasSuggestions,
          onAsk: onAskAtlasQuestion,
        ),
        const SizedBox(height: AtlasSpacing.lg),
        AcademyTrackBanner(
          emoji: track.emoji,
          title: 'First track: ${track.title}',
          subtitle: track.subtitle,
        ),
        const SizedBox(height: AtlasSpacing.lg),
        AcademyLearningPathCard(
          title: 'Collector Basics',
          subtitle: 'Start here to learn the foundation terms collectors use.',
          lessonCount: collectorBasicsLessonCount,
          onTap: () {
            final AcademyCategory? category = collectorBasicsCategory;

            if (category == null) {
              return;
            }

            onOpenCategory(category);
          },
        ),
        const SizedBox(height: AtlasSpacing.lg),
        for (int index = 0; index < categories.length; index++) ...[
          AcademyCategoryCard(
            category: categories[index],
            onTap: () {
              onOpenCategory(categories[index]);
            },
          ),
          if (index != categories.length - 1)
            const SizedBox(height: AtlasSpacing.sm),
        ],
        if (roadmapTopics.isNotEmpty) ...[
          const SizedBox(height: AtlasSpacing.lg),
          FunkoAcademyRoadmapSection(topics: roadmapTopics),
        ],
        const SizedBox(height: AtlasSpacing.lg),
        AcademyTopicRequestCard(
          storageBehavior: requestStorageBehavior,
          onSubmit: onTopicRequestSubmitted,
        ),
      ],
    );
  }
}
