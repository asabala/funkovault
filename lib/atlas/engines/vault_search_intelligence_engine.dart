class VaultSearchIntent {
  const VaultSearchIntent({
    required this.title,
    required this.message,
    this.filterKey,
    this.searchQuery,
    this.minimumValue,
    this.maximumValue,
    this.sortKey,
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

  bool get hasFilter =>
      filterKey != null && filterKey!.trim().isNotEmpty;

  bool get hasSearch =>
      searchQuery != null && searchQuery!.trim().isNotEmpty;

  bool get hasValueRange =>
      minimumValue != null || maximumValue != null;

  bool get hasSort =>
      sortKey != null && sortKey!.trim().isNotEmpty;

  bool get hasNavigationAction =>
      hasFilter || hasSearch || hasValueRange || hasSort;
}

class VaultSearchIntelligenceEngine {
  const VaultSearchIntelligenceEngine();

  VaultSearchIntent interpret(String question) {
    final cleanedQuestion = question.trim();
    final normalized = cleanedQuestion.toLowerCase();

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

    if (valueIntent != null) {
      return valueIntent;
    }

    final filterIntent = _interpretFilterIntent(normalized);

    if (filterIntent != null) {
      return filterIntent;
    }

    final extractedSearch = _extractSearchQuery(
      originalQuestion: cleanedQuestion,
      normalizedQuestion: normalized,
    );

    if (extractedSearch != null) {
      return VaultSearchIntent(
        title: 'Search Entire Vault',
        message:
        'Atlas can search your Vault for “$extractedSearch” using name, number, category, series, and owner.',
        searchQuery: extractedSearch,
      );
    }

    return const VaultSearchIntent(
      title: 'Vault Search',
      message:
      'Atlas could not identify a supported Vault filter, value range, or search phrase. Try asking for signed Pops, exclusives, wishlist items, stickers, variants, a collectible name, or a value range.',
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
      final firstValue = double.tryParse(
        betweenMatch.group(1) ?? '',
      );
      final secondValue = double.tryParse(
        betweenMatch.group(2) ?? '',
      );

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
      final minimumValue = double.tryParse(
        minimumMatch.group(1) ?? '',
      );

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
      final maximumValue = double.tryParse(
        maximumMatch.group(1) ?? '',
      );

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

    if (_containsAny(question, const [
      'wishlist',
      'wish list',
      'wanted',
    ])) {
      return const VaultSearchIntent(
        title: 'Wishlist Collectibles',
        message:
        'Atlas can open Entire Vault and show collectibles currently on your wishlist.',
        filterKey: 'wishlist',
      );
    }

    if (_containsAny(question, const [
      'owned',
      'my collection',
      'i own',
    ])) {
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
      'look for ',
      'look up ',
    ];

    for (final prefix in prefixes) {
      if (!normalizedQuestion.startsWith(prefix)) {
        continue;
      }

      final extracted = originalQuestion
          .substring(prefix.length)
          .trim()
          .replaceAll(
        RegExp(
          r'\b(pops?|collectibles?|items?)\b',
          caseSensitive: false,
        ),
        '',
      )
          .trim();

      if (extracted.isNotEmpty) {
        return extracted;
      }
    }

    return null;
  }

  bool _containsAny(
      String value,
      List<String> terms,
      ) {
    return terms.any(value.contains);
  }
}