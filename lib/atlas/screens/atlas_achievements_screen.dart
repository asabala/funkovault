import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/app_state.dart';
import '../../widgets/atlas_greeting_card.dart';
import '../../widgets/vault_scroll_view.dart';
import '../engines/atlas_achievement_engine.dart';
import '../repositories/vault_repository.dart';

class AtlasAchievementsScreen extends StatelessWidget {
  const AtlasAchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    const repository = VaultRepository();
    const achievementEngine = AtlasAchievementEngine();

    final pops = repository.allPops(appState);
    final achievements =
    achievementEngine.evaluate(pops);

    final unlockedCount =
        achievements.where((a) => a.unlocked).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Atlas Achievements'),
      ),
      body: VaultScrollView(
        children: [
          AtlasGreetingCard(
            title: '$unlockedCount / ${achievements.length} Unlocked',
            message:
            'Atlas celebrates important milestones in your collecting journey.',
            icon: Icons.emoji_events,
          ),

          const SizedBox(height: 16),

          ...achievements.map(
                (achievement) {
              return Card(
                child: ListTile(
                  leading: Text(
                    achievement.icon,
                    style: const TextStyle(
                      fontSize: 28,
                    ),
                  ),
                  title: Text(achievement.title),
                  subtitle: Text(achievement.description),
                  trailing: Icon(
                    achievement.unlocked
                        ? Icons.check_circle
                        : Icons.lock_outline,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}