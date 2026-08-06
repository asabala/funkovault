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

  int get remainingReleaseCount {
    return totalReleaseCount - ownedReleaseCount;
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

  double get completionRatio {
    if (totalReleaseCount == 0) {
      return 0;
    }

    return (
        ownedReleaseCount /
            totalReleaseCount
    ).clamp(
      0,
      1,
    );
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

  bool get hasStarted {
    return ownedReleaseCount > 0;
  }

  bool get isNearCompletion {
    return !isComplete &&
        totalReleaseCount > 1 &&
        remainingReleaseCount <= 2;
  }

  bool get isHalfComplete {
    return !isComplete &&
        completionPercent >= 50;
  }

  bool get hasMissingChase {
    return missingItems.any(
          (AtlasCompletionItem item) {
        final String searchableText =
        <String>[
          item.displayName,
          item.variantName ?? '',
          item.catalogProduct.attributes
          ['rarity']
              ?.toString() ??
              '',
          item.catalogProduct.attributes
          ['treatment']
              ?.toString() ??
              '',
          item.catalogProduct.attributes
          ['finish']
              ?.toString() ??
              '',
        ].join(
          ' ',
        ).toLowerCase();

        return searchableText.contains(
          'chase',
        );
      },
    );
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

  String get formattedReleaseProgress {
    return '$ownedReleaseCount of '
        '$totalReleaseCount '
        '${totalReleaseCount == 1 ? 'Release' : 'Releases'}';
  }

  String get milestoneMessage {
    if (totalReleaseCount == 0) {
      return 'No related catalog releases were found.';
    }

    if (isComplete) {
      return 'Collection complete. Every release is owned.';
    }

    if (ownedReleaseCount == 0 &&
        wishlistReleaseCount > 0) {
      return 'Your next collecting goal is already on the Wishlist.';
    }

    if (ownedReleaseCount == 0) {
      return 'Start this collection with your first release.';
    }

    if (remainingReleaseCount == 1) {
      return hasMissingChase
          ? 'Only the Chase remains.'
          : 'Only one release remains.';
    }

    if (isNearCompletion) {
      return hasMissingChase
          ? 'Almost complete. A Chase is still missing.'
          : 'Almost complete. Only '
          '$remainingReleaseCount releases remain.';
    }

    if (completionPercent >= 75) {
      return 'The finish line is in sight.';
    }

    if (completionPercent >= 50) {
      return 'You are halfway there.';
    }

    if (hasWishlistItems) {
      return 'Good progress. Your Wishlist can guide the next move.';
    }

    return 'Great start. Keep building this collection.';
  }

  String get nextGoalLabel {
    if (totalReleaseCount == 0) {
      return 'Catalog review needed';
    }

    if (isComplete) {
      return 'All releases collected';
    }

    if (remainingReleaseCount == 1) {
      return 'Collect the final release';
    }

    if (hasMissingChase) {
      return 'Track down the missing Chase';
    }

    if (wishlistReleaseCount > 0) {
      return 'Review Wishlist releases';
    }

    return 'Collect the next missing release';
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