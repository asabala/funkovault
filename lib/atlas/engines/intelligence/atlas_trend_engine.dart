import '../../../models/pop.dart';

class AtlasTrendReport {
  const AtlasTrendReport({
    required this.totalPops,
    required this.totalValue,
    required this.averageValue,
    required this.highestValue,
  });

  final int totalPops;
  final double totalValue;
  final double averageValue;
  final double highestValue;
}

class AtlasTrendEngine {
  const AtlasTrendEngine();

  AtlasTrendReport analyze(List<Pop> pops) {
    final totalPops = pops.length;

    final totalValue = pops.fold<double>(0, (total, pop) => total + pop.value);

    final double averageValue = totalPops == 0 ? 0.0 : totalValue / totalPops;

    final double highestValue = pops.isEmpty
        ? 0.0
        : pops
              .map((pop) => pop.value)
              .reduce((a, b) => a > b ? a : b)
              .toDouble();

    return AtlasTrendReport(
      totalPops: totalPops,
      totalValue: totalValue,
      averageValue: averageValue,
      highestValue: highestValue,
    );
  }
}
