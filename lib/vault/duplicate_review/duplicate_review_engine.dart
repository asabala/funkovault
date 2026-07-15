import '../../models/pop.dart';

class DuplicateReviewEngine {
  const DuplicateReviewEngine();

  String reviewKey(Pop pop) {
    final name = _normalize(pop.name);
    final number = _normalize(pop.number);

    if (name.isEmpty || number.isEmpty) {
      return '';
    }

    return '$name|$number';
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
        .where((entry) => entry.value > 1)
        .map((entry) => entry.key)
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
        pops: List<Pop>.unmodifiable(entry.value),
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
    final cleaned = _normalize(value);

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

  static String _normalize(String value) {
    return value.trim().toLowerCase();
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

  List<String> get differenceLabels {
    final differences = <String>[];

    if (_hasDifferentValues(
      pops.map((pop) => pop.variant),
      emptyValue: 'standard',
    )) {
      differences.add('Variant details differ');
    }

    if (_hasDifferentValues(
      pops.map((pop) => pop.retailExclusive),
      emptyValue: 'none',
    )) {
      differences.add('Exclusive details differ');
    }

    if (_hasDifferentValues(
      pops.map((pop) => pop.eventSticker),
      emptyValue: 'none',
    )) {
      differences.add('Sticker details differ');
    }

    if (_hasDifferentValues(
      pops.map((pop) => pop.signature),
      emptyValue: 'unsigned',
    )) {
      differences.add('Signature details differ');
    }

    if (_hasDifferentValues(
      pops.map((pop) => pop.limitedEdition),
      emptyValue: 'none',
    )) {
      differences.add('Limited edition details differ');
    }

    return differences;
  }

  bool _hasDifferentValues(
      Iterable<String> values, {
        required String emptyValue,
      }) {
    final normalizedValues = values
        .map(
          (value) => _normalizeReviewValue(
        value,
        emptyValue: emptyValue,
      ),
    )
        .toSet();

    return normalizedValues.length > 1;
  }

  String _normalizeReviewValue(
      String value, {
        required String emptyValue,
      }) {
    final cleaned = value.trim().toLowerCase();

    if (cleaned.isEmpty ||
        cleaned == 'none' ||
        cleaned == 'no' ||
        cleaned == 'n/a' ||
        cleaned == 'na') {
      return emptyValue;
    }

    if (emptyValue == 'standard' &&
        (cleaned == 'common' || cleaned == 'standard')) {
      return 'standard';
    }

    if (emptyValue == 'unsigned' && cleaned == 'unsigned') {
      return 'unsigned';
    }

    return cleaned;
  }
}