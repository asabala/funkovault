import '../academy_ids.dart';
import '../models/academy_lesson.dart';

const funkoBeginnerLessons = [
  AcademyLesson(
    id: AcademyLessonIds.funkoCommon,
    trackId: AcademyTrackIds.funkoCollecting,
    categoryId: AcademyCategoryIds.funkoCollectorBasics,
    title: 'Common',
    subtitle: 'The standard version of a collectible.',
    readingTimeMinutes: 2,
    difficulty: 'Beginner',
    quickAnswer:
        'A Common Funko Pop is the standard version of a figure. It is usually the easiest version to find and is often sold through major retailers and online stores.',
    deepAnswer:
        'A Common is the regular release of a Funko collectible. It is usually produced in larger quantities than special variants, exclusives, or limited editions. Commons are important because they form the foundation of most collections. Even though they are called Common, some can become harder to find or more valuable later if they are vaulted, tied to a popular character, or become harder to buy in good condition.',
    analogy:
        'Think of a Common like the regular version of a trading card before you start chasing rare holos, alternate arts, or special editions.',
    collectorWarning:
        'Do not ignore Commons completely. Some Commons can increase in value over time, especially after they are vaulted or become harder to find in good box condition.',
    sections: [
      AcademyLessonSection(
        heading: 'What is a Common?',
        body:
            'A Common is the standard version of a Funko collectible. It is usually mass-produced and widely available through major retailers and online stores.',
      ),
      AcademyLessonSection(
        heading: 'Why it matters',
        body:
            'Commons are the foundation of most collections. They are usually easier to find and are often the best way to start collecting a character, franchise, or set.',
      ),
      AcademyLessonSection(
        heading: 'Collector Note',
        body:
            'Commons do not always stay common forever. If a figure becomes vaulted, damaged stock disappears, or demand rises, some Commons can become more valuable over time.',
      ),
    ],
    atlasTips: [
      'Use Commons to build the foundation of your Vault before chasing rare variants.',
      'Track values anyway. Some Commons can rise after being vaulted.',
    ],
    searchKeywords: [
      'common',
      'standard',
      'regular',
      'basic pop',
      'regular release',
      'standard figure',
    ],
    relatedLessonIds: [
      AcademyLessonIds.funkoChase,
      AcademyLessonIds.funkoVaulted,
    ],
  ),
  AcademyLesson(
    id: AcademyLessonIds.funkoChase,
    trackId: AcademyTrackIds.funkoCollecting,
    categoryId: AcademyCategoryIds.funkoCollectorBasics,
    title: 'Chase',
    subtitle: 'A rarer variant randomly packed with Common figures.',
    readingTimeMinutes: 3,
    difficulty: 'Beginner',
    quickAnswer:
        'A Chase Funko Pop is a rarer variant of a standard Common figure. It usually keeps the same character and box number but has a special physical difference like a new pose, color, glow effect, accessory, or finish.',
    deepAnswer:
        'A Chase Funko Pop is a rare variant of a regular Common release. It is usually randomly packed into shipments, which makes it harder to find than the standard version. A Chase normally represents the same character and often shares the same box number as the Common, but it includes a noticeable difference such as a changed outfit, alternate paint, special finish, glow effect, different pose, or added detail. Because Chase figures are harder to find, collectors often value them more than the Common version.',
    analogy:
        'Think of a Chase like pulling a rare shiny Pokémon card or finding a mini-lottery prize while shopping.',
    collectorWarning:
        'Always verify the sticker, box number, condition, and variant details before buying a Chase. A Chase and a Common can look similar at first glance, but their values can be very different.',
    sections: [
      AcademyLessonSection(
        heading: 'What is a Chase?',
        body:
            'A Chase is a rarer version of a standard figure. It may have a different pose, color, paint style, accessory, or special finish.',
      ),
      AcademyLessonSection(
        heading: 'Why collectors want them',
        body:
            'Chase figures are harder to find because they are usually packed randomly in smaller quantities. That scarcity can make them more desirable than the Common version.',
      ),
      AcademyLessonSection(
        heading: 'Common odds',
        body:
            'Many Chase figures are commonly associated with 1-in-6 odds, but ratios can vary depending on the release, retailer, and product type.',
      ),
    ],
    atlasTips: [
      'Track Chase figures separately from Commons because values can be very different.',
      'Always verify the sticker, variant, and box condition before buying a Chase.',
    ],
    searchKeywords: [
      'chase',
      'rare variant',
      'chase variant',
      'chase sticker',
      '1 in 6',
      'alternate version',
      'special version',
      'common variant',
    ],
    relatedLessonIds: [
      AcademyLessonIds.funkoCommon,
      AcademyLessonIds.funkoGrail,
    ],
  ),
  AcademyLesson(
    id: AcademyLessonIds.funkoGrail,
    trackId: AcademyTrackIds.funkoCollecting,
    categoryId: AcademyCategoryIds.funkoCollectorBasics,
    title: 'Grail',
    subtitle: 'A highly desired collectible that collectors hunt for.',
    readingTimeMinutes: 3,
    difficulty: 'Beginner',
    quickAnswer:
        'A Grail is a collector term for a highly desired Pop or collectible. It is usually hard to find, expensive, personally meaningful, or one of the most wanted pieces in someone’s collection.',
    deepAnswer:
        'A Grail is not an official Funko product type. It is a collector term used for an item that feels special, rare, valuable, difficult to obtain, or personally important. Some Grails are expensive because they are old, vaulted, exclusive, signed, limited, or tied to a popular character. Other Grails may not be expensive but still matter deeply to a collector because they complete a set or represent a favorite character, movie, game, or memory.',
    analogy:
        'Think of a Grail like the dream item at the top of your collector wishlist — the one piece you would be excited to finally add to your Vault.',
    collectorWarning:
        'Do not chase price alone. A true Grail should matter to your collection. Always verify authenticity, condition, seller reputation, and recent market prices before buying.',
    sections: [
      AcademyLessonSection(
        heading: 'What is a Grail?',
        body:
            'A Grail is a collector term for a highly desired, hard-to-find, or expensive item. It is not an official product type. It is a community term used for special pieces collectors want most.',
      ),
      AcademyLessonSection(
        heading: 'What makes a Pop a Grail?',
        body:
            'A Grail may be vaulted, old, limited, signed, exclusive, low-production, or connected to a very popular character or franchise.',
      ),
      AcademyLessonSection(
        heading: 'Value warning',
        body:
            'Grails can be expensive and prices can move quickly. Always verify authenticity, condition, seller reputation, and recent market sales before buying.',
      ),
    ],
    atlasTips: [
      'Use your Dream Grail field to tell Atlas what you are working toward.',
      'Do not chase value alone. A true Grail should matter to your collection.',
    ],
    searchKeywords: [
      'grail',
      'dream grail',
      'rare pop',
      'expensive pop',
      'wishlist',
      'hard to find',
      'valuable',
      'personal grail',
    ],
    relatedLessonIds: [
      AcademyLessonIds.funkoVaulted,
      AcademyLessonIds.funkoChase,
    ],
  ),
  AcademyLesson(
    id: AcademyLessonIds.funkoVaulted,
    trackId: AcademyTrackIds.funkoCollecting,
    categoryId: AcademyCategoryIds.funkoCollectorBasics,
    title: 'Vaulted',
    subtitle: 'A retired collectible that is no longer being produced.',
    readingTimeMinutes: 3,
    difficulty: 'Beginner',
    quickAnswer:
        'Vaulted means a Funko product has been retired from production. In simple terms, Funko is no longer actively making new units of that item.',
    deepAnswer:
        'When a Funko Pop is vaulted, it means the product has been retired from production. This can make collectors pay closer attention because the available supply may become limited over time. However, vaulted does not automatically mean rare or valuable. Demand, character popularity, age, condition, exclusivity, and how many were produced all still matter.',
    analogy:
        'Think of Vaulted like a retired sneaker release or an out-of-print trading card set. New ones are not being made, so collectors rely on the remaining supply.',
    collectorWarning:
        'Vaulted status is only one piece of the value puzzle. A vaulted Pop with low demand may stay affordable, while a vaulted Pop with strong demand can rise quickly.',
    sections: [
      AcademyLessonSection(
        heading: 'What does Vaulted mean?',
        body:
            'Vaulted means a Funko product has been retired from production. In most cases, that means no new units are being manufactured.',
      ),
      AcademyLessonSection(
        heading: 'Why it matters',
        body:
            'Once a figure is vaulted, collectors often pay more attention to it because supply may become limited over time.',
      ),
      AcademyLessonSection(
        heading: 'Important reminder',
        body:
            'Vaulted does not automatically mean valuable. Demand, character popularity, condition, rarity, and timing all affect value.',
      ),
    ],
    atlasTips: [
      'Vaulted status is one signal, not the whole story.',
      'A vaulted Pop with strong demand can become a long-term collection highlight.',
    ],
    searchKeywords: [
      'vaulted',
      'retired',
      'no longer made',
      'out of production',
      'retired pop',
      'vault',
      'discontinued',
    ],
    relatedLessonIds: [
      AcademyLessonIds.funkoCommon,
      AcademyLessonIds.funkoGrail,
    ],
  ),
];
