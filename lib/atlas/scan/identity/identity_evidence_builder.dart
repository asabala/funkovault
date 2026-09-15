import '../contributions/contribution_collection.dart';
import '../contributions/identity_contribution.dart';
import '../models/scan_session.dart';
import 'identity_evidence.dart';

// Builds IdentityEvidence from a ScanSession or ContributionCollection.
//
// This isolates contribution filtering from downstream product-resolution
// engines. Product-resolution consumes strongly typed identity evidence
// instead of querying ContributionCollection directly.
abstract final class IdentityEvidenceBuilder {
  static IdentityEvidence fromSession(ScanSession session) {
    return fromContributions(session.contributions);
  }

  static IdentityEvidence fromContributions(
    ContributionCollection contributions,
  ) {
    return IdentityEvidence(
      contributions: contributions.ofType<IdentityContribution>().toList(
        growable: false,
      ),
    );
  }
}
