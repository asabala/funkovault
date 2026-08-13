import 'package:flutter/material.dart';

import '../../academy/models/academy_category.dart';
import '../../academy/models/academy_lesson.dart';
import '../../academy/repository/academy_repository.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/components/atlas_action_row.dart';
import '../../widgets/atlas/components/atlas_info_banner.dart';
import '../../widgets/atlas/components/atlas_section_header.dart';
import '../../widgets/atlas/components/atlas_status_chip.dart';

class AcademyLessonScreen extends StatelessWidget {
  const AcademyLessonScreen({required this.lesson, super.key});

  final AcademyLesson lesson;

  static const AcademyRepository _repository = AcademyRepository();

  @override
  Widget build(BuildContext context) {
    final AcademyCategory? lessonCategory = _repository.getCategoryById(
      lesson.categoryId,
    );

    final String lessonCategoryTitle =
        lessonCategory == null || lessonCategory.title.trim().isEmpty
        ? 'Academy'
        : lessonCategory.title.trim();

    final String atlasTip = lesson.atlasTips.isEmpty
        ? 'Keep learning. Small details can make a big difference in collecting.'
        : lesson.atlasTips.first;

    final List<AcademyLesson> relatedLessons = lesson.relatedLessonIds
        .map(_repository.getLessonById)
        .whereType<AcademyLesson>()
        .where((AcademyLesson relatedLesson) {
          return relatedLesson.id != lesson.id;
        })
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: Text(lesson.title)),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AtlasSectionHeader(
                  title: lesson.title,
                  subtitle: lesson.subtitle,
                  icon: Icons.menu_book_rounded,
                  accentColor: AtlasColors.vaultGold,
                  titleStyle: AtlasTypography.headingLarge,
                ),
                const SizedBox(height: AtlasSpacing.lg),
                Wrap(
                  spacing: AtlasSpacing.sm,
                  runSpacing: AtlasSpacing.sm,
                  children: [
                    AtlasStatusChip(
                      label: lessonCategoryTitle,
                      icon: Icons.category_outlined,
                      accentColor: AtlasColors.vaultGold,
                      size: AtlasStatusChipSize.compact,
                    ),
                    AtlasStatusChip(
                      label: '${lesson.readingTimeMinutes} min',
                      icon: Icons.schedule_rounded,
                      accentColor: AtlasColors.vaultGold,
                      size: AtlasStatusChipSize.compact,
                    ),
                    AtlasStatusChip(
                      label: lesson.difficulty,
                      icon: Icons.school_rounded,
                      accentColor: AtlasColors.vaultGold,
                      size: AtlasStatusChipSize.compact,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AtlasSpacing.lg),
          _LessonContentCard(
            title: 'Quick Answer',
            body: lesson.quickAnswer,
            icon: Icons.flash_on_rounded,
          ),
          const SizedBox(height: AtlasSpacing.md),
          _LessonContentCard(
            title: 'Atlas Explains',
            body: _combinedExplanation(
              deepAnswer: lesson.deepAnswer,
              analogy: lesson.analogy,
            ),
            icon: Icons.psychology_outlined,
          ),
          const SizedBox(height: AtlasSpacing.md),
          AtlasInfoBanner(
            icon: Icons.lightbulb_outline_rounded,
            title: 'Atlas Tip',
            message: atlasTip,
            accentColor: AtlasColors.vaultGold,
          ),
          const SizedBox(height: AtlasSpacing.md),
          _LessonContentCard(
            title: 'Collector Warning',
            body: lesson.collectorWarning,
            icon: Icons.warning_amber_rounded,
            accentColor: AtlasColors.warning,
          ),
          if (lesson.sections.isNotEmpty) ...[
            const SizedBox(height: AtlasSpacing.lg),
            AtlasGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AtlasSectionHeader(
                    title: 'Lesson Details',
                    subtitle:
                        'Go deeper with the key collector concepts covered in this lesson.',
                    icon: Icons.auto_stories_rounded,
                  ),
                  const SizedBox(height: AtlasSpacing.lg),
                  for (
                    int index = 0;
                    index < lesson.sections.length;
                    index++
                  ) ...[
                    _LessonContentPanel(
                      title: lesson.sections[index].heading,
                      body: lesson.sections[index].body,
                    ),
                    if (index != lesson.sections.length - 1)
                      const SizedBox(height: AtlasSpacing.sm),
                  ],
                ],
              ),
            ),
          ],
          if (relatedLessons.isNotEmpty) ...[
            const SizedBox(height: AtlasSpacing.lg),
            AtlasGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AtlasSectionHeader(
                    title: 'Related Lessons',
                    subtitle: 'Keep learning with connected collector topics.',
                    icon: Icons.link_rounded,
                  ),
                  const SizedBox(height: AtlasSpacing.lg),
                  for (
                    int index = 0;
                    index < relatedLessons.length;
                    index++
                  ) ...[
                    AtlasActionRow(
                      title: relatedLessons[index].title,
                      description: relatedLessons[index].subtitle,
                      icon: Icons.menu_book_outlined,
                      accentColor: AtlasColors.vaultGold,
                      badge: AtlasStatusChip(
                        label:
                            '${relatedLessons[index].readingTimeMinutes} min',
                        icon: Icons.schedule_rounded,
                        accentColor: AtlasColors.vaultGold,
                        size: AtlasStatusChipSize.compact,
                      ),
                      onTap: () {
                        _openRelatedLesson(context, relatedLessons[index]);
                      },
                    ),
                    if (index != relatedLessons.length - 1)
                      const SizedBox(height: AtlasSpacing.sm),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _combinedExplanation({
    required String deepAnswer,
    required String analogy,
  }) {
    final String cleanedDeepAnswer = deepAnswer.trim();

    final String cleanedAnalogy = analogy.trim();

    if (cleanedDeepAnswer.isEmpty) {
      return cleanedAnalogy;
    }

    if (cleanedAnalogy.isEmpty) {
      return cleanedDeepAnswer;
    }

    return '$cleanedDeepAnswer\n\n$cleanedAnalogy';
  }

  void _openRelatedLesson(BuildContext context, AcademyLesson relatedLesson) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => AcademyLessonScreen(lesson: relatedLesson),
      ),
    );
  }
}

class _LessonContentCard extends StatelessWidget {
  const _LessonContentCard({
    required this.title,
    required this.body,
    required this.icon,
    this.accentColor,
  });

  final String title;
  final String body;
  final IconData icon;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final Color effectiveAccent = accentColor ?? AtlasColors.vaultGold;

    return AtlasGlassCard(
      accentColor: effectiveAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AtlasSectionHeader(
            title: title,
            icon: icon,
            accentColor: effectiveAccent,
          ),
          const SizedBox(height: AtlasSpacing.md),
          Text(
            _displayBody(body),
            style: AtlasTypography.bodyMedium.copyWith(
              color: AtlasColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonContentPanel extends StatelessWidget {
  const _LessonContentPanel({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.trim().isEmpty ? 'Lesson Note' : title.trim(),
            style: AtlasTypography.headingSmall.copyWith(
              color: AtlasColors.vaultGold,
            ),
          ),
          const SizedBox(height: AtlasSpacing.sm),
          Text(
            _displayBody(body),
            style: AtlasTypography.bodyMedium.copyWith(
              color: AtlasColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

String _displayBody(String value) {
  final String cleaned = value.trim();

  if (cleaned.isEmpty) {
    return 'More lesson details are coming soon.';
  }

  return cleaned;
}
