import 'funko_retailer.dart';

// Converts retailer aliases into canonical Atlas retailers.
//
// OCR, CSV imports, APIs, and user-entered data rarely use identical
// wording. This class centralizes retailer normalization so the rest
// of Atlas works with strongly typed retailer values.
final class FunkoRetailerNormalizer {
  const FunkoRetailerNormalizer();
  Map<FunkoRetailer, List<String>> get aliases {
    return Map<FunkoRetailer, List<String>>.unmodifiable(
      _aliases.map(
        (key, value) => MapEntry(key, List<String>.unmodifiable(value)),
      ),
    );
  }

  FunkoRetailer normalize(String? value) {
    final String normalized = normalizeText(value);

    if (normalized.isEmpty) {
      return FunkoRetailer.unknown;
    }

    for (final MapEntry<FunkoRetailer, List<String>> entry
        in _aliases.entries) {
      if (entry.value.contains(normalized)) {
        return entry.key;
      }
    }

    return FunkoRetailer.unknown;
  }

  bool isKnownRetailer(String? value) {
    return normalize(value) != FunkoRetailer.unknown;
  }

  String normalizeText(String? value) {
    return value
            ?.trim()
            .toLowerCase()
            .replaceAll(RegExp(r'[éèêë]'), 'e')
            .replaceAll(RegExp(r'[áàâä]'), 'a')
            .replaceAll(RegExp(r'[íìîï]'), 'i')
            .replaceAll(RegExp(r'[óòôö]'), 'o')
            .replaceAll(RegExp(r'[úùûü]'), 'u')
            .replaceAll('ñ', 'n')
            .replaceAll('ç', 'c')
            .replaceAll('&', ' and ')
            .replaceAll('-', ' ')
            .replaceAll('_', ' ')
            .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim() ??
        '';
  }

  static const Map<FunkoRetailer, List<String>> _aliases =
      <FunkoRetailer, List<String>>{
        FunkoRetailer.funkoShop: <String>['funko shop', 'funkoshop'],
        FunkoRetailer.funkoHq: <String>['funko hq', 'funko everett', 'everett'],
        FunkoRetailer.funkoHollywood: <String>['funko hollywood'],
        FunkoRetailer.amazon: <String>['amazon', 'amazon exclusive'],
        FunkoRetailer.target: <String>['target', 'target exclusive'],
        FunkoRetailer.walmart: <String>['walmart', 'walmart exclusive'],
        FunkoRetailer.hotTopic: <String>[
          'hot topic',
          'hot topic exclusive',
          'hottopic',
          'ht',
        ],
        FunkoRetailer.boxLunch: <String>[
          'box lunch',
          'box lunch exclusive',
          'boxlunch',
        ],
        FunkoRetailer.gameStop: <String>[
          'gamestop',
          'game stop',
          'gamestop exclusive',
          'game stop exclusive',
        ],
        FunkoRetailer.ebGames: <String>['eb games', 'ebgames'],
        FunkoRetailer.entertainmentEarth: <String>[
          'entertainment earth',
          'entertainment earth exclusive',
          'entertainmentearth',
          'ee',
        ],
        FunkoRetailer.chalice: <String>['chalice', 'chalice collectibles'],
        FunkoRetailer.booksAMillion: <String>[
          'books a million',
          'booksamillion',
          'bam',
        ],
        FunkoRetailer.barnesAndNoble: <String>[
          'barnes and noble',
          'barnes noble',
          'b and n',
        ],
        FunkoRetailer.fye: <String>['fye', 'for your entertainment'],
        FunkoRetailer.walgreens: <String>['walgreens'],
        FunkoRetailer.cvs: <String>['cvs', 'cvs pharmacy'],
        FunkoRetailer.sevenEleven: <String>['7 eleven', 'seven eleven'],
        FunkoRetailer.pxPreviews: <String>[
          'px',
          'px previews',
          'previews exclusive',
        ],
        FunkoRetailer.fugitiveToys: <String>['fugitive toys', 'fugitive'],
        FunkoRetailer.toyTokyo: <String>['toy tokyo', 'toytokyo'],
        FunkoRetailer.toyTemple: <String>['toy temple', 'toytemple'],
        FunkoRetailer.popcultcha: <String>['popcultcha'],
        FunkoRetailer.lids: <String>['lids'],
        FunkoRetailer.footLocker: <String>['foot locker', 'footlocker'],
        FunkoRetailer.disneyStore: <String>['disney store'],
        FunkoRetailer.disneyParks: <String>['disney parks', 'disney park'],
        FunkoRetailer.pokemonCenter: <String>['pokemon center'],
        FunkoRetailer.marvelCollectorCorps: <String>[
          'marvel collector corps',
          'mcc',
        ],
        FunkoRetailer.smugglersBounty: <String>['smugglers bounty'],
        FunkoRetailer.legionOfCollectors: <String>[
          'legion of collectors',
          'dc legion of collectors',
        ],
      };
}
