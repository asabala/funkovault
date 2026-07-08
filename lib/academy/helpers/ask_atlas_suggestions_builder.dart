import '../academy_ids.dart';
import '../repository/academy_repository.dart';

class AskAtlasSuggestionsBuilder {
  const AskAtlasSuggestionsBuilder._();

  static List<String> buildFunkoSuggestions({
    required AcademyRepository repository,
  }) {
    return [
      ...repository.getLessons().map(
            (lesson) => 'What is a ${lesson.title}?',
      ),
      ...repository
          .getRoadmapTopicsForTrack(AcademyTrackIds.funkoCollecting)
          .take(4)
          .map(
            (topic) => 'What is ${topic.title}?',
      ),
    ];
  }
}