import '../contributions/contribution_collection.dart';
import '../contributions/product_resolution_contribution.dart';
import '../models/scan_session.dart';
import 'resolution_evidence.dart';

// Builds ResolutionEvidence from a ScanSession or ContributionCollection.
//
// Downstream intelligence engines should consume ResolutionEvidence rather
// than querying ContributionCollection directly.
abstract final class ResolutionEvidenceBuilder {
  static ResolutionEvidence fromSession(ScanSession session) {
    return fromContributions(session.contributions);
  }

  static ResolutionEvidence fromContributions(
    ContributionCollection contributions,
  ) {
    return ResolutionEvidence(
      contributions: contributions
          .ofType<ProductResolutionContribution>()
          .toList(growable: false),
    );
  }
}
