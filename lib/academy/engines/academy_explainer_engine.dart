import '../models/academy_lesson.dart';
import '../models/academy_topic.dart';
import '../repository/academy_repository.dart';

enum AcademyExplainerResultType {
  lesson,
  roadmapTopic,
}

class AcademyExplainerResult {
  const AcademyExplainerResult._({
    required this.type,
    required this.answer,
    required this.atlasTip,
    this.lesson,
    this.topic,
  });

  factory AcademyExplainerResult.lesson({
    required AcademyLesson lesson,
    required String answer,
    required String atlasTip,
  }) {
    return AcademyExplainerResult._(
      type: AcademyExplainerResultType.lesson,
      lesson: lesson,
      answer: answer,
      atlasTip: atlasTip,
    );
  }

  factory AcademyExplainerResult.roadmapTopic({
    required AcademyTopic topic,
    required String answer,
    required String atlasTip,
  }) {
    return AcademyExplainerResult._(
      type: AcademyExplainerResultType.roadmapTopic,
      topic: topic,
      answer: answer,
      atlasTip: atlasTip,
    );
  }

  final AcademyExplainerResultType type;
  final AcademyLesson? lesson;
  final AcademyTopic? topic;
  final String answer;
  final String atlasTip;

  bool get isLesson => type == AcademyExplainerResultType.lesson;
  bool get isRoadmapTopic => type == AcademyExplainerResultType.roadmapTopic;
}

class AcademyExplainerEngine {
  const AcademyExplainerEngine({
    this.repository = const AcademyRepository(),
  });

  final AcademyRepository repository;

  AcademyExplainerResult? explain(String question) {
    final lesson = _findBestLesson(question);

    if (lesson != null) {
      return AcademyExplainerResult.lesson(
        lesson: lesson,
        answer: _buildLessonAnswer(lesson),
        atlasTip: _bestTipForLesson(lesson),
      );
    }

    final topic = _findBestTopic(question);

    if (topic != null) {
      return AcademyExplainerResult.roadmapTopic(
        topic: topic,
        answer: _buildRoadmapTopicAnswer(topic),
        atlasTip: _bestTipForTopic(topic),
      );
    }

    return null;
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

  AcademyTopic? _findBestTopic(String question) {
    final normalizedQuestion = question.trim().toLowerCase();

    if (normalizedQuestion.isEmpty) {
      return null;
    }

    for (final topic in repository.getTopics()) {
      if (topic.title.toLowerCase() == normalizedQuestion) {
        return topic;
      }

      if (normalizedQuestion.contains(topic.title.toLowerCase())) {
        return topic;
      }

      for (final keyword in topic.searchKeywords) {
        if (normalizedQuestion.contains(keyword.toLowerCase())) {
          return topic;
        }
      }
    }

    final results = repository.searchTopics(normalizedQuestion);

    if (results.isEmpty) {
      return null;
    }

    return results.first;
  }

  String _buildLessonAnswer(AcademyLesson lesson) {
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

  String _buildRoadmapTopicAnswer(AcademyTopic topic) {
    final buffer = StringBuffer();

    buffer.writeln(topic.subtitle);
    buffer.writeln();

    if (topic.isAvailable) {
      buffer.writeln(
        'Atlas has this topic marked as available in Academy.',
      );
    } else {
      buffer.writeln(
        'Atlas recognizes this topic, but the full lesson is still on the Academy roadmap.',
      );
    }

    if (topic.isPremium) {
      buffer.writeln();
      buffer.writeln(
        'Premium Insight: This topic is planned for deeper Atlas intelligence tied to your Vault, values, condition risks, and collecting strategy.',
      );
    }

    return buffer.toString().trim();
  }

  String _bestTipForLesson(AcademyLesson lesson) {
    if (lesson.atlasTips.isEmpty) {
      return 'Keep learning. Small details can make a big difference in collecting.';
    }

    return lesson.atlasTips.first;
  }

  String _bestTipForTopic(AcademyTopic topic) {
    if (topic.isPremium) {
      return 'Premium topics are strongest when Atlas can connect the lesson to your actual Vault.';
    }

    return 'This topic is already on the Academy roadmap, so Atlas can grow into a full lesson for it later.';
  }
}