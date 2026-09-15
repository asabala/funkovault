import '../../../models/pop.dart';
import '../../collectibility/models/atlas_collectibility_summary.dart';
import '../models/atlas_recommendation.dart';
import '../models/atlas_recommendation_priority.dart';
import '../models/atlas_recommendation_summary.dart';
import '../models/atlas_recommendation_type.dart';

/// Produces trusted, actionable next steps for one collectible.
///
/// The engine does not perform navigation or modify collectible data.
/// It only explains what Atlas recommends and why.
class AtlasRecommendationEngine {
  const AtlasRecommendationEngine();

  AtlasRecommendationSummary build({
    required Pop pop,
    required AtlasCollectibilitySummary collectibilitySummary,
  }) {
    final recommendations = <AtlasRecommendation>[];
    final addedIds = <String>{};

    void addRecommendation(AtlasRecommendation recommendation) {
      if (addedIds.add(recommendation.id)) {
        recommendations.add(recommendation);
      }
    }

    _addValueRecommendation(pop: pop, addRecommendation: addRecommendation);

    if (pop.imageUrl.trim().isEmpty) {
      addRecommendation(
        const AtlasRecommendation(
          id: 'add-image',
          type: AtlasRecommendationType.addImage,
          priority: AtlasRecommendationPriority.medium,
          title: 'Add a collectible image',
          description: 'Photograph or add an image of this collectible.',
          reason:
              'An image improves identification, presentation, and future comparison workflows.',
          actionLabel: 'Add Image',
        ),
      );
    }

    if (pop.releaseDate.trim().isEmpty) {
      addRecommendation(
        const AtlasRecommendation(
          id: 'add-release-date',
          type: AtlasRecommendationType.addReleaseDate,
          priority: AtlasRecommendationPriority.low,
          title: 'Add the release date',
          description: 'Record when this collectible was originally released.',
          reason:
              'Release dates improve historical context and future age-based intelligence.',
          actionLabel: 'Add Release Date',
        ),
      );
    }

    if (!_hasCatalogIdentity(pop)) {
      addRecommendation(
        const AtlasRecommendation(
          id: 'add-catalog-identity',
          type: AtlasRecommendationType.addCatalogIdentity,
          priority: AtlasRecommendationPriority.high,
          title: 'Add catalog identification',
          description: 'Add a UPC, source catalog ID, or collectible ID.',
          reason:
              'Catalog identifiers strengthen duplicate review, release matching, and import accuracy.',
          actionLabel: 'Add Catalog Details',
        ),
      );
    }

    if (pop.itemCondition.trim().isEmpty) {
      addRecommendation(
        const AtlasRecommendation(
          id: 'add-item-condition',
          type: AtlasRecommendationType.addItemCondition,
          priority: AtlasRecommendationPriority.medium,
          title: 'Record item condition',
          description: 'Document the physical condition of the collectible.',
          reason:
              'Condition is important for value, display, sale, and insurance analysis.',
          actionLabel: 'Add Item Condition',
        ),
      );
    }

    if (pop.boxCondition.trim().isEmpty) {
      addRecommendation(
        const AtlasRecommendation(
          id: 'add-box-condition',
          type: AtlasRecommendationType.addBoxCondition,
          priority: AtlasRecommendationPriority.medium,
          title: 'Record box condition',
          description: 'Document the current condition of the packaging.',
          reason:
              'Box condition can materially affect collector interest and estimated value.',
          actionLabel: 'Add Box Condition',
        ),
      );
    }

    if (_hasMeaningfulSignature(pop.signature) &&
        !_hasAuthenticationDetails(pop)) {
      addRecommendation(
        const AtlasRecommendation(
          id: 'authenticate-signature',
          type: AtlasRecommendationType.authenticateSignature,
          priority: AtlasRecommendationPriority.high,
          title: 'Add autograph authentication',
          description:
              'Record the authentication provider or certificate number.',
          reason:
              'Authentication documentation strengthens confidence in a signed collectible.',
          actionLabel: 'Add Authentication',
        ),
      );
    }

    if (collectibilitySummary.shouldReviewForInsurance) {
      addRecommendation(
        AtlasRecommendation(
          id: 'review-for-insurance',
          type: AtlasRecommendationType.reviewForInsurance,
          priority: pop.value >= 500
              ? AtlasRecommendationPriority.high
              : AtlasRecommendationPriority.medium,
          title: 'Review insurance documentation',
          description:
              'Consider whether this collectible should be included in your insured collection records.',
          reason:
              'Its value, score, or documented collector traits make it worth reviewing.',
          actionLabel: 'Review Documentation',
        ),
      );
    }

    if (collectibilitySummary.isDisplayPiece) {
      addRecommendation(
        const AtlasRecommendation(
          id: 'display-collectible',
          type: AtlasRecommendationType.displayCollectible,
          priority: AtlasRecommendationPriority.low,
          title: 'Consider this as a display piece',
          description:
              'This collectible has visual or collector traits that may make it suitable for display.',
          reason:
              'Atlas detected a strong score or visually distinctive release identity.',
          actionLabel: 'Review Display Details',
        ),
      );
    }

    if (!collectibilitySummary.isMarketReady) {
      addRecommendation(
        AtlasRecommendation(
          id: 'improve-market-readiness',
          type: AtlasRecommendationType.improveMarketReadiness,
          priority: collectibilitySummary.marketReadiness == 'Needs Details'
              ? AtlasRecommendationPriority.high
              : AtlasRecommendationPriority.medium,
          title: 'Improve market readiness',
          description:
              'Complete the missing value, image, identity, and condition information.',
          reason:
              'Complete records make future sale, comparison, valuation, and insurance workflows more reliable.',
          actionLabel: 'Complete Record',
        ),
      );
    }

    if (_shouldPreserveDocumentation(
      pop: pop,
      collectibilitySummary: collectibilitySummary,
    )) {
      addRecommendation(
        const AtlasRecommendation(
          id: 'preserve-documentation',
          type: AtlasRecommendationType.preserveDocumentation,
          priority: AtlasRecommendationPriority.medium,
          title: 'Preserve supporting documentation',
          description:
              'Keep certificates, receipts, grading records, and related provenance together.',
          reason:
              'Documented provenance strengthens future authentication, insurance, and sale records.',
          actionLabel: 'Review Documentation',
        ),
      );
    }

    recommendations.sort(_compareRecommendations);

    return AtlasRecommendationSummary(
      recommendations: List<AtlasRecommendation>.unmodifiable(recommendations),
    );
  }

