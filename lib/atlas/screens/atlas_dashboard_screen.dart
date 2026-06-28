import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/app_state.dart';
import '../../widgets/atlas_priority_chip.dart';
import '../../widgets/atlas_section_card.dart';
import '../../widgets/atlas_stat_tile.dart';
import '../../widgets/vault_scroll_view.dart';
import '../engines/atlas_confidence_engine.dart';
import '../engines/atlas_daily_briefing_engine.dart';
import '../engines/atlas_decision_engine.dart';
import '../engines/atlas_intelligence_engine.dart';
import '../engines/atlas_mission_engine.dart';
import '../engines/atlas_recommendation_engine_v2.dart';
import '../repositories/vault_repository.dart';
import '../tasks/atlas_task_engine.dart';
import 'atlas_achievements_screen.dart';
import 'atlas_confidence_screen.dart';
import 'atlas_timeline_screen.dart';
import 'duplicate_review_screen.dart';
import 'missing_values_screen.dart';
import 'vault_health_screen.dart';
import 'vault_tasks_screen.dart';
import 'atlas_intelligence_center.dart';

class AtlasDashboardScreen extends StatelessWidget {
  const AtlasDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    const briefingEngine = AtlasDailyBriefingEngine();
    const repository = VaultRepository();
    const taskEngine = AtlasTaskEngine();
    const confidenceEngine = AtlasConfidenceEngine();
    const intelligenceEngine = AtlasIntelligenceEngine();
    const recommendationEngineV2 = AtlasRecommendationEngineV2();
    const decisionEngine = AtlasDecisionEngine();
    const missionEngine = AtlasMissionEngine();

    final briefing = briefingEngine.build(
      appState,
      collectorName: 'Arthur',
    );

    final allPops = repository.allPops(appState);

    final duplicateCount =
        repository.duplicatePopGroups(appState).length;

    final missingValueCount =
        allPops.where((pop) => pop.value <= 0).length;

    const missingPurchaseDateCount = 0;

    final tasks = taskEngine.buildTasks(
      duplicateCount: duplicateCount,
      missingValueCount: missingValueCount,
      missingPurchaseDateCount: missingPurchaseDateCount,
    );

    final vaultHealth = _calculateVaultHealth(
      totalPops: allPops.length,
      duplicateCount: duplicateCount,
      missingValueCount: missingValueCount,
    );

    final confidence = confidenceEngine.calculate(allPops);

    final intelligence = intelligenceEngine.analyze(
      pops: allPops,
      duplicateCount: duplicateCount,
      missingValueCount: missingValueCount,
    );

    final smartRecommendations =
    recommendationEngineV2.analyze(
      pops: allPops,
      duplicateCount: duplicateCount,
      missingValueCount: missingValueCount,
    );

    final decision = decisionEngine.decide(
      recommendations: smartRecommendations,
    );

    final mission = missionEngine.buildMission(
      decision,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Atlas Command Center'),
      ),
      body: VaultScrollView(
        children: [
          AtlasSectionCard(
            title: briefing.title,
            icon: Icons.auto_awesome,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  briefing.summary,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 12),
                Text(briefing.message),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              AtlasStatTile(
                title: 'Health',
                value: '${vaultHealth.toStringAsFixed(0)}%',
                icon: Icons.health_and_safety,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const VaultHealthScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              AtlasStatTile(
                title: 'Pops',
                value: repository
                    .totalPops(appState)
                    .toString(),
                icon: Icons.inventory_2,
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              AtlasStatTile(
                title: 'Value',
                value:
                '\$${repository.totalValue(appState).toStringAsFixed(2)}',
                icon: Icons.attach_money,
              ),
              const SizedBox(width: 12),
              AtlasStatTile(
                title: 'Tasks',
                value: tasks.length.toString(),
                icon: Icons.task_alt,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VaultTasksScreen(
                        tasks: tasks,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              AtlasStatTile(
                title: 'Duplicates',
                value: duplicateCount.toString(),
                icon: Icons.copy,
                onTap: duplicateCount == 0
                    ? null
                    : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const DuplicateReviewScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              AtlasStatTile(
                title: 'Missing Values',
                value: missingValueCount.toString(),
                icon: Icons.sell,
                onTap: missingValueCount == 0
                    ? null
                    : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const MissingValuesScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              AtlasStatTile(
                title: 'Confidence',
                value:
                '${confidence.score.toStringAsFixed(0)}%',
                icon: Icons.psychology,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const AtlasConfidenceScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              AtlasStatTile(
                title: 'Timeline',
                value: 'Live',
                icon: Icons.timeline,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const AtlasTimelineScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              AtlasStatTile(
                title: 'Achievements',
                value: 'New',
                icon: Icons.emoji_events,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const AtlasAchievementsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              const AtlasStatTile(
                title: 'Status',
                value: 'Online',
                icon: Icons.verified_user,
              ),
            ],
          ),

          const SizedBox(height: 16),

          AtlasStatTile(
            title: 'Intelligence',
            value: 'Open',
            icon: Icons.auto_awesome,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const AtlasIntelligenceCenter(),
                ),
              );
            },
          ),

          AtlasSectionCard(
            title: "Today's Mission",
            icon: Icons.flag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AtlasPriorityChip(
                  severity: decision.severity,
                ),

                const SizedBox(height: 12),

                Text(
                  mission.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(mission.description),

                const SizedBox(height: 12),

                Text(
                  'Estimated Time: ${mission.estimatedTime}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Reward: ${mission.reward}',
                ),

                const SizedBox(height: 12),

                Text(
                  'Why: ${decision.why}',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          AtlasSectionCard(
            title: intelligence.primaryFocusTitle,
            icon: Icons.lightbulb_outline,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(intelligence.primaryFocusMessage),

                const SizedBox(height: 12),

                Text(
                  'Confidence: ${intelligence.confidenceScore.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(intelligence.confidenceMessage),

                if (tasks.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.task_alt),
                      label: const Text('Review Vault Tasks'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                VaultTasksScreen(tasks: tasks),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _calculateVaultHealth({
    required int totalPops,
    required int duplicateCount,
    required int missingValueCount,
  }) {
    if (totalPops == 0) {
      return 100;
    }

    final issueCount =
        duplicateCount + missingValueCount;

    final score =
        100 - ((issueCount / totalPops) * 100);

    return score.clamp(0, 100);
  }
}