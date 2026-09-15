import '../identity/identity_hypothesis.dart';
import 'abstract_intelligence_contribution.dart';
import 'contribution_category.dart';

// Identity intelligence produced from recognition evidence.
//
// The Identity Engine may produce one or more hypotheses. The first hypothesis
// is considered the current best candidate, while additional hypotheses are
// retained for review or future resolution.
final class IdentityContribution extends AbstractIntelligenceContribution {
  IdentityContribution({
    required super.contributionId,
    required super.sourceEngineId,
    required super.createdAt,
    required List<IdentityHypothesis> hypotheses,
    super.confidence,
    super.attributes,
  }) : hypotheses = List<IdentityHypothesis>.unmodifiable(hypotheses);

  // Candidate identities ordered from strongest to weakest.
  final List<IdentityHypothesis> hypotheses;

  bool get hasHypotheses {
    return hypotheses.isNotEmpty;
  }

  int get hypothesisCount {
    return hypotheses.length;
  }

  IdentityHypothesis? get primaryHypothesis {
    if (hypotheses.isEmpty) {
      return null;
    }

    return hypotheses.first;
  }

  bool get hasAlternatives {
    return hypotheses.length > 1;
  }

  Iterable<IdentityHypothesis> get alternativeHypotheses {
    if (hypotheses.length <= 1) {
      return const Iterable<IdentityHypothesis>.empty();
    }

    return hypotheses.skip(1);
  }

  bool get requiresReview {
    return hasAlternatives;
  }

  @override
  ContributionCategory get category {
    return ContributionCategory.identity;
  }

  @override
  String toString() {
    return 'IdentityContribution('
        'hypotheses: ${hypotheses.length}, '
        'primary: ${primaryHypothesis?.displayName}, '
        'confidence: $confidence'
        ')';
  }
}
