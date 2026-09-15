// Describes whether Atlas has identified the exact physical variant.
enum ScanVariantStatus {
  exactMatch,
  likelyMatch,
  multipleCandidates,
  visualConfirmationRequired,
  unknown,
}

// Immutable summary of variant resolution.
class ScanVariantResolution {
  const ScanVariantResolution({
    this.status = ScanVariantStatus.unknown,
    this.candidateProductIds = const [],
    this.confirmedTraits = const [],
    this.unconfirmedTraits = const [],
    this.confidence = 0.0,
  });

  final ScanVariantStatus status;

  final List<String> candidateProductIds;

  final List<String> confirmedTraits;

  final List<String> unconfirmedTraits;

  final double confidence;

  bool get isExact {
    return status == ScanVariantStatus.exactMatch;
  }

  bool get requiresConfirmation {
    return status == ScanVariantStatus.multipleCandidates ||
        status == ScanVariantStatus.visualConfirmationRequired;
  }

  bool get hasMultipleCandidates {
    return candidateProductIds.length > 1;
  }

  ScanVariantResolution copyWith({
    ScanVariantStatus? status,
    List<String>? candidateProductIds,
    List<String>? confirmedTraits,
    List<String>? unconfirmedTraits,
    double? confidence,
  }) {
    return ScanVariantResolution(
      status: status ?? this.status,
      candidateProductIds: candidateProductIds ?? this.candidateProductIds,
      confirmedTraits: confirmedTraits ?? this.confirmedTraits,
      unconfirmedTraits: unconfirmedTraits ?? this.unconfirmedTraits,
      confidence: confidence ?? this.confidence,
    );
  }
}
