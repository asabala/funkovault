import '../models/academy_category.dart';

const funkoAcademyCategories = [
  AcademyCategory(
    id: 'funko_collector_basics',
    track: 'Funko Collecting',
    title: 'Collector Basics',
    subtitle: 'Learn the core terms every Funko collector should know.',
    icon: '🎓',
    lessonIds: [
      'funko_common',
      'funko_chase',
      'funko_grail',
      'funko_vaulted',
    ],
  ),
  AcademyCategory(
    id: 'funko_variants',
    track: 'Funko Collecting',
    title: 'Variants',
    subtitle: 'Understand Chase, Glow, Flocked, Metallic, and more.',
    icon: '✨',
    lessonIds: [],
  ),
  AcademyCategory(
    id: 'funko_stickers',
    track: 'Funko Collecting',
    title: 'Stickers & Exclusives',
    subtitle: 'Learn why stickers can change identity, rarity, and value.',
    icon: '🏷️',
    lessonIds: [],
  ),
  AcademyCategory(
    id: 'funko_formats',
    track: 'Funko Collecting',
    title: 'Figure Types',
    subtitle: 'Explore different product formats like Rides, Moments, and Jumbo.',
    icon: '📦',
    lessonIds: [],
  ),
];