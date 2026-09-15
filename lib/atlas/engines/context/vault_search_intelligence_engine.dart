class VaultSearchIntent {
  const VaultSearchIntent({
    required this.title,
    required this.message,
    this.filterKey,
    this.searchQuery,
    this.minimumValue,
    this.maximumValue,
    this.sortKey,
    this.unsupportedParts = const [],
  });

  final String title;
  final String message;

  /// Existing Entire Vault filter key.
  final String? filterKey;

  /// Existing Entire Vault text search.
  final String? searchQuery;

  /// Optional inclusive minimum collectible value.
  final double? minimumValue;

  /// Optional inclusive maximum collectible value.
  final double? maximumValue;

  /// Optional existing Entire Vault sort key.
  final String? sortKey;

  /// Clearly recognized request details Atlas cannot currently apply.
  final List<String> unsupportedParts;

  bool get hasFilter => filterKey != null && filterKey!.trim().isNotEmpty;

  bool get hasSearch => searchQuery != null && searchQuery!.trim().isNotEmpty;

  bool get hasValueRange => minimumValue != null || maximumValue != null;

  bool get hasSort => sortKey != null && sortKey!.trim().isNotEmpty;

  bool get hasUnsupportedParts => unsupportedParts.isNotEmpty;

  bool get hasNavigationAction =>
      hasFilter || hasSearch || hasValueRange || hasSort;
}

class VaultSearchIntelligenceEngine {
  const VaultSearchIntelligenceEngine();

  VaultSearchIntent interpret(String question) {
    final cleanedQuestion = question.trim();
    final normalized = cleanedQuestion.toLowerCase();
    final unsupportedParts = _detectUnsupportedParts(normalized);

    if (normalized.isEmpty) {
      return const VaultSearchIntent(
        title: 'Vault Search',
        message:
            'Ask Atlas to find a collectible, category, series, owner, Vault status, or value range.',
      );
    }

    final valueIntent = _interpretValueIntent(
      originalQuestion: cleanedQuestion,
      normalizedQuestion: normalized,
    );

    final filterIntent = _interpretFilterIntent(normalized);

    final extractedSearch = _extractSearchQuery(
      originalQuestion: cleanedQuestion,
      normalizedQuestion: normalized,
    );

    final filterKey = filterIntent?.filterKey ?? valueIntent?.filterKey;

    final minimumValue = valueIntent?.minimumValue;
    final maximumValue = valueIntent?.maximumValue;
    final sortKey = valueIntent?.sortKey;

    final hasFilter = filterKey != null && filterKey.trim().isNotEmpty;

    final hasSearch =
        extractedSearch != null && extractedSearch.trim().isNotEmpty;

    final hasValueRange = minimumValue != null || maximumValue != null;

    final hasSort = sortKey != null && sortKey.trim().isNotEmpty;

    if (hasFilter || hasSearch || hasValueRange || hasSort) {
      return VaultSearchIntent(
        title: _titleForCombinedIntent(
          hasSearch: hasSearch,
          hasValueRange: hasValueRange,
          hasSort: hasSort,
          filterIntent: filterIntent,
          valueIntent: valueIntent,
        ),
        message:
            'Atlas identified supported Vault search criteria and can open Entire Vault with the requested view.',
        filterKey: filterKey,
        searchQuery: extractedSearch,
        minimumValue: minimumValue,
        maximumValue: maximumValue,
        sortKey: sortKey,
        unsupportedParts: unsupportedParts,
      );
    }

    return VaultSearchIntent(
      title: 'Vault Search',
      message: unsupportedParts.isNotEmpty
          ? 'Atlas recognized part of the request, but the requested criteria are not currently supported.'
          : 'Atlas could not identify a supported Vault filter, value range, or search phrase. Try asking for signed Pops, exclusives, wishlist items, stickers, variants, a collectible name, or a value range.',
      unsupportedParts: unsupportedParts,
    );
  }

