import '../../models/pop.dart';

class DuplicateReviewEngine {
  const DuplicateReviewEngine();

  /// Duplicate Review compares the collectible release itself.
  ///
  /// Owner, wishlist status, value, condition, quantity, and other
  /// collection-specific details do not define the collectible.
  String reviewKey(Pop pop) {
    return pop.collectibleIdentityKey;
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

    return pops.where((pop) => duplicateKeys.contains(reviewKey(pop))).toList();
  }

  List<DuplicateReviewGroup> buildGroups(List<Pop> pops) {
    final popsByKey = <String, List<Pop>>{};

    for (final pop in pops) {
      final key = reviewKey(pop);

      if (key.isEmpty) {
        continue;
      }

      popsByKey.putIfAbsent(key, () => <Pop>[]);

      popsByKey[key]!.add(pop);
    }

    return popsByKey.entries
        .where((entry) => entry.value.length > 1)
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
      final wouldExceedLimit = visibleItemCount + group.itemCount > itemLimit;

      if (visibleGroups.isNotEmpty && wouldExceedLimit) {
        break;
      }

      visibleGroups.add(group);
      visibleItemCount += group.itemCount;
    }

    return visibleGroups;
  }

  bool hasMeaningfulValue(String value) {
    return Pop.hasMeaningfulIdentityLabel(value);
  }
}

class DuplicateReviewGroup {
  const DuplicateReviewGroup({required this.key, required this.pops});

  final String key;
  final List<Pop> pops;

  Pop get firstPop => pops.first;

  int get itemCount => pops.length;

  int get totalQuantity {
    return pops.fold<int>(0, (total, pop) => total + pop.quantity);
  }

  String get name {
    final value = firstPop.name.trim();

    return value.isEmpty ? 'Unnamed Pop' : value;
  }

  String get number {
    final value = firstPop.number.trim();

    return value.isEmpty ? 'No #' : '#$value';
  }

  /// Every Pop in a group now shares the same centralized collectible
  /// identity. Collection-specific values may still differ, but those
  /// differences do not describe a different collectible release.
  List<String> get differenceLabels => const [];
}
