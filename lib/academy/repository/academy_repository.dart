import '../data/funko_academy_categories.dart';
import '../data/funko_beginner_lessons.dart';
import '../models/academy_category.dart';
import '../models/academy_lesson.dart';

class AcademyRepository {
  const AcademyRepository();

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