import '../../models/pop.dart';

class VaultQueryPreviewResult {
  const VaultQueryPreviewResult({
    required this.matches,
  });

  final List<Pop> matches;

  int get matchCount => matches.length;

  bool get hasMatches => matches.isNotEmpty;
}

class VaultQueryPreviewEngine {
  const VaultQueryPreviewEngine();

  VaultQueryPreviewResult preview({
    required List<Pop> pops,
    String? filterKey,
    String? searchQuery,
    double? minimumValue,
    double? maximumValue,
    String? sortKey,
  }) {
    Iterable<Pop> results = pops;

    final cleanedSearch = searchQuery?.trim().toLowerCase();

    if (cleanedSearch != null && cleanedSearch.isNotEmpty) {
      results = results.where(
            (pop) => _matchesSearch(
          pop,
          cleanedSearch,
        ),
      );
    }

    if (filterKey != null && filterKey.trim().isNotEmpty) {
      results = _applyFilter(
        pops: pops,
        currentResults: results,
        filterKey: filterKey,
      );
    }

    if (minimumValue != null) {
      results = results.where(
            (pop) => pop.value >= minimumValue,
      );
    }

    if (maximumValue != null) {
      results = results.where(
            (pop) => pop.value <= maximumValue,
      );
    }

    final sortedResults = results.toList();

    _applySort(
      sortedResults,
      sortKey,
    );

    return VaultQueryPreviewResult(
      matches: List<Pop>.unmodifiable(
        sortedResults,
      ),
    );
  }

  bool _matchesSearch(
      Pop pop,
      String search,
      ) {
    final searchableValues = [
      pop.name,
      pop.number,
      pop.category,
      pop.series,
      pop.owner,
    ];

    return searchableValues.any(
          (value) => value.toLowerCase().contains(search),
    );
  }

  Iterable<Pop> _applyFilter({
    required List<Pop> pops,
    required Iterable<Pop> currentResults,
    required String filterKey,
  }) {
    switch (filterKey) {
      case 'signed':
        return currentResults.where(
              (pop) => _hasMeaningfulValue(
            pop.signature,
            ignoredValues: const {
              'unsigned',
            },
          ),
        );

      case 'exclusives':
        return currentResults.where(
              (pop) => _hasMeaningfulValue(
            pop.retailExclusive,
          ),
        );

      case 'stickers':
        return currentResults.where(
              (pop) => _hasMeaningfulValue(
            pop.eventSticker,
          ),
        );

      case 'variants':
        return currentResults.where(
          _isVariant,
        );

      case 'limited':
        return currentResults.where(
              (pop) => _hasMeaningfulValue(
            pop.limitedEdition,
          ),
        );

      case 'wishlist':
        return currentResults.where(
              (pop) => pop.isWishlist,
        );

      case 'owned':
        return currentResults.where(
              (pop) => !pop.isWishlist,
        );

      case 'needsValue':
        return currentResults.where(
              (pop) => pop.value <= 0,
        );

      case 'hasValue':
        return currentResults.where(
              (pop) => pop.value > 0,
        );

      case 'duplicates':
        final duplicateIdentities =
        _buildDuplicateIdentities(pops);

        return currentResults.where(
              (pop) {
            final identity = pop.collectorIdentity;

            return identity.isNotEmpty &&
                duplicateIdentities.contains(identity);
          },
        );

      default:
        return currentResults;
    }
  }

  Set<String> _buildDuplicateIdentities(
      List<Pop> pops,
      ) {
    final identityCounts = <String, int>{};

    for (final pop in pops) {
      final identity = pop.collectorIdentity;

      if (identity.isEmpty) {
        continue;
      }

      identityCounts[identity] =
          (identityCounts[identity] ?? 0) + 1;
    }

    return identityCounts.entries
        .where((entry) => entry.value > 1)
        .map((entry) => entry.key)
        .toSet();
  }

  bool _isVariant(Pop pop) {
    return _hasMeaningfulValue(
      pop.variant,
      ignoredValues: const {
        'common',
        'standard',
      },
    ) ||
        _hasMeaningfulValue(
          pop.edition,
          ignoredValues: const {
            'common',
            'standard',
          },
        );
  }

  bool _hasMeaningfulValue(
      String value, {
        Set<String> ignoredValues = const {},
      }) {
    final cleaned = value.trim().toLowerCase();

    if (cleaned.isEmpty ||
        cleaned == 'none' ||
        cleaned == 'no' ||
        cleaned == 'n/a' ||
        cleaned == 'na') {
      return false;
    }

    return !ignoredValues.contains(cleaned);
  }

  void _applySort(
      List<Pop> results,
      String? sortKey,
      ) {
    switch (sortKey) {
      case 'highestValue':
        results.sort(
              (first, second) =>
              second.value.compareTo(first.value),
        );
        return;

      case 'lowestValue':
        results.sort(
              (first, second) =>
              first.value.compareTo(second.value),
        );
        return;

      case 'nameAZ':
        results.sort(
              (first, second) => first.name
              .toLowerCase()
              .compareTo(
            second.name.toLowerCase(),
          ),
        );
        return;

      case 'nameZA':
        results.sort(
              (first, second) => second.name
              .toLowerCase()
              .compareTo(
            first.name.toLowerCase(),
          ),
        );
        return;

      default:
        return;
    }
  }
}