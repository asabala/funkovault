import '../academy_ids.dart';
import '../models/academy_track.dart';

const List<AcademyTrack> academyTracks = <AcademyTrack>[
  AcademyTrack(
    id: AcademyTrackIds.funkoCollecting,
    title: 'Funko Collecting',
    subtitle:
        'Learn the foundation terms, variants, value signals, and collector habits behind Funko Pop collecting.',
    description:
        'Atlas starts with Funko Collecting because it is the first supported collecting track in your Vault. More collectible tracks can be added later without rebuilding Academy.',
    emoji: '🎓',
    status: 'Available now',
    isAvailable: true,
    categoryIds: [
      AcademyCategoryIds.funkoCollectorBasics,
      AcademyCategoryIds.funkoVariants,
      AcademyCategoryIds.funkoStickers,
      AcademyCategoryIds.funkoFormats,
    ],
    searchKeywords: [
      'funko',
      'pop',
      'chase',
      'grail',
      'vaulted',
      'common',
      'collector basics',
    ],
  ),
  AcademyTrack(
    id: AcademyTrackIds.pokemonCards,
    title: 'Pokémon Cards',
    subtitle:
        'Learn card rarity, sets, grading, condition, value signals, and collecting strategy.',
    description: 'A future Academy track for Pokémon card collectors.',
    emoji: '🃏',
    status: 'Coming later',
    isAvailable: false,
    categoryIds: [],
    searchKeywords: ['pokemon', 'cards', 'tcg', 'graded cards', 'rarity'],
  ),
  AcademyTrack(
    id: AcademyTrackIds.hotWheels,
    title: 'Hot Wheels',
    subtitle:
        'Learn mainlines, treasure hunts, supers, variations, condition, and collector value.',
    description: 'A future Academy track for die-cast vehicle collectors.',
    emoji: '🏎️',
    status: 'Coming later',
    isAvailable: false,
    categoryIds: [],
    searchKeywords: [
      'hot wheels',
      'die cast',
      'treasure hunt',
      'super treasure hunt',
      'variation',
    ],
  ),
  AcademyTrack(
    id: AcademyTrackIds.sportsCards,
    title: 'Sports Cards',
    subtitle:
        'Learn rookies, parallels, inserts, grading, condition, comps, and market trends.',
    description: 'A future Academy track for sports card collectors.',
    emoji: '🏆',
    status: 'Coming later',
    isAvailable: false,
    categoryIds: [],
    searchKeywords: [
      'sports cards',
      'rookie card',
      'parallel',
      'insert',
      'grading',
    ],
  ),
  AcademyTrack(
    id: AcademyTrackIds.comics,
    title: 'Comics',
    subtitle:
        'Learn keys, first appearances, variants, grades, slabs, and comic value signals.',
    description: 'A future Academy track for comic collectors.',
    emoji: '📚',
    status: 'Coming later',
    isAvailable: false,
    categoryIds: [],
    searchKeywords: [
      'comics',
      'comic books',
      'key issue',
      'variant cover',
      'first appearance',
    ],
  ),
  AcademyTrack(
    id: AcademyTrackIds.coins,
    title: 'Coins',
    subtitle:
        'Learn mint marks, condition, grading, rarity, errors, and historical value.',
    description: 'A future Academy track for coin collectors.',
    emoji: '🪙',
    status: 'Coming later',
    isAvailable: false,
    categoryIds: [],
    searchKeywords: [
      'coins',
      'mint mark',
      'coin grading',
      'rare coin',
      'error coin',
    ],
  ),
  AcademyTrack(
    id: AcademyTrackIds.autographs,
    title: 'Autographs',
    subtitle:
        'Learn authentication, certificates, provenance, condition, and display protection.',
    description: 'A future Academy track for autograph collectors.',
    emoji: '✍️',
    status: 'Coming later',
    isAvailable: false,
    categoryIds: [],
    searchKeywords: [
      'autographs',
      'signature',
      'authentication',
      'certificate',
      'coa',
    ],
  ),
];
