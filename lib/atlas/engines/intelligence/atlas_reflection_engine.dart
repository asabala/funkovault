import '../../../models/pop.dart';

class AtlasReflection {
  const AtlasReflection({
    required this.title,
    required this.message,
    required this.tone,
  });

  final String title;
  final String message;
  final String tone;
}

class AtlasReflectionEngine {
  const AtlasReflectionEngine();

  AtlasReflection reflect({
    required String collectorName,
    required List<Pop> pops,
  }) {
    final hour = DateTime.now().hour;
    final totalPops = pops.length;

    final missingValues =
        pops.where((pop) => pop.value <= 0).length;

    final grails =
        pops.where((pop) => pop.value >= 100).length;

    if (hour >= 18) {
      return AtlasReflection(
        title: 'Good Evening, $collectorName',
        message: totalPops == 0
            ? 'Your Vault is ready when you are. Add your first collectible to begin your journey.'
            : 'Today your Vault holds $totalPops collectibles. Atlas is ready to help you review, reflect, and prepare for tomorrow.',
        tone: 'reflection',
      );
    }

    if (hour >= 12) {
      return AtlasReflection(
        title: 'Good Afternoon, $collectorName',
        message: missingValues > 0
            ? 'Atlas noticed $missingValues collectibles still need estimated values. A quick update will improve your Vault intelligence.'
            : 'Your collection is looking strong. Atlas is monitoring your Vault and ready when you are.',
        tone: 'guidance',
      );
    }

    return AtlasReflection(
      title: 'Good Morning, $collectorName',
      message: grails > 0
          ? 'Atlas found $grails grail-level collectible${grails == 1 ? '' : 's'} in your Vault. Today is a good day to keep building your legacy.'
          : 'Atlas is online. Your collection is ready, and today’s mission is waiting.',
      tone: 'morning',
    );
  }
}