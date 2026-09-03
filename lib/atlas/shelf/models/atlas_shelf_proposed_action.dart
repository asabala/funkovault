enum AtlasShelfProposedActionType {
  addToVault,
  addAnotherCopy,
  reviewVariant,
  reviewObservation,
}

/// A staged collector action proposed by Shelf Intelligence.
///
/// This is intentionally data-only. 6B has no action executor and therefore
/// cannot mutate AppState or the Vault by itself.
final class AtlasShelfProposedAction {
  const AtlasShelfProposedAction({
    required this.actionId,
    required this.type,
    required this.observationId,
    required this.title,
    required this.explanation,
  });

  final String actionId;
  final AtlasShelfProposedActionType type;
  final String observationId;
  final String title;
  final String explanation;

  bool get requiresExplicitConfirmation => true;
}
