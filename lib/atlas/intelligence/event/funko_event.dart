enum FunkoEvent {
  sdcc(
    code: 'sdcc',
    displayName: 'San Diego Comic-Con',
    aliases: {'sdcc', 'san diego comic con', 'san diego comic-con'},
  ),

  nycc(
    code: 'nycc',
    displayName: 'New York Comic Con',
    aliases: {'nycc', 'new york comic con'},
  ),

  eccc(
    code: 'eccc',
    displayName: 'Emerald City Comic Con',
    aliases: {'eccc', 'emerald city comic con'},
  ),

  wondercon(
    code: 'wondercon',
    displayName: 'WonderCon',
    aliases: {'wondercon'},
  ),

  animeExpo(
    code: 'anime_expo',
    displayName: 'Anime Expo',
    aliases: {'anime expo'},
  ),

  starWarsCelebration(
    code: 'star_wars_celebration',
    displayName: 'Star Wars Celebration',
    aliases: {'star wars celebration'},
  ),

  toyFair(
    code: 'toy_fair',
    displayName: 'Toy Fair',
    aliases: {'toy fair', 'new york toy fair'},
  ),

  c2e2(
    code: 'c2e2',
    displayName: 'C2E2',
    aliases: {'c2e2', 'chicago comic entertainment expo'},
  ),

  fundays(
    code: 'fundays',
    displayName: 'Funko Fundays',
    aliases: {'fundays', 'funko fundays'},
  ),

  unknown(code: 'unknown', displayName: 'Unknown', aliases: {});

  const FunkoEvent({
    required this.code,
    required this.displayName,
    required this.aliases,
  });

  final String code;
  final String displayName;
  final Set<String> aliases;

  bool get isKnown => this != FunkoEvent.unknown;

  static FunkoEvent fromCode(String code) {
    for (final event in values) {
      if (event.code == code) {
        return event;
      }
    }

    return FunkoEvent.unknown;
  }
}
