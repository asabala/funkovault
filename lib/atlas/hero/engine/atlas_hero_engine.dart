import '../../../models/pop.dart';
import '../models/atlas_hero_score_result.dart';
import '../models/atlas_hero_summary.dart';
import '../rules/atlas_hero_rule.dart';
import '../rules/atlas_hero_rules.dart';

class AtlasHeroEngine {
  const AtlasHeroEngine({
    this.rules = AtlasHeroRules.all,
  });

  final List<AtlasHeroRule> rules;

  AtlasHeroSummary build(Pop pop) {
    final results = _evaluateRules(pop);

    final collectorScore = _calculateScore(results);
    final classification = _buildClassification(collectorScore);
    final primaryEmoji = _buildPrimaryEmoji(collectorScore);
    final headline = _buildHeadline(
      pop: pop,
      collectorScore: collectorScore,
      classification: classification,
    );

    final scoreReasons = results
        .where((result) => result.isPositive)
        .map(
          (result) => '+${result.points} ${result.reason}',
    )
        .toList(growable: false);

    final improvementSuggestions = results
        .where((result) => result.hasImprovementSuggestion)
        .map((result) => result.improvementSuggestion!.trim())
        .where((suggestion) => suggestion.isNotEmpty)
        .toSet()
        .toList(growable: false);

    return AtlasHeroSummary(
      collectorScore: collectorScore,
      classification: classification,
      headline: headline,
      summary: _buildSummary(
        collectorScore: collectorScore,
        classification: classification,
        positiveResultCount: scoreReasons.length,
      ),
      primaryEmoji: primaryEmoji,
      scoreReasons: scoreReasons,
      improvementSuggestions: improvementSuggestions,
    );
  }

  List<AtlasHeroScoreResult> _evaluateRules(Pop pop) {
    final results = <AtlasHeroScoreResult>[];

    for (final rule in rules) {
      final result = rule.apply(pop);

      if (result != null) {
        results.add(result);
      }
    }

    return List<AtlasHeroScoreResult>.unmodifiable(results);
  }

  int _calculateScore(List<AtlasHeroScoreResult> results) {
    const baseScore = 45;

    final rulePoints = results.fold<int>(
      0,
          (total, result) => total + result.points,
    );

    return (baseScore + rulePoints).clamp(0, 100);
  }

  String _buildClassification(int score) {
    if (score >= 90) {
      return 'Grail Collectible';
    }

    if (score >= 75) {
      return 'Premium Collectible';
    }

    if (score >= 55) {
      return 'Notable Collectible';
    }

    return 'Standard Collectible';
  }

  String _buildPrimaryEmoji(int score) {
    if (score >= 90) {
      return '👑';
    }

    if (score >= 75) {
      return '🏆';
    }

    if (score >= 55) {
      return '✨';
    }

    return '📦';
  }

  String _buildHeadline({
    required Pop pop,
    required int collectorScore,
    required String classification,
  }) {
    final name = pop.name.trim();

    if (name.isEmpty) {
      return classification;
    }

    if (collectorScore >= 90) {
      return '$name stands out as a grail-level collectible.';
    }

    if (collectorScore >= 75) {
      return '$name has a strong premium collector identity.';
    }

    if (collectorScore >= 55) {
      return '$name has several notable collector traits.';
    }

    return '$name is a solid foundation collectible.';
  }

  String _buildSummary({
    required int collectorScore,
    required String classification,
    required int positiveResultCount,
  }) {
    if (collectorScore >= 90) {
      return 'Atlas identified $positiveResultCount strong collector traits, '
          'placing this item in the $classification tier.';
    }

    if (collectorScore >= 75) {
      return 'Atlas found $positiveResultCount collector traits that give this '
          'item a strong premium identity.';
    }

    if (collectorScore >= 55) {
      return 'Atlas found $positiveResultCount notable collector traits that '
          'help this item stand out in your vault.';
    }

    if (positiveResultCount > 0) {
      return 'Atlas found $positiveResultCount collector traits. This item has '
          'a strong foundation with room for additional record details.';
    }

    return 'Atlas currently classifies this as a standard collectible. '
        'Additional identity and value details can strengthen its profile.';
  }
}