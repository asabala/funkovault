import '../../completion/models/atlas_completion_item.dart';
import '../../../services/duplicate_review_service.dart';
import 'atlas_shelf_expected_item.dart';
import 'atlas_shelf_observation.dart';
import 'atlas_shelf_proposed_action.dart';

final class AtlasShelfReconciliationResult {
  AtlasShelfReconciliationResult({
    required Iterable<AtlasShelfObservation> observations,
    required Iterable<AtlasShelfExpectedItem> expectedItems,
    required Iterable<AtlasShelfProposedAction> proposedActions,
    required Iterable<AtlasCompletionItem> completionGaps,
    required this.vaultIdentityReview,
  }) : observations = List<AtlasShelfObservation>.unmodifiable(observations),
       expectedItems = List<AtlasShelfExpectedItem>.unmodifiable(expectedItems),
       proposedActions = List<AtlasShelfProposedAction>.unmodifiable(
         proposedActions,
       ),
       completionGaps = List<AtlasCompletionItem>.unmodifiable(completionGaps);

  final List<AtlasShelfObservation> observations;
  final List<AtlasShelfExpectedItem> expectedItems;
  final List<AtlasShelfProposedAction> proposedActions;

  /// Catalog/set releases not yet owned. These are completion gaps, not
  /// physical objects that Atlas expected to see on the shelf.
  final List<AtlasCompletionItem> completionGaps;

  /// Existing Vault identity intelligence. Shelf Intelligence does not create
  /// another duplicate classifier.
  final DuplicateReviewReport vaultIdentityReview;

  int get ownedObservationCount => observations
      .where((item) => item.state == AtlasShelfObservationState.owned)
      .length;

  int get notInVaultCount => observations
      .where((item) => item.state == AtlasShelfObservationState.notInVault)
      .length;

  int get possibleVariantCount => observations
      .where((item) => item.state == AtlasShelfObservationState.possibleVariant)
      .length;

  int get extraCopyCount => observations
      .where((item) => item.state == AtlasShelfObservationState.extraCopy)
      .length;

  int get needsReviewCount => observations
      .where((item) => item.state == AtlasShelfObservationState.needsReview)
      .length;

  int get missingFromShelfCount => expectedItems
      .where((item) => item.missingQuantity > 0)
      .fold<int>(0, (total, item) => total + item.missingQuantity);

  bool get hasProposedActions => proposedActions.isNotEmpty;
}
