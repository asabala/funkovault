import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'entire_vault_screen.dart';
import '../../atlas/repositories/vault_repository.dart';
import '../../security/auth_provider.dart';
import '../../services/app_state.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../vault/health/vault_health_engine.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/atlas_glass_panel.dart';
import '../../widgets/atlas/atlas_stat_tile.dart';
import '../../widgets/atlas/components/atlas_action_row.dart';
import '../../widgets/atlas/components/atlas_insight_panel.dart';
import '../../widgets/atlas/components/atlas_section_header.dart';
import '../../widgets/vault/advanced_vault_health_preview.dart';

class VaultHealthScreen extends StatelessWidget {
  const VaultHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final authProvider = context.watch<AuthProvider>();

    const repository = VaultRepository();
    const vaultHealthEngine = VaultHealthEngine();

    final pops = repository.allPops(appState);
    final vaultHealth = vaultHealthEngine.calculate(pops);

    final totalValue = vaultHealth.totalValue;
    final duplicateGroupCount =
        vaultHealth.duplicateGroupCount;
    final needsValueCount =
        vaultHealth.needsValueCount;
    final healthScore =
        vaultHealth.healthScore;
    final priority =
        vaultHealth.priority;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vault Health'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AtlasSpacing.md,
            AtlasSpacing.md,
            AtlasSpacing.md,
            100,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AtlasGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AtlasSectionHeader(
                      title: 'Vault Health',
                      subtitle:
                      'Review the health of your collection and see what needs attention first.',
                      icon: Icons.health_and_safety_rounded,
                      titleStyle: AtlasTypography.headingLarge,
                    ),
                    const SizedBox(height: AtlasSpacing.lg),
                    AtlasGlassPanel(
                      child: Row(
                        children: [
                          Expanded(
                            child: AtlasStatTile(
                              label: 'Duplicates',
                              value: duplicateGroupCount.toString(),
                              icon: Icons.content_copy_rounded,
                              layout: AtlasStatTileLayout.leading,
                              onTap: duplicateGroupCount > 0
                                  ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const EntireVaultScreen(
                                      initialFilterKey: 'duplicates',
                                    ),
                                  ),
                                );
                              }
                                  : null,
                            ),
                          ),
                          Expanded(
                            child: AtlasStatTile(
                              label: 'Value',
                              value: '\$${totalValue.toStringAsFixed(0)}',
                            ),
                          ),
                          Expanded(
                            child: AtlasStatTile(
                              label: 'Health',
                              value: '${healthScore.round()}%',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AtlasSpacing.lg),
              AtlasGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AtlasSectionHeader(
                      title: 'Health Summary',
                      subtitle:
                      'Atlas checks missing values and duplicate groups to estimate vault health.',
                      icon: Icons.monitor_heart_rounded,
                    ),
                    const SizedBox(height: AtlasSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: AtlasStatTile(
                            label: 'Health Score',
                            value: '${healthScore.round()}%',
                            icon: Icons.favorite_rounded,
                            layout: AtlasStatTileLayout.leading,
                            showPanel: true,
                          ),
                        ),
                        const SizedBox(width: AtlasSpacing.sm),
                        Expanded(
                          child: AtlasStatTile(
                            label: 'Priority',
                            value: priority,
                            icon: Icons.priority_high_rounded,
                            layout: AtlasStatTileLayout.leading,
                            showPanel: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AtlasSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: AtlasStatTile(
                            label: 'Needs Value',
                            value: needsValueCount.toString(),
                            icon: Icons.attach_money_rounded,
                            layout: AtlasStatTileLayout.leading,
                            showPanel: true,
                            onTap: needsValueCount > 0
                                ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const EntireVaultScreen(
                                    initialFilterKey: 'needsValue',
                                  ),
                                ),
                              );
                            }
                                : null,
                          ),
                        ),
                        const SizedBox(width: AtlasSpacing.sm),
                        Expanded(
                          child: AtlasStatTile(
                            label: 'Duplicates',
                            value: duplicateGroupCount.toString(),
                            icon: Icons.content_copy_rounded,
                            layout: AtlasStatTileLayout.leading,
                            showPanel: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AtlasSpacing.lg),
                    const _VaultHealthActionGuide(),
                    const SizedBox(height: AtlasSpacing.lg),
                    const _VaultHealthScoreExplanation(),
                  ],
                ),
              ),
              const SizedBox(height: AtlasSpacing.lg),
              AdvancedVaultHealthPreview(
                isPremium: authProvider.isPremium,
                onUpgrade: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Premium upgrade flow is coming soon.'),
                    ),
                  );
                },
                child: AtlasGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      AtlasSectionHeader(
                        title: 'Advanced Vault Health',
                        subtitle:
                        'Premium intelligence for deeper vault analysis and cleanup prioritization.',
                        icon: Icons.workspace_premium_rounded,
                        accentColor: AtlasColors.vaultGold,
                      ),
                      SizedBox(height: AtlasSpacing.md),

                      AtlasActionRow(
                        title: 'Risk Score',
                        description:
                        'See which parts of your collection may need the most attention.',
                        icon: Icons.warning_amber_rounded,
                        accentColor: AtlasColors.vaultGold,
                        showChevron: false,
                        compact: true,
                      ),

                      SizedBox(height: AtlasSpacing.sm),

                      AtlasActionRow(
                        title: 'Duplicate Intelligence',
                        description:
                        'Review possible duplicates with smarter context for variants, stickers, exclusives, and signed Pops.',
                        icon: Icons.content_copy_rounded,
                        accentColor: AtlasColors.vaultGold,
                        showChevron: false,
                        compact: true,
                      ),

                      SizedBox(height: AtlasSpacing.sm),

                      AtlasActionRow(
                        title: 'Value Cleanup Priority',
                        description:
                        'Prioritize missing values based on impact instead of cleaning everything randomly.',
                        icon: Icons.attach_money_rounded,
                        accentColor: AtlasColors.vaultGold,
                        showChevron: false,
                        compact: true,
                      ),

                      SizedBox(height: AtlasSpacing.sm),

                      AtlasActionRow(
                        title: 'Collection Health Trends',
                        description:
                        'Track how your vault health improves as your collection becomes cleaner.',
                        icon: Icons.show_chart_rounded,
                        accentColor: AtlasColors.vaultGold,
                        showChevron: false,
                        compact: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VaultHealthScoreExplanation extends StatelessWidget {
  const _VaultHealthScoreExplanation();

  @override
  Widget build(BuildContext context) {
    return AtlasGlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AtlasInsightPanel(
            eyebrow: 'Vault Health',
            title: 'How Vault Health Works',
            message:
            'Atlas starts from a clean-vault baseline and lowers the score when important collection data still needs attention.',
            icon: Icons.info_outline_rounded,
            tone: AtlasInsightPanelTone.intelligence,
          ),
          const SizedBox(
            height: AtlasSpacing.md,
          ),
          const AtlasActionRow(
            title: 'Starts at 100%',
            description:
            'A clean vault starts with a full health score before issues are counted.',
            icon: Icons.favorite_rounded,
            accentColor: AtlasColors.vaultGold,
            showChevron: false,
            compact: true,
          ),
          const SizedBox(
            height: AtlasSpacing.sm,
          ),
          const AtlasActionRow(
            title: 'Missing values lower the score',
            description:
            'Pops without values make the vault less complete and reduce the health score.',
            icon: Icons.attach_money_rounded,
            accentColor: AtlasColors.vaultGold,
            showChevron: false,
            compact: true,
          ),
          const SizedBox(
            height: AtlasSpacing.sm,
          ),
          const AtlasActionRow(
            title: 'Duplicate review groups lower the score',
            description:
            'Possible duplicate groups are counted as review items until they are confirmed as variants or cleaned up.',
            icon: Icons.content_copy_rounded,
            accentColor: AtlasColors.vaultGold,
            showChevron: false,
            compact: true,
          ),
          const SizedBox(
            height: AtlasSpacing.sm,
          ),
          const AtlasActionRow(
            title: 'Higher score means a cleaner vault',
            description:
            'A higher score means fewer missing values and fewer possible duplicate review groups.',
            icon: Icons.trending_up_rounded,
            accentColor: AtlasColors.vaultGold,
            showChevron: false,
            compact: true,
          ),
        ],
      ),
    );
  }
}

