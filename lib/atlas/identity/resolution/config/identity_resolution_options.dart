// Defines optional behavior for an identity resolution run.
//
// These options control orchestration behavior only.
// Identity matching rules remain inside IdentityPolicy, while profile
// canonicalization remains inside CanonicalizationStrategy.
class IdentityResolutionOptions {
  const IdentityResolutionOptions({
    this.allowSingleCandidate = true,
    this.compareAllCandidates = true,
    this.recordUnmatchedCandidates = true,
    this.buildResolutionSession = true,
    this.includeComparisonNotes = true,
  });

  // Allows resolution to complete when only one candidate profile exists.
  final bool allowSingleCandidate;

  // Compares every candidate profile with every other candidate once.
  final bool compareAllCandidates;

  // Preserves candidates that do not match another candidate.
  final bool recordUnmatchedCandidates;

  // Records source records, mapper results, comparisons, and canonical
  // profiles in an IdentityResolutionSession.
  final bool buildResolutionSession;

  // Includes comparison and resolution notes in the final result.
  final bool includeComparisonNotes;

  static const IdentityResolutionOptions standard = IdentityResolutionOptions();

  IdentityResolutionOptions copyWith({
    bool? allowSingleCandidate,
    bool? compareAllCandidates,
    bool? recordUnmatchedCandidates,
    bool? buildResolutionSession,
    bool? includeComparisonNotes,
  }) {
    return IdentityResolutionOptions(
      allowSingleCandidate: allowSingleCandidate ?? this.allowSingleCandidate,
      compareAllCandidates: compareAllCandidates ?? this.compareAllCandidates,
      recordUnmatchedCandidates:
          recordUnmatchedCandidates ?? this.recordUnmatchedCandidates,
      buildResolutionSession:
          buildResolutionSession ?? this.buildResolutionSession,
      includeComparisonNotes:
          includeComparisonNotes ?? this.includeComparisonNotes,
    );
  }

  Map<String, Object> toMap() {
    return <String, Object>{
      'allowSingleCandidate': allowSingleCandidate,
      'compareAllCandidates': compareAllCandidates,
      'recordUnmatchedCandidates': recordUnmatchedCandidates,
      'buildResolutionSession': buildResolutionSession,
      'includeComparisonNotes': includeComparisonNotes,
    };
  }

  @override
  String toString() {
    return 'IdentityResolutionOptions('
        'allowSingleCandidate: $allowSingleCandidate, '
        'compareAllCandidates: $compareAllCandidates, '
        'recordUnmatchedCandidates: $recordUnmatchedCandidates, '
        'buildResolutionSession: $buildResolutionSession, '
        'includeComparisonNotes: $includeComparisonNotes'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is IdentityResolutionOptions &&
            runtimeType == other.runtimeType &&
            allowSingleCandidate == other.allowSingleCandidate &&
            compareAllCandidates == other.compareAllCandidates &&
            recordUnmatchedCandidates == other.recordUnmatchedCandidates &&
            buildResolutionSession == other.buildResolutionSession &&
            includeComparisonNotes == other.includeComparisonNotes;
  }

  @override
  int get hashCode {
    return Object.hash(
      allowSingleCandidate,
      compareAllCandidates,
      recordUnmatchedCandidates,
      buildResolutionSession,
      includeComparisonNotes,
    );
  }
}
