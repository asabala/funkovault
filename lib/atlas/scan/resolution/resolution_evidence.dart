import '../contributions/product_resolution_contribution.dart';
import 'product_resolution.dart';

// Immutable canonical product evidence produced during one Atlas scan.
//
// Downstream engines such as Market Intelligence, Vault Intelligence,
// Authenticity, and Atlas Briefing consume this typed view instead of
// querying ContributionCollection directly.
final class ResolutionEvidence {
  ResolutionEvidence({
    List<ProductResolutionContribution> contributions =
        const <ProductResolutionContribution>[],
  }) : contributions = List<ProductResolutionContribution>.unmodifiable(
         contributions,
       );

  final List<ProductResolutionContribution> contributions;

  bool get hasResolution {
    return contributions.isNotEmpty;
  }

  bool get hasNoResolution {
    return contributions.isEmpty;
  }

  int get contributionCount {
    return contributions.length;
  }

  ProductResolutionContribution? get primaryContribution {
    if (contributions.isEmpty) {
      return null;
    }

    return contributions.first;
  }

  ProductResolution? get primaryResolution {
    return primaryContribution?.resolution;
  }

  bool get requiresReview {
    return primaryResolution?.requiresReview ?? false;
  }

  double? get confidence {
    return primaryResolution?.matchConfidence;
  }

  bool get isHighConfidence {
    return primaryResolution?.isHighConfidence ?? false;
  }

  bool get isMediumConfidence {
    return primaryResolution?.isMediumConfidence ?? false;
  }

  bool get isLowConfidence {
    return primaryResolution?.isLowConfidence ?? false;
  }

  @override
  String toString() {
    return 'ResolutionEvidence('
        'contributions: $contributionCount, '
        'resolved: $hasResolution, '
        'confidence: $confidence'
        ')';
  }
}
