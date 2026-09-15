import '../evidence/identity_evidence.dart';

// Result produced by a single identity comparator.
//
// A comparator evaluates one portion of identity (for example,
// Core Anchors or Variant Modifiers) and returns its evidence.
// The Decision Engine combines multiple comparator results into
// one final identity decision.
class IdentityComparatorResult {
  const IdentityComparatorResult({
    required this.comparatorId,
    required this.comparatorName,
    required this.isMatch,
    required this.confidence,
    required this.evidence,
    this.notes = const <String>[],
  });

  // Stable identifier for the comparator.
  final String comparatorId;

  // Human-readable comparator name.
  final String comparatorName;

  // Whether this comparator considers its portion of identity a match.
  final bool isMatch;

  // Confidence of this comparator only.
  final double confidence;

  // Structured evidence produced by this comparator.
  final List<IdentityEvidence> evidence;

  // Optional comparator notes.
  final List<String> notes;

  bool get hasEvidence => evidence.isNotEmpty;

  bool get hasConflicts {
    return evidence.any((IdentityEvidence item) => item.isConflict);
  }

  bool get hasMissingEvidence {
    return evidence.any((IdentityEvidence item) => item.isMissing);
  }

  double get weightedConfidence {
    if (evidence.isEmpty) {
      return confidence;
    }

    final Iterable<IdentityEvidence> participating = evidence.where(
      (IdentityEvidence item) => item.participatesInDecision,
    );

    if (participating.isEmpty) {
      return confidence;
    }

    double totalWeight = 0;
    double totalScore = 0;

    for (final IdentityEvidence item in participating) {
      totalWeight += item.weight;
      totalScore += item.weightedConfidence;
    }

    if (totalWeight == 0) {
      return confidence;
    }

    return totalScore / totalWeight;
  }

  IdentityComparatorResult copyWith({
    String? comparatorId,
    String? comparatorName,
    bool? isMatch,
    double? confidence,
    List<IdentityEvidence>? evidence,
    List<String>? notes,
  }) {
    return IdentityComparatorResult(
      comparatorId: comparatorId ?? this.comparatorId,
      comparatorName: comparatorName ?? this.comparatorName,
      isMatch: isMatch ?? this.isMatch,
      confidence: confidence ?? this.confidence,
      evidence: evidence ?? this.evidence,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'IdentityComparatorResult('
        'comparator: $comparatorName, '
        'match: $isMatch, '
        'confidence: $confidence, '
        'evidence: ${evidence.length}'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is IdentityComparatorResult &&
            comparatorId == other.comparatorId &&
            comparatorName == other.comparatorName &&
            isMatch == other.isMatch &&
            confidence == other.confidence &&
            _listEquals(evidence, other.evidence) &&
            _listEquals(notes, other.notes);
  }

  @override
  int get hashCode {
    return Object.hash(
      comparatorId,
      comparatorName,
      isMatch,
      confidence,
      Object.hashAll(evidence),
      Object.hashAll(notes),
    );
  }

  static bool _listEquals<T>(List<T> first, List<T> second) {
    if (identical(first, second)) {
      return true;
    }

    if (first.length != second.length) {
      return false;
    }

    for (int i = 0; i < first.length; i++) {
      if (first[i] != second[i]) {
        return false;
      }
    }

    return true;
  }
}
