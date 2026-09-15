import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../atlas/repositories/vault_repository.dart';
import '../../services/app_state.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_icons.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/atlas_glass_panel.dart';
import '../../widgets/vault/vault_scroll_view.dart';

class AtlasInsightsScreen extends StatelessWidget {
  const AtlasInsightsScreen({super.key});

  String _formatCurrency(double value) {
    return '\$${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    const repository = VaultRepository();

    final ownerLeaderboard = repository.ownerLeaderboard(appState);

    final categoryCounts = repository.categoryCounts(appState).entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final categoryValues = repository.categoryValues(appState).entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topPops = repository.mostValuablePops(appState);

    return Scaffold(
      appBar: AppBar(title: const Text('Atlas Insights')),
      body: VaultScrollView(
        children: [
          AtlasGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  AtlasIcons.trend,
                  color: AtlasColors.vaultGold,
                  size: 34,
                ),
                const SizedBox(height: AtlasSpacing.md),
                Text(
                  'Collection Intelligence',
                  style: AtlasTypography.headingLarge,
                ),
                const SizedBox(height: AtlasSpacing.sm),
                Text(
                  'Track owners, categories, value, and your strongest collection trends.',
                  style: AtlasTypography.bodyMedium.copyWith(
                    color: AtlasColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AtlasSpacing.lg),

          _InsightListCard(
            title: 'Owner Leaderboard',
            items: ownerLeaderboard
                .take(6)
                .map(
                  (entry) => _InsightItem(
                    title: entry.key,
                    value: _formatCurrency(entry.value),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: AtlasSpacing.lg),

          _InsightListCard(
            title: 'Top Categories',
            items: categoryCounts
                .take(6)
                .map(
                  (entry) => _InsightItem(
                    title: entry.key,
                    value: '${entry.value} Pops',
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: AtlasSpacing.lg),

          _InsightListCard(
            title: 'Category Values',
            items: categoryValues
                .take(6)
                .map(
                  (entry) => _InsightItem(
                    title: entry.key,
                    value: _formatCurrency(entry.value),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: AtlasSpacing.lg),

          _InsightListCard(
            title: 'Top Valuable Pops',
            items: topPops
                .take(6)
                .map(
                  (pop) => _InsightItem(
                    title: pop.name,
                    value: _formatCurrency(pop.value),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _InsightListCard extends StatelessWidget {
  const _InsightListCard({required this.title, required this.items});

  final String title;
  final List<_InsightItem> items;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AtlasTypography.headingSmall),
          const SizedBox(height: AtlasSpacing.md),
          if (items.isEmpty)
            AtlasGlassPanel(
              child: Text(
                'No data available yet.',
                style: AtlasTypography.bodyMedium.copyWith(
                  color: AtlasColors.textSecondary,
                ),
              ),
            )
          else
            Column(
              children: List.generate(items.length, (index) {
                final item = items[index];

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == items.length - 1 ? 0 : AtlasSpacing.sm,
                  ),
                  child: AtlasGlassPanel(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 15,
                          backgroundColor: AtlasColors.vaultGold.withValues(
                            alpha: 0.18,
                          ),
                          child: Text(
                            '${index + 1}',
                            style: AtlasTypography.bodySmall.copyWith(
                              color: AtlasColors.vaultGold,
                            ),
                          ),
                        ),
                        const SizedBox(width: AtlasSpacing.md),
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AtlasTypography.bodyMedium,
                          ),
                        ),
                        Text(
                          item.value,
                          style: AtlasTypography.bodySmall.copyWith(
                            color: AtlasColors.vaultGold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }
}

class _InsightItem {
  const _InsightItem({required this.title, required this.value});

  final String title;
  final String value;
}
