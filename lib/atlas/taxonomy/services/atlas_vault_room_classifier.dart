import '../../../models/pop.dart';

enum AtlasVaultRoom {
  anime('Anime'),
  marvel('Marvel'),
  dc('DC'),
  starWars('Star Wars'),
  moviesAndTv('Movies & TV'),
  gaming('Gaming'),
  sports('Sports'),
  music('Music / Rocks'),
  icons('Icons'),
  retroToys('Retro Toys'),
  originals('Originals'),
  asiaInternational('Asia / International'),
  other('Other');

  const AtlasVaultRoom(this.displayName);

  final String displayName;

  static AtlasVaultRoom? fromDisplayName(String? value) {
    final normalized = value?.trim().toLowerCase() ?? '';

    for (final room in AtlasVaultRoom.values) {
      if (room.displayName.toLowerCase() == normalized) {
        return room;
      }
    }

    return null;
  }
}

/// Resolves one authoritative Vault Room for a Pop using the source metadata
/// already preserved on the Pop model.
///
/// The classifier is intentionally derived instead of persisted so existing
/// HobbyDB imports can be reclassified without a destructive migration or
/// re-import. Every Pop receives exactly one room.
final class AtlasVaultRoomClassifier {
  const AtlasVaultRoomClassifier();

  AtlasVaultRoom roomFor(Pop pop) {
    final series = _normalize(pop.series);
    final category = _normalize(pop.category);
    final name = _normalize(pop.name);
    final combined = '$series $category $name';

    // High-confidence official Funko line / franchise signals.
    if (_containsAny(combined, const <String>['star wars'])) {
      return AtlasVaultRoom.starWars;
    }

    if (_containsAny(combined, const <String>['marvel']) ||
        _marvelExactNames.contains(name)) {
      return AtlasVaultRoom.marvel;
    }

    // HobbyDB commonly exports DC Pops as Pop! Heroes rather than "DC".
    if (_containsAny(series, const <String>['pop! heroes']) ||
        _containsAny(combined, _dcSignals)) {
      return AtlasVaultRoom.dc;
    }

    if (_containsAny(series, const <String>['pop! games', 'pop! gaming']) ||
        _containsAny(category, const <String>['games', 'gaming']) ||
        _gamingExactNames.contains(name)) {
      return AtlasVaultRoom.gaming;
    }

    // Franchise aliases repair HobbyDB rows whose Series only describes the
    // product format (Limited Edition, Plus, Rides, Trains, and similar)
    // instead of the underlying franchise. Keep these narrow so format names
    // never become category authority on their own.
    if (_animeFranchiseExactNames.contains(name)) {
      return AtlasVaultRoom.anime;
    }

    if (_moviesAndTvExactNames.contains(name) ||
        _containsAny(series, _moviesAndTvSeriesSignals)) {
      return AtlasVaultRoom.moviesAndTv;
    }

    // Sports lines are grouped into one room instead of creating separate
    // rooms for football, basketball, soccer, wrestling, and similar lines.
    if (_containsAny(series, _sportsSeriesSignals)) {
      return AtlasVaultRoom.sports;
    }

    if (_containsAny(series, const <String>['pop! rocks', 'gold music'])) {
      return AtlasVaultRoom.music;
    }

    if (_containsAny(series, const <String>['pop! icons', 'pop! ad icons'])) {
      return AtlasVaultRoom.icons;
    }

    if (_containsAny(series, const <String>['pop! retro toys'])) {
      return AtlasVaultRoom.retroToys;
    }

    if (_containsAny(series, const <String>['pop! originals']) ||
        _originalsExactNames.contains(name)) {
      return AtlasVaultRoom.originals;
    }

    if (_containsAny(series, const <String>['pop! asia'])) {
      return AtlasVaultRoom.asiaInternational;
    }

    // Explicit anime source signals take priority over the generic Animation
    // line because Pop! Animation includes western animation as well.
    if (_containsAny(series, _explicitAnimeSeriesSignals)) {
      return AtlasVaultRoom.anime;
    }

    // Explicit movie/television/Disney signals should not be promoted to Anime
    // merely because a crossover also includes Pop! Animation.
    if (_containsAny(series, const <String>[
      'pop! movies',
      'pop! television',
      'pop! disney',
    ])) {
      return AtlasVaultRoom.moviesAndTv;
    }

    if (_containsAny(series, const <String>['pop! animation'])) {
      if (_animeExactNames.contains(name) ||
          _containsAny(name, _animeCharacterSignals)) {
        return AtlasVaultRoom.anime;
      }

      return AtlasVaultRoom.moviesAndTv;
    }

    if (_containsAny(series, const <String>[
      'movies',
      'television',
      'tv',
      'disney',
    ])) {
      return AtlasVaultRoom.moviesAndTv;
    }

    return AtlasVaultRoom.other;
  }

  bool isInRoom(Pop pop, AtlasVaultRoom room) {
    return roomFor(pop) == room;
  }

  Map<AtlasVaultRoom, int> countsFor(Iterable<Pop> pops) {
    final counts = <AtlasVaultRoom, int>{
      for (final room in AtlasVaultRoom.values) room: 0,
    };

    for (final pop in pops) {
      if (pop.isWishlist) {
        continue;
      }

      final room = roomFor(pop);
      counts[room] = (counts[room] ?? 0) + 1;
    }

    return counts;
  }

  static String _normalize(String value) {
    return value.trim().toLowerCase();
  }

  static bool _containsAny(String value, Iterable<String> signals) {
    for (final signal in signals) {
      if (value.contains(signal)) {
        return true;
      }
    }

    return false;
  }

