import '../atlas/intelligence/identity/identity_review_service.dart';
import '../atlas/intelligence/models/identity_review_models.dart';
import '../models/pop.dart';

/// Compatibility service for the existing Vault duplicate-review workflow.
///
/// Atlas Identity Intelligence now performs the actual analysis. This service
/// converts the richer intelligence results into the older report structure
/// currently expected by Vault screens.
class DuplicateReviewService {
  const DuplicateReviewService({
    this.identityReviewService = const IdentityReviewService(),
  });

  final IdentityReviewService identityReviewService;

  DuplicateReviewReport buildReport(List<Pop> pops) {
    final identityResult = identityReviewService.analyze(pops);

    final sameIdentityGroups = identityResult.exactDuplicates
        .map(_convertGroup)
        .toList(growable: false);

    final possibleVariantGroups = identityResult.allGroups
        .where(
          (group) =>
      group.relationship != IdentityRelationship.exactDuplicate,
    )
        .map(_convertGroup)
        .toList(growable: false);

    return DuplicateReviewReport(
      sameIdentityGroups: sameIdentityGroups,
      possibleVariantGroups: possibleVariantGroups,
      identityResult: identityResult,
    );
  }

  DuplicateReviewGroup _convertGroup(
      IdentityReviewGroup group,
      ) {
    return DuplicateReviewGroup(
      key: group.key,
      pops: group.pops,
      relationship: group.relationship,
      title: group.title,
      explanation: group.explanation,
      confidence: group.confidence,
      evidence: group.evidence,
    );
  }
}

class DuplicateReviewReport {
  const DuplicateReviewReport({
    required this.sameIdentityGroups,
    required this.possibleVariantGroups,
    this.identityResult = const IdentityReviewResult(),
  });

  /// Records Atlas believes represent the same exact collectible release.
  final List<DuplicateReviewGroup> sameIdentityGroups;

  /// Related records with meaningful release differences or incomplete data.
  ///
  /// This keeps the existing property name so current Vault screens continue
  /// working while the UI is gradually upgraded to Identity Intelligence.
  final List<DuplicateReviewGroup> possibleVariantGroups;

  /// Complete Identity Intelligence result for newer Atlas features.
  final IdentityReviewResult identityResult;

  int get totalGroups {
    return sameIdentityGroups.length + possibleVariantGroups.length;
  }

  int get exactDuplicateGroupCount => sameIdentityGroups.length;

  int get reviewGroupCount => possibleVariantGroups.length;

  bool get hasGroups => totalGroups > 0;

  bool get hasExactDuplicates => sameIdentityGroups.isNotEmpty;

  bool get hasReviewGroups => possibleVariantGroups.isNotEmpty;
}

class DuplicateReviewGroup {
  const DuplicateReviewGroup({
    required this.key,
    required this.pops,
    this.relationship = IdentityRelationship.needsReview,
    this.title = 'Identity Review Needed',
    this.explanation = '',
    this.confidence = 0,
    this.evidence = const <String>[],
  });

  final String key;
  final List<Pop> pops;

  /// Richer classification supplied by Atlas Identity Intelligence.
  final IdentityRelationship relationship;

  final String title;
  final String explanation;

  /// Classification confidence from 0 to 100.
  final int confidence;

  /// Human-readable reasons supporting the classification.
  final List<String> evidence;

  Pop get firstPop => pops.first;

  int get itemCount => pops.length;

  int get totalQuantity {
    return pops.fold<int>(
      0,
          (total, pop) => total + pop.quantity,
    );
  }

  String get name {
    final value = firstPop.name.trim();
    return value.isEmpty ? 'Unnamed Pop' : value;
  }

  String get number {
    final value = firstPop.number.trim();
    return value.isEmpty ? 'No #' : '#$value';
  }

  bool get isExactDuplicate {
    return relationship == IdentityRelationship.exactDuplicate;
  }

  bool get requiresReview => !isExactDuplicate;
}