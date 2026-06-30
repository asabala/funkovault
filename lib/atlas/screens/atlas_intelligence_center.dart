import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/app_state.dart';
import '../../theme/atlas_spacing.dart';
import '../../widgets/dashboard/collector_header.dart';
import '../../widgets/dashboard/health_confidence_panel.dart';
import '../../widgets/dashboard/mission_card.dart';
import '../../widgets/dashboard/reflection_card.dart';
import '../../widgets/vault_scroll_view.dart';
import '../engines/atlas_confidence_engine.dart';
import '../engines/atlas_decision_engine.dart';
import '../engines/atlas_mission_engine.dart';
import '../engines/atlas_recommendation_engine_v2.dart';
import '../engines/atlas_reflection_engine.dart';
import '../repositories/vault_repository.dart';
import 'atlas_confidence_screen.dart';
import 'vault_health_screen.dart';

class AtlasIntelligenceCenter extends StatelessWidget {
  const AtlasIntelligenceCenter({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    const collectorName = 'Arthur';

    const repository = VaultRepository();
    const confidenceEngine = AtlasConfidenceEngine();
    const recommendationEngine = AtlasRecommendationEngineV2();
    const decisionEngine = AtlasDecisionEngine();
    const missionEngine = AtlasMissionEngine();
    const reflectionEngine = AtlasReflectionEngine();

    final pops = repository.allPops(appState);

    final duplicateCount =
        repository.duplicatePopGroups(appState).length;

    final missingValueCount =
        pops.where((pop) => pop.value <= 0).length;

    final health = _calculateVaultHealth(
      totalPops: pops.length,
      duplicateCount: duplicateCount,
      missingValueCount: missingValueCount,
    );

    final confidence = confidenceEngine.calculate(pops);

    final recommendations = recommendationEngine.analyze(
      pops: pops,
      duplicateCount: duplicateCount,
      missingValueCount: missingValueCount,
    );

    final decision = decisionEngine.decide(
      recommendations: recommendations,
    );

    final mission = missionEngine.buildMission(
      decision,
    );

    final reflection = reflectionEngine.reflect(
      collectorName: collectorName,
      pops: pops,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Atlas Intelligence Center'),
      ),
      body: VaultScrollView(
        children: [
          const CollectorHeader(
            collectorName: collectorName,
            status: 'Collector Intelligence Platform',
          ),

          const SizedBox(height: AtlasSpacing.lg),

          HealthConfidencePanel(
            health: health,
            confidence: confidence.score,
            onHealthTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const VaultHealthScreen(),
                ),
              );
            },
            onConfidenceTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AtlasConfidenceScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: AtlasSpacing.lg),

          MissionCard(
            title: mission.title,
            description: mission.description,
            reward: mission.reward,
            estimatedTime: mission.estimatedTime,
            severity: decision.severity,
          ),

          const SizedBox(height: AtlasSpacing.lg),

          ReflectionCard(
            title: reflection.title,
            message: reflection.message,
            tone: reflection.tone,
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