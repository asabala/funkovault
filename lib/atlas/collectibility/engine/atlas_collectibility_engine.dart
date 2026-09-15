import '../../../models/pop.dart';
import '../../hero/models/atlas_hero_summary.dart';
import '../../identity/pop/pop_identity_rule.dart';
import '../models/atlas_collectibility_signal.dart';
import '../models/atlas_collectibility_summary.dart';

/// Builds a unified collectibility analysis for one collectible.
///
/// Version 1 deliberately reuses the trusted Hero score instead of
/// recreating or competing with the existing Hero scoring rules.
///
/// This engine adds:
/// - structured collectibility signals,
/// - confidence,
/// - collector-facing explanations,
/// - display recommendations,
/// - insurance-review recommendations,
/// - and market-readiness analysis.
class AtlasCollectibilityEngine {
  const AtlasCollectibilityEngine();

  AtlasCollectibilitySummary build({
    required Pop pop,
    required AtlasHeroSummary heroSummary,
    required List<PopIdentityBadgeData> identityBadges,
  }) {
    final signals = _buildSignals(pop: pop, identityBadges: identityBadges);

    final strengths = _buildStrengths(
      heroSummary: heroSummary,
      signals: signals,
    );

    final opportunities = _buildOpportunities(pop);

    final score = heroSummary.normalizedScore;
    final tier = heroSummary.classification;

    final confidence = _buildConfidence(pop: pop, signalCount: signals.length);

    final marketReadiness = _buildMarketReadiness(pop);

    return AtlasCollectibilitySummary(
      score: score,
      tier: tier,
      confidence: confidence,
      headline: _buildHeadline(pop: pop, tier: tier, signals: signals),
      explanation: _buildExplanation(
        tier: tier,
        confidence: confidence,
        signals: signals,
      ),
      strengths: List<String>.unmodifiable(strengths),
      opportunities: List<String>.unmodifiable(opportunities),
      signals: List<AtlasCollectibilitySignal>.unmodifiable(signals),
      isDisplayPiece: _isDisplayPiece(score: score, signals: signals),
      shouldReviewForInsurance: _shouldReviewForInsurance(
        pop: pop,
        score: score,
        signals: signals,
      ),
      marketReadiness: marketReadiness,
    );
  }

