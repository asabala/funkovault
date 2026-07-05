import 'package:flutter/material.dart';

import '../../academy/models/academy_category.dart';
import '../../academy/repository/academy_repository.dart';
import 'academy_lesson_screen.dart';

class AcademyCategoryScreen extends StatelessWidget {
  const AcademyCategoryScreen({
    required this.category,
    super.key,
  });

  final AcademyCategory category;

  static const _repository = AcademyRepository();

  @override
  Widget build(BuildContext context) {
    final lessons = _repository.getLessonsForCategory(category.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(category.title),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Text(
            category.icon,
            style: const TextStyle(fontSize: 42),
          ),
          const SizedBox(height: 14),
          Text(
            category.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            category.subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 22),
          if (lessons.isEmpty)
            _EmptyLessonsCard(category: category)
          else
            for (final lesson in lessons) ...[
              _LessonPreviewCard(
                title: lesson.title,
                subtitle: lesson.subtitle,
                readingTimeMinutes: lesson.readingTimeMinutes,
                difficulty: lesson.difficulty,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AcademyLessonScreen(
                        lesson: lesson,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _LessonPreviewCard extends StatelessWidget {
  const _LessonPreviewCard({
    required this.title,
    required this.subtitle,
    required this.readingTimeMinutes,
    required this.difficulty,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final int readingTimeMinutes;
  final String difficulty;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFF171717),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6B25E).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Color(0xFFD6B25E),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.62),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$readingTimeMinutes min • $difficulty',
                      style: const TextStyle(
                        color: Color(0xFFD6B25E),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyLessonsCard extends StatelessWidget {
  const _EmptyLessonsCard({
    required this.category,
  });

  final AcademyCategory category;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFF171717),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFFD6B25E).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.auto_stories_outlined,
                color: Color(0xFFD6B25E),
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Lessons Coming Soon',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${category.title} is already part of the Atlas Academy structure. Full lessons for this path are planned for a future update.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.68),
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            _ComingSoonNote(
              icon: Icons.psychology_outlined,
              text:
              'Ask Atlas may already recognize some related terms from the roadmap.',
            ),
            const SizedBox(height: 10),
            _ComingSoonNote(
              icon: Icons.map_outlined,
              text:
              'Check the Funko Academy Roadmap for upcoming topics in this area.',
            ),
            const SizedBox(height: 10),
            _ComingSoonNote(
              icon: Icons.workspace_premium_outlined,
              text:
              'Advanced collector intelligence may become part of Atlas Premium later.',
            ),
          ],
        ),
      ),
    );
  }
}

class _ComingSoonNote extends StatelessWidget {
  const _ComingSoonNote({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFFD6B25E).withValues(alpha: 0.90),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.62),
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}