  void _addValueRecommendation({
    required Pop pop,
    required void Function(AtlasRecommendation recommendation)
    addRecommendation,
  }) {
    if (pop.value <= 0) {
      addRecommendation(
        const AtlasRecommendation(
          id: 'add-current-value',
          type: AtlasRecommendationType.addCurrentValue,
          priority: AtlasRecommendationPriority.high,
          title: 'Add a current estimated value',
          description:
              'Record the latest estimated value for this collectible.',
          reason:
              'Value is required for collection totals, insurance review, trends, and market analysis.',
          actionLabel: 'Add Current Value',
        ),
      );

      return;
    }

    if (_isValuePossiblyStale(pop)) {
      addRecommendation(
        const AtlasRecommendation(
          id: 'update-current-value',
          type: AtlasRecommendationType.updateCurrentValue,
          priority: AtlasRecommendationPriority.medium,
          title: 'Review the current value',
          description:
              'Confirm that the saved estimated value is still current.',
          reason:
              'The recorded value may be outdated based on the last update date.',
          actionLabel: 'Update Current Value',
        ),
      );
    }
  }

  bool _isValuePossiblyStale(Pop pop) {
    final parsedDate = DateTime.tryParse(pop.lastUpdated.trim());

    if (parsedDate == null) {
      return true;
    }

    return DateTime.now().difference(parsedDate).inDays >= 180;
  }

  bool _hasCatalogIdentity(Pop pop) {
    return pop.sourceCatalogId.trim().isNotEmpty ||
        pop.sourceCollectibleId.trim().isNotEmpty ||
        pop.sourceUpc.trim().isNotEmpty;
  }

  bool _hasAuthenticationDetails(Pop pop) {
    return _hasMeaningfulValue(pop.authenticationProvider) ||
        _hasMeaningfulValue(pop.authenticityNumber);
  }

  bool _shouldPreserveDocumentation({
    required Pop pop,
    required AtlasCollectibilitySummary collectibilitySummary,
  }) {
    return _hasAuthenticationDetails(pop) ||
        _hasMeaningfulValue(pop.gradingCompany) ||
        _hasMeaningfulSignature(pop.signature) ||
        collectibilitySummary.shouldReviewForInsurance;
  }

  bool _hasMeaningfulSignature(String value) {
    final cleaned = value.trim().toLowerCase();

    return cleaned.isNotEmpty &&
        cleaned != 'none' &&
        cleaned != 'no' &&
        cleaned != 'na' &&
        cleaned != 'n/a' &&
        cleaned != 'unsigned';
  }

  bool _hasMeaningfulValue(String value) {
    final cleaned = value.trim().toLowerCase();

    return cleaned.isNotEmpty &&
        cleaned != 'none' &&
        cleaned != 'no' &&
        cleaned != 'na' &&
        cleaned != 'n/a' &&
        cleaned != 'common' &&
        cleaned != 'standard' &&
        cleaned != 'unsigned';
  }

  int _compareRecommendations(
    AtlasRecommendation first,
    AtlasRecommendation second,
  ) {
    final priorityComparison = second.priority.weight.compareTo(
      first.priority.weight,
    );

    if (priorityComparison != 0) {
      return priorityComparison;
    }

    return first.title.compareTo(second.title);
  }
}
