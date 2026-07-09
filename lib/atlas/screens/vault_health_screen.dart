import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/app_state.dart';
import '../../widgets/vault/atlas_evidence_card.dart';
import '../../widgets/atlas/atlas_greeting_card.dart';
import '../../widgets/vault/vault_scroll_view.dart';
import '../repositories/vault_repository.dart';

class VaultHealthScreen extends StatelessWidget {
  const VaultHealthScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    const repository = VaultRepository();

    final allPops = repository.allPops(appState);

    final duplicateGroups =
        repository.duplicatePopGroups(appState).length;

    final missingValues =
        allPops.where((p) => p.value <= 0).length;

    final missingImages =
        allPops.where((p) => p.imageUrl.isEmpty).length;

    final missingCollectorIdentity =
        allPops.where((p) =>
        p.variant == 'Common' &&
            p.retailExclusive == 'None' &&
            p.eventSticker == 'None' &&
            p.limitedEdition == 'None' &&
            p.signature == 'Unsigned').length;

    final score = _calculateHealth(
      total: allPops.length,
      duplicates: duplicateGroups,
      missingValues: missingValues,
      missingImages: missingImages,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Atlas Vault Health',
        ),
      ),
      body: VaultScrollView(
        children: [
          AtlasGreetingCard(
            title: 'Vault Health ${score.toStringAsFixed(0)}%',
            message: _assessment(score),
            icon: Icons.health_and_safety,
          ),

          const SizedBox(height: 24),

          _HealthTile(
            title: 'Duplicate Groups',
            value: duplicateGroups.toString(),
            icon: Icons.copy,
            healthy: duplicateGroups == 0,
          ),

          _HealthTile(
            title: 'Missing Values',
            value: missingValues.toString(),
            icon: Icons.attach_money,
            healthy: missingValues == 0,
          ),

          _HealthTile(
            title: 'Missing Images',
            value: missingImages.toString(),
            icon: Icons.image,
            healthy: missingImages == 0,
          ),

          _HealthTile(
            title: 'Collector Identity Incomplete',
            value: missingCollectorIdentity.toString(),
            icon: Icons.badge,
            healthy: missingCollectorIdentity == 0,
          ),

          const SizedBox(height: 24),

          AtlasEvidenceCard(
            title: 'Atlas Evidence',
            evidence: [
              '$duplicateGroups duplicate groups found.',
              '$missingValues Pops missing estimated values.',
              '$missingImages Pops missing images.',
              '$missingCollectorIdentity Pops have incomplete collector identity.',
            ],
          ),
        ],
      ),
    );
  }

  double _calculateHealth({
    required int total,
    required int duplicates,
    required int missingValues,
    required int missingImages,
  }) {
    if (total == 0) {
      return 100;
    }

    final issues =
        duplicates + missingValues + missingImages;

    return (100 - ((issues / total) * 100))
        .clamp(0, 100);
  }

  String _assessment(double score) {
    if (score >= 95) {
      return 'Excellent. Atlas considers this Vault to be in outstanding condition.';
    }

    if (score >= 85) {
      return 'Very Good. A few improvements will strengthen your Vault.';
    }

    if (score >= 70) {
      return 'Good. Atlas recommends reviewing missing information.';
    }

    if (score >= 50) {
      return 'Fair. Several issues are reducing data quality.';
    }

    return 'Needs Attention. Atlas recommends improving your Vault before relying on analytics.';
  }
}

class _HealthTile extends StatelessWidget {
  const _HealthTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.healthy,
  });

  final String title;
  final String value;
  final IconData icon;
  final bool healthy;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(
          healthy ? 'Healthy' : 'Needs Attention',
        ),
        trailing: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}