  static const List<String> _sportsSeriesSignals = <String>[
    'pop! football',
    'pop! basketball',
    'pop! baseball',
    'pop! hockey',
    'pop! soccer',
    'pop! wwe',
    'pop! wrestling',
    'bitty pop! sports',
    'gold, sports',
    'pop! mlb',
  ];

  /// Generic Limited Edition rows that still have an unambiguous Marvel
  /// identity in this HobbyDB export.
  static const Set<String> _marvelExactNames = <String>{'loki', 'sabretooth'};

  /// Anime identities found in generic Pop! Plus / Rides rows. These are
  /// exact names from the current HobbyDB export rather than broad keywords.
  static const Set<String> _animeFranchiseExactNames = <String>{
    'monkey d. luffy',
    'mitsuri kanroji',
    'tanjiro',
    'silvers raleigh',
    'nezuko kamado',
    'gyokko',
    'shanks',
    'tony tony chopper with brachio tank v',
    'nami with white hobby horse',
  };

  /// High-confidence franchise identities whose HobbyDB Series is a generic
  /// product format or a franchise line not covered by Pop! Movies/Television.
  static const Set<String> _moviesAndTvExactNames = <String>{
    'megaton',
    'megaton le',
    'megatron',
    'he-man on battle cat',
    'walt with the crystal ship',
    'minnie mouse on the casey jr. circus train attraction',
    'goofy on the casey jr. circus train attraction',
    'lucy',
    'ham',
    'crying demon',
    'battle beast',
    'gurney halleck',
    'cheshire cat',
    'forky & karen beverly',
    'gizmo',
    'cosmo & wanda as goldfish',
    'sorceress with castle grayskull',
    'evil-lyn box set',
    'zuko',
    'demogorgon',
    'stitch (christmas)',
    'rosie the robot',
    'jane jetson',
    'tommy',
    'chuckie',
    'angelica',
  };

  static const List<String> _moviesAndTvSeriesSignals = <String>[
    'power rangers',
    'pop! harry potter',
    'pop! my little pony',
  ];

  /// Exact-name exceptions for collectibles whose HobbyDB Series is too
  /// generic to reveal the franchise. Red Dragon Wyrmling is a Dungeons &
  /// Dragons collectible in this export, while other "dragon" names may
  /// belong to Anime and must not be matched generically.
  static const Set<String> _gamingExactNames = <String>{
    'red dragon wyrmling',
    'loot',
    'ncr power armor',
    'donald (kingdom hearts)',
    'sora (monsters, inc.)',
  };

  /// Funko-original identities whose HobbyDB Series is a generic Digital line.
  static const Set<String> _originalsExactNames = <String>{
    'kitsune mask franny',
    'ultimate freddy',
  };

  static const List<String> _explicitAnimeSeriesSignals = <String>[
    'my hero academia',
    'naruto',
    'funimation',
    'crunchyroll',
    'dragon ball',
    'one piece',
    'demon slayer',
    'jujutsu kaisen',
    'bleach',
    'solo leveling',
    'death note',
    'yu-gi-oh',
  ];

  /// Character/subject signals needed for ambiguous HobbyDB Pop! Animation
  /// rows where the export does not include a franchise field. These signals
  /// are deliberately narrow; unmatched Animation records fall back to
  /// Movies & TV rather than becoming false Anime positives.
  static const List<String> _animeCharacterSignals = <String>[
    'soba mask',
    'all might',
    'deku',
    'himmel',
    'suguru geto',
    'aoi todo',
    'gigantomachia',
    'reiju',
    'zenitsu',
    'monkey d.',
    'vegito',
    'kuro',
    'akaza',
    'muzan',
    'rukia',
    'buggy',
    'chopper',
    'haganezuka',
    'sung jinwoo',
    'brook',
    'tanjiro',
    'vegeta',
    'baek yoonho',
    'minato',
    'grimmjow',
    'gogeta',
    'goku',
    'sniper king',
    'kaido',
    'sasuke',
    'sosuke aizen',
    'vinsmoke sanji',
    'tomura shigaraki',
    'overhaul',
    'ichigo kurosaki',
    'samurai brook',
    'yahaba',
    'whitebeard',
    'bon clay',
    'inosuke',
    'muichiro',
    'shinobu',
    'zohakuten',
    'gyutaro',
    'kaigaku',
    'nico robin',
    'super saiyan',
    'monkey d. dragon',
    'tengen uzui',
    'kagaya ubuyashiki',
    'stardust dragon',
    'tanjuro kamado',
    'nezuko',
    'makomo',
    'sabito',
    'hantengu',
    'spider demon father',
    'elemental hero',
    'luffy',
    'misa amane',
    'ryuk',
    'exodia',
    'hidan',
    'igris',
    'orochimaru',
    'mayuri kurotsuchi',
    'kakashi',
    'susamaru',
    'aoi kanzaki',
    'roronoa zoro',
    'jinbe',
    'tsuyu asui',
    'makio',
    'yamato',
    // In this HobbyDB export, Iron is the Solo Leveling collectible.
    'iron',
    'kaiju no. 8',
  ];

  static const Set<String> _animeExactNames = <String>{
    'baby',
    'ban',
    'bomb',
    'destro',
    'genma',
    'killer',
    'l',
    'lilith',
    'mai',
    'sanji',
  };

  static const List<String> _dcSignals = <String>[
    'dc comics',
    'dc x funko',
    'batman',
    'superman',
    'supergirl',
    'wonder woman',
    'justice league',
    'green lantern',
    'harley quinn',
    'the joker',
    'catwoman',
    'the flash',
    'aquaman',
    'suicide squad',
  ];
}
