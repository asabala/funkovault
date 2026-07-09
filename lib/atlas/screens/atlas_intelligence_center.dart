import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/app_state.dart';
import '../../theme/atlas_spacing.dart';
import '../../widgets/dashboard/collector_header.dart';
import '../../widgets/dashboard/health_confidence_panel.dart';
import '../../widgets/dashboard/mission_card.dart';
import '../../widgets/dashboard/recommendation_card.dart';
import '../../widgets/dashboard/reflection_card.dart';
import '../../widgets/dashboard/today_memory_card.dart';
import '../../widgets/vault/vault_scroll_view.dart';
import '../core/atlas_core.dart';
import '../repositories/vault_repository.dart';
import 'atlas_confidence_screen.dart';
import 'vault_health_screen.dart';
import '../../widgets/dashboard/collector_dna_card.dart';

class AtlasIntelligenceCenter extends StatelessWidget {
  const AtlasIntelligenceCenter({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    const collectorName = 'Arthur';

    const repository = VaultRepository();
    const atlasCore = AtlasCore();

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

    final report = atlasCore.analyze(
      collectorName: collectorName,
      pops: pops,
      duplicateCount: duplicateCount,
      missingValueCount: missingValueCount,
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
            confidence: report.confidence.score,
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

          CollectorDNACard(
            primaryTrait: report.collectorDNA.primaryTrait,
            secondaryTrait: report.collectorDNA.secondaryTrait,
            confidence: report.collectorDNA.confidence,
            summary: report.collectorDNA.summary,
          ),

          const SizedBox(height: AtlasSpacing.lg),

          MissionCard(
            title: report.mission.title,
            description: report.mission.description,
            reward: report.mission.reward,
            estimatedTime: report.mission.estimatedTime,
            severity: report.decision.severity,
          ),

          const SizedBox(height: AtlasSpacing.lg),

          ReflectionCard(
            title: report.reflection.title,
            message: report.reflection.message,
            tone: report.reflection.tone,
          ),

          const SizedBox(height: AtlasSpacing.lg),

          TodayMemoryCard(
            title: report.memory.title,
            message: report.memory.message,
            footer: report.memory.footer,
          ),

          const SizedBox(height: AtlasSpacing.lg),

          RecommendationCard(
            title: report.decision.title,
            message: report.decision.message,
            confidenceScore: report.confidence.score,
            confidenceMessage: report.confidence.message,
            severity: report.decision.severity,
            why: report.decision.why,
          ),

          const SizedBox(height: AtlasSpacing.xl),
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