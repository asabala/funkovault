import '../../../models/pop.dart';
import '../../../vault/duplicate_review/duplicate_review_engine.dart';
import '../models/identity_review_models.dart';

class IdentityReviewService {
  const IdentityReviewService({
    this.duplicateReviewEngine = const DuplicateReviewEngine(),
  });

  final DuplicateReviewEngine duplicateReviewEngine;

  /// Analyzes the entire collection and separates exact duplicates from
  /// related releases that may differ by variant, sticker, packaging,
  /// production run, signature, or other physical identity metadata.
  IdentityReviewResult analyze(List<Pop> pops) {
    if (pops.length < 2) {
      return const IdentityReviewResult();
    }

    final exactDuplicates = _buildExactDuplicateGroups(pops);
    final relatedGroups = _buildRelatedReviewGroups(pops);

    return IdentityReviewResult(
      exactDuplicates: exactDuplicates,
      possibleVariants: _groupsFor(
        relatedGroups,
        IdentityRelationship.possibleVariant,
      ),
      stickerDifferences: _groupsFor(
        relatedGroups,
        IdentityRelationship.stickerDifference,
      ),
      finishDifferences: _groupsFor(
        relatedGroups,
        IdentityRelationship.finishDifference,
      ),
      packagingDifferences: _groupsFor(
        relatedGroups,
        IdentityRelationship.packagingDifference,
      ),
      productionDifferences: _groupsFor(
        relatedGroups,
        IdentityRelationship.productionDifference,
      ),
      signatureDifferences: _groupsFor(
        relatedGroups,
        IdentityRelationship.signatureDifference,
      ),
      authenticationDifferences: _groupsFor(
        relatedGroups,
        IdentityRelationship.authenticationDifference,
      ),
      retailerDifferences: _groupsFor(
        relatedGroups,
        IdentityRelationship.retailerDifference,
      ),
      eventDifferences: _groupsFor(
        relatedGroups,
        IdentityRelationship.eventDifference,
      ),
      needsReview: _groupsFor(relatedGroups, IdentityRelationship.needsReview),
    );
  }

  List<IdentityReviewGroup> _buildExactDuplicateGroups(List<Pop> pops) {
    final groups = duplicateReviewEngine.buildGroups(pops);

    return groups
        .map(
          (group) => IdentityReviewGroup(
            key: group.key,
            relationship: IdentityRelationship.exactDuplicate,
            pops: group.pops,
            title: 'Exact Duplicate',
            explanation:
                'These records share the same Atlas release fingerprint.',
            confidence: 100,
            evidence: const <String>[
              'Release identity matches',
              'Variant identity matches',
              'Packaging identity matches',
            ],
          ),
        )
        .toList(growable: false);
  }

  List<IdentityReviewGroup> _buildRelatedReviewGroups(List<Pop> pops) {
    final popsBySimilarityKey = <String, List<Pop>>{};

    for (final pop in pops) {
      final key = pop.similarityReviewKey;

      if (key.isEmpty) {
        continue;
      }

      popsBySimilarityKey.putIfAbsent(key, () => <Pop>[]);

      popsBySimilarityKey[key]!.add(pop);
    }

    final groups = <IdentityReviewGroup>[];

    for (final entry in popsBySimilarityKey.entries) {
      final relatedPops = entry.value;

      if (relatedPops.length < 2) {
        continue;
      }

      // If every record has the same exact release fingerprint, the existing
      // DuplicateReviewEngine already reports it as an exact duplicate.
      final exactKeys = relatedPops
          .map((pop) => pop.collectibleIdentityKey)
          .where((key) => key.isNotEmpty)
          .toSet();

      if (exactKeys.length <= 1) {
        continue;
      }

      groups.add(_classifyRelatedGroup(key: entry.key, pops: relatedPops));
    }

    return List<IdentityReviewGroup>.unmodifiable(groups);
  }

