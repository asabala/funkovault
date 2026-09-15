import '../academy_ids.dart';
import '../repository/academy_repository.dart';

class AskAtlasSuggestionsBuilder {
  const AskAtlasSuggestionsBuilder._();

  static List<String> buildFunkoSuggestions({
    required AcademyRepository repository,
  }) {
    final List<String> suggestions = <String>[];

    final Set<String> seen = <String>{};

    for (final lesson in repository.getLessons()) {
      _addSuggestion(
        suggestions: suggestions,
        seen: seen,
        value: _questionForTitle(lesson.title),
      );
    }

    for (final topic
        in repository
            .getRoadmapTopicsForTrack(AcademyTrackIds.funkoCollecting)
            .take(4)) {
      _addSuggestion(
        suggestions: suggestions,
        seen: seen,
        value: _questionForTitle(topic.title),
      );
    }

    return List<String>.unmodifiable(suggestions);
  }

  static String _questionForTitle(String title) {
    final String cleanedTitle = title.trim();

    if (cleanedTitle.isEmpty) {
      return '';
    }

    if (cleanedTitle.endsWith('?')) {
      return cleanedTitle;
    }

    return 'What is $cleanedTitle?';
  }

  static void _addSuggestion({
    required List<String> suggestions,
    required Set<String> seen,
    required String value,
  }) {
    final String cleanedValue = value.trim();

    if (cleanedValue.isEmpty) {
      return;
    }

    final String normalized = cleanedValue.toLowerCase();

    if (!seen.add(normalized)) {
      return;
    }

    suggestions.add(cleanedValue);
  }
}
