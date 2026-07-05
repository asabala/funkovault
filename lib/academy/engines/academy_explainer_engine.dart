import '../models/academy_lesson.dart';
import '../repository/academy_repository.dart';

class AcademyExplainerResult {
  const AcademyExplainerResult({
    required this.lesson,
    required this.answer,
    required this.atlasTip,
  });

  final AcademyLesson lesson;
  final String answer;
  final String atlasTip;
}

class AcademyExplainerEngine {
  const AcademyExplainerEngine({
    this.repository = const AcademyRepository(),
  });

  final AcademyRepository repository;

  AcademyExplainerResult? explain(String question) {
    final lesson = _findBestLesson(question);

    if (lesson == null) {
      return null;
    }

    return AcademyExplainerResult(
      lesson: lesson,
      answer: _buildAnswer(lesson),
      atlasTip: _bestTipForLesson(lesson),
    );
  }

  AcademyLesson? _findBestLesson(String question) {
    final normalizedQuestion = question.trim().toLowerCase();

    if (normalizedQuestion.isEmpty) {
      return null;
    }

    for (final lesson in repository.getLessons()) {
      if (lesson.title.toLowerCase() == normalizedQuestion) {
        return lesson;
      }

      if (normalizedQuestion.contains(lesson.title.toLowerCase())) {
        return lesson;
      }

      for (final keyword in lesson.searchKeywords) {
        if (normalizedQuestion.contains(keyword.toLowerCase())) {
          return lesson;
        }
      }
    }

    final results = repository.searchLessons(normalizedQuestion);

    if (results.isEmpty) {
      return null;
    }

    return results.first;
  }

  String _buildAnswer(AcademyLesson lesson) {
    final buffer = StringBuffer();

    buffer.writeln(lesson.quickAnswer);
    buffer.writeln();
    buffer.writeln(lesson.analogy);

    if (lesson.collectorWarning.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Collector Warning: ${lesson.collectorWarning}');
    }

    return buffer.toString().trim();
  }

  String _bestTipForLesson(AcademyLesson lesson) {
    if (lesson.atlasTips.isEmpty) {
      return 'Keep learning. Small details can make a big difference in collecting.';
    }

    return lesson.atlasTips.first;
  }
}