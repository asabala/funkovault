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

  bool get isLesson {
    return type ==
        AcademyExplainerResultType.lesson;
  }

  bool get isRoadmapTopic {
    return type ==
        AcademyExplainerResultType.roadmapTopic;
  }
}

class AcademyExplainerEngine {
  const AcademyExplainerEngine({
    this.repository = const AcademyRepository(),
  });

  final AcademyRepository repository;

  AcademyExplainerResult? explain(
      String question,
      ) {
    final String normalizedQuestion =
    _normalizeText(
      question,
    );

    if (normalizedQuestion.isEmpty) {
      return null;
    }

    final AcademyLesson? lesson =
    _findBestLesson(
      normalizedQuestion,
    );

    if (lesson != null) {
      return AcademyExplainerResult.lesson(
        lesson: lesson,
        answer: _buildLessonAnswer(
          lesson,
        ),
        atlasTip: _bestTipForLesson(
          lesson,
        ),
      );
    }

    final AcademyTopic? topic =
    _findBestTopic(
      normalizedQuestion,
    );

    if (topic != null) {
      return AcademyExplainerResult.roadmapTopic(
        topic: topic,
        answer: _buildRoadmapTopicAnswer(
          topic,
        ),
        atlasTip: _bestTipForTopic(
          topic,
        ),
      );
    }

    return null;
  }

  AcademyLesson? _findBestLesson(
      String normalizedQuestion,
      ) {
    for (final AcademyLesson lesson
    in repository.getLessons()) {
      final String normalizedTitle =
      _normalizeText(
        lesson.title,
      );

      if (normalizedTitle.isNotEmpty &&
          normalizedQuestion ==
              normalizedTitle) {
        return lesson;
      }
    }

    for (final AcademyLesson lesson
    in repository.getLessons()) {
      if (_containsPhrase(
        normalizedQuestion,
        lesson.title,
      )) {
        return lesson;
      }
    }

    for (final AcademyLesson lesson
    in repository.getLessons()) {
      if (_matchesAnyKeyword(
        normalizedQuestion,
        lesson.searchKeywords,
      )) {
        return lesson;
      }
    }

    final List<AcademyLesson> results =
    repository.searchLessons(
      normalizedQuestion,
    );

    if (results.isEmpty) {
      return null;
    }

    return results.first;
  }

  AcademyTopic? _findBestTopic(
      String normalizedQuestion,
      ) {
    for (final AcademyTopic topic
    in repository.getTopics()) {
      final String normalizedTitle =
      _normalizeText(
        topic.title,
      );

      if (normalizedTitle.isNotEmpty &&
          normalizedQuestion ==
              normalizedTitle) {
        return topic;
      }
    }

    for (final AcademyTopic topic
    in repository.getTopics()) {
      if (_containsPhrase(
        normalizedQuestion,
        topic.title,
      )) {
        return topic;
      }
    }

    for (final AcademyTopic topic
    in repository.getTopics()) {
      if (_matchesAnyKeyword(
        normalizedQuestion,
        topic.searchKeywords,
      )) {
        return topic;
      }
    }

    final List<AcademyTopic> results =
    repository.searchTopics(
      normalizedQuestion,
    );

    if (results.isEmpty) {
      return null;
    }

    return results.first;
  }

  String _buildLessonAnswer(
      AcademyLesson lesson,
      ) {
    final List<String> answerParts =
    <String>[];

    _addIfNotEmpty(
      answerParts,
      lesson.quickAnswer,
    );

    _addIfNotEmpty(
      answerParts,
      lesson.analogy,
    );

    final String collectorWarning =
    lesson.collectorWarning.trim();

    if (collectorWarning.isNotEmpty) {
      answerParts.add(
        'Collector Warning: $collectorWarning',
      );
    }

    if (answerParts.isEmpty) {
      return 'Atlas has an approved Academy lesson for this topic, '
          'but the explanation is still being expanded.';
    }

    return answerParts.join(
      '\n\n',
    );
  }

  String _buildRoadmapTopicAnswer(
      AcademyTopic topic,
      ) {
    final List<String> answerParts =
    <String>[];

    _addIfNotEmpty(
      answerParts,
      topic.subtitle,
    );

    if (topic.isAvailable) {
      answerParts.add(
        'Atlas has this topic marked as available in Academy.',
      );
    } else {
      answerParts.add(
        'Atlas recognizes this topic, but the full lesson is still on the Academy roadmap.',
      );
    }

    if (topic.isPremium) {
      answerParts.add(
        'Premium Insight: This topic is planned for deeper Atlas intelligence tied to your Vault, values, condition risks, and collecting strategy.',
      );
    }

    return answerParts.join(
      '\n\n',
    );
  }

  String _bestTipForLesson(
      AcademyLesson lesson,
      ) {
    for (final String tip
    in lesson.atlasTips) {
      final String cleanedTip =
      tip.trim();

      if (cleanedTip.isNotEmpty) {
        return cleanedTip;
      }
    }

    return 'Keep learning. Small details can make a big difference in collecting.';
  }

  String _bestTipForTopic(
      AcademyTopic topic,
      ) {
    if (topic.isPremium) {
      return 'Premium topics are strongest when Atlas can connect the lesson to your actual Vault.';
    }

    return 'This topic is already on the Academy roadmap, so Atlas can grow into a full lesson for it later.';
  }

  static bool _matchesAnyKeyword(
      String normalizedQuestion,
      List<String> keywords,
      ) {
    for (final String keyword in keywords) {
      if (_containsPhrase(
        normalizedQuestion,
        keyword,
      )) {
        return true;
      }
    }

    return false;
  }

  static bool _containsPhrase(
      String normalizedQuestion,
      String value,
      ) {
    final String normalizedValue =
    _normalizeText(
      value,
    );

    if (normalizedValue.isEmpty) {
      return false;
    }

    final String paddedQuestion =
        ' $normalizedQuestion ';

    final String paddedValue =
        ' $normalizedValue ';

    return paddedQuestion.contains(
      paddedValue,
    );
  }

  static String _normalizeText(
      String value,
      ) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(
      RegExp(r'[^a-z0-9]+'),
      ' ',
    )
        .replaceAll(
      RegExp(r'\s+'),
      ' ',
    )
        .trim();
  }

  static void _addIfNotEmpty(
      List<String> target,
      String value,
      ) {
    final String cleaned =
    value.trim();

    if (cleaned.isNotEmpty) {
      target.add(
        cleaned,
      );
    }
  }
}