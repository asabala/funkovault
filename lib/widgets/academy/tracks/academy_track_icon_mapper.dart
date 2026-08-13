import 'package:flutter/material.dart';

import '../../../academy/academy_ids.dart';

class AcademyTrackIconMapper {
  const AcademyTrackIconMapper._();

  static IconData iconFor(String trackId) {
    return switch (trackId) {
      AcademyTrackIds.funkoCollecting => Icons.school_rounded,
      AcademyTrackIds.pokemonCards => Icons.catching_pokemon_rounded,
      AcademyTrackIds.hotWheels => Icons.directions_car_rounded,
      AcademyTrackIds.sportsCards => Icons.sports_baseball_rounded,
      AcademyTrackIds.comics => Icons.menu_book_rounded,
      AcademyTrackIds.coins => Icons.paid_rounded,
      AcademyTrackIds.autographs => Icons.draw_rounded,
      _ => Icons.collections_bookmark_rounded,
    };
  }
}
