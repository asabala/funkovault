import 'package:flutter/material.dart';

import '../../academy/academy_ids.dart';
import '../../academy/engines/academy_explainer_engine.dart';
import '../../academy/models/academy_lesson.dart';
import '../../academy/repository/academy_repository.dart';
import '../../widgets/academy/academy_category_card.dart';
import '../../widgets/academy/academy_learning_path_card.dart';
import '../../widgets/academy/academy_premium_insight_card.dart';
import '../../widgets/academy/academy_topic_request_card.dart';
import '../../widgets/academy/academy_topic_roadmap_card.dart';
import '../../widgets/academy/academy_track_banner.dart';
import '../../widgets/academy/ask_atlas_card.dart';
import 'academy_category_screen.dart';
import 'academy_lesson_screen.dart';

class AtlasAcademyScreen extends StatelessWidget {
  const AtlasAcademyScreen({super.key});

  static const _repository = AcademyRepository();
  static const _explainerEngine = AcademyExplainerEngine();

  @override
  Widget build(BuildContext context) {
    final categories = _repository.getCategoriesForTrack(
      AcademyTrackTitles.funkoCollecting,
    );

    final roadmapTopics = _repository
        .getRoadmapTopicsForTrack(AcademyTrackIds.funkoCollecting)
        .take(8)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Atlas Academy'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          const Text(
            'Become a smarter collector.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Learn collector terms, variants, stickers, figure types, values, and collecting tips directly inside Atlas.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 22),
          AskAtlasCard(
            suggestions: [
              ..._repository
                  .getLessons()
                  .map((lesson) => 'What is a ${lesson.title}?'),
              ..._repository
                  .getRoadmapTopicsForTrack('funko-collecting')
                  .take(4)
                  .map((topic) => 'What is ${topic.title}?'),
            ],
            onAsk: (question) {
              _showAskAtlasAnswer(
                context: context,
                question: question,
              );
            },
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
            lessonCount: _repository
                .getLessonsForCategory(AcademyCategoryIds.funkoCollectorBasics)
                .length,
            onTap: () {
              if (categories.isEmpty) {
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AcademyCategoryScreen(
                    category: categories.first,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          for (final category in categories) ...[
            AcademyCategoryCard(
              category: category,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AcademyCategoryScreen(
                      category: category,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
          if (roadmapTopics.isNotEmpty) ...[
            const SizedBox(height: 18),
            const Text(
              'Funko Academy Roadmap',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upcoming lessons Atlas Academy is being built to support.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            for (final topic in roadmapTopics) ...[
              AcademyTopicRoadmapCard(
                topic: topic,
                onTap: () {
                  _showRoadmapTopicPreview(
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
          const SizedBox(height: 18),
          AcademyTopicRequestCard(
            onSubmit: (topic) {
              _showTopicRequestConfirmation(
                context: context,
                topic: topic,
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAskAtlasAnswer({
    required BuildContext context,
    required String question,
  }) {
    final result = _explainerEngine.explain(question);

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      builder: (sheetContext) {
        if (result == null) {
          return _AskAtlasEmptyAnswer(
            question: question,
            suggestions: _repository.getLessons(),
            onSuggestionTap: (lesson) {
              Navigator.pop(sheetContext);

              _showAskAtlasAnswer(
                context: context,
                question: lesson.title,
              );
            },
          );
        }

        if (result.isRoadmapTopic) {
          return _AskAtlasRoadmapAnswerSheet(
            question: question,
            result: result,
          );
        }

        final lesson = result.lesson;

        if (lesson == null) {
          return _AskAtlasEmptyAnswer(
            question: question,
            suggestions: _repository.getLessons(),
            onSuggestionTap: (suggestedLesson) {
              Navigator.pop(sheetContext);

              _showAskAtlasAnswer(
                context: context,
                question: suggestedLesson.title,
              );
            },
          );
        }

        return _AskAtlasAnswerSheet(
          question: question,
          lesson: lesson,
          answer: result.answer,
          atlasTip: result.atlasTip,
          onOpenLesson: () {
            Navigator.pop(sheetContext);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AcademyLessonScreen(
                  lesson: lesson,
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showRoadmapTopicPreview({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool isPremium,
  }) {

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: const Color(0xFF1A1A1A),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPremium
                      ? 'Premium Academy Topic'
                      : 'Academy Roadmap Topic',
                  style: const TextStyle(
                    color: Color(0xFFD6B25E),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                if (isPremium)
                  const AcademyPremiumInsightCard()
                else
                  Text(
                    'This topic is planned for a future Atlas Academy lesson.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

void _showTopicRequestConfirmation({
  required BuildContext context,
  required String topic,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Topic request received: $topic',
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

class _AskAtlasAnswerSheet extends StatelessWidget {
  const _AskAtlasAnswerSheet({
    required this.question,
    required this.lesson,
    required this.answer,
    required this.atlasTip,
    required this.onOpenLesson,
  });

  final String question;
  final AcademyLesson lesson;
  final String answer;
  final String atlasTip;
  final VoidCallback onOpenLesson;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ask Atlas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              question,
              style: const TextStyle(
                color: Color(0xFFD6B25E),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              lesson.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              lesson.subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _AskAtlasMetaPill(
                  icon: Icons.schedule_rounded,
                  label: '${lesson.readingTimeMinutes} min',
                ),
                _AskAtlasMetaPill(
                  icon: Icons.school_rounded,
                  label: lesson.difficulty,
                ),
              ],
            ),
            const SizedBox(height: 18),
            _AskAtlasSection(
              title: 'Atlas Answer',
              body: answer,
            ),
            const SizedBox(height: 14),
            _AskAtlasSection(
              title: 'Atlas Tip',
              body: atlasTip,
              highlight: true,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onOpenLesson,
                icon: const Icon(Icons.menu_book_rounded),
                label: const Text('Open Full Lesson'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AskAtlasRoadmapAnswerSheet extends StatelessWidget {
  const _AskAtlasRoadmapAnswerSheet({
    required this.question,
    required this.result,
  });

  final String question;
  final AcademyExplainerResult result;

  @override
  Widget build(BuildContext context) {
    final topic = result.topic;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ask Atlas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              question,
              style: const TextStyle(
                color: Color(0xFFD6B25E),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              topic?.title ?? 'Academy Roadmap Topic',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              topic?.subtitle ??
                  'Atlas recognizes this as a planned Academy topic.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            _AskAtlasSection(
              title: 'Atlas Answer',
              body: result.answer,
            ),
            const SizedBox(height: 14),
            _AskAtlasSection(
              title: 'Atlas Tip',
              body: result.atlasTip,
              highlight: true,
            ),
            if (topic?.isPremium ?? false) ...[
              const SizedBox(height: 14),
              const AcademyPremiumInsightCard(),
            ],
          ],
        ),
      ),
    );
  }
}

class _AskAtlasEmptyAnswer extends StatelessWidget {
  const _AskAtlasEmptyAnswer({
    required this.question,
    required this.suggestions,
    required this.onSuggestionTap,
  });

  final String question;
  final List<AcademyLesson> suggestions;
  final ValueChanged<AcademyLesson> onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    final visibleSuggestions = suggestions.take(4).toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ask Atlas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              question,
              style: const TextStyle(
                color: Color(0xFFD6B25E),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Atlas does not have an approved Academy answer for this yet.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Try asking about:',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final lesson in visibleSuggestions)
                  ActionChip(
                    label: Text(lesson.title),
                    onPressed: () => onSuggestionTap(lesson),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AskAtlasMetaPill extends StatelessWidget {
  const _AskAtlasMetaPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: const Color(0xFFD6B25E),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AskAtlasSection extends StatelessWidget {
  const _AskAtlasSection({
    required this.title,
    required this.body,
    this.highlight = false,
  });

  final String title;
  final String body;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final borderColor = highlight
        ? const Color(0xFFD6B25E).withValues(alpha: 0.28)
        : Colors.white.withValues(alpha: 0.10);

    final backgroundColor = highlight
        ? const Color(0xFFD6B25E).withValues(alpha: 0.10)
        : Colors.white.withValues(alpha: 0.05);

    final titleColor = highlight
        ? const Color(0xFFD6B25E)
        : Colors.white.withValues(alpha: 0.85);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}