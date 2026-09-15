import 'package:flutter/material.dart';

import '../../academy/models/academy_category.dart';
import '../../academy/models/academy_lesson.dart';
import '../../academy/repository/academy_repository.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/components/atlas_action_row.dart';
import '../../widgets/atlas/components/atlas_empty_state.dart';
import '../../widgets/atlas/components/atlas_info_banner.dart';
import '../../widgets/atlas/components/atlas_section_header.dart';
import '../../widgets/atlas/components/atlas_status_chip.dart';
import 'academy_lesson_screen.dart';

class AcademyCategoryScreen extends StatelessWidget {
  const AcademyCategoryScreen({required this.category, super.key});

  final AcademyCategory category;

  static const AcademyRepository _repository = AcademyRepository();

  @override
  Widget build(BuildContext context) {
    final List<AcademyLesson> lessons = _repository
        .getLessonsForCategory(category.id)
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: Text(category.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AtlasSpacing.md,
          AtlasSpacing.sm,
          AtlasSpacing.md,
          AtlasSpacing.xl,
        ),
        children: [
          AtlasGlassCard(
            accentColor: AtlasColors.vaultGold,
            child: AtlasSectionHeader(
              title: category.title,
              subtitle: category.subtitle,
              icon: Icons.school_rounded,
              accentColor: AtlasColors.vaultGold,
              badge: Text(category.icon, style: const TextStyle(fontSize: 30)),
            ),
          ),
          const SizedBox(height: AtlasSpacing.lg),
          if (lessons.isEmpty)
            _EmptyLessonsSection(category: category)
          else
            _LessonsSection(
              lessons: lessons,
              onOpenLesson: (AcademyLesson lesson) {
                _openLesson(context, lesson);
              },
            ),
        ],
      ),
    );
  }

  void _openLesson(BuildContext context, AcademyLesson lesson) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => AcademyLessonScreen(lesson: lesson),
      ),
    );
  }
}

class _LessonsSection extends StatelessWidget {
  const _LessonsSection({required this.lessons, required this.onOpenLesson});

  final List<AcademyLesson> lessons;
  final ValueChanged<AcademyLesson> onOpenLesson;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AtlasSectionHeader(
            title: 'Lessons',
            subtitle:
                '${lessons.length} '
                '${lessons.length == 1 ? 'lesson' : 'lessons'} '
                'available in this Academy category.',
            icon: Icons.auto_stories_rounded,
          ),
          const SizedBox(height: AtlasSpacing.lg),
          for (int index = 0; index < lessons.length; index++) ...[
            _LessonPreviewRow(
              lesson: lessons[index],
              onTap: () {
                onOpenLesson(lessons[index]);
              },
            ),
            if (index != lessons.length - 1)
              const SizedBox(height: AtlasSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _LessonPreviewRow extends StatelessWidget {
  const _LessonPreviewRow({required this.lesson, required this.onTap});

  final AcademyLesson lesson;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AtlasActionRow(
      title: lesson.title,
      description: lesson.subtitle,
      icon: Icons.school_rounded,
      accentColor: AtlasColors.vaultGold,
      onTap: onTap,
      badge: AtlasStatusChip(
        label: '${lesson.readingTimeMinutes} min • ${lesson.difficulty}',
        icon: Icons.schedule_rounded,
        accentColor: AtlasColors.vaultGold,
        size: AtlasStatusChipSize.compact,
      ),
    );
  }
}

class _EmptyLessonsSection extends StatelessWidget {
  const _EmptyLessonsSection({required this.category});

  final AcademyCategory category;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AtlasGlassCard(
          child: AtlasEmptyState(
            eyebrow: 'Atlas Academy',
            title: 'Lessons Coming Soon',
            message:
                '${category.title} is already part of the Atlas Academy structure. '
                'Full lessons for this learning path are planned for a future update.',
            icon: Icons.auto_stories_outlined,
            compact: true,
          ),
        ),
        const SizedBox(height: AtlasSpacing.lg),
        const AtlasInfoBanner(
          icon: Icons.psychology_outlined,
          title: 'Ask Atlas',
          message:
              'Ask Atlas may already recognize related collector terms even when a full Academy lesson has not been published yet.',
        ),
        const SizedBox(height: AtlasSpacing.sm),
        const AtlasInfoBanner(
          icon: Icons.map_outlined,
          title: 'Academy Roadmap',
          message:
              'Upcoming topics for this learning path can appear in the Funko Academy roadmap before full lessons are released.',
        ),
        const SizedBox(height: AtlasSpacing.sm),
        const AtlasInfoBanner(
          icon: Icons.workspace_premium_outlined,
          title: 'Advanced Learning',
          message:
              'Advanced collector intelligence and deeper strategy lessons may expand through Atlas Premium later.',
          accentColor: AtlasColors.vaultGold,
        ),
      ],
    );
  }
}
