import '../../../models/pop.dart';
import '../models/atlas_hero_score_result.dart';
import 'atlas_hero_rule.dart';

class KeywordHeroRule extends AtlasHeroRule {
  const KeywordHeroRule({
    required this.ruleId,
    required this.points,
    required this.reason,
    required this.keywords,
    this.improvementSuggestion,
  });

  final String ruleId;
  final int points;
  final String reason;
  final List<String> keywords;
  final String? improvementSuggestion;

  @override
  String get id => ruleId;

  @override
  bool matches(Pop pop) {
    final searchableText = _buildSearchableText(pop);

    return keywords.any(
          (keyword) => searchableText.contains(_normalize(keyword)),
    );
  }

  @override
  AtlasHeroScoreResult evaluate(Pop pop) {
    return AtlasHeroScoreResult(
      ruleId: id,
      points: points,
      reason: reason,
      improvementSuggestion: improvementSuggestion,
    );
  }

  String _buildSearchableText(Pop pop) {
    final values = <Object?>[
      pop.name,
      pop.variant,
      pop.collectorLabel,
      pop.category,
      pop.series,
    ];

    return values
        .whereType<Object>()
        .map((value) => _normalize(value.toString()))
        .where((value) => value.isNotEmpty)
        .join(' ');
  }

  String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}