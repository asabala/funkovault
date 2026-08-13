import '../academy_ids.dart';
import '../models/academy_category.dart';

const funkoAcademyCategories = [
  AcademyCategory(
    id: AcademyCategoryIds.funkoCollectorBasics,
    trackId: AcademyTrackIds.funkoCollecting,
    title: 'Collector Basics',
    subtitle: 'Learn the core terms every Funko collector should know.',
    icon: '🎓',
    lessonIds: [
      AcademyLessonIds.funkoCommon,
      AcademyLessonIds.funkoChase,
      AcademyLessonIds.funkoGrail,
      AcademyLessonIds.funkoVaulted,
    ],
  ),
  AcademyCategory(
    id: AcademyCategoryIds.funkoVariants,
    trackId: AcademyTrackIds.funkoCollecting,
    title: 'Variants',
    subtitle: 'Understand Chase, Glow, Flocked, Metallic, and more.',
    icon: '✨',
    lessonIds: [],
  ),
  AcademyCategory(
    id: AcademyCategoryIds.funkoStickers,
    trackId: AcademyTrackIds.funkoCollecting,
    title: 'Stickers & Exclusives',
    subtitle: 'Learn why stickers can change identity, rarity, and value.',
    icon: '🏷️',
    lessonIds: [],
  ),
  AcademyCategory(
    id: AcademyCategoryIds.funkoFormats,
    trackId: AcademyTrackIds.funkoCollecting,
    title: 'Figure Types',
    subtitle:
        'Explore different product formats like Rides, Moments, and Jumbo.',
    icon: '📦',
    lessonIds: [],
  ),
];
