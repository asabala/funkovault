import '../../models/pop.dart';

class AtlasMemory {
  const AtlasMemory({
    required this.title,
    required this.message,
    required this.footer,
    required this.category,
    required this.priority,
  });

  final String title;
  final String message;
  final String footer;
  final String category;
  final int priority;
}

class AtlasMemoryEngine {
  const AtlasMemoryEngine();

  AtlasMemory remember({
    required List<Pop> pops,
  }) {
    if (pops.isEmpty) {
      return const AtlasMemory(
        title: 'Your Story Begins Here',
        message:
        'Add your first collectible and Atlas will begin remembering your journey.',
        footer: 'Every collection starts with one.',
        category: 'beginning',
        priority: 100,
      );
    }

    final totalPops = pops.length;

    final grails =
        pops.where((pop) => pop.value >= 100).length;

    final signed =
        pops.where((pop) => pop.signature != 'Unsigned').length;

    final chase =
        pops.where((pop) => pop.variant == 'Chase').length;

    if (totalPops >= 100) {
      return AtlasMemory(
        title: 'Century Collector',
        message:
        'Your Vault has reached $totalPops collectibles. That is a milestone worth remembering.',
        footer: 'Atlas is tracking your collecting legacy.',
        category: 'milestone',
        priority: 95,
      );
    }

    if (grails > 0) {
      return AtlasMemory(
        title: 'Grail Memory',
        message:
        'Atlas found $grails grail-level collectible${grails == 1 ? '' : 's'} in your Vault.',
        footer: 'Great collections are built one meaningful piece at a time.',
        category: 'grail',
        priority: 90,
      );
    }

    if (signed > 0) {
      return AtlasMemory(
        title: 'Signed Collection',
        message:
        'You have $signed signed collectible${signed == 1 ? '' : 's'} documented in your Vault.',
        footer: 'Signatures turn collectibles into moments.',
        category: 'signature',
        priority: 80,
      );
    }

    if (chase > 0) {
      return AtlasMemory(
        title: 'Chase Hunter',
        message:
        'Your Vault includes $chase Chase collectible${chase == 1 ? '' : 's'}.',
        footer: 'The hunt is part of the story.',
        category: 'variant',
        priority: 70,
      );
    }

    return AtlasMemory(
      title: 'Growing Vault',
      message:
      'Your Vault currently holds $totalPops collectible${totalPops == 1 ? '' : 's'}. Atlas will remember the milestones as it grows.',
      footer: 'Every collection tells a story.',
      category: 'growth',
      priority: 60,
    );
  }
}