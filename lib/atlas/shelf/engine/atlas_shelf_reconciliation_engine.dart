import '../../../models/pop.dart';
import '../../../services/duplicate_review_service.dart';
import '../../collection/engine/atlas_collector_state_engine.dart';
import '../../collection/models/atlas_collector_state.dart';
import '../../completion/models/atlas_completion_result.dart';
import '../models/atlas_shelf_expected_item.dart';
import '../models/atlas_shelf_observation.dart';
import '../models/atlas_shelf_proposed_action.dart';
import '../models/atlas_shelf_reconciliation_result.dart';

/// Projects existing Atlas collector, identity-review, and completion truth
/// into a physical shelf-session view.
///
/// This engine is pure: it never writes to AppState and never commits actions.
final class AtlasShelfReconciliationEngine {
  const AtlasShelfReconciliationEngine({
    this.collectorStateEngine = const AtlasCollectorStateEngine(),
    this.duplicateReviewService = const DuplicateReviewService(),
  });

  final AtlasCollectorStateEngine collectorStateEngine;
  final DuplicateReviewService duplicateReviewService;

  AtlasShelfReconciliationResult reconcile({
    required Iterable<AtlasShelfObservation> observations,
    required List<Pop> collectionPops,
    Set<String> ownedWishlistIdentityKeys = const <String>{},
    AtlasCompletionResult? completionResult,
  }) {
    final List<AtlasShelfObservation> ordered = observations.toList()
      ..sort((first, second) {
        final int time = first.firstSeenAt.compareTo(second.firstSeenAt);
        if (time != 0) return time;
        return first.observationId.compareTo(second.observationId);
      });

    final Map<String, int> observedExactCounts = <String, int>{};
    final List<AtlasShelfObservation> reconciled = <AtlasShelfObservation>[];

    for (final AtlasShelfObservation observation in ordered) {
      reconciled.add(
        _reconcileObservation(
          observation: observation,
          collectionPops: collectionPops,
          ownedWishlistIdentityKeys: ownedWishlistIdentityKeys,
          observedExactCounts: observedExactCounts,
        ),
      );
    }

    final List<AtlasShelfExpectedItem> expectedItems = _buildExpectedItems(
      collectionPops: collectionPops,
      observations: reconciled,
    );

    final List<AtlasShelfProposedAction> actions = reconciled
        .map(_actionForObservation)
        .whereType<AtlasShelfProposedAction>()
        .toList(growable: false);

    return AtlasShelfReconciliationResult(
      observations: reconciled,
      expectedItems: expectedItems,
      proposedActions: actions,
      completionGaps: completionResult?.missingItems ?? const [],
      vaultIdentityReview: duplicateReviewService.buildReport(collectionPops),
    );
  }

  AtlasShelfObservation _reconcileObservation({
    required AtlasShelfObservation observation,
    required List<Pop> collectionPops,
    required Set<String> ownedWishlistIdentityKeys,
    required Map<String, int> observedExactCounts,
  }) {
    final Pop? product = observation.product;

    if (product == null ||
        observation.resolutionRequiresReview ||
        product.collectibleIdentityKey.trim().isEmpty) {
      return observation.copyWith(
        state: AtlasShelfObservationState.needsReview,
        ownedQuantity: 0,
        observedCopyIndex: 0,
      );
    }

    final bool hasPossibleVariantRelationship = _hasPossibleVariantRelationship(
      product: product,
      collectionPops: collectionPops,
    );

    final AtlasCollectorState collectorState = collectorStateEngine.evaluate(
      product: product,
      collectionPops: collectionPops,
      scannedBarcode: observation.scannedBarcode,
      ownedWishlistIdentityKeys: ownedWishlistIdentityKeys,
    );

    final String identityKey = product.collectibleIdentityKey.trim();
    final int copyIndex = (observedExactCounts[identityKey] ?? 0) + 1;
    observedExactCounts[identityKey] = copyIndex;

    // Identity Intelligence gets first say on meaningful release differences.
    // This prevents a reused UPC from collapsing Common/Chase/sticker variants
    // into an exact shelf match.
    if (hasPossibleVariantRelationship) {
      return observation.copyWith(
        state: AtlasShelfObservationState.possibleVariant,
        ownedQuantity: 0,
        observedCopyIndex: copyIndex,
      );
    }

    if (collectorState.isOwned) {
      final AtlasShelfObservationState state =
          copyIndex > collectorState.ownedQuantity
          ? AtlasShelfObservationState.extraCopy
          : AtlasShelfObservationState.owned;

      return observation.copyWith(
        state: state,
        ownedQuantity: collectorState.ownedQuantity,
        observedCopyIndex: copyIndex,
      );
    }

    if (collectorState.hasRelatedMatches) {
      return observation.copyWith(
        state: AtlasShelfObservationState.possibleVariant,
        ownedQuantity: 0,
        observedCopyIndex: copyIndex,
      );
    }

    return observation.copyWith(
      state: AtlasShelfObservationState.notInVault,
      ownedQuantity: 0,
      observedCopyIndex: copyIndex,
    );
  }

