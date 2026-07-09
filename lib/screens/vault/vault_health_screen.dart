import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'entire_vault_screen.dart';
import '../../atlas/repositories/vault_repository.dart';
import '../../services/app_state.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/atlas_glass_panel.dart';
import '../../widgets/vault/advanced_vault_health_preview.dart';

class VaultHealthScreen extends StatelessWidget {
  const VaultHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    const repository = VaultRepository();

    final pops = repository.allPops(appState);
    final profile = appState.collectorProfile;
    final totalValue = repository.totalValue(appState);
    final duplicateGroupCount = repository.duplicatePopGroups(appState).length;
    final needsValueCount = pops.where((pop) => pop.value <= 0).length;

    final healthScore = _calculateVaultHealth(
      totalPops: pops.length,
      duplicateCount: duplicateGroupCount,
      missingValueCount: needsValueCount,
    );

    final priority = _priorityLabel(
      needsValueCount: needsValueCount,
      duplicateGroupCount: duplicateGroupCount,
      healthScore: healthScore,
    );

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
                    Text(
                      'Vault Health',
                      style: AtlasTypography.headingLarge,
                    ),
                    const SizedBox(height: AtlasSpacing.sm),
                    Text(
                      'Review the health of your collection and see what needs attention first.',
                      style: AtlasTypography.bodyMedium.copyWith(
                        color: AtlasColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AtlasSpacing.lg),
                    AtlasGlassPanel(
                      child: Row(
                        children: [
                          Expanded(
                            child: _VaultHealthMetricTile(
                              label: 'Duplicates',
                              value: duplicateGroupCount.toString(),
                              icon: Icons.content_copy_rounded,
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
                            child: _VaultHealthSummaryItem(
                              label: 'Value',
                              value: '\$${totalValue.toStringAsFixed(0)}',
                            ),
                          ),
                          Expanded(
                            child: _VaultHealthSummaryItem(
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
                    Text(
                      'Health Summary',
                      style: AtlasTypography.headingSmall,
                    ),
                    const SizedBox(height: AtlasSpacing.sm),
                    Text(
                      'Atlas checks missing values and duplicate groups to estimate vault health.',
                      style: AtlasTypography.bodyMedium.copyWith(
                        color: AtlasColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AtlasSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: _VaultHealthMetricTile(
                            label: 'Health Score',
                            value: '${healthScore.round()}%',
                            icon: Icons.favorite_rounded,
                          ),
                        ),
                        const SizedBox(width: AtlasSpacing.sm),
                        Expanded(
                          child: _VaultHealthMetricTile(
                            label: 'Priority',
                            value: priority,
                            icon: Icons.priority_high_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AtlasSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: _VaultHealthMetricTile(
                            label: 'Needs Value',
                            value: needsValueCount.toString(),
                            icon: Icons.attach_money_rounded,
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
                          child: _VaultHealthMetricTile(
                            label: 'Duplicates',
                            value: duplicateGroupCount.toString(),
                            icon: Icons.content_copy_rounded,
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
                isPremium: profile.isPremium,
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
                      _AdvancedVaultHealthTeaserHeader(),
                      SizedBox(height: AtlasSpacing.md),
                      _AdvancedVaultHealthTeaserItem(
                        icon: Icons.warning_amber_rounded,
                        title: 'Risk Score',
                        message:
                        'See which parts of your collection may need the most attention.',
                      ),
                      SizedBox(height: AtlasSpacing.sm),
                      _AdvancedVaultHealthTeaserItem(
                        icon: Icons.content_copy_rounded,
                        title: 'Duplicate Intelligence',
                        message:
                        'Review possible duplicates with smarter context for variants, stickers, exclusives, and signed Pops.',
                      ),
                      SizedBox(height: AtlasSpacing.sm),
                      _AdvancedVaultHealthTeaserItem(
                        icon: Icons.attach_money_rounded,
                        title: 'Value Cleanup Priority',
                        message:
                        'Prioritize missing values based on impact instead of cleaning everything randomly.',
                      ),
                      SizedBox(height: AtlasSpacing.sm),
                      _AdvancedVaultHealthTeaserItem(
                        icon: Icons.show_chart_rounded,
                        title: 'Collection Health Trends',
                        message:
                        'Track how your vault health improves as your collection becomes cleaner.',
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

  double _calculateVaultHealth({
    required int totalPops,
    required int duplicateCount,
    required int missingValueCount,
  }) {
    if (totalPops == 0) {
      return 100;
    }

    final issueCount = duplicateCount + missingValueCount;
    final score = 100 - ((issueCount / totalPops) * 100);

    return score.clamp(0, 100);
  }

  String _priorityLabel({
    required int needsValueCount,
    required int duplicateGroupCount,
    required double healthScore,
  }) {
    final issueCount = needsValueCount + duplicateGroupCount;

    if (issueCount == 0 && healthScore >= 95) {
      return 'Clean';
    }

    if (healthScore >= 85 && issueCount <= 10) {
      return 'Low';
    }

    if (healthScore >= 65) {
      return 'Medium';
    }

    return 'High';
  }
}

class _VaultHealthSummaryItem extends StatelessWidget {
  const _VaultHealthSummaryItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AtlasTypography.headingSmall.copyWith(
            color: AtlasColors.vaultGold,
          ),
        ),
        const SizedBox(height: AtlasSpacing.xs),
        Text(
          label,
          style: AtlasTypography.bodySmall.copyWith(
            color: AtlasColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _AdvancedVaultHealthTeaserHeader extends StatelessWidget {
  const _AdvancedVaultHealthTeaserHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.workspace_premium_rounded,
          color: AtlasColors.vaultGold,
        ),
        const SizedBox(width: AtlasSpacing.sm),
        Expanded(
          child: Text(
            'Advanced Vault Health',
            style: AtlasTypography.headingSmall,
          ),
        ),
      ],
    );
  }
}

class _AdvancedVaultHealthTeaserItem extends StatelessWidget {
  const _AdvancedVaultHealthTeaserItem({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassPanel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AtlasColors.vaultGold,
            size: 20,
          ),
          const SizedBox(width: AtlasSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AtlasTypography.bodyMedium.copyWith(
                    color: AtlasColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: AtlasTypography.bodySmall.copyWith(
                    color: AtlasColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
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
        children: const [
          _VaultHealthExplanationHeader(),
          SizedBox(height: AtlasSpacing.md),
          _VaultHealthExplanationItem(
            icon: Icons.favorite_rounded,
            title: 'Starts at 100%',
            message:
            'A clean vault starts with a full health score before issues are counted.',
          ),
          SizedBox(height: AtlasSpacing.sm),
          _VaultHealthExplanationItem(
            icon: Icons.attach_money_rounded,
            title: 'Missing values lower the score',
            message:
            'Pops without values make the vault less complete and reduce the health score.',
          ),
          SizedBox(height: AtlasSpacing.sm),
          _VaultHealthExplanationItem(
            icon: Icons.content_copy_rounded,
            title: 'Duplicate review groups lower the score',
            message:
            'Possible duplicate groups are counted as review items until they are confirmed as variants or cleaned up.',
          ),
          SizedBox(height: AtlasSpacing.sm),
          _VaultHealthExplanationItem(
            icon: Icons.trending_up_rounded,
            title: 'Higher score means a cleaner vault',
            message:
            'A higher score means fewer missing values and fewer possible duplicate review groups.',
          ),
        ],
      ),
    );
  }
}

class _VaultHealthExplanationHeader extends StatelessWidget {
  const _VaultHealthExplanationHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.info_outline_rounded,
          color: AtlasColors.vaultGold,
        ),
        const SizedBox(width: AtlasSpacing.sm),
        Expanded(
          child: Text(
            'How Vault Health Works',
            style: AtlasTypography.bodyMedium.copyWith(
              color: AtlasColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _VaultHealthExplanationItem extends StatelessWidget {
  const _VaultHealthExplanationItem({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AtlasColors.vaultGold,
          size: 20,
        ),
        const SizedBox(width: AtlasSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AtlasTypography.bodySmall.copyWith(
                  color: AtlasColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                message,
                style: AtlasTypography.bodySmall.copyWith(
                  color: AtlasColors.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VaultHealthActionGuide extends StatelessWidget {
  const _VaultHealthActionGuide();

  @override
  Widget build(BuildContext context) {
    return AtlasGlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _VaultHealthActionStep(
            number: '1',
            title: 'Add missing values first',
            message:
            'Missing values make it harder for Atlas to estimate your collection strength.',
          ),
          SizedBox(height: AtlasSpacing.sm),
          _VaultHealthActionStep(
            number: '2',
            title: 'Review duplicate groups',
            message:
            'Duplicates are review groups only. Check variants, Chase versions, stickers, exclusives, and signatures before making changes.',
          ),
          SizedBox(height: AtlasSpacing.sm),
          _VaultHealthActionStep(
            number: '3',
            title: 'Protect important variants',
            message:
            'Variant details, sticker details, limited editions, and signed Pops should stay clearly labeled.',
          ),
        ],
      ),
    );
  }
}

class _VaultHealthActionStep extends StatelessWidget {
  const _VaultHealthActionStep({
    required this.number,
    required this.title,
    required this.message,
  });

  final String number;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AtlasColors.vaultGold.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AtlasColors.vaultGold.withValues(alpha: 0.34),
            ),
          ),
          child: Text(
            number,
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.vaultGold,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: AtlasSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AtlasTypography.bodyMedium.copyWith(
                  color: AtlasColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                message,
                style: AtlasTypography.bodySmall.copyWith(
                  color: AtlasColors.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VaultHealthMetricTile extends StatelessWidget {
  const _VaultHealthMetricTile({
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isTappable = onTap != null;

    final tile = AtlasGlassPanel(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: AtlasColors.vaultGold,
                    size: 20,
                  ),
                  if (isTappable) ...[
                    const Spacer(),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AtlasColors.vaultGold,
                      size: 20,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AtlasSpacing.sm),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AtlasTypography.headingSmall.copyWith(
                  color: AtlasColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AtlasTypography.bodySmall.copyWith(
                  color: AtlasColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return tile;
  }
}