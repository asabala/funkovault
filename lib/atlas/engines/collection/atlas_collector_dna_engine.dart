import '../../../models/pop.dart';

class AtlasCollectorDNA {
  const AtlasCollectorDNA({
    required this.primaryTrait,
    required this.secondaryTrait,
    required this.confidence,
    required this.summary,
  });

  final String primaryTrait;
  final String secondaryTrait;
  final double confidence;
  final String summary;
}

class AtlasCollectorDNAEngine {
  const AtlasCollectorDNAEngine();

  AtlasCollectorDNA analyze(List<Pop> pops) {
    if (pops.isEmpty) {
      return const AtlasCollectorDNA(
        primaryTrait: 'New Collector',
        secondaryTrait: 'Explorer',
        confidence: 100,
        summary: 'Every great collection begins with a single collectible.',
      );
    }

    final totalValue = pops.fold<double>(0, (sum, pop) => sum + pop.value);

    final grails = pops.where((pop) => pop.value >= 100).length;

    final averageValue = totalValue / pops.length;

    String primaryTrait;
    String secondaryTrait;

    if (grails >= 10) {
      primaryTrait = 'Grail Hunter';
      secondaryTrait = 'Investor';
    } else if (averageValue >= 60) {
      primaryTrait = 'Premium Collector';
      secondaryTrait = 'Curator';
    } else if (pops.length >= 100) {
      primaryTrait = 'Completionist';
      secondaryTrait = 'Dedicated Collector';
    } else {
      primaryTrait = 'Growing Collector';
      secondaryTrait = 'Explorer';
    }

    return AtlasCollectorDNA(
      primaryTrait: primaryTrait,
      secondaryTrait: secondaryTrait,
      confidence: 94,
      summary: 'Atlas is continuously learning your collecting habits.',
    );
  }
}