  bool _hasPossibleVariantRelationship({
    required Pop product,
    required List<Pop> collectionPops,
  }) {
    if (collectionPops.isEmpty) return false;

    final List<Pop> combined = <Pop>[...collectionPops, product];
    final DuplicateReviewReport report = duplicateReviewService.buildReport(
      combined,
    );

    return report.possibleVariantGroups.any(
      (group) => group.pops.any((pop) => identical(pop, product)),
    );
  }

  List<AtlasShelfExpectedItem> _buildExpectedItems({
    required List<Pop> collectionPops,
    required List<AtlasShelfObservation> observations,
  }) {
    final Map<String, int> observedByIdentity = <String, int>{};

    for (final AtlasShelfObservation observation in observations) {
      if (observation.state != AtlasShelfObservationState.owned &&
          observation.state != AtlasShelfObservationState.extraCopy) {
        continue;
      }

      final String key = observation.collectibleIdentityKey;
      if (key.isEmpty) continue;
      observedByIdentity[key] = (observedByIdentity[key] ?? 0) + 1;
    }

    final Map<String, ({Pop pop, int quantity})> expectedByIdentity =
        <String, ({Pop pop, int quantity})>{};

    for (final Pop pop in collectionPops.where((pop) => !pop.isWishlist)) {
      final String key = pop.collectibleIdentityKey.trim();
      if (key.isEmpty) continue;

      final int quantity = pop.quantity < 1 ? 1 : pop.quantity;
      final current = expectedByIdentity[key];
      expectedByIdentity[key] = (
        pop: current?.pop ?? pop,
        quantity: (current?.quantity ?? 0) + quantity,
      );
    }

    final List<AtlasShelfExpectedItem> result = <AtlasShelfExpectedItem>[];

    for (final entry in expectedByIdentity.entries) {
      final int expectedQuantity = entry.value.quantity;
      final int observedQuantity = (observedByIdentity[entry.key] ?? 0)
          .clamp(0, expectedQuantity)
          .toInt();

      final AtlasShelfExpectedItemState state;
      if (observedQuantity <= 0) {
        state = AtlasShelfExpectedItemState.missingFromShelf;
      } else if (observedQuantity < expectedQuantity) {
        state = AtlasShelfExpectedItemState.partiallyObserved;
      } else {
        state = AtlasShelfExpectedItemState.observed;
      }

      result.add(
        AtlasShelfExpectedItem(
          pop: entry.value.pop,
          expectedQuantity: expectedQuantity,
          observedQuantity: observedQuantity,
          state: state,
        ),
      );
    }

    return List<AtlasShelfExpectedItem>.unmodifiable(result);
  }

  AtlasShelfProposedAction? _actionForObservation(
    AtlasShelfObservation observation,
  ) {
    final String id = observation.observationId;

    return switch (observation.state) {
      AtlasShelfObservationState.owned => null,
      AtlasShelfObservationState.notInVault => AtlasShelfProposedAction(
        actionId: 'shelf-add-$id',
        type: AtlasShelfProposedActionType.addToVault,
        observationId: id,
        title: 'Add to Vault',
        explanation:
            'This observed release is not currently owned in the scoped Vault.',
      ),
      AtlasShelfObservationState.possibleVariant => AtlasShelfProposedAction(
        actionId: 'shelf-variant-$id',
        type: AtlasShelfProposedActionType.reviewVariant,
        observationId: id,
        title: 'Review Variant / Sticker',
        explanation:
            'Atlas found a related release, but not an exact owned release.',
      ),
      AtlasShelfObservationState.extraCopy => AtlasShelfProposedAction(
        actionId: 'shelf-copy-$id',
        type: AtlasShelfProposedActionType.addAnotherCopy,
        observationId: id,
        title: 'Review Extra Copy',
        explanation:
            'More physical copies were observed than the scoped Vault quantity.',
      ),
      AtlasShelfObservationState.needsReview => AtlasShelfProposedAction(
        actionId: 'shelf-review-$id',
        type: AtlasShelfProposedActionType.reviewObservation,
        observationId: id,
        title: 'Needs Review',
        explanation:
            'Identity evidence is incomplete or the scanner requested collector review.',
      ),
    };
  }
}
