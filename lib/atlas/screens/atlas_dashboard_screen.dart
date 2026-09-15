import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/app_state.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_constants.dart';
import '../../theme/atlas_icons.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../widgets/atlas/atlas_greeting_card.dart';
import '../../widgets/vault/atlas_priority_chip.dart';
import '../../widgets/atlas/atlas_section_card.dart';
import '../../widgets/vault/atlas_stat_tile.dart';
import '../../widgets/vault/vault_scroll_view.dart';
import '../engines/intelligence/atlas_confidence_engine.dart';
import '../engines/engagement/atlas_daily_briefing_engine.dart';
import '../engines/intelligence/atlas_decision_engine.dart';
import '../engines//intelligence/atlas_intelligence_engine.dart';
import '../engines/engagement/atlas_mission_engine.dart';
import '../engines//intelligence/atlas_recommendation_engine_v2.dart';
import '../repositories/vault_repository.dart';
import '../tasks/atlas_task_engine.dart';
import 'atlas_achievements_screen.dart';
import 'atlas_confidence_screen.dart';
import 'atlas_intelligence_center.dart';
import 'atlas_timeline_screen.dart';
import 'duplicate_review_screen.dart';
import 'missing_values_screen.dart';
import 'vault_health_screen.dart';
import 'vault_tasks_screen.dart';

class AtlasDashboardScreen extends StatelessWidget {
  const AtlasDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    const collectorName = 'Arthur';

    const briefingEngine = AtlasDailyBriefingEngine();
    const repository = VaultRepository();
    const taskEngine = AtlasTaskEngine();
    const confidenceEngine = AtlasConfidenceEngine();
    const intelligenceEngine = AtlasIntelligenceEngine();
    const recommendationEngine = AtlasRecommendationEngineV2();
    const decisionEngine = AtlasDecisionEngine();
    const missionEngine = AtlasMissionEngine();

    final allPops = repository.allPops(appState);

    final duplicateCount = repository.duplicatePopGroups(appState).length;

    final missingValueCount = allPops.where((pop) => pop.value <= 0).length;

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

    final smartRecommendations = recommendationEngine.analyze(
      pops: allPops,
      duplicateCount: duplicateCount,
      missingValueCount: missingValueCount,
    );

    final decision = decisionEngine.decide(
      recommendations: smartRecommendations,
    );

    final mission = missionEngine.buildMission(decision);

    final briefing = briefingEngine.build(
      appState,
      collectorName: collectorName,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Atlas Command Center')),
      body: VaultScrollView(
        children: [
          AtlasGreetingCard(
            title: briefing.title,
            message: briefing.message,
            icon: AtlasIcons.atlas,
          ),

          const SizedBox(height: AtlasSpacing.lg),

          Text(
            briefing.summary,
            style: AtlasTypography.label.copyWith(
              color: AtlasColors.intelligenceBlue,
            ),
          ),

          const SizedBox(height: AtlasSpacing.lg),

          Row(
            children: [
              AtlasStatTile(
                title: 'Health',
                value: '${vaultHealth.toStringAsFixed(0)}%',
                icon: AtlasIcons.health,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VaultHealthScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(width: AtlasSpacing.md),
              AtlasStatTile(
                title: 'Pops',
                value: repository.totalPops(appState).toString(),
                icon: AtlasIcons.collection,
              ),
            ],
          ),

          const SizedBox(height: AtlasSpacing.md),

          Row(
            children: [
              AtlasStatTile(
                title: 'Value',
                value:
                    '\$${repository.totalValue(appState).toStringAsFixed(2)}',
                icon: AtlasIcons.value,
              ),
              const SizedBox(width: AtlasSpacing.md),
              AtlasStatTile(
                title: 'Tasks',
                value: tasks.length.toString(),
                icon: AtlasIcons.recommendation,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VaultTasksScreen(tasks: tasks),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: AtlasSpacing.md),

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
                            builder: (_) => const DuplicateReviewScreen(),
                          ),
                        );
                      },
              ),
              const SizedBox(width: AtlasSpacing.md),
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
                            builder: (_) => const MissingValuesScreen(),
                          ),
                        );
                      },
              ),
            ],
          ),

          const SizedBox(height: AtlasSpacing.md),

          Row(
            children: [
              AtlasStatTile(
                title: 'Confidence',
                value: '${confidence.score.toStringAsFixed(0)}%',
                icon: AtlasIcons.confidence,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AtlasConfidenceScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(width: AtlasSpacing.md),
              AtlasStatTile(
                title: 'Timeline',
                value: 'Live',
                icon: AtlasIcons.timeline,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AtlasTimelineScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: AtlasSpacing.md),

          Row(
            children: [
              AtlasStatTile(
                title: 'Achievements',
                value: 'New',
                icon: AtlasIcons.achievement,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AtlasAchievementsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(width: AtlasSpacing.md),
              AtlasStatTile(
                title: 'Intelligence',
                value: 'Open',
                icon: AtlasIcons.intelligence,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AtlasIntelligenceCenter(),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: AtlasSpacing.xl),

          _SectionLabel(text: 'Today'),

          const SizedBox(height: AtlasSpacing.sm),

          AtlasSectionCard(
            title: "Today's Mission",
            icon: AtlasIcons.mission,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AtlasPriorityChip(severity: decision.severity),

                const SizedBox(height: AtlasSpacing.md),

                Text(mission.title, style: AtlasTypography.headingSmall),

                const SizedBox(height: AtlasSpacing.sm),

                Text(mission.description, style: AtlasTypography.bodyMedium),

                const SizedBox(height: AtlasSpacing.md),

                Text(
                  'Estimated Time: ${mission.estimatedTime}',
                  style: AtlasTypography.label,
                ),

                const SizedBox(height: AtlasSpacing.sm),

                Text(
                  'Reward: ${mission.reward}',
                  style: AtlasTypography.label.copyWith(
                    color: AtlasColors.vaultGold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AtlasSpacing.lg),

          AtlasSectionCard(
            title: intelligence.primaryFocusTitle,
            icon: AtlasIcons.decision,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  intelligence.primaryFocusMessage,
                  style: AtlasTypography.bodyMedium,
                ),

                const SizedBox(height: AtlasSpacing.md),

                Text(
                  'Confidence: ${intelligence.confidenceScore.toStringAsFixed(0)}%',
                  style: AtlasTypography.label.copyWith(
                    color: AtlasColors.intelligenceBlue,
                  ),
                ),

                const SizedBox(height: AtlasSpacing.sm),

                Text(
                  intelligence.confidenceMessage,
                  style: AtlasTypography.bodySmall,
                ),

                if (tasks.isNotEmpty) ...[
                  const SizedBox(height: AtlasSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(AtlasIcons.recommendation),
                      label: const Text('Review Vault Tasks'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VaultTasksScreen(tasks: tasks),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: AtlasSpacing.xl),

          Center(
            child: Text(
              '${AtlasConstants.poweredBy} • ${AtlasConstants.version}',
              style: AtlasTypography.bodySmall,
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

    final issueCount = duplicateCount + missingValueCount;

    final score = 100 - ((issueCount / totalPops) * 100);

    return score.clamp(0, 100);
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AtlasTypography.label.copyWith(
        letterSpacing: 1.2,
        color: AtlasColors.textMuted,
      ),
    );
  }
}