  VaultSearchIntent? _interpretValueIntent({
    required String originalQuestion,
    required String normalizedQuestion,
  }) {
    if (_containsAny(normalizedQuestion, const [
      'most valuable',
      'highest value',
      'highest valued',
      'most expensive',
      'top value',
    ])) {
      return const VaultSearchIntent(
        title: 'Most Valuable Collectibles',
        message:
            'Atlas can open Entire Vault with collectibles sorted from highest to lowest recorded value.',
        filterKey: 'hasValue',
        sortKey: 'highestValue',
      );
    }

    final betweenMatch = RegExp(
      r'(?:between|from)\s+\$?(\d+(?:\.\d{1,2})?)\s+(?:and|to)\s+\$?(\d+(?:\.\d{1,2})?)',
      caseSensitive: false,
    ).firstMatch(originalQuestion);

    if (betweenMatch != null) {
      final firstValue = double.tryParse(betweenMatch.group(1) ?? '');
      final secondValue = double.tryParse(betweenMatch.group(2) ?? '');

      if (firstValue != null && secondValue != null) {
        final minimumValue = firstValue <= secondValue
            ? firstValue
            : secondValue;

        final maximumValue = firstValue <= secondValue
            ? secondValue
            : firstValue;

        return VaultSearchIntent(
          title: 'Collectibles by Value',
          message:
              'Atlas can show collectibles with recorded values between '
              '\$${minimumValue.toStringAsFixed(2)} and '
              '\$${maximumValue.toStringAsFixed(2)}.',
          minimumValue: minimumValue,
          maximumValue: maximumValue,
          sortKey: 'highestValue',
        );
      }
    }

    final minimumMatch = RegExp(
      r'(?:over|above|more than|greater than|at least|minimum|min)\s+\$?(\d+(?:\.\d{1,2})?)',
      caseSensitive: false,
    ).firstMatch(originalQuestion);

    if (minimumMatch != null) {
      final minimumValue = double.tryParse(minimumMatch.group(1) ?? '');

      if (minimumValue != null) {
        return VaultSearchIntent(
          title: 'Collectibles Above a Value',
          message:
              'Atlas can show collectibles with recorded values of '
              '\$${minimumValue.toStringAsFixed(2)} or more.',
          minimumValue: minimumValue,
          sortKey: 'highestValue',
        );
      }
    }

    final maximumMatch = RegExp(
      r'(?:under|below|less than|no more than|at most|maximum|max)\s+\$?(\d+(?:\.\d{1,2})?)',
      caseSensitive: false,
    ).firstMatch(originalQuestion);

    if (maximumMatch != null) {
      final maximumValue = double.tryParse(maximumMatch.group(1) ?? '');

      if (maximumValue != null) {
        return VaultSearchIntent(
          title: 'Collectibles Below a Value',
          message:
              'Atlas can show collectibles with recorded values up to '
              '\$${maximumValue.toStringAsFixed(2)}.',
          maximumValue: maximumValue,
          sortKey: 'highestValue',
        );
      }
    }

    return null;
  }

  VaultSearchIntent? _interpretFilterIntent(String question) {
    if (_containsAny(question, const [
      'signed',
      'signature',
      'autograph',
      'autographed',
    ])) {
      return const VaultSearchIntent(
        title: 'Signed Collectibles',
        message:
            'Atlas can open Entire Vault and show collectibles with signature details.',
        filterKey: 'signed',
      );
    }

    if (_containsAny(question, const [
      'exclusive',
      'exclusives',
      'retail exclusive',
    ])) {
      return const VaultSearchIntent(
        title: 'Exclusive Collectibles',
        message:
            'Atlas can open Entire Vault and show collectibles with exclusive details.',
        filterKey: 'exclusives',
      );
    }

    if (_containsAny(question, const [
      'sticker',
      'stickers',
      'stickered',
      'event sticker',
    ])) {
      return const VaultSearchIntent(
        title: 'Stickered Collectibles',
        message:
            'Atlas can open Entire Vault and show collectibles with sticker details.',
        filterKey: 'stickers',
      );
    }

    if (_containsAny(question, const [
      'variant',
      'variants',
      'chase',
      'blacklight',
      'black light',
      'glow',
      'metallic',
      'flocked',
    ])) {
      return const VaultSearchIntent(
        title: 'Variant Collectibles',
        message:
            'Atlas can open Entire Vault and show collectibles with variant details.',
        filterKey: 'variants',
      );
    }

    if (_containsAny(question, const [
      'limited edition',
      'limited',
      'numbered piece',
      'numbered pieces',
    ])) {
      return const VaultSearchIntent(
        title: 'Limited Collectibles',
        message:
            'Atlas can open Entire Vault and show collectibles with limited-edition details.',
        filterKey: 'limited',
      );
    }

    if (_containsAny(question, const ['wishlist', 'wish list', 'wanted'])) {
      return const VaultSearchIntent(
        title: 'Wishlist Collectibles',
        message:
            'Atlas can open Entire Vault and show collectibles currently on your wishlist.',
        filterKey: 'wishlist',
      );
    }

    if (_containsAny(question, const ['owned', 'my collection', 'i own'])) {
      return const VaultSearchIntent(
        title: 'Owned Collectibles',
        message:
            'Atlas can open Entire Vault and show collectibles marked as owned.',
        filterKey: 'owned',
      );
    }

    if (_containsAny(question, const [
      'missing value',
      'missing values',
      'needs value',
      'need values',
      'without value',
    ])) {
      return const VaultSearchIntent(
        title: 'Collectibles Needing Values',
        message:
            'Atlas can open Entire Vault and show collectibles that still need estimated values.',
        filterKey: 'needsValue',
      );
    }

    if (_containsAny(question, const [
      'has value',
      'with values',
      'valued pops',
      'valued collectibles',
    ])) {
      return const VaultSearchIntent(
        title: 'Collectibles With Values',
        message:
            'Atlas can open Entire Vault and show collectibles with recorded values.',
        filterKey: 'hasValue',
      );
    }

    if (_containsAny(question, const [
      'duplicate',
      'duplicates',
      'possible duplicate',
      'variant review group',
    ])) {
      return const VaultSearchIntent(
        title: 'Possible Duplicate Groups',
        message:
            'Atlas can open Entire Vault and show possible duplicate or variant review groups.',
        filterKey: 'duplicates',
      );
    }

    return null;
  }

