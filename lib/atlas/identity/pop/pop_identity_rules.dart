import 'pop_identity_rule.dart';

abstract final class PopIdentityRules {
  static const List<PopIdentityRule> all = [
    // ============================================================
    // VARIANT AND FINISH RULES
    // ============================================================

    PopIdentityRule(
      id: 'chase',
      emoji: '🔥',
      label: 'Chase',
      targetScopes: {
        PopIdentityScope.variant,
        PopIdentityScope.collectorLabel,
      },
      keywords: [
        'chase',
        'chase variant',
        'glow chase',
        'metallic chase',
      ],
    ),
    PopIdentityRule(
      id: 'glow',
      emoji: '✨',
      label: 'Glow in the Dark',
      targetScopes: {
        PopIdentityScope.variant,
        PopIdentityScope.collectorLabel,
      },
      keywords: [
        'glow in the dark',
        'glow-in-the-dark',
        'gitd',
        'glow',
      ],
    ),
    PopIdentityRule(
      id: 'blacklight',
      emoji: '🎨',
      label: 'Blacklight',
      targetScopes: {
        PopIdentityScope.variant,
        PopIdentityScope.collectorLabel,
      },
      keywords: [
        'blacklight',
        'black light',
      ],
    ),
    PopIdentityRule(
      id: 'diamond',
      emoji: '💎',
      label: 'Diamond',
      targetScopes: {
        PopIdentityScope.variant,
        PopIdentityScope.collectorLabel,
      },
      keywords: [
        'diamond collection',
        'diamond edition',
        'diamond',
        'glitter',
      ],
    ),
    PopIdentityRule(
      id: 'flocked',
      emoji: '🐑',
      label: 'Flocked',
      targetScopes: {
        PopIdentityScope.variant,
        PopIdentityScope.collectorLabel,
      },
      keywords: [
        'flocked',
        'flock',
      ],
    ),
    PopIdentityRule(
      id: 'metallic',
      emoji: '🪙',
      label: 'Metallic',
      targetScopes: {
        PopIdentityScope.variant,
        PopIdentityScope.collectorLabel,
      },
      keywords: [
        'metallic',
        'chrome',
        'gold chrome',
        'silver chrome',
      ],
    ),
    PopIdentityRule(
      id: 'scented',
      emoji: '🌸',
      label: 'Scented',
      targetScopes: {
        PopIdentityScope.variant,
      },
      keywords: [
        'scented',
        'scent',
      ],
    ),
    PopIdentityRule(
      id: 'art_series',
      emoji: '🖼️',
      label: 'Art Series',
      targetScopes: {
        PopIdentityScope.variant,
        PopIdentityScope.collectorLabel,
      },
      keywords: [
        'art series',
      ],
    ),
    PopIdentityRule(
      id: 'nft',
      emoji: '🌐',
      label: 'NFT',
      targetScopes: {
        PopIdentityScope.variant,
        PopIdentityScope.collectorLabel,
      },
      keywords: [
        'nft',
        'digital pop',
        'digital collectible',
      ],
    ),
    PopIdentityRule(
      id: 'translucent',
      emoji: '🫧',
      label: 'Translucent',
      targetScopes: {
        PopIdentityScope.variant,
      },
      keywords: [
        'translucent',
        'transparent',
        'clear variant',
        'clear edition',
      ],
    ),
    PopIdentityRule(
      id: 'bloody',
      emoji: '🩸',
      label: 'Bloody',
      targetScopes: {
        PopIdentityScope.variant,
      },
      keywords: [
        'bloody',
        'blood splatter',
        'blood-splatter',
        'blood splattered',
      ],
    ),
    PopIdentityRule(
      id: 'pearlescent',
      emoji: '🦪',
      label: 'Pearlescent',
      targetScopes: {
        PopIdentityScope.variant,
      },
      keywords: [
        'pearlescent',
        'pearl finish',
        'pearl edition',
        'opal',
      ],
    ),
    PopIdentityRule(
      id: 'patina',
      emoji: '🏺',
      label: 'Patina',
      targetScopes: {
        PopIdentityScope.variant,
      },
      keywords: [
        'patina',
        'rust finish',
        'bronze finish',
      ],
    ),
    PopIdentityRule(
      id: 'light_up',
      emoji: '💡',
      label: 'Light-Up',
      targetScopes: {
        PopIdentityScope.variant,
      },
      keywords: [
        'light up',
        'light-up',
        'lights up',
      ],
    ),
    PopIdentityRule(
      id: 'sound',
      emoji: '🔊',
      label: 'Sound',
      targetScopes: {
        PopIdentityScope.variant,
      },
      keywords: [
        'sound edition',
        'sound feature',
        'with sound',
      ],
    ),
    PopIdentityRule(
      id: 'prototype',
      emoji: '🧪',
      label: 'Prototype',
      targetScopes: {
        PopIdentityScope.variant,
        PopIdentityScope.collectorLabel,
      },
      keywords: [
        'prototype',
        'proto',
      ],
    ),
    PopIdentityRule(
      id: 'unmasked',
      emoji: '👤',
      label: 'Unmasked',
      targetScopes: {
        PopIdentityScope.variant,
      },
      keywords: [
        'unmasked',
        'no mask',
      ],
    ),
    PopIdentityRule(
      id: 'masked',
      emoji: '🥷',
      label: 'Masked',
      targetScopes: {
        PopIdentityScope.variant,
      },
      keywords: [
        'masked',
        'with mask',
      ],
    ),
    PopIdentityRule(
      id: 'helmeted',
      emoji: '🪖',
      label: 'Helmeted',
      targetScopes: {
        PopIdentityScope.variant,
      },
      keywords: [
        'helmeted',
        'with helmet',
      ],
    ),

    // ============================================================
    // FORM FACTOR AND COLLECTOR STATUS RULES
    // ============================================================

    PopIdentityRule(
      id: 'oversized',
      emoji: '📏',
      label: 'Oversized',
      targetScopes: {
        PopIdentityScope.variant,
        PopIdentityScope.collectorLabel,
      },
      keywords: [
        'jumbo',
        'super sized',
        'supersized',
        '6-inch',
        '6 inch',
        '10-inch',
        '10 inch',
        '18-inch',
        '18 inch',
      ],
    ),
    PopIdentityRule(
      id: 'vaulted',
      emoji: '🔒',
      label: 'Vaulted',
      targetScopes: {
        PopIdentityScope.collectorLabel,
      },
      keywords: [
        'vaulted',
        'retired',
      ],
    ),
    PopIdentityRule(
      id: 'pop_cover',
      emoji: '📖',
      label: 'Pop Cover',
      targetScopes: {
        PopIdentityScope.collectorLabel,
        PopIdentityScope.variant,
      },
      keywords: [
        'comic cover',
        'album cover',
        'poster cover',
        'pop cover',
      ],
    ),
    PopIdentityRule(
      id: 'grail',
      emoji: '👑',
      label: 'Grail',
      targetScopes: {
        PopIdentityScope.collectorLabel,
      },
      keywords: [
        'grail',
      ],
    ),

    // ============================================================
    // CONVENTION AND EVENT STICKER RULES
    // ============================================================

    PopIdentityRule(
      id: 'sdcc',
      emoji: '🎟️',
      label: 'SDCC',
      targetScopes: {
        PopIdentityScope.eventSticker,
      },
      keywords: [
        'sdcc',
        'san diego comic con',
        'san diego comic-con',
      ],
    ),
    PopIdentityRule(
      id: 'nycc',
      emoji: '🎟️',
      label: 'NYCC',
      targetScopes: {
        PopIdentityScope.eventSticker,
      },
      keywords: [
        'nycc',
        'new york comic con',
        'new york comic-con',
      ],
    ),
    PopIdentityRule(
      id: 'eccc',
      emoji: '🎟️',
      label: 'ECCC',
      targetScopes: {
        PopIdentityScope.eventSticker,
      },
      keywords: [
        'eccc',
        'emerald city comic con',
        'emerald city comic-con',
      ],
    ),
    PopIdentityRule(
      id: 'wondercon',
      emoji: '🎟️',
      label: 'WonderCon',
      targetScopes: {
        PopIdentityScope.eventSticker,
      },
      keywords: [
        'wondercon',
        'wonder con',
      ],
    ),
    PopIdentityRule(
      id: 'c2e2',
      emoji: '🎟️',
      label: 'C2E2',
      targetScopes: {
        PopIdentityScope.eventSticker,
      },
      keywords: [
        'c2e2',
        'chicago comic and entertainment expo',
      ],
    ),
    PopIdentityRule(
      id: 'lacc',
      emoji: '🎟️',
      label: 'LACC',
      targetScopes: {
        PopIdentityScope.eventSticker,
      },
      keywords: [
        'lacc',
        'los angeles comic con',
        'los angeles comic-con',
      ],
    ),
    PopIdentityRule(
      id: 'fundays',
      emoji: '🎉',
      label: 'Fundays',
      targetScopes: {
        PopIdentityScope.eventSticker,
        PopIdentityScope.collectorLabel,
      },
      keywords: [
        'fundays',
        'fun days',
        'box of fun',
      ],
    ),
    PopIdentityRule(
      id: 'd23',
      emoji: '🏰',
      label: 'D23',
      targetScopes: {
        PopIdentityScope.eventSticker,
      },
      keywords: [
        'd23',
        'd23 expo',
      ],
    ),
    PopIdentityRule(
      id: 'fan_expo',
      emoji: '🎟️',
      label: 'Fan Expo',
      targetScopes: {
        PopIdentityScope.eventSticker,
      },
      keywords: [
        'fan expo',
        'fanexpo',
      ],
    ),
    PopIdentityRule(
      id: 'fright_night',
      emoji: '🎃',
      label: 'Fright Night',
      targetScopes: {
        PopIdentityScope.eventSticker,
        PopIdentityScope.collectorLabel,
      },
      keywords: [
        'fright night',
        'frightnight',
      ],
    ),
    PopIdentityRule(
      id: 'shared_convention',
      emoji: '🤝',
      label: 'Shared Convention',
      targetScopes: {
        PopIdentityScope.eventSticker,
      },
      keywords: [
        'shared convention',
        'shared exclusive',
        'shared sticker',
      ],
    ),
    PopIdentityRule(
      id: 'official_convention',
      emoji: '🎟️',
      label: 'Official Convention',
      targetScopes: {
        PopIdentityScope.eventSticker,
      },
      keywords: [
        'official convention',
        'official con sticker',
        'official convention sticker',
      ],
    ),
    PopIdentityRule(
      id: 'special_edition',
      emoji: '⭐',
      label: 'Special Edition',
      targetScopes: {
        PopIdentityScope.eventSticker,
        PopIdentityScope.retailExclusive,
      },
      keywords: [
        'special edition',
        'special edition sticker',
      ],
    ),

    // ============================================================
    // RETAIL EXCLUSIVE RULES
    // ============================================================

    PopIdentityRule(
      id: 'funko_shop',
      emoji: '🛒',
      label: 'Funko Shop',
      targetScopes: {
        PopIdentityScope.retailExclusive,
      },
      keywords: [
        'funko shop',
        'funko.com',
        'web exclusive',
      ],
    ),

    // ============================================================
    // SCOPED METADATA RULES
    // ============================================================

    PopIdentityRule(
      id: 'limited_edition',
      emoji: '🏆',
      label: 'Limited Edition',
      targetScopes: {
        PopIdentityScope.limitedEdition,
      },
      keywords: [
        'limited edition',
        'limited release',
        'piece limited',
        'pieces',
        ' pcs',
      ],
    ),
    PopIdentityRule(
      id: 'signed',
      emoji: '🖋️',
      label: 'Signed',
      targetScopes: {
        PopIdentityScope.signature,
      },
      keywords: [
        'signed',
        'signature',
        'autographed',
        'autograph',
      ],
    ),
  ];

