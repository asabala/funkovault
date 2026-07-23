// Describes the outcome of evaluating one piece of identity evidence.
enum IdentityEvidenceOutcome {
  matched,
  conflicted,
  missingLeft,
  missingRight,
  missingBoth,
  ignored,
  uncertain,
}

extension IdentityEvidenceOutcomeX on IdentityEvidenceOutcome {
  // Whether this evidence supports the identities matching.
  bool get supportsMatch {
    return this == IdentityEvidenceOutcome.matched;
  }

  // Whether this evidence directly contradicts a match.
  bool get isConflict {
    return this == IdentityEvidenceOutcome.conflicted;
  }

  // Whether comparison data was unavailable.
  bool get isMissing {
    return this == IdentityEvidenceOutcome.missingLeft ||
        this == IdentityEvidenceOutcome.missingRight ||
        this == IdentityEvidenceOutcome.missingBoth;
  }

  // Whether this evidence should affect the final decision.
  bool get participatesInDecision {
    return this != IdentityEvidenceOutcome.ignored;
  }

  // Whether the evidence requires additional review.
  bool get requiresReview {
    return isConflict ||
        isMissing ||
        this == IdentityEvidenceOutcome.uncertain;
  }

  String get serializedValue {
    return switch (this) {
      IdentityEvidenceOutcome.matched => 'matched',
      IdentityEvidenceOutcome.conflicted => 'conflicted',
      IdentityEvidenceOutcome.missingLeft => 'missing_left',
      IdentityEvidenceOutcome.missingRight => 'missing_right',
      IdentityEvidenceOutcome.missingBoth => 'missing_both',
      IdentityEvidenceOutcome.ignored => 'ignored',
      IdentityEvidenceOutcome.uncertain => 'uncertain',
    };
  }

  static IdentityEvidenceOutcome fromSerializedValue(
      String value,
      ) {
    return switch (value.trim().toLowerCase()) {
      'matched' => IdentityEvidenceOutcome.matched,
      'conflicted' => IdentityEvidenceOutcome.conflicted,
      'missing_left' => IdentityEvidenceOutcome.missingLeft,
      'missing_right' => IdentityEvidenceOutcome.missingRight,
      'missing_both' => IdentityEvidenceOutcome.missingBoth,
      'ignored' => IdentityEvidenceOutcome.ignored,
      'uncertain' => IdentityEvidenceOutcome.uncertain,
      _ => IdentityEvidenceOutcome.uncertain,
    };
  }
}