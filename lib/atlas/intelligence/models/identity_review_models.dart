import '../../../models/pop.dart';

enum IdentityRelationship {
  exactDuplicate,
  possibleVariant,
  stickerDifference,
  finishDifference,
  packagingDifference,
  productionDifference,
  signatureDifference,
  authenticationDifference,
  retailerDifference,
  eventDifference,
  needsReview,
}

class IdentityReviewGroup {
  const IdentityReviewGroup({
    required this.key,
    required this.relationship,
    required this.pops,
    required this.title,
    required this.explanation,
    this.confidence = 0,
    this.evidence = const <String>[],
  });

  final String key;
  final IdentityRelationship relationship;
  final List<Pop> pops;
  final String title;
  final String explanation;

  /// Confidence from 0 to 100.
  final int confidence;

  /// Human-readable reasons supporting this classification.
  final List<String> evidence;

  Pop get firstPop => pops.first;

  int get itemCount => pops.length;

  int get totalQuantity {
    return pops.fold<int>(0, (total, pop) => total + pop.quantity);
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

  bool get requiresReview {
    return relationship != IdentityRelationship.exactDuplicate;
  }
}

class IdentityReviewResult {
  const IdentityReviewResult({
    this.exactDuplicates = const <IdentityReviewGroup>[],
    this.possibleVariants = const <IdentityReviewGroup>[],
    this.stickerDifferences = const <IdentityReviewGroup>[],
    this.finishDifferences = const <IdentityReviewGroup>[],
    this.packagingDifferences = const <IdentityReviewGroup>[],
    this.productionDifferences = const <IdentityReviewGroup>[],
    this.signatureDifferences = const <IdentityReviewGroup>[],
    this.authenticationDifferences = const <IdentityReviewGroup>[],
    this.retailerDifferences = const <IdentityReviewGroup>[],
    this.eventDifferences = const <IdentityReviewGroup>[],
    this.needsReview = const <IdentityReviewGroup>[],
  });

  final List<IdentityReviewGroup> exactDuplicates;
  final List<IdentityReviewGroup> possibleVariants;
  final List<IdentityReviewGroup> stickerDifferences;
  final List<IdentityReviewGroup> finishDifferences;
  final List<IdentityReviewGroup> packagingDifferences;
  final List<IdentityReviewGroup> productionDifferences;
  final List<IdentityReviewGroup> signatureDifferences;
  final List<IdentityReviewGroup> authenticationDifferences;
  final List<IdentityReviewGroup> retailerDifferences;
  final List<IdentityReviewGroup> eventDifferences;
  final List<IdentityReviewGroup> needsReview;

  int get exactDuplicateGroupCount => exactDuplicates.length;

  int get reviewGroupCount {
    return possibleVariants.length +
        stickerDifferences.length +
        finishDifferences.length +
        packagingDifferences.length +
        productionDifferences.length +
        signatureDifferences.length +
        authenticationDifferences.length +
        retailerDifferences.length +
        eventDifferences.length +
        needsReview.length;
  }

  int get totalGroupCount {
    return exactDuplicateGroupCount + reviewGroupCount;
  }

  bool get hasResults => totalGroupCount > 0;

  List<IdentityReviewGroup> get allGroups {
    return <IdentityReviewGroup>[
      ...exactDuplicates,
      ...possibleVariants,
      ...stickerDifferences,
      ...finishDifferences,
      ...packagingDifferences,
      ...productionDifferences,
      ...signatureDifferences,
      ...authenticationDifferences,
      ...retailerDifferences,
      ...eventDifferences,
      ...needsReview,
    ];
  }
}