  static const List<String> knownRetailers = [
    'funko shop',
    'funko.com',
    'web exclusive',
    'target',
    'walmart',
    'amazon',
    'gamestop',
    'game stop',
    'hot topic',
    'boxlunch',
    'box lunch',
    'entertainment earth',
    'fye',
    'walgreens',
    'barnes & noble',
    'barnes and noble',
    'books-a-million',
    'books a million',
    'costco',
    'best buy',
    'macy\'s',
    'toys r us',
    'toys "r" us',
    'hobby lobby',
    'funko hollywood',
    'funko headquarters',
    'funko hq',
    'hq exclusive',
    'hollywood exclusive',
    'funko europe',
    'crunchyroll',
    'chalice collectibles',
    'chalice',
    '7-eleven',
    '7 eleven',
    '711',
    'aaa anime',
    'fugitive toys',
    'gemini collectibles',
    'piab',
    'pop in a box',
    'toy temple',
    'shumi',
    'shumi nation',
    'plastic empire',
    'specialty series',
    'px previews',
    'previews exclusive',
    'loungefly',
    'popcultcha',
    'pop culture',
    'smyths',
    'tesco',
    'five below',
    'fivebelow',
    'meijer',
    'kroger',
    'foot locker',
    'newbury comics',
  ];
}