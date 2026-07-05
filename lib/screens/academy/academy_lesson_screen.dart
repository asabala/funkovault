import 'package:flutter/material.dart';

import '../../academy/models/academy_lesson.dart';
import '../../academy/repository/academy_repository.dart';

class AcademyLessonScreen extends StatelessWidget {
  const AcademyLessonScreen({
    required this.lesson,
    super.key,
  });

  final AcademyLesson lesson;

  static const _repository = AcademyRepository();

  @override
  Widget build(BuildContext context) {
    final atlasTip = lesson.atlasTips.isEmpty
        ? 'Keep learning. Small details can make a big difference in collecting.'
        : lesson.atlasTips.first;

    final relatedLessons = lesson.relatedLessonIds
        .map(_repository.getLessonById)
        .whereType<AcademyLesson>()
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.title),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Text(
            lesson.category,
            style: const TextStyle(
              color: Color(0xFFD6B25E),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            lesson.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            lesson.subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 15,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _LessonMetaPill(
                icon: Icons.schedule_rounded,
                label: '${lesson.readingTimeMinutes} min',
              ),
              const SizedBox(width: 10),
              _LessonMetaPill(
                icon: Icons.school_rounded,
                label: lesson.difficulty,
              ),
            ],
          ),
          const SizedBox(height: 22),
          _LessonCard(
            title: 'Quick Answer',
            body: lesson.quickAnswer,
          ),
          const SizedBox(height: 14),
          _LessonCard(
            title: 'Atlas Explains',
            body: '${lesson.deepAnswer}\n\n${lesson.analogy}',
          ),
          const SizedBox(height: 14),
          _AtlasTipCard(tip: atlasTip),
          const SizedBox(height: 14),
          _LessonCard(
            title: 'Collector Warning',
            body: lesson.collectorWarning,
          ),
          const SizedBox(height: 22),
          for (final section in lesson.sections) ...[
            _LessonCard(
              title: section.heading,
              body: section.body,
            ),
            const SizedBox(height: 14),
          ],
          if (relatedLessons.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text(
              'Related Lessons',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Keep learning with connected collector topics.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            for (final relatedLesson in relatedLessons) ...[
              _RelatedLessonCard(
                lesson: relatedLesson,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AcademyLessonScreen(
                        lesson: relatedLesson,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ],
        ],
      ),
    );
  }
}

class _LessonMetaPill extends StatelessWidget {
  const _LessonMetaPill({
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

class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

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
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFFD6B25E),
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              body,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.78),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AtlasTipCard extends StatelessWidget {
  const _AtlasTipCard({
    required this.tip,
  });

  final String tip;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFFD6B25E).withValues(alpha: 0.10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: const Color(0xFFD6B25E).withValues(alpha: 0.22),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '💡',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Atlas Tip: $tip',
                style: const TextStyle(
                  color: Color(0xFFD6B25E),
                  fontSize: 14,
                  height: 1.45,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RelatedLessonCard extends StatelessWidget {
  const _RelatedLessonCard({
    required this.lesson,
    required this.onTap,
  });

  final AcademyLesson lesson;
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 8,
        ),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFD6B25E).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.menu_book_outlined,
            color: Color(0xFFD6B25E),
          ),
        ),
        title: Text(
          lesson.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          lesson.subtitle,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.62),
            height: 1.35,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}