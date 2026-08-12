import 'package:flutter/material.dart';

import '../academy_ids.dart';
import '../models/academy_track_selector_item.dart';

export '../models/academy_track_selector_item.dart';

class AcademyTrackSelectorItems {
  const AcademyTrackSelectorItems._();

  static const List<AcademyTrackSelectorItem> all =
  <AcademyTrackSelectorItem>[
    AcademyTrackSelectorItem(
      id: AcademyTrackIds.funkoCollecting,
      title: AcademyTrackTitles.funkoCollecting,
      subtitle:
      'Learn Funko basics, stickers, variants, value, and collecting terms.',
      icon: Icons.school_rounded,
      isAvailable: true,
      badge: 'Active',
    ),
    AcademyTrackSelectorItem(
      id: AcademyTrackIds.pokemonCards,
      title: AcademyTrackTitles.pokemonCards,
      subtitle:
      'Card grading, rarity, sets, condition, pulls, and collecting basics.',
      icon: Icons.catching_pokemon_rounded,
      isAvailable: false,
      badge: 'Soon',
    ),
    AcademyTrackSelectorItem(
      id: AcademyTrackIds.hotWheels,
      title: AcademyTrackTitles.hotWheels,
      subtitle:
      'Treasure Hunts, Super Treasure Hunts, castings, and card condition.',
      icon: Icons.directions_car_rounded,
      isAvailable: false,
      badge: 'Soon',
    ),
    AcademyTrackSelectorItem(
      id: AcademyTrackIds.sportsCards,
      title: AcademyTrackTitles.sportsCards,
      subtitle:
      'Rookies, parallels, inserts, grading, comps, and market basics.',
      icon: Icons.sports_baseball_rounded,
      isAvailable: false,
      badge: 'Soon',
    ),
    AcademyTrackSelectorItem(
      id: AcademyTrackIds.comics,
      title: AcademyTrackTitles.comics,
      subtitle:
      'Keys, variants, grades, first appearances, and collector terms.',
      icon: Icons.menu_book_rounded,
      isAvailable: false,
      badge: 'Soon',
    ),
    AcademyTrackSelectorItem(
      id: AcademyTrackIds.coins,
      title: AcademyTrackTitles.coins,
      subtitle:
      'Mint marks, grading, errors, condition, and long-term value basics.',
      icon: Icons.paid_rounded,
      isAvailable: false,
      badge: 'Soon',
    ),
    AcademyTrackSelectorItem(
      id: AcademyTrackIds.autographs,
      title: AcademyTrackTitles.autographs,
      subtitle:
      'Authentication, certificates, signatures, inscriptions, and value impact.',
      icon: Icons.draw_rounded,
      isAvailable: false,
      badge: 'Soon',
    ),
  ];
}