  List<AtlasCollectibilitySignal> _buildSignals({
    required Pop pop,
    required List<PopIdentityBadgeData> identityBadges,
  }) {
    final signals = <AtlasCollectibilitySignal>[];
    final addedIds = <String>{};

    void addSignal(AtlasCollectibilitySignal signal) {
      if (addedIds.add(signal.id)) {
        signals.add(signal);
      }
    }

    for (final badge in identityBadges) {
      addSignal(
        AtlasCollectibilitySignal(
          id: 'identity-${badge.id}',
          label: badge.label,
          description:
              '${badge.displayLabel} is part of this collectible’s release identity.',
          category: 'Identity',
          points: 6,
        ),
      );
    }

    final variantText = _combinedText([pop.edition, pop.variant, pop.finish]);

    if (_containsAny(variantText, const ['chase'])) {
      addSignal(
        const AtlasCollectibilitySignal(
          id: 'chase',
          label: 'Chase Release',
          description:
              'Chase releases are distinct collectible variants with stronger collector differentiation.',
          category: 'Variant',
          points: 15,
        ),
      );
    }

    if (_containsAny(variantText, const ['prototype', 'proto'])) {
      addSignal(
        const AtlasCollectibilitySignal(
          id: 'prototype',
          label: 'Prototype',
          description:
              'Prototype collectibles may have unusual production history and limited availability.',
          category: 'Production',
          points: 20,
        ),
      );
    }

    if (_containsAny(variantText, const [
      'glow',
      'glow in the dark',
      'gitd',
      'flocked',
      'metallic',
      'diamond',
      'blacklight',
      'black light',
      'chrome',
      'translucent',
      'holographic',
    ])) {
      addSignal(
        const AtlasCollectibilitySignal(
          id: 'special-finish',
          label: 'Special Finish',
          description:
              'A special finish gives this release a visually distinct collector identity.',
          category: 'Variant',
          points: 8,
        ),
      );
    }

    if (_hasMeaningfulValue(pop.retailExclusive)) {
      addSignal(
        AtlasCollectibilitySignal(
          id: 'retail-exclusive',
          label: 'Retail Exclusive',
          description:
              'This release is associated with ${pop.retailExclusive.trim()}.',
          category: 'Distribution',
          points: 8,
        ),
      );
    }

    if (_hasMeaningfulValue(pop.eventSticker) ||
        _hasMeaningfulValue(pop.stickerType)) {
      final stickerLabel = _firstMeaningfulValue([
        pop.eventSticker,
        pop.stickerType,
      ]);

      addSignal(
        AtlasCollectibilitySignal(
          id: 'sticker-release',
          label: 'Sticker Release',
          description: '$stickerLabel helps distinguish this physical release.',
          category: 'Release',
          points: 8,
        ),
      );
    }

    if (_hasMeaningfulValue(pop.limitedEdition)) {
      addSignal(
        AtlasCollectibilitySignal(
          id: 'limited-edition',
          label: 'Limited Edition',
          description:
              '${pop.limitedEdition.trim()} indicates restricted or numbered production.',
          category: 'Production',
          points: 15,
        ),
      );
    }

    if (_hasMeaningfulSignature(pop.signature)) {
      addSignal(
        AtlasCollectibilitySignal(
          id: 'signed',
          label: 'Signed Collectible',
          description:
              '${pop.signature.trim()} adds autograph-related collector significance.',
          category: 'Authentication',
          points: 10,
        ),
      );
    }

    if (_hasMeaningfulValue(pop.authenticationProvider) ||
        _hasMeaningfulValue(pop.authenticityNumber)) {
      addSignal(
        const AtlasCollectibilitySignal(
          id: 'authenticated',
          label: 'Authentication Recorded',
          description:
              'Authentication information strengthens the collectible’s documented provenance.',
          category: 'Authentication',
          points: 10,
        ),
      );
    }

    if (_hasMeaningfulValue(pop.gradingCompany)) {
      addSignal(
        AtlasCollectibilitySignal(
          id: 'graded',
          label: 'Grading Recorded',
          description:
              '${pop.gradingCompany.trim()} is recorded as the grading company.',
          category: 'Condition',
          points: 8,
        ),
      );
    }

    final productionStatus = pop.productionStatus.trim().toLowerCase();

    if (_containsAny(productionStatus, const [
      'vaulted',
      'retired',
      'discontinued',
      'out of production',
    ])) {
      addSignal(
        AtlasCollectibilitySignal(
          id: 'production-ended',
          label: 'Production Ended',
          description:
              '${pop.productionStatus.trim()} may increase collector interest by limiting future supply.',
          category: 'Production',
          points: 10,
        ),
      );
    }

    final sourceMetadataCount = [
      pop.sourceCatalogId,
      pop.sourceCollectibleId,
      pop.sourceUpc,
    ].where(_hasMeaningfulValue).length;

    if (sourceMetadataCount >= 2) {
      addSignal(
        const AtlasCollectibilitySignal(
          id: 'catalog-identity',
          label: 'Strong Catalog Identity',
          description:
              'Multiple catalog identifiers strengthen release matching and record confidence.',
          category: 'Data Quality',
          points: 4,
        ),
      );
    }

    return signals;
  }

  List<String> _buildStrengths({
    required AtlasHeroSummary heroSummary,
    required List<AtlasCollectibilitySignal> signals,
  }) {
    final strengths = <String>{};

    for (final reason in heroSummary.scoreReasons) {
      final cleaned = reason.trim();

      if (cleaned.isNotEmpty) {
        strengths.add(cleaned);
      }
    }

    for (final signal in signals) {
      strengths.add(signal.description);
    }

    return strengths.toList(growable: false);
  }

  List<String> _buildOpportunities(Pop pop) {
    final opportunities = <String>[];

    if (pop.value <= 0) {
      opportunities.add(
        'Add a current estimated value to strengthen value and insurance analysis.',
      );
    }

    if (pop.imageUrl.trim().isEmpty) {
      opportunities.add(
        'Add a collectible image to improve identification and presentation.',
      );
    }

    if (pop.releaseDate.trim().isEmpty) {
      opportunities.add(
        'Add the release date to strengthen historical context.',
      );
    }

    if (pop.sourceCatalogId.trim().isEmpty &&
        pop.sourceCollectibleId.trim().isEmpty &&
        pop.sourceUpc.trim().isEmpty) {
      opportunities.add(
        'Add a catalog ID or UPC to strengthen release matching.',
      );
    }

    if (pop.itemCondition.trim().isEmpty) {
      opportunities.add(
        'Record the item condition for stronger collector analysis.',
      );
    }

    if (pop.boxCondition.trim().isEmpty) {
      opportunities.add(
        'Record the box condition for stronger value and display analysis.',
      );
    }

    if (_hasMeaningfulSignature(pop.signature) &&
        !_hasMeaningfulValue(pop.authenticationProvider) &&
        !_hasMeaningfulValue(pop.authenticityNumber)) {
      opportunities.add('Add autograph authentication details when available.');
    }

    return opportunities;
  }

