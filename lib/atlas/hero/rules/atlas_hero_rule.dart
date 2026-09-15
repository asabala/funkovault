import '../../../models/pop.dart';
import '../models/atlas_hero_score_result.dart';

abstract class AtlasHeroRule {
  const AtlasHeroRule();

  /// Stable identifier used for testing, debugging, and future analytics.
  String get id;

  /// Determines whether this rule applies to the supplied collectible.
  bool matches(Pop pop);

  /// Creates the transparent scoring result for this rule.
  ///
  /// This method is only called when [matches] returns true.
  AtlasHeroScoreResult evaluate(Pop pop);

  /// Convenience method used by the Hero Engine.
  ///
  /// Returns null when the rule does not apply.
  AtlasHeroScoreResult? apply(Pop pop) {
    if (!matches(pop)) {
      return null;
    }

    return evaluate(pop);
  }
}
