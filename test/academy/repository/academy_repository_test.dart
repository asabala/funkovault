import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/academy/academy_ids.dart';
import 'package:funkovault2/academy/models/academy_category.dart';
import 'package:funkovault2/academy/models/academy_lesson.dart';
import 'package:funkovault2/academy/models/academy_topic.dart';
import 'package:funkovault2/academy/models/academy_track.dart';
import 'package:funkovault2/academy/repository/academy_repository.dart';

void main() {
  group('AcademyRepository metadata integrity', () {
    const AcademyRepository repository = AcademyRepository();

    test('track IDs are unique', () {
      final List<AcademyTrack> tracks = repository.getTracks();
      final Set<String> trackIds = tracks.map((track) => track.id).toSet();

      expect(trackIds.length, tracks.length);
    });

    test('track titles are unique', () {
      final List<AcademyTrack> tracks = repository.getTracks();
      final Set<String> trackTitles = tracks
          .map((track) => track.title.trim().toLowerCase())
          .toSet();

      expect(trackTitles.length, tracks.length);
    });

    test('category IDs are unique', () {
      final List<AcademyCategory> categories = repository.getCategories();
      final Set<String> ids = categories.map((category) => category.id).toSet();

      expect(ids.length, categories.length);
    });

    test('lesson IDs are unique', () {
      final List<AcademyLesson> lessons = repository.getLessons();
      final Set<String> ids = lessons.map((lesson) => lesson.id).toSet();

      expect(ids.length, lessons.length);
    });

    test('topic IDs are unique', () {
      final List<AcademyTopic> topics = repository.getTopics();
      final Set<String> ids = topics.map((topic) => topic.id).toSet();

      expect(ids.length, topics.length);
    });

    test('Funko Collecting exists and is available', () {
      final AcademyTrack? funkoTrack = repository.getTrackById(
        AcademyTrackIds.funkoCollecting,
      );

      expect(funkoTrack, isNotNull);
      expect(funkoTrack?.isAvailable, isTrue);
    });

    test('coming-soon tracks are not available', () {
      final List<AcademyTrack> comingSoonTracks = repository
          .getComingSoonTracks();

      expect(comingSoonTracks, isNotEmpty);
      expect(comingSoonTracks.every((track) => !track.isAvailable), isTrue);
    });

    test('every track category ID resolves and points back to its track', () {
      for (final AcademyTrack track in repository.getTracks()) {
        for (final String categoryId in track.categoryIds) {
          final AcademyCategory? category = repository.getCategoryById(
            categoryId,
          );

          expect(
            category,
            isNotNull,
            reason:
                'Track ${track.id} references missing category $categoryId.',
          );
          expect(
            category?.trackId,
            track.id,
            reason:
                'Category $categoryId does not point back to track ${track.id}.',
          );
        }
      }
    });

    test('every category resolves to and is referenced by its track', () {
      for (final AcademyCategory category in repository.getCategories()) {
        final AcademyTrack? track = repository.getTrackById(category.trackId);

        expect(
          track,
          isNotNull,
          reason:
              'Category ${category.id} references missing track '
              '${category.trackId}.',
        );
        expect(
          track?.categoryIds,
          contains(category.id),
          reason:
              'Track ${category.trackId} does not reference category '
              '${category.id}.',
        );
      }
    });

    test('every lesson track and category ID resolves consistently', () {
      for (final AcademyLesson lesson in repository.getLessons()) {
        final AcademyTrack? track = repository.getTrackById(lesson.trackId);
        final AcademyCategory? category = repository.getCategoryById(
          lesson.categoryId,
        );

        expect(
          track,
          isNotNull,
          reason:
              'Lesson ${lesson.id} references missing track ${lesson.trackId}.',
        );
        expect(
          category,
          isNotNull,
          reason:
              'Lesson ${lesson.id} references missing category '
              '${lesson.categoryId}.',
        );
        expect(
          category?.trackId,
          lesson.trackId,
          reason:
              'Lesson ${lesson.id} and category ${lesson.categoryId} '
              'reference different tracks.',
        );
      }
    });

    test(
      'every category lesson ID resolves and points back to its category',
      () {
        for (final AcademyCategory category in repository.getCategories()) {
          for (final String lessonId in category.lessonIds) {
            final AcademyLesson? lesson = repository.getLessonById(lessonId);

            expect(
              lesson,
              isNotNull,
              reason:
                  'Category ${category.id} references missing lesson $lessonId.',
            );
            expect(
              lesson?.categoryId,
              category.id,
              reason:
                  'Lesson $lessonId does not point back to category '
                  '${category.id}.',
            );
          }
        }
      },
    );

    test('every topic track ID resolves', () {
      for (final AcademyTopic topic in repository.getTopics()) {
        expect(
          repository.getTrackById(topic.trackId),
          isNotNull,
          reason:
              'Topic ${topic.id} references missing track ${topic.trackId}.',
        );
      }
    });

    test('Funko Collecting references all Funko categories in order', () {
      final AcademyTrack? track = repository.getTrackById(
        AcademyTrackIds.funkoCollecting,
      );

      expect(track?.categoryIds, const <String>[
        AcademyCategoryIds.funkoCollectorBasics,
        AcademyCategoryIds.funkoVariants,
        AcademyCategoryIds.funkoStickers,
        AcademyCategoryIds.funkoFormats,
      ]);
    });

    test('Funko track query returns all four categories in order', () {
      final List<String> categoryIds = repository
          .getCategoriesForTrack(AcademyTrackIds.funkoCollecting)
          .map((category) => category.id)
          .toList(growable: false);

      expect(categoryIds, const <String>[
        AcademyCategoryIds.funkoCollectorBasics,
        AcademyCategoryIds.funkoVariants,
        AcademyCategoryIds.funkoStickers,
        AcademyCategoryIds.funkoFormats,
      ]);
    });

    test('Funko track query returns all current lessons', () {
      final List<String> lessonIds = repository
          .getLessonsForTrack(AcademyTrackIds.funkoCollecting)
          .map((lesson) => lesson.id)
          .toList(growable: false);

      expect(lessonIds, const <String>[
        AcademyLessonIds.funkoCommon,
        AcademyLessonIds.funkoChase,
        AcademyLessonIds.funkoGrail,
        AcademyLessonIds.funkoVaulted,
      ]);
    });

    test('category lesson query preserves explicit lesson ordering', () {
      final List<String> lessonIds = repository
          .getLessonsForCategory(AcademyCategoryIds.funkoCollectorBasics)
          .map((lesson) => lesson.id)
          .toList(growable: false);

      expect(lessonIds, const <String>[
        AcademyLessonIds.funkoCommon,
        AcademyLessonIds.funkoChase,
        AcademyLessonIds.funkoGrail,
        AcademyLessonIds.funkoVaulted,
      ]);
    });

    test('lesson search includes resolved category presentation title', () {
      final List<AcademyLesson> results = repository.searchLessons(
        'Collector Basics',
      );

      expect(results, hasLength(4));
    });

    test('lesson search includes resolved track presentation title', () {
      final List<AcademyLesson> results = repository.searchLessons(
        'Funko Collecting',
      );

      expect(results, hasLength(4));
    });
  });
}