  IdentityReviewGroup _classifyRelatedGroup({
    required String key,
    required List<Pop> pops,
  }) {
    final evidence = <String>[];

    final hasVariantDifference = _hasDifference(
      pops,
      (pop) => <String>[pop.edition, pop.variant, pop.limitedEdition].join('|'),
    );

    final hasStickerDifference = _hasDifference(pops, (pop) => pop.stickerType);

    final hasEventDifference = _hasDifference(pops, (pop) => pop.eventSticker);

    final hasFinishDifference = _hasDifference(pops, (pop) => pop.finish);

    final hasRetailerDifference = _hasDifference(
      pops,
      (pop) => pop.retailExclusive,
    );

    final hasPackagingDifference = _hasDifference(
      pops,
      (pop) => <String>[
        pop.size,
        pop.packagingType,
        pop.boxVersion,
        pop.copyrightYear,
      ].join('|'),
    );

    final hasProductionDifference = _hasDifference(
      pops,
      (pop) => <String>[pop.productionCode, pop.releaseDate].join('|'),
    );

    final hasSignatureDifference = _hasDifference(pops, (pop) => pop.signature);

    final hasAuthenticationDifference = _hasDifference(
      pops,
      (pop) => <String>[
        pop.authenticationProvider,
        pop.gradingCompany,
        pop.authenticityNumber,
      ].join('|'),
    );

    if (hasVariantDifference) {
      evidence.add('Variant or edition details differ');
    }

    if (hasStickerDifference) {
      evidence.add('Sticker type differs');
    }

    if (hasEventDifference) {
      evidence.add('Convention or event sticker differs');
    }

    if (hasFinishDifference) {
      evidence.add('Physical finish differs');
    }

    if (hasRetailerDifference) {
      evidence.add('Retail exclusive differs');
    }

    if (hasPackagingDifference) {
      evidence.add('Size, packaging, or box version differs');
    }

    if (hasProductionDifference) {
      evidence.add('Production or release information differs');
    }

    if (hasSignatureDifference) {
      evidence.add('Signature status differs');
    }

    if (hasAuthenticationDifference) {
      evidence.add('Authentication information differs');
    }

    final relationship = _primaryRelationship(
      hasVariantDifference: hasVariantDifference,
      hasStickerDifference: hasStickerDifference,
      hasEventDifference: hasEventDifference,
      hasFinishDifference: hasFinishDifference,
      hasRetailerDifference: hasRetailerDifference,
      hasPackagingDifference: hasPackagingDifference,
      hasProductionDifference: hasProductionDifference,
      hasSignatureDifference: hasSignatureDifference,
      hasAuthenticationDifference: hasAuthenticationDifference,
    );

    return IdentityReviewGroup(
      key: key,
      relationship: relationship,
      pops: List<Pop>.unmodifiable(pops),
      title: _titleFor(relationship),
      explanation: _explanationFor(relationship),
      confidence: _confidenceFor(relationship),
      evidence: List<String>.unmodifiable(
        evidence.isEmpty
            ? const <String>[
                'The records share a broad identity but require review',
              ]
            : evidence,
      ),
    );
  }

  IdentityRelationship _primaryRelationship({
    required bool hasVariantDifference,
    required bool hasStickerDifference,
    required bool hasEventDifference,
    required bool hasFinishDifference,
    required bool hasRetailerDifference,
    required bool hasPackagingDifference,
    required bool hasProductionDifference,
    required bool hasSignatureDifference,
    required bool hasAuthenticationDifference,
  }) {
    // Authentication is checked before signature because it represents a
    // stronger physical-collectible distinction.
    if (hasAuthenticationDifference) {
      return IdentityRelationship.authenticationDifference;
    }

    if (hasSignatureDifference) {
      return IdentityRelationship.signatureDifference;
    }

    if (hasEventDifference) {
      return IdentityRelationship.eventDifference;
    }

    if (hasStickerDifference) {
      return IdentityRelationship.stickerDifference;
    }

    if (hasRetailerDifference) {
      return IdentityRelationship.retailerDifference;
    }

    if (hasFinishDifference) {
      return IdentityRelationship.finishDifference;
    }

    if (hasPackagingDifference) {
      return IdentityRelationship.packagingDifference;
    }

    if (hasProductionDifference) {
      return IdentityRelationship.productionDifference;
    }

    if (hasVariantDifference) {
      return IdentityRelationship.possibleVariant;
    }

    return IdentityRelationship.needsReview;
  }

