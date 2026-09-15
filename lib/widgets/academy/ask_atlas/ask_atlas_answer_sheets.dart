import 'package:flutter/material.dart';

import '../../../academy/engines/academy_explainer_engine.dart';
import '../../../academy/models/academy_lesson.dart';
import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';
import '../../../theme/atlas_typography.dart';
import '../../atlas/atlas_glass_card.dart';
import '../../atlas/atlas_glass_panel.dart';
import '../../atlas/components/atlas_action_row.dart';
import '../../atlas/components/atlas_info_banner.dart';
import '../../atlas/components/atlas_section_header.dart';
import '../../atlas/components/atlas_status_chip.dart';
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
    return _AskAtlasSheetShell(
      children: [
        const AtlasSectionHeader(
          title: 'Ask Atlas',
          subtitle: 'Approved collector knowledge from Atlas Academy.',
          icon: Icons.auto_awesome_rounded,
          accentColor: AtlasColors.vaultGold,
        ),
        const SizedBox(height: AtlasSpacing.lg),
        _AskAtlasQuestionBanner(question: question),
        const SizedBox(height: AtlasSpacing.lg),
        Text(lesson.title, style: AtlasTypography.headingLarge),
        const SizedBox(height: AtlasSpacing.xs),
        Text(
          lesson.subtitle,
          style: AtlasTypography.bodyMedium.copyWith(
            color: AtlasColors.textSecondary,
            height: 1.45,
          ),
        ),
        const SizedBox(height: AtlasSpacing.md),
        Wrap(
          spacing: AtlasSpacing.sm,
          runSpacing: AtlasSpacing.sm,
          children: [
            AtlasStatusChip(
              label: '${lesson.readingTimeMinutes} min',
              icon: Icons.schedule_rounded,
              accentColor: AtlasColors.intelligenceBlue,
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
        const SizedBox(height: AtlasSpacing.lg),
        _AskAtlasSection(
          title: 'Atlas Answer',
          body: answer,
          icon: Icons.psychology_outlined,
        ),
        const SizedBox(height: AtlasSpacing.md),
        _AskAtlasSection(
          title: 'Atlas Tip',
          body: atlasTip,
          icon: Icons.lightbulb_outline_rounded,
          highlight: true,
        ),
        const SizedBox(height: AtlasSpacing.lg),
        AtlasActionRow(
          title: 'Open Full Lesson',
          description:
              'Continue into the complete Academy lesson for this topic.',
          icon: Icons.menu_book_rounded,
          accentColor: AtlasColors.vaultGold,
          onTap: onOpenLesson,
        ),
      ],
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

    return _AskAtlasSheetShell(
      children: [
        const AtlasSectionHeader(
          title: 'Ask Atlas',
          subtitle: 'Atlas recognizes this as an Academy roadmap topic.',
          icon: Icons.auto_awesome_rounded,
          accentColor: AtlasColors.vaultGold,
        ),
        const SizedBox(height: AtlasSpacing.lg),
        _AskAtlasQuestionBanner(question: question),
        const SizedBox(height: AtlasSpacing.lg),
        Text(
          topic?.title ?? 'Academy Roadmap Topic',
          style: AtlasTypography.headingLarge,
        ),
        const SizedBox(height: AtlasSpacing.xs),
        Text(
          topic?.subtitle ??
              'Atlas recognizes this as a planned Academy topic.',
          style: AtlasTypography.bodyMedium.copyWith(
            color: AtlasColors.textSecondary,
            height: 1.45,
          ),
        ),
        const SizedBox(height: AtlasSpacing.lg),
        _AskAtlasSection(
          title: 'Atlas Answer',
          body: result.answer,
          icon: Icons.psychology_outlined,
        ),
        const SizedBox(height: AtlasSpacing.md),
        _AskAtlasSection(
          title: 'Atlas Tip',
          body: result.atlasTip,
          icon: Icons.lightbulb_outline_rounded,
          highlight: true,
        ),
        if (topic?.isPremium ?? false) ...[
          const SizedBox(height: AtlasSpacing.md),
          const AcademyPremiumInsightCard(),
        ],
      ],
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
    final List<AcademyLesson> visibleSuggestions = suggestions.take(4).toList();

    return _AskAtlasSheetShell(
      children: [
        const AtlasSectionHeader(
          title: 'Ask Atlas',
          subtitle: 'Atlas answers from approved Academy knowledge.',
          icon: Icons.auto_awesome_rounded,
          accentColor: AtlasColors.vaultGold,
        ),
        const SizedBox(height: AtlasSpacing.lg),
        _AskAtlasQuestionBanner(question: question),
        const SizedBox(height: AtlasSpacing.lg),
        const AtlasInfoBanner(
          icon: Icons.search_off_rounded,
          title: 'No Approved Answer Yet',
          message:
              'Atlas does not have an approved Academy answer for this question yet.',
        ),
        if (visibleSuggestions.isNotEmpty) ...[
          const SizedBox(height: AtlasSpacing.lg),
          Text('Try asking about', style: AtlasTypography.headingSmall),
          const SizedBox(height: AtlasSpacing.md),
          AtlasGlassCard(
            child: Column(
              children: [
                for (
                  int index = 0;
                  index < visibleSuggestions.length;
                  index++
                ) ...[
                  AtlasActionRow(
                    title: visibleSuggestions[index].title,
                    description: visibleSuggestions[index].subtitle,
                    icon: Icons.menu_book_outlined,
                    accentColor: AtlasColors.intelligenceBlue,
                    compact: true,
                    onTap: () {
                      onSuggestionTap(visibleSuggestions[index]);
                    },
                  ),
                  if (index != visibleSuggestions.length - 1)
                    const SizedBox(height: AtlasSpacing.sm),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _AskAtlasSheetShell extends StatelessWidget {
  const _AskAtlasSheetShell({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AtlasSpacing.md,
          AtlasSpacing.sm,
          AtlasSpacing.md,
          AtlasSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

class _AskAtlasQuestionBanner extends StatelessWidget {
  const _AskAtlasQuestionBanner({required this.question});

  final String question;

  @override
  Widget build(BuildContext context) {
    final String cleanedQuestion = question.trim();

    return AtlasGlassPanel(
      child: Padding(
        padding: const EdgeInsets.all(AtlasSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.chat_bubble_outline_rounded,
              color: AtlasColors.vaultGold,
            ),
            const SizedBox(width: AtlasSpacing.sm),
            Expanded(
              child: Text(
                cleanedQuestion.isEmpty
                    ? 'Collector question'
                    : cleanedQuestion,
                style: AtlasTypography.bodyMedium.copyWith(
                  color: AtlasColors.vaultGold,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AskAtlasSection extends StatelessWidget {
  const _AskAtlasSection({
    required this.title,
    required this.body,
    required this.icon,
    this.highlight = false,
  });

  final String title;
  final String body;
  final IconData icon;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final Color accentColor = highlight
        ? AtlasColors.vaultGold
        : AtlasColors.intelligenceBlue;

    final String cleanedBody = body.trim();

    return AtlasGlassCard(
      accentColor: accentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: accentColor),
              const SizedBox(width: AtlasSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: AtlasTypography.headingSmall.copyWith(
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AtlasSpacing.sm),
          Text(
            cleanedBody.isEmpty
                ? 'No additional information is available yet.'
                : cleanedBody,
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
