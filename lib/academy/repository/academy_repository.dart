import '../data/academy_tracks.dart';
import '../data/funko_academy_categories.dart';
import '../data/funko_academy_topics.dart';
import '../data/funko_beginner_lessons.dart';
import '../models/academy_category.dart';
import '../models/academy_lesson.dart';
import '../models/academy_topic.dart';
import '../models/academy_track.dart';

class AcademyRepository {
  const AcademyRepository();

  List<AcademyTrack> getTracks() {
    return List<AcademyTrack>.unmodifiable(academyTracks);
  }

  List<AcademyTrack> getAvailableTracks() {
    return getTracks()
        .where((AcademyTrack track) => track.isAvailable)
        .toList(growable: false);
  }

  List<AcademyTrack> getComingSoonTracks() {
    return getTracks()
        .where((AcademyTrack track) => !track.isAvailable)
        .toList(growable: false);
  }

  AcademyTrack? getTrackById(String id) {
    final String normalizedId = id.trim();

    if (normalizedId.isEmpty) {
      return null;
    }

    for (final AcademyTrack track in getTracks()) {
      if (track.id == normalizedId) {
        return track;
      }
    }

    return null;
  }

  List<AcademyTopic> getTopics() {
    return List<AcademyTopic>.unmodifiable(funkoAcademyTopics);
  }

  List<AcademyTopic> getTopicsForTrack(String trackId) {
    final String normalizedTrackId = trackId.trim();

    if (normalizedTrackId.isEmpty) {
      return const <AcademyTopic>[];
    }

    return getTopics()
        .where((AcademyTopic topic) => topic.trackId == normalizedTrackId)
        .toList(growable: false);
  }

  List<AcademyTopic> getAvailableTopicsForTrack(String trackId) {
    return getTopicsForTrack(
      trackId,
    ).where((AcademyTopic topic) => topic.isAvailable).toList(growable: false);
  }

  List<AcademyTopic> getRoadmapTopicsForTrack(String trackId) {
    return getTopicsForTrack(
      trackId,
    ).where((AcademyTopic topic) => !topic.isAvailable).toList(growable: false);
  }

  List<AcademyTopic> getPremiumTopicsForTrack(String trackId) {
    return getTopicsForTrack(
      trackId,
    ).where((AcademyTopic topic) => topic.isPremium).toList(growable: false);
  }

  List<AcademyTopic> getFreeTopicsForTrack(String trackId) {
    return getTopicsForTrack(
      trackId,
    ).where((AcademyTopic topic) => !topic.isPremium).toList(growable: false);
  }

  AcademyTopic? getTopicById(String id) {
    final String normalizedId = id.trim();

    if (normalizedId.isEmpty) {
      return null;
    }

    for (final AcademyTopic topic in getTopics()) {
      if (topic.id == normalizedId) {
        return topic;
      }
    }

    return null;
  }

  List<AcademyTopic> searchTopics(String query) {
    final String normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return const <AcademyTopic>[];
    }

    return getTopics()
        .where((AcademyTopic topic) {
          final String searchableText = <String>[
            topic.title,
            topic.subtitle,
            topic.category,
            ...topic.searchKeywords,
          ].join(' ').toLowerCase();

          return searchableText.contains(normalizedQuery);
        })
        .toList(growable: false);
  }

  List<AcademyCategory> getCategories() {
    return List<AcademyCategory>.unmodifiable(funkoAcademyCategories);
  }

  List<AcademyLesson> getLessons() {
    return List<AcademyLesson>.unmodifiable(funkoBeginnerLessons);
  }

  List<AcademyCategory> getCategoriesForTrack(String trackId) {
    final String normalizedTrackId = trackId.trim();

    if (normalizedTrackId.isEmpty) {
      return const <AcademyCategory>[];
    }

    return getCategories()
        .where(
          (AcademyCategory category) => category.trackId == normalizedTrackId,
        )
        .toList(growable: false);
  }

  List<AcademyLesson> getLessonsForTrack(String trackId) {
    final String normalizedTrackId = trackId.trim();

    if (normalizedTrackId.isEmpty) {
      return const <AcademyLesson>[];
    }

    return getLessons()
        .where((AcademyLesson lesson) => lesson.trackId == normalizedTrackId)
        .toList(growable: false);
  }

  List<AcademyLesson> getLessonsForCategory(String categoryId) {
    final AcademyCategory? category = getCategoryById(categoryId);

    if (category == null) {
      return const <AcademyLesson>[];
    }

    return category.lessonIds
        .map(getLessonById)
        .whereType<AcademyLesson>()
        .toList(growable: false);
  }

  AcademyCategory? getCategoryById(String id) {
    final String normalizedId = id.trim();

    if (normalizedId.isEmpty) {
      return null;
    }

    for (final AcademyCategory category in getCategories()) {
      if (category.id == normalizedId) {
        return category;
      }
    }

    return null;
  }

  AcademyLesson? getLessonById(String id) {
    final String normalizedId = id.trim();

    if (normalizedId.isEmpty) {
      return null;
    }

    for (final AcademyLesson lesson in getLessons()) {
      if (lesson.id == normalizedId) {
        return lesson;
      }
    }

    return null;
  }

  List<AcademyLesson> searchLessons(String query) {
    final String normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return const <AcademyLesson>[];
    }

    return getLessons()
        .where((AcademyLesson lesson) {
          final AcademyTrack? track = getTrackById(lesson.trackId);
          final AcademyCategory? category = getCategoryById(lesson.categoryId);

          final String searchableText = <String>[
            lesson.title,
            lesson.subtitle,
            category?.title ?? '',
            track?.title ?? '',
            lesson.quickAnswer,
            lesson.deepAnswer,
            lesson.analogy,
            lesson.collectorWarning,
            ...lesson.atlasTips,
            ...lesson.searchKeywords,
          ].join(' ').toLowerCase();

          return searchableText.contains(normalizedQuery);
        })
        .toList(growable: false);
  }
}