  bool _hasDifference(List<Pop> pops, String Function(Pop pop) selector) {
    final values = pops
        .map(selector)
        .map(Pop.normalizeIdentityText)
        .where((value) => value.isNotEmpty)
        .toSet();

    return values.length > 1;
  }

  List<IdentityReviewGroup> _groupsFor(
    List<IdentityReviewGroup> groups,
    IdentityRelationship relationship,
  ) {
    return groups
        .where((group) => group.relationship == relationship)
        .toList(growable: false);
  }

  String _titleFor(IdentityRelationship relationship) {
    switch (relationship) {
      case IdentityRelationship.exactDuplicate:
        return 'Exact Duplicate';
      case IdentityRelationship.possibleVariant:
        return 'Possible Variant';
      case IdentityRelationship.stickerDifference:
        return 'Sticker Difference';
      case IdentityRelationship.finishDifference:
        return 'Finish Difference';
      case IdentityRelationship.packagingDifference:
        return 'Packaging Difference';
      case IdentityRelationship.productionDifference:
        return 'Production Run Difference';
      case IdentityRelationship.signatureDifference:
        return 'Signature Difference';
      case IdentityRelationship.authenticationDifference:
        return 'Authentication Difference';
      case IdentityRelationship.retailerDifference:
        return 'Retailer Difference';
      case IdentityRelationship.eventDifference:
        return 'Event Sticker Difference';
      case IdentityRelationship.needsReview:
        return 'Identity Review Needed';
    }
  }

  String _explanationFor(IdentityRelationship relationship) {
    switch (relationship) {
      case IdentityRelationship.exactDuplicate:
        return 'These records appear to represent the same exact release.';

      case IdentityRelationship.possibleVariant:
        return 'These collectibles share a broad identity, but their variant '
            'or edition details differ.';

      case IdentityRelationship.stickerDifference:
        return 'These collectibles appear related, but their sticker details '
            'do not match.';

      case IdentityRelationship.finishDifference:
        return 'These collectibles appear related, but their physical finishes '
            'do not match.';

      case IdentityRelationship.packagingDifference:
        return 'These collectibles appear related, but their size, packaging, '
            'or box-version details differ.';

      case IdentityRelationship.productionDifference:
        return 'These collectibles may represent different production runs '
            'or re-releases.';

      case IdentityRelationship.signatureDifference:
        return 'These collectibles differ by signature status.';

      case IdentityRelationship.authenticationDifference:
        return 'These collectibles differ by grading or authentication '
            'information.';

      case IdentityRelationship.retailerDifference:
        return 'These collectibles differ by retailer-exclusive identity.';

      case IdentityRelationship.eventDifference:
        return 'These collectibles differ by convention or event sticker.';

      case IdentityRelationship.needsReview:
        return 'Atlas found a broad identity match but not enough structured '
            'information to classify the difference safely.';
    }
  }

  int _confidenceFor(IdentityRelationship relationship) {
    switch (relationship) {
      case IdentityRelationship.exactDuplicate:
        return 100;
      case IdentityRelationship.authenticationDifference:
        return 96;
      case IdentityRelationship.signatureDifference:
        return 95;
      case IdentityRelationship.eventDifference:
        return 94;
      case IdentityRelationship.stickerDifference:
        return 93;
      case IdentityRelationship.retailerDifference:
        return 92;
      case IdentityRelationship.finishDifference:
        return 92;
      case IdentityRelationship.packagingDifference:
        return 90;
      case IdentityRelationship.productionDifference:
        return 88;
      case IdentityRelationship.possibleVariant:
        return 85;
      case IdentityRelationship.needsReview:
        return 65;
    }
  }
}
