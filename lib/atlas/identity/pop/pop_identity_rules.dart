import 'pop_identity_rule.dart';

abstract final class PopIdentityRules {
  static const List<PopIdentityRule> all = [
    PopIdentityRule(
      id: 'chase',
      emoji: '🔥',
      label: 'Chase',
      keywords: [
        'chase',
      ],
    ),
    PopIdentityRule(
      id: 'glow',
      emoji: '✨',
      label: 'Glow in the Dark',
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
      keywords: [
        'blacklight',
        'black light',
      ],
    ),
    PopIdentityRule(
      id: 'diamond',
      emoji: '💎',
      label: 'Diamond',
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
      keywords: [
        'flocked',
        'flock',
      ],
    ),
    PopIdentityRule(
      id: 'metallic',
      emoji: '🪙',
      label: 'Metallic',
      keywords: [
        'metallic',
        'chrome',
      ],
    ),
    PopIdentityRule(
      id: 'scented',
      emoji: '🌸',
      label: 'Scented',
      keywords: [
        'scented',
        'scent',
      ],
    ),
    PopIdentityRule(
      id: 'art_series',
      emoji: '🖼️',
      label: 'Art Series',
      keywords: [
        'art series',
      ],
    ),
    PopIdentityRule(
      id: 'nft',
      emoji: '🌐',
      label: 'NFT',
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
      keywords: [
        'translucent',
        'transparent',
        'clear variant',
        'clear edition',
      ],
    ),
    PopIdentityRule(
      id: 'oversized',
      emoji: '📏',
      label: 'Oversized',
      keywords: [
        'jumbo',
        'super sized',
        'supersized',
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
      keywords: [
        'vaulted',
        'retired',
      ],
    ),
    PopIdentityRule(
      id: 'bloody',
      emoji: '🩸',
      label: 'Bloody',
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
      keywords: [
        'sound edition',
        'sound feature',
        'with sound',
      ],
    ),
    PopIdentityRule(
      id: 'pop_cover',
      emoji: '📖',
      label: 'Pop Cover',
      keywords: [
        'comic cover',
        'album cover',
        'poster cover',
        'pop cover',
      ],
    ),
    PopIdentityRule(
      id: 'prototype',
      emoji: '🧪',
      label: 'Prototype',
      keywords: [
        'prototype',
        'proto',
      ],
    ),
    PopIdentityRule(
      id: 'funko_shop',
      emoji: '🛒',
      label: 'Funko Shop',
      keywords: [
        'funko shop',
        'funko.com',
        'web exclusive',
      ],
    ),
    PopIdentityRule(
      id: 'grail',
      emoji: '👑',
      label: 'Grail',
      keywords: [
        'grail',
      ],
    ),
    PopIdentityRule(
      id: 'limited_edition',
      emoji: '🏆',
      label: 'Limited Edition',
      keywords: [
        'limited edition',
        'limited release',
      ],
    ),
    PopIdentityRule(
      id: 'signed',
      emoji: '🖋️',
      label: 'Signed',
      keywords: [
        'signed',
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
  ];
}