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
    return academyTracks;
  }

  List<AcademyTrack> getAvailableTracks() {
    return getTracks()
        .where((track) => track.isAvailable)
        .toList();
  }

  List<AcademyTrack> getComingSoonTracks() {
    return getTracks()
        .where((track) => !track.isAvailable)
        .toList();
  }

  AcademyTrack? getTrackById(String id) {
    for (final track in getTracks()) {
      if (track.id == id) {
        return track;
      }
    }

    return null;
  }

  AcademyTrack? getTrackByTitle(String title) {
    final normalizedTitle = title.trim().toLowerCase();

    for (final track in getTracks()) {
      if (track.title.toLowerCase() == normalizedTitle) {
        return track;
      }
    }

    return null;
  }

  List<AcademyTopic> getTopics() {
    return funkoAcademyTopics;
  }

  List<AcademyTopic> getTopicsForTrack(String trackId) {
    return getTopics()
        .where((topic) => topic.trackId == trackId)
        .toList();
  }

  List<AcademyTopic> getAvailableTopicsForTrack(String trackId) {
    return getTopicsForTrack(trackId)
        .where((topic) => topic.isAvailable)
        .toList();
  }

  List<AcademyTopic> getRoadmapTopicsForTrack(String trackId) {
    return getTopicsForTrack(trackId)
        .where((topic) => !topic.isAvailable)
        .toList();
  }

  List<AcademyTopic> getPremiumTopicsForTrack(String trackId) {
    return getTopicsForTrack(trackId)
        .where((topic) => topic.isPremium)
        .toList();
  }

  List<AcademyTopic> getFreeTopicsForTrack(String trackId) {
    return getTopicsForTrack(trackId)
        .where((topic) => !topic.isPremium)
        .toList();
  }

  AcademyTopic? getTopicById(String id) {
    for (final topic in getTopics()) {
      if (topic.id == id) {
        return topic;
      }
    }

    return null;
  }

  List<AcademyTopic> searchTopics(String query) {
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return [];
    }

    return getTopics().where((topic) {
      final searchableText = [
        topic.title,
        topic.subtitle,
        topic.category,
        ...topic.searchKeywords,
      ].join(' ').toLowerCase();

      return searchableText.contains(normalizedQuery);
    }).toList();
  }

  List<AcademyCategory> getCategories() {
    return funkoAcademyCategories;
  }

  List<AcademyLesson> getLessons() {
    return funkoBeginnerLessons;
  }

  List<AcademyCategory> getCategoriesForTrack(String track) {
    return getCategories()
        .where((category) => category.track == track)
        .toList();
  }

  List<AcademyLesson> getLessonsForTrack(String track) {
    return getLessons()
        .where((lesson) => lesson.track == track)
        .toList();
  }

  List<AcademyLesson> getLessonsForCategory(String categoryId) {
    final category = getCategoryById(categoryId);

    if (category == null) {
      return [];
    }

    return category.lessonIds
        .map(getLessonById)
        .whereType<AcademyLesson>()
        .toList();
  }

  AcademyCategory? getCategoryById(String id) {
    for (final category in getCategories()) {
      if (category.id == id) {
        return category;
      }
    }

    return null;
  }

  AcademyLesson? getLessonById(String id) {
    for (final lesson in getLessons()) {
      if (lesson.id == id) {
        return lesson;
      }
    }

    return null;
  }

  List<AcademyLesson> searchLessons(String query) {
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return [];
    }

    return getLessons().where((lesson) {
      final searchableText = [
        lesson.title,
        lesson.subtitle,
        lesson.category,
        lesson.track,
        lesson.quickAnswer,
        lesson.deepAnswer,
        lesson.analogy,
        lesson.collectorWarning,
        ...lesson.atlasTips,
        ...lesson.searchKeywords,
      ].join(' ').toLowerCase();

      return searchableText.contains(normalizedQuery);
    }).toList();
  }
}