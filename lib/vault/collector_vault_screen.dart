import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../atlas/repositories/vault_repository.dart';
import '../services/app_state.dart';
import '../theme/atlas_colors.dart';
import '../theme/atlas_icons.dart';
import '../theme/atlas_spacing.dart';
import '../theme/atlas_typography.dart';
import '../widgets/atlas_section_card.dart';
import '../widgets/vault/vault_summary_card.dart';
import '../widgets/vault_scroll_view.dart';

class CollectorVaultScreen extends StatelessWidget {
  const CollectorVaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    const repository = VaultRepository();

    final allPops = repository.allPops(appState);

    final duplicateCount =
        repository.duplicatePopGroups(appState).length;

    final missingValueCount =
        allPops.where((pop) => pop.value <= 0).length;

    final health = _calculateVaultHealth(
      totalPops: allPops.length,
      duplicateCount: duplicateCount,
      missingValueCount: missingValueCount,
    );

    final totalValue = repository.totalValue(appState);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Collector's Vault"),
      ),
      body: VaultScrollView(
        children: [
          Text(
            "Welcome back, Arthur",
            style: AtlasTypography.headingLarge,
          ),

          const SizedBox(height: AtlasSpacing.sm),

          Text(
            'Your collection is protected, organized, and ready for review.',
            style: AtlasTypography.bodyMedium.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),

          const SizedBox(height: AtlasSpacing.lg),

          VaultSummaryCard(
            totalPops: allPops.length,
            totalValue: totalValue,
            health: health,
          ),

          const SizedBox(height: AtlasSpacing.lg),

          AtlasSectionCard(
            title: 'Vault Collections',
            icon: AtlasIcons.vault,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _VaultCollectionTile(
                  title: 'Entire Collection',
                  subtitle: 'View every collectible in your Vault.',
                  icon: AtlasIcons.collection,
                ),
                _VaultCollectionTile(
                  title: 'Personal Collection',
                  subtitle: 'Your main collector profile.',
                  icon: AtlasIcons.atlas,
                ),
                _VaultCollectionTile(
                  title: 'Wishlist',
                  subtitle: 'Items you are hunting for.',
                  icon: AtlasIcons.wishlist,
                ),
              ],
            ),
          ),

          const SizedBox(height: AtlasSpacing.lg),

          AtlasSectionCard(
            title: 'Atlas Vault Insight',
            icon: AtlasIcons.intelligence,
            child: Text(
              allPops.isEmpty
                  ? 'Add your first collectible to begin building your Vault intelligence.'
                  : 'Atlas is monitoring your Vault health, value, and collection growth.',
              style: AtlasTypography.bodyMedium,
            ),
          ),
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

class _VaultCollectionTile extends StatelessWidget {
  const _VaultCollectionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: AtlasColors.vaultGold,
      ),
      title: Text(
        title,
        style: AtlasTypography.headingSmall,
      ),
      subtitle: Text(
        subtitle,
        style: AtlasTypography.bodySmall,
      ),
      trailing: const Icon(
        Icons.chevron_right,
      ),
    );
  }
}