  String _buildConfidence({required Pop pop, required int signalCount}) {
    var evidenceCount = signalCount;

    if (pop.value > 0) {
      evidenceCount++;
    }

    if (pop.imageUrl.trim().isNotEmpty) {
      evidenceCount++;
    }

    if (pop.releaseDate.trim().isNotEmpty) {
      evidenceCount++;
    }

    if (pop.sourceCatalogId.trim().isNotEmpty ||
        pop.sourceCollectibleId.trim().isNotEmpty ||
        pop.sourceUpc.trim().isNotEmpty) {
      evidenceCount++;
    }

    if (pop.itemCondition.trim().isNotEmpty) {
      evidenceCount++;
    }

    if (pop.boxCondition.trim().isNotEmpty) {
      evidenceCount++;
    }

    if (evidenceCount >= 7) {
      return 'High';
    }

    if (evidenceCount >= 4) {
      return 'Moderate';
    }

    return 'Developing';
  }

  String _buildHeadline({
    required Pop pop,
    required String tier,
    required List<AtlasCollectibilitySignal> signals,
  }) {
    final name = pop.name.trim().isEmpty ? 'This collectible' : pop.name.trim();

    if (signals.isEmpty) {
      return '$name currently has a standard collector profile.';
    }

    final strongestSignal = signals.reduce(
      (current, next) => next.points > current.points ? next : current,
    );

    return '$name is classified as a $tier, led by its '
        '${strongestSignal.label.toLowerCase()} identity.';
  }

  String _buildExplanation({
    required String tier,
    required String confidence,
    required List<AtlasCollectibilitySignal> signals,
  }) {
    if (signals.isEmpty) {
      return 'Atlas currently classifies this as a $tier. '
          'Additional release, value, condition, and catalog details can '
          'strengthen the analysis. Confidence is $confidence.';
    }

    final strongSignalCount = signals
        .where((signal) => signal.isStrongSignal)
        .length;

    return 'Atlas identified ${signals.length} meaningful collector '
        '${signals.length == 1 ? 'signal' : 'signals'}, including '
        '$strongSignalCount strong '
        '${strongSignalCount == 1 ? 'signal' : 'signals'}. '
        'The current classification is $tier with $confidence confidence.';
  }

  bool _isDisplayPiece({
    required int score,
    required List<AtlasCollectibilitySignal> signals,
  }) {
    final hasVisualSignal = signals.any(
      (signal) =>
          signal.id == 'special-finish' ||
          signal.id == 'chase' ||
          signal.id == 'prototype' ||
          signal.id == 'signed' ||
          signal.id == 'sticker-release',
    );

    return score >= 55 || hasVisualSignal;
  }

  bool _shouldReviewForInsurance({
    required Pop pop,
    required int score,
    required List<AtlasCollectibilitySignal> signals,
  }) {
    final hasStrongDocumentation = signals.any(
      (signal) =>
          signal.id == 'authenticated' ||
          signal.id == 'graded' ||
          signal.id == 'limited-edition' ||
          signal.id == 'prototype',
    );

    return pop.value >= 250 ||
        score >= 90 ||
        (pop.value >= 100 && hasStrongDocumentation);
  }

  String _buildMarketReadiness(Pop pop) {
    final hasValue = pop.value > 0;
    final hasImage = pop.imageUrl.trim().isNotEmpty;
    final hasCondition = pop.itemCondition.trim().isNotEmpty;
    final hasBoxCondition = pop.boxCondition.trim().isNotEmpty;
    final hasReleaseIdentity =
        pop.sourceCatalogId.trim().isNotEmpty ||
        pop.sourceCollectibleId.trim().isNotEmpty ||
        pop.sourceUpc.trim().isNotEmpty;

    if (hasValue &&
        hasImage &&
        hasCondition &&
        hasBoxCondition &&
        hasReleaseIdentity) {
      return 'Ready';
    }

    if (hasValue && (hasImage || hasReleaseIdentity)) {
      return 'Nearly Ready';
    }

    return 'Needs Details';
  }

  static bool _hasMeaningfulValue(String value) {
    final cleaned = value.trim().toLowerCase();

    return cleaned.isNotEmpty &&
        cleaned != 'none' &&
        cleaned != 'no' &&
        cleaned != 'n/a' &&
        cleaned != 'na' &&
        cleaned != 'common' &&
        cleaned != 'standard' &&
        cleaned != 'unsigned';
  }

  static bool _hasMeaningfulSignature(String value) {
    final cleaned = value.trim().toLowerCase();

    return cleaned.isNotEmpty &&
        cleaned != 'none' &&
        cleaned != 'no' &&
        cleaned != 'n/a' &&
        cleaned != 'na' &&
        cleaned != 'unsigned';
  }

  static String _combinedText(List<String> values) {
    return values
        .map((value) => value.trim().toLowerCase())
        .where((value) => value.isNotEmpty)
        .join(' ');
  }

  static bool _containsAny(String source, List<String> values) {
    return values.any(source.contains);
  }

  static String _firstMeaningfulValue(List<String> values) {
    for (final value in values) {
      if (_hasMeaningfulValue(value)) {
        return value.trim();
      }
    }

    return 'Recorded sticker information';
  }
}
