import 'package:flutter/material.dart';

import '../../../academy/models/academy_category.dart';
import '../../../academy/models/academy_request_submission_result.dart';
import '../../../academy/models/academy_topic.dart';
import '../../../academy/models/academy_track.dart';
import '../../../theme/atlas_spacing.dart';
import '../ask_atlas/ask_atlas_card.dart';
import '../roadmap/funko_academy_roadmap_section.dart';
import '../shared/academy_category_card.dart';
import '../shared/academy_topic_request_card.dart';

class FunkoAcademyTrackSection extends StatefulWidget {
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
  });

  final AcademyTrack track;
  final List<AcademyCategory> categories;
  final List<AcademyTopic> roadmapTopics;
  final List<String> askAtlasSuggestions;
  final ValueChanged<String> onAskAtlasQuestion;
  final ValueChanged<AcademyCategory> onOpenCategory;
  final AcademyRequestStorageBehavior requestStorageBehavior;
  final Future<bool> Function(String topic)? onTopicRequestSubmitted;

  @override
  State<FunkoAcademyTrackSection> createState() =>
      _FunkoAcademyTrackSectionState();
}

class _FunkoAcademyTrackSectionState extends State<FunkoAcademyTrackSection> {
  bool _showRoadmap = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AskAtlasCard(
          suggestions: widget.askAtlasSuggestions,
          onAsk: widget.onAskAtlasQuestion,
        ),
        const SizedBox(height: AtlasSpacing.lg),

        for (int index = 0; index < widget.categories.length; index++) ...[
          AcademyCategoryCard(
            category: widget.categories[index],
            onTap: () {
              widget.onOpenCategory(widget.categories[index]);
            },
          ),
          if (index != widget.categories.length - 1)
            const SizedBox(height: AtlasSpacing.sm),
        ],

        if (widget.roadmapTopics.isNotEmpty) ...[
          const SizedBox(height: AtlasSpacing.lg),
          _RoadmapToggle(
            expanded: _showRoadmap,
            topicCount: widget.roadmapTopics.length,
            onTap: () {
              setState(() {
                _showRoadmap = !_showRoadmap;
              });
            },
          ),
          if (_showRoadmap) ...[
            const SizedBox(height: AtlasSpacing.md),
            FunkoAcademyRoadmapSection(topics: widget.roadmapTopics),
          ],
        ],

        const SizedBox(height: AtlasSpacing.lg),
        AcademyTopicRequestCard(
          storageBehavior: widget.requestStorageBehavior,
          onSubmit: widget.onTopicRequestSubmitted,
        ),
      ],
    );
  }
}

class _RoadmapToggle extends StatelessWidget {
  const _RoadmapToggle({
    required this.expanded,
    required this.topicCount,
    required this.onTap,
  });

  final bool expanded;
  final int topicCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AtlasSpacing.md),
          child: Row(
            children: [
              const Icon(Icons.route_rounded),
              const SizedBox(width: AtlasSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Funko Academy Roadmap',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      expanded
                          ? 'Hide upcoming Academy topics.'
                          : 'Preview $topicCount upcoming Academy topics.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AtlasSpacing.sm),
              Icon(
                expanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
