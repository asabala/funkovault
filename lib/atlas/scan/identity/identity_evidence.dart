import '../contributions/identity_contribution.dart';
import 'identity_hypothesis.dart';

// Immutable identity evidence produced during one Atlas scan.
//
// Product-resolution engines consume this typed view instead of filtering the
// ContributionCollection or depending directly on individual identity engines.
final class IdentityEvidence {
  IdentityEvidence({
    List<IdentityContribution> contributions =
    const <IdentityContribution>[],
  }) : contributions =
  List<IdentityContribution>.unmodifiable(
    contributions,
  );

  // Identity contributions ordered by their appearance in the scan session.
  final List<IdentityContribution> contributions;

  bool get hasIdentity {
    return contributions.isNotEmpty;
  }

  bool get hasNoIdentity {
    return contributions.isEmpty;
  }

  int get contributionCount {
    return contributions.length;
  }

  Iterable<IdentityHypothesis> get hypotheses {
    return contributions.expand(
          (IdentityContribution contribution) {
        return contribution.hypotheses;
      },
    );
  }

  int get hypothesisCount {
    return hypotheses.length;
  }

  bool get hasHypotheses {
    return hypotheses.isNotEmpty;
  }

  bool get hasAlternatives {
    return hypothesisCount > 1;
  }

  IdentityContribution? get primaryContribution {
    if (contributions.isEmpty) {
      return null;
    }

    return contributions.first;
  }

  IdentityHypothesis? get primaryHypothesis {
    for (final IdentityContribution contribution
    in contributions) {
      final IdentityHypothesis? hypothesis =
          contribution.primaryHypothesis;

      if (hypothesis != null) {
        return hypothesis;
      }
    }

    return null;
  }

  Iterable<IdentityHypothesis> get alternativeHypotheses {
    final IdentityHypothesis? primary =
        primaryHypothesis;

    if (primary == null) {
      return const Iterable<IdentityHypothesis>.empty();
    }

    bool primarySkipped = false;

    return hypotheses.where(
          (IdentityHypothesis hypothesis) {
        if (!primarySkipped &&
            identical(hypothesis, primary)) {
          primarySkipped = true;
          return false;
        }

        return true;
      },
    );
  }

  bool get requiresReview {
    if (hasAlternatives) {
      return true;
    }

    for (final IdentityContribution contribution
    in contributions) {
      if (contribution.requiresReview) {
        return true;
      }
    }

    return false;
  }

  double? get primaryConfidence {
    return primaryHypothesis?.confidence ??
        primaryContribution?.confidence;
  }

  Iterable<String> get supportingContributionIds {
    return hypotheses.expand(
          (IdentityHypothesis hypothesis) {
        return hypothesis.supportingContributionIds;
      },
    );
  }

  bool containsHypothesis(
      String hypothesisId,
      ) {
    final String normalizedId =
    hypothesisId.trim();

    if (normalizedId.isEmpty) {
      return false;
    }

    return hypotheses.any(
          (IdentityHypothesis hypothesis) {
        return hypothesis.hypothesisId ==
            normalizedId;
      },
    );
  }

  IdentityHypothesis? hypothesisById(
      String hypothesisId,
      ) {
    final String normalizedId =
    hypothesisId.trim();

    if (normalizedId.isEmpty) {
      return null;
    }

    for (final IdentityHypothesis hypothesis
    in hypotheses) {
      if (hypothesis.hypothesisId ==
          normalizedId) {
        return hypothesis;
      }
    }

    return null;
  }

  @override
  String toString() {
    return 'IdentityEvidence('
        'contributions: $contributionCount, '
        'hypotheses: $hypothesisCount, '
        'requiresReview: $requiresReview, '
        'primary: ${primaryHypothesis?.displayName}'
        ')';
  }
}