class _VaultHealthActionGuide extends StatelessWidget {
  const _VaultHealthActionGuide();

  @override
  Widget build(BuildContext context) {
    return const AtlasGlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AtlasSectionHeader(
            title: 'Recommended Next Steps',
            subtitle:
            'Work through the highest-impact vault cleanup opportunities first.',
            icon: Icons.route_rounded,
          ),
          SizedBox(
            height: AtlasSpacing.md,
          ),
          AtlasActionRow(
            title: '1. Add missing values first',
            description:
            'Missing values make it harder for Atlas to estimate your collection strength.',
            icon: Icons.attach_money_rounded,
            accentColor: AtlasColors.vaultGold,
            showChevron: false,
            compact: true,
          ),
          SizedBox(
            height: AtlasSpacing.sm,
          ),
          AtlasActionRow(
            title: '2. Review duplicate groups',
            description:
            'Duplicates are review groups only. Check variants, Chase versions, stickers, exclusives, and signatures before making changes.',
            icon: Icons.content_copy_rounded,
            accentColor: AtlasColors.vaultGold,
            showChevron: false,
            compact: true,
          ),
          SizedBox(
            height: AtlasSpacing.sm,
          ),
          AtlasActionRow(
            title: '3. Protect important variants',
            description:
            'Variant details, sticker details, limited editions, and signed Pops should stay clearly labeled.',
            icon: Icons.verified_user_outlined,
            accentColor: AtlasColors.vaultGold,
            showChevron: false,
            compact: true,
          ),
        ],
      ),
    );
  }
}