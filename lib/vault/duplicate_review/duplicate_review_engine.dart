import '../../models/pop.dart';

class DuplicateReviewEngine {
  const DuplicateReviewEngine();

  /// Builds the collectible identity used for duplicate review.
  ///
  /// Pops are only considered possible duplicates when all meaningful
  /// release details match. Collection-specific details such as value,
  /// condition, owner, quantity, and wishlist status are intentionally
  /// excluded.
  String reviewKey(Pop pop) {
    final name = _normalizeText(pop.name);
    final number = _normalizeText(pop.number);

    if (name.isEmpty || number.isEmpty) {
      return '';
    }

    return [
      name,
      number,
      _normalizeText(pop.category),
      _normalizeText(pop.series),
      _normalizeVariantValue(pop.edition),
      _normalizeVariantValue(pop.variant),
      _normalizeOptionalIdentityValue(pop.retailExclusive),
      _normalizeOptionalIdentityValue(pop.eventSticker),
      _normalizeOptionalIdentityValue(pop.limitedEdition),
      _normalizeSignatureValue(pop.signature),
    ].join('|');
  }

  Set<String> reviewKeys(List<Pop> pops) {
    final countsByKey = <String, int>{};

    for (final pop in pops) {
      final key = reviewKey(pop);

      if (key.isEmpty) {
        continue;
      }

      countsByKey[key] = (countsByKey[key] ?? 0) + 1;
    }

    return countsByKey.entries
        .where(
          (entry) => entry.value > 1,
    )
        .map(
          (entry) => entry.key,
    )
        .toSet();
  }

  int countGroups(List<Pop> pops) {
    return reviewKeys(pops).length;
  }

  List<Pop> filterReviewPops(List<Pop> pops) {
    final duplicateKeys = reviewKeys(pops);

    return pops
        .where(
          (pop) => duplicateKeys.contains(
        reviewKey(pop),
      ),
    )
        .toList();
  }

  List<DuplicateReviewGroup> buildGroups(List<Pop> pops) {
    final popsByKey = <String, List<Pop>>{};

    for (final pop in pops) {
      final key = reviewKey(pop);

      if (key.isEmpty) {
        continue;
      }

      popsByKey.putIfAbsent(
        key,
            () => <Pop>[],
      );

      popsByKey[key]!.add(pop);
    }

    return popsByKey.entries
        .where(
          (entry) => entry.value.length > 1,
    )
        .map(
          (entry) => DuplicateReviewGroup(
        key: entry.key,
        pops: List<Pop>.unmodifiable(
          entry.value,
        ),
      ),
    )
        .toList();
  }

  List<DuplicateReviewGroup> takeVisibleGroups(
      List<DuplicateReviewGroup> groups,
      int itemLimit,
      ) {
    final visibleGroups = <DuplicateReviewGroup>[];
    var visibleItemCount = 0;

    for (final group in groups) {
      final wouldExceedLimit =
          visibleItemCount + group.itemCount > itemLimit;

      if (visibleGroups.isNotEmpty && wouldExceedLimit) {
        break;
      }

      visibleGroups.add(group);
      visibleItemCount += group.itemCount;
    }

    return visibleGroups;
  }

  bool hasMeaningfulValue(String value) {
    final cleaned = _normalizeText(value);

    if (cleaned.isEmpty) {
      return false;
    }

    return cleaned != 'none' &&
        cleaned != 'common' &&
        cleaned != 'standard' &&
        cleaned != 'unsigned' &&
        cleaned != 'no' &&
        cleaned != 'n/a' &&
        cleaned != 'na';
  }

  static String _normalizeText(String value) {
    return value.trim().toLowerCase();
  }

  /// Common, Standard, None, and blank all represent the baseline release.
  static String _normalizeVariantValue(String value) {
    final cleaned = _normalizeText(value);

    if (cleaned.isEmpty ||
        cleaned == 'none' ||
        cleaned == 'no' ||
        cleaned == 'n/a' ||
        cleaned == 'na' ||
        cleaned == 'common' ||
        cleaned == 'standard') {
      return 'common';
    }

    return cleaned;
  }

