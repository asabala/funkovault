import 'dart:collection';

import 'atlas_completion_item.dart';
import 'atlas_completion_query.dart';

final class AtlasCompletionResult {
  AtlasCompletionResult({
    required this.query,
    required Iterable<AtlasCompletionItem> items,
  }) : items =
  List<AtlasCompletionItem>.unmodifiable(
    items,
  );

  final AtlasCompletionQuery query;

  final List<AtlasCompletionItem> items;

  bool get isEmpty {
    return items.isEmpty;
  }

  bool get isNotEmpty {
    return items.isNotEmpty;
  }

  int get totalReleaseCount {
    return items.length;
  }

  int get ownedReleaseCount {
    return items.where(
          (AtlasCompletionItem item) {
        return item.isOwned;
      },
    ).length;
  }

  int get wishlistReleaseCount {
    return items.where(
          (AtlasCompletionItem item) {
        return item.isWishlisted;
      },
    ).length;
  }

  int get missingReleaseCount {
    return items.where(
          (AtlasCompletionItem item) {
        return item.isMissing;
      },
    ).length;
  }

  int get totalOwnedQuantity {
    return items.fold<int>(
      0,
          (
          int total,
          AtlasCompletionItem item,
          ) {
        return total + item.ownedQuantity;
      },
    );
  }

  double get completionPercent {
    if (totalReleaseCount == 0) {
      return 0;
    }

    return (
        ownedReleaseCount /
            totalReleaseCount
    ) *
        100;
  }

  double get wishlistProgressPercent {
    if (totalReleaseCount == 0) {
      return 0;
    }

    return (
        (
            ownedReleaseCount +
                wishlistReleaseCount
        ) /
            totalReleaseCount
    ) *
        100;
  }

  bool get isComplete {
    return totalReleaseCount > 0 &&
        ownedReleaseCount ==
            totalReleaseCount;
  }

  bool get hasWishlistItems {
    return wishlistReleaseCount > 0;
  }

  bool get hasMissingItems {
    return missingReleaseCount > 0;
  }

  List<AtlasCompletionItem> get ownedItems {
    return List<AtlasCompletionItem>.unmodifiable(
      items.where(
            (AtlasCompletionItem item) {
          return item.isOwned;
        },
      ),
    );
  }

  List<AtlasCompletionItem> get wishlistItems {
    return List<AtlasCompletionItem>.unmodifiable(
      items.where(
            (AtlasCompletionItem item) {
          return item.isWishlisted;
        },
      ),
    );
  }

  List<AtlasCompletionItem> get missingItems {
    return List<AtlasCompletionItem>.unmodifiable(
      items.where(
            (AtlasCompletionItem item) {
          return item.isMissing;
        },
      ),
    );
  }

  Map<AtlasCompletionItemState, List<AtlasCompletionItem>>
  get itemsByState {
    final Map<
        AtlasCompletionItemState,
        List<AtlasCompletionItem>>
    groupedItems =
    <AtlasCompletionItemState,
        List<AtlasCompletionItem>>{
      for (final AtlasCompletionItemState state
      in AtlasCompletionItemState.values)
        state: <AtlasCompletionItem>[],
    };

    for (final AtlasCompletionItem item
    in items) {
      groupedItems[item.state]!.add(
        item,
      );
    }

    return UnmodifiableMapView<
        AtlasCompletionItemState,
        List<AtlasCompletionItem>>(
      groupedItems.map(
            (
            AtlasCompletionItemState state,
            List<AtlasCompletionItem> items,
            ) {
          return MapEntry<
              AtlasCompletionItemState,
              List<AtlasCompletionItem>>(
            state,
            List<AtlasCompletionItem>.unmodifiable(
              items,
            ),
          );
        },
      ),
    );
  }

  String get formattedCompletion {
    return '${completionPercent.toStringAsFixed(0)}%';
  }

  String get formattedProgress {
    return '$ownedReleaseCount / $totalReleaseCount';
  }

  String get summaryLabel {
    if (totalReleaseCount == 0) {
      return 'No catalog releases found';
    }

    if (isComplete) {
      return 'Collection complete';
    }

    if (ownedReleaseCount == 0) {
      return 'No releases owned yet';
    }

    return '$missingReleaseCount release'
        '${missingReleaseCount == 1 ? '' : 's'} missing';
  }

  AtlasCompletionResult copyWith({
    AtlasCompletionQuery? query,
    Iterable<AtlasCompletionItem>? items,
  }) {
    return AtlasCompletionResult(
      query: query ?? this.query,
      items: items ?? this.items,
    );
  }

  @override
  String toString() {
    return 'AtlasCompletionResult('
        '$formattedProgress, '
        '$formattedCompletion'
        ')';
  }
}