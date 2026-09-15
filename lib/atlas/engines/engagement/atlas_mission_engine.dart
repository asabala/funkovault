import '../intelligence/atlas_decision_engine.dart';

class AtlasMission {
  const AtlasMission({
    required this.title,
    required this.description,
    required this.reward,
    required this.estimatedTime,
  });

  final String title;
  final String description;
  final String reward;
  final String estimatedTime;
}

class AtlasMissionEngine {
  const AtlasMissionEngine();

  AtlasMission buildMission(AtlasDecision decision) {
    switch (decision.severity) {
      case 'High':
        return AtlasMission(
          title: 'Priority Mission',
          description: decision.message,
          reward: '+Health  +Confidence',
          estimatedTime: '2-5 min',
        );

      case 'Medium':
        return AtlasMission(
          title: 'Improvement Mission',
          description: decision.message,
          reward: '+Atlas Accuracy',
          estimatedTime: '5 min',
        );

      default:
        return const AtlasMission(
          title: 'Enjoy Your Collection',
          description:
              'No critical work today. Spend some time enjoying your Vault.',
          reward: 'Collector Satisfaction 😊',
          estimatedTime: 'Relax',
        );
    }
  }
}