  /// Blank, None, No, and N/A all represent no saved identity detail.
  static String _normalizeOptionalIdentityValue(String value) {
    final cleaned = _normalizeText(value);

    if (cleaned.isEmpty ||
        cleaned == 'none' ||
        cleaned == 'no' ||
        cleaned == 'n/a' ||
        cleaned == 'na') {
      return 'none';
    }

    return cleaned;
  }

  /// Blank, None, No, N/A, and Unsigned all represent an unsigned Pop.
  static String _normalizeSignatureValue(String value) {
    final cleaned = _normalizeText(value);

    if (cleaned.isEmpty ||
        cleaned == 'none' ||
        cleaned == 'no' ||
        cleaned == 'n/a' ||
        cleaned == 'na' ||
        cleaned == 'unsigned') {
      return 'unsigned';
    }

    return cleaned;
  }
}

class DuplicateReviewGroup {
  const DuplicateReviewGroup({
    required this.key,
    required this.pops,
  });

  final String key;
  final List<Pop> pops;

  Pop get firstPop => pops.first;

  int get itemCount => pops.length;

  String get name {
    final value = firstPop.name.trim();

    return value.isEmpty ? 'Unnamed Pop' : value;
  }

  String get number {
    final value = firstPop.number.trim();

    return value.isEmpty ? 'No #' : '#$value';
  }

  /// Groups now contain only Pops whose meaningful collectible identity
  /// fields match. This remains available for UI compatibility and future
  /// comparison fields.
  List<String> get differenceLabels {
    final differences = <String>[];

    if (_hasDifferentValues(
      pops.map((pop) => pop.category),
      normalizer: _normalizeText,
    )) {
      differences.add('Category details differ');
    }

    if (_hasDifferentValues(
      pops.map((pop) => pop.series),
      normalizer: _normalizeText,
    )) {
      differences.add('Series details differ');
    }

    if (_hasDifferentValues(
      pops.map((pop) => pop.edition),
      normalizer: _normalizeVariantValue,
    )) {
      differences.add('Edition details differ');
    }

    if (_hasDifferentValues(
      pops.map((pop) => pop.variant),
      normalizer: _normalizeVariantValue,
    )) {
      differences.add('Variant details differ');
    }

    if (_hasDifferentValues(
      pops.map((pop) => pop.retailExclusive),
      normalizer: _normalizeOptionalIdentityValue,
    )) {
      differences.add('Exclusive details differ');
    }

    if (_hasDifferentValues(
      pops.map((pop) => pop.eventSticker),
      normalizer: _normalizeOptionalIdentityValue,
    )) {
      differences.add('Sticker details differ');
    }

    if (_hasDifferentValues(
      pops.map((pop) => pop.limitedEdition),
      normalizer: _normalizeOptionalIdentityValue,
    )) {
      differences.add('Limited edition details differ');
    }

    if (_hasDifferentValues(
      pops.map((pop) => pop.signature),
      normalizer: _normalizeSignatureValue,
    )) {
      differences.add('Signature details differ');
    }

    return differences;
  }

  bool _hasDifferentValues(
      Iterable<String> values, {
        required String Function(String value) normalizer,
      }) {
    final normalizedValues = values
        .map(normalizer)
        .toSet();

    return normalizedValues.length > 1;
  }

  static String _normalizeText(String value) {
    return value.trim().toLowerCase();
  }

  static String _normalizeVariantValue(String value) {
    final cleaned = _normalizeText(value);

    if (cleaned.isEmpty ||
        cleaned == 'none' ||
        cleaned == 'no' ||
        cleaned == 'n/a' ||
        cleaned == 'na' ||
        cleaned == 'common' ||
        cleaned == 'standard') {
      return 'common';
    }

    return cleaned;
  }

  static String _normalizeOptionalIdentityValue(String value) {
    final cleaned = _normalizeText(value);

    if (cleaned.isEmpty ||
        cleaned == 'none' ||
        cleaned == 'no' ||
        cleaned == 'n/a' ||
        cleaned == 'na') {
      return 'none';
    }

    return cleaned;
  }

  static String _normalizeSignatureValue(String value) {
    final cleaned = _normalizeText(value);

    if (cleaned.isEmpty ||
        cleaned == 'none' ||
        cleaned == 'no' ||
        cleaned == 'n/a' ||
        cleaned == 'na' ||
        cleaned == 'unsigned') {
      return 'unsigned';
    }

    return cleaned;
  }
}