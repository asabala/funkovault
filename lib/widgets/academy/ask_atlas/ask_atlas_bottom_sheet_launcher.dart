import 'package:flutter/material.dart';

import '../../../academy/engines/academy_explainer_engine.dart';
import '../../../academy/models/academy_lesson.dart';
import '../../../academy/repository/academy_repository.dart';
import 'ask_atlas_answer_sheets.dart';

class AskAtlasBottomSheetLauncher {
  const AskAtlasBottomSheetLauncher._();

  static void show({
    required BuildContext context,
    required String question,
    required AcademyRepository repository,
    required AcademyExplainerEngine explainerEngine,
    required ValueChanged<AcademyLesson> onOpenLesson,
  }) {
    final result = explainerEngine.explain(question);

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      builder: (sheetContext) {
        if (result == null) {
          return AskAtlasEmptyAnswer(
            question: question,
            suggestions: repository.getLessons(),
            onSuggestionTap: (lesson) {
              Navigator.pop(sheetContext);

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

        if (result.isRoadmapTopic) {
          return AskAtlasRoadmapAnswerSheet(
            question: question,
            result: result,
          );
        }

        final lesson = result.lesson;

        if (lesson == null) {
          return AskAtlasEmptyAnswer(
            question: question,
            suggestions: repository.getLessons(),
            onSuggestionTap: (suggestedLesson) {
              Navigator.pop(sheetContext);

              show(
                context: context,
                question: suggestedLesson.title,
                repository: repository,
                explainerEngine: explainerEngine,
                onOpenLesson: onOpenLesson,
              );
            },
          );
        }

        return AskAtlasAnswerSheet(
          question: question,
          lesson: lesson,
          answer: result.answer,
          atlasTip: result.atlasTip,
          onOpenLesson: () {
            Navigator.pop(sheetContext);
            onOpenLesson(lesson);
          },
        );
      },
    );
  }
}