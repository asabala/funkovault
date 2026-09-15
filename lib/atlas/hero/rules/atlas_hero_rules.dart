import 'atlas_hero_rule.dart';
import 'keyword_hero_rule.dart';

class AtlasHeroRules {
  const AtlasHeroRules._();

  static const List<AtlasHeroRule> all = <AtlasHeroRule>[
    KeywordHeroRule(
      ruleId: 'signed',
      points: 12,
      reason: 'Signed collectible identity detected.',
      keywords: <String>['signed', 'autographed', 'autograph'],
    ),
    KeywordHeroRule(
      ruleId: 'limited_edition',
      points: 10,
      reason: 'Limited-edition collectible identity detected.',
      keywords: <String>['limited edition', 'limited', 'le ', 'piece count'],
    ),
    KeywordHeroRule(
      ruleId: 'prototype',
      points: 10,
      reason: 'Prototype collectible identity detected.',
      keywords: <String>['prototype', 'proto'],
    ),
    KeywordHeroRule(
      ruleId: 'chase',
      points: 8,
      reason: 'Chase edition detected.',
      keywords: <String>['chase'],
    ),
    KeywordHeroRule(
      ruleId: 'grail',
      points: 8,
      reason: 'Grail identity detected.',
      keywords: <String>['grail', 'holy grail'],
    ),
    KeywordHeroRule(
      ruleId: 'nft',
      points: 7,
      reason: 'Digital collectible release identity detected.',
      keywords: <String>['nft', 'digital pop', 'redeemable'],
    ),
    KeywordHeroRule(
      ruleId: 'convention',
      points: 6,
      reason: 'Convention or event-exclusive identity detected.',
      keywords: <String>[
        'convention exclusive',
        'event exclusive',
        'sdcc',
        'nycc',
        'ecc',
        'wondercon',
        'fundays',
        'comic con',
      ],
    ),
    KeywordHeroRule(
      ruleId: 'funko_shop',
      points: 5,
      reason: 'Funko Shop exclusive identity detected.',
      keywords: <String>['funko shop', 'funko exclusive'],
    ),
    KeywordHeroRule(
      ruleId: 'blacklight',
      points: 5,
      reason: 'Blacklight finish detected.',
      keywords: <String>['blacklight', 'black light'],
    ),
    KeywordHeroRule(
      ruleId: 'glow',
      points: 5,
      reason: 'Glow-in-the-dark finish detected.',
      keywords: <String>[
        'glow in the dark',
        'glow-in-the-dark',
        'glow',
        'gitd',
      ],
    ),
    KeywordHeroRule(
      ruleId: 'diamond',
      points: 4,
      reason: 'Diamond finish detected.',
      keywords: <String>['diamond collection', 'diamond', 'glitter'],
    ),
    KeywordHeroRule(
      ruleId: 'flocked',
      points: 4,
      reason: 'Flocked finish detected.',
      keywords: <String>['flocked', 'flock'],
    ),
    KeywordHeroRule(
      ruleId: 'metallic',
      points: 4,
      reason: 'Metallic finish detected.',
      keywords: <String>['metallic', 'chrome'],
    ),
    KeywordHeroRule(
      ruleId: 'art_series',
      points: 4,
      reason: 'Art Series identity detected.',
      keywords: <String>['art series', 'artist series'],
    ),
    KeywordHeroRule(
      ruleId: 'scented',
      points: 4,
      reason: 'Scented finish detected.',
      keywords: <String>['scented'],
    ),
    KeywordHeroRule(
      ruleId: 'translucent',
      points: 4,
      reason: 'Translucent finish detected.',
      keywords: <String>['translucent', 'transparent', 'clear'],
    ),
    KeywordHeroRule(
      ruleId: 'pearlescent',
      points: 4,
      reason: 'Pearlescent finish detected.',
      keywords: <String>['pearlescent', 'pearl'],
    ),
    KeywordHeroRule(
      ruleId: 'patina',
      points: 4,
      reason: 'Patina finish detected.',
      keywords: <String>['patina'],
    ),
    KeywordHeroRule(
      ruleId: 'bloody',
      points: 4,
      reason: 'Bloody variant detected.',
      keywords: <String>['bloody', 'blood splatter'],
    ),
    KeywordHeroRule(
      ruleId: 'light_up',
      points: 4,
      reason: 'Light-up feature detected.',
      keywords: <String>['light up', 'light-up'],
    ),
    KeywordHeroRule(
      ruleId: 'sound',
      points: 4,
      reason: 'Sound feature detected.',
      keywords: <String>['sound', 'sound effects'],
    ),
    KeywordHeroRule(
      ruleId: 'oversized',
      points: 3,
      reason: 'Oversized collectible format detected.',
      keywords: <String>[
        'oversized',
        'jumbo',
        'super sized',
        'super-sized',
        '10 inch',
        '18 inch',
      ],
    ),
    KeywordHeroRule(
      ruleId: 'pop_cover',
      points: 3,
      reason: 'Pop Cover collectible format detected.',
      keywords: <String>['pop cover', 'album cover', 'comic cover'],
    ),
    KeywordHeroRule(
      ruleId: 'vaulted',
      points: 3,
      reason: 'Vaulted collectible status detected.',
      keywords: <String>['vaulted'],
    ),
  ];
}
