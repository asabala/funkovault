import '../../models/pop.dart';
import '../engines/collection/atlas_collector_dna_engine.dart';
import '../engines/intelligence/atlas_confidence_engine.dart';
import '../engines/intelligence/atlas_decision_engine.dart';
import '../engines/intelligence/atlas_memory_engine.dart';
import '../engines/engagement/atlas_mission_engine.dart';
import '../engines/intelligence/atlas_recommendation_engine_v2.dart';
import '../engines/intelligence/atlas_reflection_engine.dart';

class AtlasCoreReport {
  const AtlasCoreReport({
    required this.collectorDNA,
    required this.confidence,
    required this.reflection,
    required this.memory,
    required this.recommendations,
    required this.decision,
    required this.mission,
  });

  final AtlasCollectorDNA collectorDNA;
  final AtlasConfidenceResult confidence;
  final AtlasReflection reflection;
  final AtlasMemory memory;
  final List<AtlasSmartRecommendation> recommendations;
  final AtlasDecision decision;
  final AtlasMission mission;
}

class AtlasCore {
  const AtlasCore();

  AtlasCoreReport analyze({
    required String collectorName,
    required List<Pop> pops,
    required int duplicateCount,
    required int missingValueCount,
  }) {
    const dnaEngine = AtlasCollectorDNAEngine();
    const confidenceEngine = AtlasConfidenceEngine();
    const reflectionEngine = AtlasReflectionEngine();
    const memoryEngine = AtlasMemoryEngine();
    const recommendationEngine =
    AtlasRecommendationEngineV2();
    const decisionEngine = AtlasDecisionEngine();
    const missionEngine = AtlasMissionEngine();

    final collectorDNA =
    dnaEngine.analyze(pops);

    final confidence =
    confidenceEngine.calculate(pops);

    final reflection =
    reflectionEngine.reflect(
      collectorName: collectorName,
      pops: pops,
    );

    final memory =
    memoryEngine.remember(
      pops: pops,
    );

    final recommendations =
    recommendationEngine.analyze(
      pops: pops,
      duplicateCount: duplicateCount,
      missingValueCount: missingValueCount,
    );

    final decision =
    decisionEngine.decide(
      recommendations: recommendations,
    );

    final mission =
    missionEngine.buildMission(
      decision,
    );

    return AtlasCoreReport(
      collectorDNA: collectorDNA,
      confidence: confidence,
      reflection: reflection,
      memory: memory,
      recommendations: recommendations,
      decision: decision,
      mission: mission,
    );
  }
}