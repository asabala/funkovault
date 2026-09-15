import 'package:flutter/material.dart';

import '../../../academy/engines/academy_explainer_engine.dart';
import '../../../academy/models/academy_lesson.dart';
import '../../../academy/repository/academy_repository.dart';
import 'ask_atlas_answer_sheets.dart';

class AskAtlasBottomSheetLauncher {
  const AskAtlasBottomSheetLauncher._();

  static Future<void> show({
    required BuildContext context,
    required String question,
    required AcademyRepository repository,
    required AcademyExplainerEngine explainerEngine,
    required ValueChanged<AcademyLesson> onOpenLesson,
  }) async {
    final String cleanedQuestion = question.trim();

    if (cleanedQuestion.isEmpty) {
      return;
    }

    final result = explainerEngine.explain(cleanedQuestion);

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (BuildContext sheetContext) {
        if (result == null) {
          return _buildEmptyAnswer(
            context: context,
            sheetContext: sheetContext,
            question: cleanedQuestion,
            repository: repository,
            explainerEngine: explainerEngine,
            onOpenLesson: onOpenLesson,
          );
        }

        if (result.isRoadmapTopic) {
          return AskAtlasRoadmapAnswerSheet(
            question: cleanedQuestion,
            result: result,
          );
        }

        final AcademyLesson? lesson = result.lesson;

        if (lesson == null) {
          return _buildEmptyAnswer(
            context: context,
            sheetContext: sheetContext,
            question: cleanedQuestion,
            repository: repository,
            explainerEngine: explainerEngine,
            onOpenLesson: onOpenLesson,
          );
        }

        return AskAtlasAnswerSheet(
          question: cleanedQuestion,
          lesson: lesson,
          answer: result.answer,
          atlasTip: result.atlasTip,
          onOpenLesson: () {
            Navigator.pop(sheetContext);

            if (!context.mounted) {
              return;
            }

            onOpenLesson(lesson);
          },
        );
      },
    );
  }

  static Widget _buildEmptyAnswer({
    required BuildContext context,
    required BuildContext sheetContext,
    required String question,
    required AcademyRepository repository,
    required AcademyExplainerEngine explainerEngine,
    required ValueChanged<AcademyLesson> onOpenLesson,
  }) {
    return AskAtlasEmptyAnswer(
      question: question,
      suggestions: repository.getLessons(),
      onSuggestionTap: (AcademyLesson lesson) {
        Navigator.pop(sheetContext);

        if (!context.mounted) {
          return;
        }

        show(
          context: context,
          question: lesson.title,
          repository: repository,
          explainerEngine: explainerEngine,
          onOpenLesson: onOpenLesson,
        );
      },
    );
  }
}
