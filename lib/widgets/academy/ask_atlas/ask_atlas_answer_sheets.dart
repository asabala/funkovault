import 'package:flutter/material.dart';

import '../../../academy/engines/academy_explainer_engine.dart';
import '../../../academy/models/academy_lesson.dart';
import '../shared/academy_premium_insight_card.dart';

class AskAtlasAnswerSheet extends StatelessWidget {
  const AskAtlasAnswerSheet({
    super.key,
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

class AskAtlasRoadmapAnswerSheet extends StatelessWidget {
  const AskAtlasRoadmapAnswerSheet({
    super.key,
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

class AskAtlasEmptyAnswer extends StatelessWidget {
  const AskAtlasEmptyAnswer({
    super.key,
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