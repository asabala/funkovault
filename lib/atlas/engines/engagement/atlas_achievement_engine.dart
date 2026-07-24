import '../../../models/pop.dart';
import '../../models/atlas_achievement.dart';

class AtlasAchievementEngine {
  const AtlasAchievementEngine();

  List<AtlasAchievement> evaluate(
      List<Pop> pops,
      ) {
    final totalPops = pops.length;

    final hasChase =
    pops.any((pop) => pop.variant == 'Chase');

    final hasSigned =
    pops.any((pop) => pop.signature != 'Unsigned');

    final hasLimitedEdition =
    pops.any((pop) => pop.limitedEdition != 'None');

    final hasGrail =
    pops.any((pop) => pop.value >= 100);

    return [
      AtlasAchievement(
        id: 'first_pop',
        title: 'First Pop',
        description: 'Add your first Funko Pop to the Vault.',
        icon: '📦',
        unlocked: totalPops >= 1,
      ),
      AtlasAchievement(
        id: 'ten_pops',
        title: 'Getting Started',
        description: 'Reach 10 Pops in your Vault.',
        icon: '🏦',
        unlocked: totalPops >= 10,
      ),
      AtlasAchievement(
        id: 'hundred_pops',
        title: 'Century Collector',
        description: 'Reach 100 Pops in your Vault.',
        icon: '💯',
        unlocked: totalPops >= 100,
      ),
      AtlasAchievement(
        id: 'first_chase',
        title: 'Chase Hunter',
        description: 'Add your first Chase Pop.',
        icon: '⚡',
        unlocked: hasChase,
      ),
      AtlasAchievement(
        id: 'first_signed',
        title: 'Signed Treasure',
        description: 'Add your first signed collectible.',
        icon: '✍️',
        unlocked: hasSigned,
      ),
      AtlasAchievement(
        id: 'limited_edition',
        title: 'Limited Edition',
        description: 'Add your first Limited Edition Pop.',
        icon: '🏆',
        unlocked: hasLimitedEdition,
      ),
      AtlasAchievement(
        id: 'first_grail',
        title: 'First Grail',
        description: 'Add a Pop valued at \$100 or more.',
        icon: '💎',
        unlocked: hasGrail,
      ),
    ];
  }
}