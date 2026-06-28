import '../../services/app_state.dart';

class AtlasDailyBriefing {
  const AtlasDailyBriefing({
    required this.title,
    required this.summary,
    required this.message,
  });

  final String title;
  final String summary;
  final String message;
}

class AtlasDailyBriefingEngine {
  const AtlasDailyBriefingEngine();

  String _greeting(String collectorName) {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good Morning $collectorName';
    }

    if (hour < 17) {
      return 'Good Afternoon $collectorName';
    }

    return 'Good Evening $collectorName';
  }

  double _calculateVaultHealth({
    required int totalPops,
    required int duplicateGroups,
    required int missingValues,
  }) {
    if (totalPops == 0) {
      return 100;
    }

    final issueCount =
        duplicateGroups + missingValues;

    return (100 - ((issueCount / totalPops) * 100))
        .clamp(0, 100);
  }

  AtlasDailyBriefing build(
      AppState appState, {
        String collectorName = 'Collector',
      }) {
    final pops = appState.selectedCollectionPops;
    final total = pops.length;
    final greeting = _greeting(collectorName);

    final missingValues =
        pops.where((p) => p.value <= 0).length;

    final duplicates = <String, int>{};

    for (final pop in pops) {
      final key = pop.collectorIdentity;

      duplicates[key] =
          (duplicates[key] ?? 0) + 1;
    }

    final duplicateGroups =
        duplicates.values.where((count) => count > 1).length;

    final vaultHealth = _calculateVaultHealth(
      totalPops: total,
      duplicateGroups: duplicateGroups,
      missingValues: missingValues,
    );

    final summary =
        '$total Pops • Health ${vaultHealth.toStringAsFixed(0)}%';

    if (total == 0) {
      return AtlasDailyBriefing(
        title: 'Welcome $collectorName',
        summary: '0 Pops • Health 100%',
        message:
        'Your Vault is empty. Add your first Funko Pop to begin building your collection.',
      );
    }

    if (missingValues > 0) {
      return AtlasDailyBriefing(
        title: greeting,
        summary:
        '$summary • $missingValues Missing Values',
        message:
        'Completing missing values will improve Atlas accuracy and strengthen your Vault Health.',
      );
    }

    if (duplicateGroups > 0) {
      return AtlasDailyBriefing(
        title: greeting,
        summary:
        '$summary • $duplicateGroups Duplicate Groups',
        message:
        'Atlas detected possible duplicate groups. Review them when you have time.',
      );
    }

    return AtlasDailyBriefing(
      title: greeting,
      summary: summary,
      message:
      'Everything looks great. Atlas has no critical recommendations today. Enjoy collecting!',
    );
  }
}