  String? _extractSearchQuery({
    required String originalQuestion,
    required String normalizedQuestion,
  }) {
    final quoted = RegExp(
      r'''["“](.+?)["”]''',
      caseSensitive: false,
    ).firstMatch(originalQuestion);

    if (quoted != null) {
      final value = quoted.group(1)?.trim();

      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    const prefixes = [
      'find my ',
      'find ',
      'search for ',
      'search ',
      'show me my ',
      'show me ',
      'show ',
      'look for ',
      'look up ',
    ];

    String extracted = originalQuestion.trim();

    for (final prefix in prefixes) {
      if (!normalizedQuestion.startsWith(prefix)) {
        continue;
      }

      extracted = originalQuestion.substring(prefix.length).trim();

      break;
    }

    extracted = extracted
        .replaceAll(
          RegExp(
            r'\b(?:and\s+)?sort(?:ed)?\s+(?:by\s+)?'
            r'(?:highest|lowest)\s+value(?:\s+first)?\b',
            caseSensitive: false,
          ),
          ' ',
        )
        .replaceAll(
          RegExp(
            r'\b(?:and\s+)?(?:highest|lowest)\s+value'
            r'(?:\s+first)?\b',
            caseSensitive: false,
          ),
          ' ',
        )
        .replaceAll(
          RegExp(
            r'\b(?:most valuable|highest valued|most expensive|top value)\b',
            caseSensitive: false,
          ),
          ' ',
        )
        .replaceAll(
          RegExp(
            r'\b(?:worth|valued?)?\s*'
            r'(?:between|from)\s+\$?\d+(?:\.\d{1,2})?'
            r'\s+(?:and|to)\s+\$?\d+(?:\.\d{1,2})?\b',
            caseSensitive: false,
          ),
          ' ',
        )
        .replaceAll(
          RegExp(
            r'\b(?:worth|valued?)?\s*'
            r'(?:over|above|more than|greater than|at least|minimum|min)'
            r'\s+\$?\d+(?:\.\d{1,2})?\b',
            caseSensitive: false,
          ),
          ' ',
        )
        .replaceAll(
          RegExp(
            r'\b(?:worth|valued?)?\s*'
            r'(?:under|below|less than|no more than|at most|maximum|max)'
            r'\s+\$?\d+(?:\.\d{1,2})?\b',
            caseSensitive: false,
          ),
          ' ',
        )
        .replaceAll(
          RegExp(
            r'\b(?:signed|signature|autograph|autographed)\b',
            caseSensitive: false,
          ),
          ' ',
        )
        .replaceAll(
          RegExp(r'\b(?:retail\s+)?exclusives?\b', caseSensitive: false),
          ' ',
        )
        .replaceAll(
          RegExp(r'\b(?:event\s+)?stickers?|stickered\b', caseSensitive: false),
          ' ',
        )
        .replaceAll(
          RegExp(
            r'\b(?:variants?|chase|black\s*light|glow|metallic|flocked)\b',
            caseSensitive: false,
          ),
          ' ',
        )
        .replaceAll(
          RegExp(
            r'\b(?:limited edition|limited|numbered pieces?)\b',
            caseSensitive: false,
          ),
          ' ',
        )
        .replaceAll(
          RegExp(r'\b(?:wishlist|wish list|wanted)\b', caseSensitive: false),
          ' ',
        )
        .replaceAll(
          RegExp(r'\b(?:owned|my collection|i own)\b', caseSensitive: false),
          ' ',
        )
        .replaceAll(
          RegExp(
            r'\b(?:missing values?|needs? values?|without value)\b',
            caseSensitive: false,
          ),
          ' ',
        )
        .replaceAll(
          RegExp(
            r'\b(?:has value|with values|valued pops|valued collectibles)\b',
            caseSensitive: false,
          ),
          ' ',
        )
        .replaceAll(
          RegExp(
            r'\b(?:possible\s+)?duplicates?|variant review group\b',
            caseSensitive: false,
          ),
          ' ',
        )
        .replaceAll(
          RegExp(r'\b(?:pops?|collectibles?|items?)\b', caseSensitive: false),
          ' ',
        )
        .replaceAll(
          RegExp(
            r'\b(?:value\s+increased|value\s+decreased|gained\s+value|'
            r'lost\s+value|value\s+history|price\s+history|'
            r'value\s+trend)\b',
            caseSensitive: false,
          ),
          ' ',
        )
        .replaceAll(
          RegExp(
            r'\b(?:released\s+in|release\s+year|'
            r'from\s+the\s+year|from)\s+'
            r'(?:\d{4}|\d{2}\s*[/\\-]\s*\d{2})\b',
            caseSensitive: false,
          ),
          ' ',
        )
        .replaceAll(
          RegExp(
            r'\b(?:mint|near mint|damaged|poor|good|excellent)\s+'
            r'(?:box\s+)?condition\b',
            caseSensitive: false,
          ),
          ' ',
        )
        .replaceAll(
          RegExp(
            r'\b(?:with|in)\s+(?:a\s+)?damaged box\b',
            caseSensitive: false,
          ),
          ' ',
        )
        .replaceAll(
          RegExp(
            r'\b(?:price paid|purchase price|what i paid|'
            r'how much i paid)\b',
            caseSensitive: false,
          ),
          ' ',
        )
        .replaceAll(
          RegExp(r'\b(?:worth|valued|value)\b', caseSensitive: false),
          ' ',
        )
        .replaceAll(RegExp(r'^(?:by|with|using)\s+', caseSensitive: false), ' ')
        .trim();

    extracted = extracted.replaceAll(RegExp(r'\s+'), ' ').trim();

    const connectorOnlyWords = {
      'and',
      'by',
      'with',
      'using',
      'for',
      'from',
      'of',
      'the',
      'that are',
      'which are',
    };

    while (extracted.isNotEmpty) {
      final previousValue = extracted;

      extracted = extracted
          .replaceFirst(
            RegExp(
              r'^(?:and|by|with|using|for|from|of|the|that are|which are)\b\s*',
              caseSensitive: false,
            ),
            '',
          )
          .replaceFirst(
            RegExp(
              r'\s*\b(?:and|by|with|using|for|from|of|the|that are|which are)$',
              caseSensitive: false,
            ),
            '',
          )
          .trim();

      if (extracted == previousValue) {
        break;
      }
    }

    if (extracted.isEmpty ||
        connectorOnlyWords.contains(extracted.toLowerCase())) {
      return null;
    }

    return extracted;
  }

  String _titleForCombinedIntent({
    required bool hasSearch,
    required bool hasValueRange,
    required bool hasSort,
    required VaultSearchIntent? filterIntent,
    required VaultSearchIntent? valueIntent,
  }) {
    if (hasSearch) {
      return 'Search Entire Vault';
    }

    if (hasValueRange) {
      return 'Collectibles by Value';
    }

    if (filterIntent != null) {
      return filterIntent.title;
    }

    if (hasSort) {
      return valueIntent?.title ?? 'Sorted Vault';
    }

    return 'Vault Search';
  }

  List<String> _detectUnsupportedParts(String question) {
    final unsupported = <String>[];

    final asksForReleaseYear = RegExp(
      r'\b(?:released\s+in|release\s+year|from\s+the\s+year|from)\s+'
      r'(?:\d{4}|\d{2}\s*[/\\-]\s*\d{2})\b',
      caseSensitive: false,
    ).hasMatch(question);

    if (asksForReleaseYear) {
      unsupported.add('release-year filtering');
    }

    final asksForCondition = _containsAny(question, const [
      'box condition',
      'item condition',
      'mint condition',
      'near mint',
      'damaged box',
      'poor condition',
      'good condition',
      'excellent condition',
    ]);

    if (asksForCondition) {
      unsupported.add('condition filtering');
    }

    final asksForPricePaid = _containsAny(question, const [
      'price paid',
      'purchase price',
      'what i paid',
      'how much i paid',
      'paid for',
    ]);

    if (asksForPricePaid) {
      unsupported.add('price-paid filtering');
    }

    final asksForValueHistory = _containsAny(question, const [
      'value increased',
      'value decreased',
      'gained value',
      'lost value',
      'value history',
      'price history',
      'value trend',
    ]);

    if (asksForValueHistory) {
      unsupported.add('value-history filtering');
    }

    return unsupported;
  }

  bool _containsAny(String value, List<String> terms) {
    return terms.any(value.contains);
  }
}
