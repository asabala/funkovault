// Canonical retailer and distribution partners recognized by Atlas.
//
// These identify where a collectible was released or distributed.
// They do NOT represent sticker classifications.
enum FunkoRetailer {
  unknown(
    code: 'unknown',
    displayName: 'Unknown',
  ),

  // Funko
  funkoShop(
    code: 'funko-shop',
    displayName: 'Funko Shop',
  ),
  funkoHq(
    code: 'funko-hq',
    displayName: 'Funko HQ',
  ),
  funkoHollywood(
    code: 'funko-hollywood',
    displayName: 'Funko Hollywood',
  ),

  // Major Retailers
  amazon(
    code: 'amazon',
    displayName: 'Amazon',
  ),
  target(
    code: 'target',
    displayName: 'Target',
  ),
  walmart(
    code: 'walmart',
    displayName: 'Walmart',
  ),
  hotTopic(
    code: 'hot-topic',
    displayName: 'Hot Topic',
  ),
  boxLunch(
    code: 'boxlunch',
    displayName: 'BoxLunch',
  ),
  gameStop(
    code: 'gamestop',
    displayName: 'GameStop',
  ),
  ebGames(
    code: 'eb-games',
    displayName: 'EB Games',
  ),
  entertainmentEarth(
    code: 'entertainment-earth',
    displayName: 'Entertainment Earth',
  ),
  chalice(
    code: 'chalice',
    displayName: 'Chalice Collectibles',
  ),
  fye(
    code: 'fye',
    displayName: 'FYE',
  ),
  booksAMillion(
    code: 'books-a-million',
    displayName: 'Books-A-Million',
  ),
  barnesAndNoble(
    code: 'barnes-and-noble',
    displayName: 'Barnes & Noble',
  ),
  walgreens(
    code: 'walgreens',
    displayName: 'Walgreens',
  ),
  cvs(
    code: 'cvs',
    displayName: 'CVS',
  ),
  sevenEleven(
    code: '7-eleven',
    displayName: '7-Eleven',
  ),

  // Specialty Retail
  pxPreviews(
    code: 'px-previews',
    displayName: 'PX Previews',
  ),
  fugitiveToys(
    code: 'fugitive-toys',
    displayName: 'Fugitive Toys',
  ),
  toyTokyo(
    code: 'toy-tokyo',
    displayName: 'Toy Tokyo',
  ),
  toyTemple(
    code: 'toy-temple',
    displayName: 'Toy Temple',
  ),
  popcultcha(
    code: 'popcultcha',
    displayName: 'Popcultcha',
  ),

  // Apparel
  lids(
    code: 'lids',
    displayName: 'Lids',
  ),
  footLocker(
    code: 'foot-locker',
    displayName: 'Foot Locker',
  ),

  // Brand Stores
  disneyStore(
    code: 'disney-store',
    displayName: 'Disney Store',
  ),
  disneyParks(
    code: 'disney-parks',
    displayName: 'Disney Parks',
  ),
  pokemonCenter(
    code: 'pokemon-center',
    displayName: 'Pokémon Center',
  ),

  // Subscription Programs
  marvelCollectorCorps(
    code: 'marvel-collector-corps',
    displayName: 'Marvel Collector Corps',
  ),
  smugglersBounty(
    code: 'smugglers-bounty',
    displayName: "Smuggler's Bounty",
  ),
  legionOfCollectors(
    code: 'legion-of-collectors',
    displayName: 'DC Legion of Collectors',
  );

  const FunkoRetailer({
    required this.code,
    required this.displayName,
  });

  final String code;

  final String displayName;

  bool get isFunkoOwned {
    return switch (this) {
      FunkoRetailer.funkoShop ||
      FunkoRetailer.funkoHq ||
      FunkoRetailer.funkoHollywood =>
      true,
      _ => false,
    };
  }

  bool get isSubscriptionProgram {
    return switch (this) {
      FunkoRetailer.marvelCollectorCorps ||
      FunkoRetailer.smugglersBounty ||
      FunkoRetailer.legionOfCollectors =>
      true,
      _ => false,
    };
  }

  static FunkoRetailer fromCode(
      String? code,
      ) {
    final String normalized =
        code?.trim().toLowerCase() ?? '';

    for (final retailer in FunkoRetailer.values) {
      if (retailer.code == normalized) {
        return retailer;
      }
    }

    return FunkoRetailer.unknown;
  }
}