import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/academy/academy_ids.dart';
import 'package:funkovault2/academy/models/academy_track.dart';
import 'package:funkovault2/academy/repository/academy_repository.dart';

void main() {
  group('AcademyRepository track metadata', () {
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

    test('available track category IDs resolve to categories', () {
      for (final AcademyTrack track in repository.getAvailableTracks()) {
        for (final String categoryId in track.categoryIds) {
          expect(
            repository.getCategoryById(categoryId),
            isNotNull,
            reason:
                'Track ${track.id} references missing category $categoryId.',
          );
        }
      }
    });
  });
}
