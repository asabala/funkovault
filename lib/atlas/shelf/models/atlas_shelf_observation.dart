import '../../../models/pop.dart';
import '../../scan/tracking/atlas_scan_observation.dart';

enum AtlasShelfObservationState {
  owned,
  notInVault,
  possibleVariant,
  extraCopy,
  needsReview,
}

/// Persistent shelf-session representation of one observed physical object.
///
/// A shelf observation may outlive any individual Scanner 6A track. Track IDs
/// remain transient acquisition identifiers; [observationId] is the persistent
/// identity used only inside the shelf scan session.
final class AtlasShelfObservation {
  AtlasShelfObservation({
    required this.observationId,
    required this.firstSeenAt,
    required this.lastSeenAt,
    required Iterable<String> sourceTrackIds,
    this.activeTrackId,
    this.product,
    this.scannedBarcode = '',
    this.confidence = 0,
    this.resolutionRequiresReview = false,
    this.lastKnownBounds,
    this.state = AtlasShelfObservationState.needsReview,
    this.ownedQuantity = 0,
    this.observedCopyIndex = 0,
    this.reidentificationConfidence,
    Iterable<String> notes = const <String>[],
  }) : sourceTrackIds = Set<String>.unmodifiable(sourceTrackIds),
       notes = List<String>.unmodifiable(notes);

  final String observationId;
  final DateTime firstSeenAt;
  final DateTime lastSeenAt;
  final Set<String> sourceTrackIds;
  final String? activeTrackId;

  // Temporary resolved product projection. Never written to the Vault by 6B.
  final Pop? product;
  final String scannedBarcode;
  final double confidence;
  final bool resolutionRequiresReview;
  final AtlasNormalizedBounds? lastKnownBounds;

  final AtlasShelfObservationState state;
  final int ownedQuantity;

  /// One-based observed physical-copy index for the exact release.
  final int observedCopyIndex;

  /// Confidence that a later track was reassociated with this session object.
  /// Null means no cross-track reassociation was performed.
  final double? reidentificationConfidence;

  final List<String> notes;

  bool get isActive =>
      activeTrackId != null && activeTrackId!.trim().isNotEmpty;

  bool get requiresReview =>
      state == AtlasShelfObservationState.needsReview ||
      state == AtlasShelfObservationState.possibleVariant;

  String get collectibleIdentityKey =>
      product?.collectibleIdentityKey.trim() ?? '';

  AtlasShelfObservation copyWith({
    DateTime? lastSeenAt,
    Iterable<String>? sourceTrackIds,
    String? activeTrackId,
    bool clearActiveTrackId = false,
    Pop? product,
    bool clearProduct = false,
    String? scannedBarcode,
    double? confidence,
    bool? resolutionRequiresReview,
    AtlasNormalizedBounds? lastKnownBounds,
    AtlasShelfObservationState? state,
    int? ownedQuantity,
    int? observedCopyIndex,
    double? reidentificationConfidence,
    bool clearReidentificationConfidence = false,
    List<String>? notes,
  }) {
    return AtlasShelfObservation(
      observationId: observationId,
      firstSeenAt: firstSeenAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      sourceTrackIds: sourceTrackIds ?? this.sourceTrackIds,
      activeTrackId: clearActiveTrackId
          ? null
          : (activeTrackId ?? this.activeTrackId),
      product: clearProduct ? null : (product ?? this.product),
      scannedBarcode: scannedBarcode ?? this.scannedBarcode,
      confidence: confidence ?? this.confidence,
      resolutionRequiresReview:
          resolutionRequiresReview ?? this.resolutionRequiresReview,
      lastKnownBounds: lastKnownBounds ?? this.lastKnownBounds,
      state: state ?? this.state,
      ownedQuantity: ownedQuantity ?? this.ownedQuantity,
      observedCopyIndex: observedCopyIndex ?? this.observedCopyIndex,
      reidentificationConfidence: clearReidentificationConfidence
          ? null
          : (reidentificationConfidence ?? this.reidentificationConfidence),
      notes: notes ?? this.notes,
    );
  }
}
