import '../../../models/pop.dart';

enum AtlasShelfExpectedItemState {
  observed,
  partiallyObserved,
  missingFromShelf,
}

/// Reconciliation of Vault-owned quantity against physical copies observed in
/// the current shelf session.
final class AtlasShelfExpectedItem {
  const AtlasShelfExpectedItem({
    required this.pop,
    required this.expectedQuantity,
    required this.observedQuantity,
    required this.state,
  });

  final Pop pop;
  final int expectedQuantity;
  final int observedQuantity;
  final AtlasShelfExpectedItemState state;

  int get missingQuantity =>
      (expectedQuantity - observedQuantity).clamp(0, expectedQuantity).toInt();

  bool get isMissing => state == AtlasShelfExpectedItemState.missingFromShelf;

  bool get isPartiallyObserved =>
      state == AtlasShelfExpectedItemState.partiallyObserved;
}
