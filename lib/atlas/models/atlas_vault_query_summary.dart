class AtlasVaultQuerySummary {
  const AtlasVaultQuerySummary({
    this.filterKey,
    this.searchQuery,
    this.minimumValue,
    this.maximumValue,
    this.sortKey,
    this.unsupportedParts = const [],
  });

  final String? filterKey;
  final String? searchQuery;
  final double? minimumValue;
  final double? maximumValue;
  final String? sortKey;
  final List<String> unsupportedParts;

  bool get hasFilter =>
      filterKey != null &&
      filterKey!.trim().isNotEmpty &&
      filterKey!.trim().toLowerCase() != 'all';

  bool get hasSearchQuery =>
      searchQuery != null && searchQuery!.trim().isNotEmpty;

  bool get hasValueRange => minimumValue != null || maximumValue != null;

  bool get hasSort => sortKey != null && sortKey!.trim().isNotEmpty;

  bool get hasUnsupportedParts => unsupportedParts.isNotEmpty;

  bool get hasRecognizedCriteria =>
      hasFilter || hasSearchQuery || hasValueRange || hasSort;

  String get confirmationText {
    if (!hasRecognizedCriteria) {
      return 'Atlas did not detect a Vault search or filter request.';
    }

    final details = <String>[];

    if (hasSearchQuery) {
      details.add('matching “${searchQuery!.trim()}”');
    }

    if (hasFilter) {
      details.add(_filterDescription(filterKey!));
    }

    final valueDescription = _valueDescription();

    if (valueDescription != null) {
      details.add(valueDescription);
    }

    if (hasSort) {
      details.add(_sortDescription(sortKey!));
    }

    return 'Showing ${_joinDetails(details)}.';
  }

  String? get unsupportedText {
    if (!hasUnsupportedParts) {
      return null;
    }

    if (unsupportedParts.length == 1) {
      return 'Atlas could not apply: ${unsupportedParts.first}.';
    }

    return 'Atlas could not apply: ${unsupportedParts.join(', ')}.';
  }

  String _filterDescription(String value) {
    switch (_normalize(value)) {
      case 'owned':
        return 'owned Pops';
      case 'wishlist':
        return 'wishlist Pops';
      case 'exclusive':
      case 'exclusives':
        return 'exclusive Pops';
      case 'variant':
      case 'variants':
        return 'variant Pops';
      case 'sticker':
      case 'stickers':
        return 'stickered Pops';
      case 'signed':
        return 'signed Pops';
      case 'limited':
      case 'limitededition':
      case 'limited_edition':
        return 'limited-edition Pops';
      case 'needsvalue':
      case 'needs_value':
        return 'Pops needing a value';
      case 'duplicates':
        return 'possible duplicate or variant-review groups';
      default:
        return '${_humanize(value)} Pops';
    }
  }

  String? _valueDescription() {
    final minimum = minimumValue;
    final maximum = maximumValue;

    if (minimum != null && maximum != null) {
      final lower = minimum <= maximum ? minimum : maximum;
      final upper = minimum <= maximum ? maximum : minimum;

      return 'valued between ${_formatCurrency(lower)} '
          'and ${_formatCurrency(upper)}';
    }

    if (minimum != null) {
      return 'valued at least ${_formatCurrency(minimum)}';
    }

    if (maximum != null) {
      return 'valued up to ${_formatCurrency(maximum)}';
    }

    return null;
  }

  String _sortDescription(String value) {
    switch (_normalize(value)) {
      case 'valuehighlow':
      case 'value_high_low':
      case 'highestvalue':
      case 'highest_value':
        return 'sorted highest value first';
      case 'valuelowhigh':
      case 'value_low_high':
      case 'lowestvalue':
      case 'lowest_value':
        return 'sorted lowest value first';
      case 'nameaz':
      case 'name_az':
        return 'sorted by name A–Z';
      case 'nameza':
      case 'name_za':
        return 'sorted by name Z–A';
      case 'newest':
      case 'newestfirst':
      case 'newest_first':
        return 'sorted newest first';
      case 'oldest':
      case 'oldestfirst':
      case 'oldest_first':
        return 'sorted oldest first';
      default:
        return 'sorted by ${_humanize(value)}';
    }
  }

  String _joinDetails(List<String> details) {
    if (details.isEmpty) {
      return 'your Vault results';
    }

    if (details.length == 1) {
      return details.first;
    }

    if (details.length == 2) {
      return '${details.first}, ${details.last}';
    }

    final leadingDetails = details.sublist(0, details.length - 1);

    return '${leadingDetails.join(', ')}, ${details.last}';
  }

  String _formatCurrency(double value) {
    final hasDecimals = value.truncateToDouble() != value;

    return '\$${value.toStringAsFixed(hasDecimals ? 2 : 0)}';
  }

  String _normalize(String value) {
    return value.trim().toLowerCase().replaceAll('-', '_').replaceAll(' ', '');
  }

  String _humanize(String value) {
    final spaced = value
        .trim()
        .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (match) => '${match.group(1)} ${match.group(2)}',
        )
        .replaceAll('_', ' ')
        .replaceAll('-', ' ');

    if (spaced.isEmpty) {
      return 'selected criteria';
    }

    return spaced;
  }
}
