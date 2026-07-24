import '../../../models/pop.dart';

class AtlasKnowledge {
  const AtlasKnowledge({
    required this.totalPops,
    required this.totalValue,
    required this.averageValue,
    required this.highestValue,
    required this.signedCount,
    required this.chaseCount,
    required this.limitedEditionCount,
    required this.exclusiveCount,
    required this.wishlistCount,
  });

  final int totalPops;
  final double totalValue;
  final double averageValue;
  final double highestValue;

  final int signedCount;
  final int chaseCount;
  final int limitedEditionCount;
  final int exclusiveCount;
  final int wishlistCount;
}

class AtlasKnowledgeEngine {
  const AtlasKnowledgeEngine();

  AtlasKnowledge analyze(
      List<Pop> pops,
      ) {
    final totalPops = pops.length;

    final totalValue = pops.fold<double>(
      0,
          (sum, pop) => sum + pop.value,
    );

    final averageValue =
    totalPops == 0
        ? 0.0
        : totalValue / totalPops;

    final highestValue = pops.isEmpty
        ? 0.0
        : pops
        .map((p) => p.value)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    final signedCount =
        pops.where((p) => p.signature != 'Unsigned').length;

    final chaseCount =
        pops.where((p) => p.variant == 'Chase').length;

    final limitedEditionCount =
        pops.where((p) => p.limitedEdition != 'None').length;

    final exclusiveCount =
        pops.where((p) => p.retailExclusive != 'None').length;

    final wishlistCount =
        pops.where((p) => p.isWishlist).length;

    return AtlasKnowledge(
      totalPops: totalPops,
      totalValue: totalValue,
      averageValue: averageValue,
      highestValue: highestValue,
      signedCount: signedCount,
      chaseCount: chaseCount,
      limitedEditionCount: limitedEditionCount,
      exclusiveCount: exclusiveCount,
      wishlistCount: wishlistCount,
    );
  }
}