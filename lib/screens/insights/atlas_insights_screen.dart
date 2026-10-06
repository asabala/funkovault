import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../atlas/repositories/vault_repository.dart';
import '../../atlas/taxonomy/services/atlas_vault_room_classifier.dart';
import '../../models/pop.dart';
import '../../screens/pop/pop_details_screen.dart';
import '../../services/app_state.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_icons.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/atlas_glass_panel.dart';
import '../../widgets/atlas/components/atlas_product_image.dart';
import '../../widgets/vault/vault_scroll_view.dart';

class AtlasInsightsScreen extends StatelessWidget {
  const AtlasInsightsScreen({super.key});

  static const AtlasVaultRoomClassifier _roomClassifier =
      AtlasVaultRoomClassifier();

  String _formatCurrency(double value) {
    return '\$${value.toStringAsFixed(0)}';
  }

  String _formatPercent(double value) {
    return '${(value * 100).round()}%';
  }

  String _formatCoveragePercent(double value) {
    final percent = value * 100;
    if (percent <= 0 || percent >= 100) {
      return '${percent.round()}%';
    }
    return '${percent.toStringAsFixed(1)}%';
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    const repository = VaultRepository();

    final pops = repository
        .allPops(appState)
        .where((pop) => !pop.isWishlist)
        .toList(growable: false);

    final totalPops = pops.length;
    final totalValue = pops.fold<double>(0, (total, pop) => total + pop.value);
    final averageValue = totalPops == 0 ? 0.0 : totalValue / totalPops;

    final valuedCount = pops.where((pop) => pop.value > 0).length;
    final imageCount = pops
        .where((pop) => pop.imageUrl.trim().isNotEmpty)
        .length;
    final catalogLinkedCount = pops.where((pop) {
      return pop.sourceCatalogId.trim().isNotEmpty ||
          pop.sourceCollectibleId.trim().isNotEmpty;
    }).length;

    final valueCoverage = totalPops == 0 ? 0.0 : valuedCount / totalPops;
    final imageCoverage = totalPops == 0 ? 0.0 : imageCount / totalPops;
    final catalogCoverage = totalPops == 0
        ? 0.0
        : catalogLinkedCount / totalPops;

    final roomCounts = _roomClassifier.countsFor(pops).entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final roomValues = <AtlasVaultRoom, double>{
      for (final room in AtlasVaultRoom.values) room: 0,
    };

    for (final pop in pops) {
      final room = _roomClassifier.roomFor(pop);
      roomValues[room] = (roomValues[room] ?? 0) + pop.value;
    }

    final roomValueEntries = roomValues.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topPops = List<Pop>.from(pops)
      ..sort((a, b) => b.value.compareTo(a.value));

    final topFiveValue = topPops
        .take(5)
        .fold<double>(0, (total, pop) => total + pop.value);
    final topFiveShare = totalValue <= 0 ? 0.0 : topFiveValue / totalValue;

    final largestRoom = roomCounts.isEmpty ? null : roomCounts.first;

    return Scaffold(
      appBar: AppBar(title: const Text('Atlas Insights')),
      body: VaultScrollView(
        children: [
          _CollectionIntelligenceCard(
            totalPops: totalPops,
            totalValue: totalValue,
            averageValue: averageValue,
            valueCoverage: valueCoverage,
            formatCurrency: _formatCurrency,
            formatPercent: _formatCoveragePercent,
          ),
          const SizedBox(height: AtlasSpacing.lg),
          _RoomBreakdownCard(
            entries: roomCounts,
            totalPops: totalPops,
            formatPercent: _formatCoveragePercent,
          ),
          const SizedBox(height: AtlasSpacing.lg),
          _RoomValueCard(
            entries: roomValueEntries,
            formatCurrency: _formatCurrency,
          ),
          const SizedBox(height: AtlasSpacing.lg),
          _CollectionHealthCard(
            totalPops: totalPops,
            valuedCount: valuedCount,
            imageCount: imageCount,
            catalogLinkedCount: catalogLinkedCount,
            valueCoverage: valueCoverage,
            imageCoverage: imageCoverage,
            catalogCoverage: catalogCoverage,
            formatPercent: _formatPercent,
          ),
          const SizedBox(height: AtlasSpacing.lg),
          _AtlasHighlightsCard(
            largestRoom: largestRoom,
            topFiveShare: topFiveShare,
            missingValueCount: totalPops - valuedCount,
            formatPercent: _formatPercent,
          ),
          const SizedBox(height: AtlasSpacing.lg),
          _TopValuablePopsCard(
            pops: topPops,
            appState: appState,
            formatCurrency: _formatCurrency,
          ),
        ],
      ),
    );
  }
}

class _CollectionIntelligenceCard extends StatelessWidget {
  const _CollectionIntelligenceCard({
    required this.totalPops,
    required this.totalValue,
    required this.averageValue,
    required this.valueCoverage,
    required this.formatCurrency,
    required this.formatPercent,
  });

  final int totalPops;
  final double totalValue;
  final double averageValue;
  final double valueCoverage;
  final String Function(double value) formatCurrency;
  final String Function(double value) formatPercent;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(AtlasIcons.trend, color: AtlasColors.vaultGold, size: 30),
          const SizedBox(height: AtlasSpacing.sm),
          Text('Collection Intelligence', style: AtlasTypography.headingLarge),
          const SizedBox(height: AtlasSpacing.xs),
          Text(
            'A clear snapshot of your collection size, value, and data quality.',
            style: AtlasTypography.bodyMedium.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
          const SizedBox(height: AtlasSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  icon: Icons.inventory_2_outlined,
                  value: '$totalPops',
                  label: 'Pops',
                ),
              ),
              Expanded(
                child: _Metric(
                  icon: Icons.attach_money_rounded,
                  value: formatCurrency(totalValue),
                  label: 'Total Value',
                ),
              ),
            ],
          ),
          const SizedBox(height: AtlasSpacing.md),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  icon: Icons.calculate_outlined,
                  value: formatCurrency(averageValue),
                  label: 'Avg. Value',
                ),
              ),
              Expanded(
                child: _Metric(
                  icon: Icons.verified_outlined,
                  value: formatPercent(valueCoverage),
                  label: 'Value Coverage',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AtlasColors.vaultGold, size: 23),
        const SizedBox(height: AtlasSpacing.xs),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: AtlasTypography.metricSmall.copyWith(
              color: AtlasColors.vaultGold,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AtlasTypography.bodySmall.copyWith(
            color: AtlasColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _RoomBreakdownCard extends StatefulWidget {
  const _RoomBreakdownCard({
    required this.entries,
    required this.totalPops,
    required this.formatPercent,
  });

  final List<MapEntry<AtlasVaultRoom, int>> entries;
  final int totalPops;
  final String Function(double value) formatPercent;

  @override
  State<_RoomBreakdownCard> createState() => _RoomBreakdownCardState();
}

class _RoomBreakdownCardState extends State<_RoomBreakdownCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final visibleEntries = _expanded
        ? widget.entries
        : widget.entries.take(5).toList();
    final hasMore = widget.entries.length > 5;

    return _InsightSectionCard(
      icon: Icons.grid_view_rounded,
      title: 'Collection Breakdown',
      subtitle: 'Your largest Vault Rooms by collectible count.',
      child: Column(
        children: [
          ...List.generate(visibleEntries.length, (index) {
            final entry = visibleEntries[index];
            final share = widget.totalPops == 0
                ? 0.0
                : entry.value / widget.totalPops;

            return Padding(
              padding: EdgeInsets.only(
                bottom: index == visibleEntries.length - 1
                    ? 0
                    : AtlasSpacing.sm,
              ),
              child: _RoomStatRow(
                rank: index + 1,
                label: entry.key.displayName,
                value: '${entry.value} Pops',
                trailing: widget.formatPercent(share),
                progress: share,
              ),
            );
          }),
          if (hasMore) ...[
            const SizedBox(height: AtlasSpacing.sm),
            _ExpandAction(
              label: _expanded
                  ? 'Show Top 5'
                  : 'View All ${widget.entries.length} Rooms',
              expanded: _expanded,
              onTap: () => setState(() => _expanded = !_expanded),
            ),
          ],
        ],
      ),
    );
  }
}

class _RoomValueCard extends StatefulWidget {
  const _RoomValueCard({required this.entries, required this.formatCurrency});

  final List<MapEntry<AtlasVaultRoom, double>> entries;
  final String Function(double value) formatCurrency;

  @override
  State<_RoomValueCard> createState() => _RoomValueCardState();
}

class _RoomValueCardState extends State<_RoomValueCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final visibleEntries = _expanded
        ? widget.entries
        : widget.entries.take(5).toList();
    final maxValue = widget.entries.isEmpty ? 0.0 : widget.entries.first.value;
    final hasMore = widget.entries.length > 5;

    return _InsightSectionCard(
      icon: Icons.monetization_on_outlined,
      title: 'Value by Room',
      subtitle: 'Where your collection value is concentrated.',
      child: Column(
        children: [
          ...List.generate(visibleEntries.length, (index) {
            final entry = visibleEntries[index];
            final progress = maxValue <= 0 ? 0.0 : entry.value / maxValue;

            return Padding(
              padding: EdgeInsets.only(
                bottom: index == visibleEntries.length - 1
                    ? 0
                    : AtlasSpacing.sm,
              ),
              child: _RoomStatRow(
                rank: index + 1,
                label: entry.key.displayName,
                value: widget.formatCurrency(entry.value),
                progress: progress,
              ),
            );
          }),
          if (hasMore) ...[
            const SizedBox(height: AtlasSpacing.sm),
            _ExpandAction(
              label: _expanded ? 'Show Top 5' : 'View All Room Values',
              expanded: _expanded,
              onTap: () => setState(() => _expanded = !_expanded),
            ),
          ],
        ],
      ),
    );
  }
}

class _RoomStatRow extends StatelessWidget {
  const _RoomStatRow({
    required this.rank,
    required this.label,
    required this.value,
    required this.progress,
    this.trailing,
  });

  final int rank;
  final String label;
  final String value;
  final double progress;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassPanel(
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AtlasColors.vaultGold.withValues(alpha: 0.16),
                child: Text(
                  '$rank',
                  style: AtlasTypography.bodySmall.copyWith(
                    color: AtlasColors.vaultGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AtlasSpacing.md),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AtlasTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                value,
                style: AtlasTypography.bodySmall.copyWith(
                  color: AtlasColors.vaultGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AtlasSpacing.sm),
                Text(
                  trailing!,
                  style: AtlasTypography.bodySmall.copyWith(
                    color: AtlasColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AtlasSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 5,
              value: progress.clamp(0.0, 1.0).toDouble(),
              backgroundColor: AtlasColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AtlasColors.vaultGold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectionHealthCard extends StatelessWidget {
  const _CollectionHealthCard({
    required this.totalPops,
    required this.valuedCount,
    required this.imageCount,
    required this.catalogLinkedCount,
    required this.valueCoverage,
    required this.imageCoverage,
    required this.catalogCoverage,
    required this.formatPercent,
  });

  final int totalPops;
  final int valuedCount;
  final int imageCount;
  final int catalogLinkedCount;
  final double valueCoverage;
  final double imageCoverage;
  final double catalogCoverage;
  final String Function(double value) formatPercent;

  @override
  Widget build(BuildContext context) {
    return _InsightSectionCard(
      icon: Icons.health_and_safety_outlined,
      title: 'Collection Health',
      subtitle: 'Coverage signals that directly affect Atlas accuracy.',
      child: Column(
        children: [
          _HealthRow(
            label: 'Current Value',
            count: '$valuedCount / $totalPops',
            percent: formatPercent(valueCoverage),
            progress: valueCoverage,
          ),
          const SizedBox(height: AtlasSpacing.sm),
          _HealthRow(
            label: 'Product Images',
            count: '$imageCount / $totalPops',
            percent: formatPercent(imageCoverage),
            progress: imageCoverage,
          ),
          const SizedBox(height: AtlasSpacing.sm),
          _HealthRow(
            label: 'Catalog Identity',
            count: '$catalogLinkedCount / $totalPops',
            percent: formatPercent(catalogCoverage),
            progress: catalogCoverage,
          ),
        ],
      ),
    );
  }
}

class _HealthRow extends StatelessWidget {
  const _HealthRow({
    required this.label,
    required this.count,
    required this.percent,
    required this.progress,
  });

  final String label;
  final String count;
  final String percent;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassPanel(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AtlasTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                count,
                style: AtlasTypography.bodySmall.copyWith(
                  color: AtlasColors.textSecondary,
                ),
              ),
              const SizedBox(width: AtlasSpacing.sm),
              Text(
                percent,
                style: AtlasTypography.bodySmall.copyWith(
                  color: AtlasColors.vaultGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AtlasSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 5,
              value: progress.clamp(0.0, 1.0).toDouble(),
              backgroundColor: AtlasColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AtlasColors.vaultGold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AtlasHighlightsCard extends StatelessWidget {
  const _AtlasHighlightsCard({
    required this.largestRoom,
    required this.topFiveShare,
    required this.missingValueCount,
    required this.formatPercent,
  });

  final MapEntry<AtlasVaultRoom, int>? largestRoom;
  final double topFiveShare;
  final int missingValueCount;
  final String Function(double value) formatPercent;

  @override
  Widget build(BuildContext context) {
    final highlights = <String>[
      if (largestRoom != null)
        '${largestRoom!.key.displayName} is your largest room with ${largestRoom!.value} Pops.',
      'Your top 5 Pops represent ${formatPercent(topFiveShare)} of total collection value.',
      if (missingValueCount == 0)
        'Every collectible currently has a value recorded.'
      else
        '$missingValueCount collectibles still need a current value.',
    ];

    return _InsightSectionCard(
      icon: Icons.auto_awesome_rounded,
      title: 'Atlas Highlights',
      subtitle: 'Calculated facts from your current Vault snapshot.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(highlights.length, (index) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == highlights.length - 1 ? 0 : AtlasSpacing.md,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: AtlasColors.vaultGold,
                  size: 18,
                ),
                const SizedBox(width: AtlasSpacing.sm),
                Expanded(
                  child: Text(
                    highlights[index],
                    style: AtlasTypography.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _TopValuablePopsCard extends StatefulWidget {
  const _TopValuablePopsCard({
    required this.pops,
    required this.appState,
    required this.formatCurrency,
  });

  final List<Pop> pops;
  final AppState appState;
  final String Function(double value) formatCurrency;

  @override
  State<_TopValuablePopsCard> createState() => _TopValuablePopsCardState();
}

class _TopValuablePopsCardState extends State<_TopValuablePopsCard> {
  bool _expanded = false;

  void _openPop(BuildContext context, Pop pop) {
    final collections = widget.appState.collectionNamesContainingPop(pop);
    final collectionName = collections.isEmpty ? null : collections.first;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PopDetailsScreen(pop: pop, collectionName: collectionName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visiblePops = _expanded ? widget.pops : widget.pops.take(5).toList();
    final hasMore = widget.pops.length > 5;

    return _InsightSectionCard(
      icon: Icons.workspace_premium_outlined,
      title: 'Top Valuable Pops',
      subtitle: 'Your highest-value collectibles right now.',
      child: widget.pops.isEmpty
          ? Text(
              'No value data available yet.',
              style: AtlasTypography.bodyMedium.copyWith(
                color: AtlasColors.textSecondary,
              ),
            )
          : Column(
              children: [
                ...List.generate(visiblePops.length, (index) {
                  final pop = visiblePops[index];
                  final room = AtlasInsightsScreen._roomClassifier.roomFor(pop);

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == visiblePops.length - 1
                          ? 0
                          : AtlasSpacing.sm,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _openPop(context, pop),
                      child: AtlasGlassPanel(
                        child: Row(
                          children: [
                            AtlasProductImage(
                              imageUrl: pop.imageUrl,
                              width: 48,
                              height: 60,
                              borderRadius: AtlasSpacing.sm,
                              placeholderIcon: Icons.inventory_2_rounded,
                              errorIcon: Icons.broken_image_rounded,
                            ),
                            const SizedBox(width: AtlasSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pop.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AtlasTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${pop.number.trim().isEmpty ? 'No #' : '#${pop.number}'} • ${room.displayName}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AtlasTypography.bodySmall.copyWith(
                                      color: AtlasColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AtlasSpacing.xs),
                            Text(
                              widget.formatCurrency(pop.value),
                              style: AtlasTypography.bodyMedium.copyWith(
                                color: AtlasColors.vaultGold,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AtlasColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                if (hasMore) ...[
                  const SizedBox(height: AtlasSpacing.sm),
                  _ExpandAction(
                    label: _expanded
                        ? 'Show Top 5'
                        : 'View All ${widget.pops.length} Valued Pops',
                    expanded: _expanded,
                    onTap: () => setState(() => _expanded = !_expanded),
                  ),
                ],
              ],
            ),
    );
  }
}

class _ExpandAction extends StatelessWidget {
  const _ExpandAction({
    required this.label,
    required this.expanded,
    required this.onTap,
  });

  final String label;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AtlasSpacing.sm,
          vertical: AtlasSpacing.xs,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: AtlasTypography.bodySmall.copyWith(
                color: AtlasColors.intelligenceBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              expanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: AtlasColors.intelligenceBlue,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightSectionCard extends StatelessWidget {
  const _InsightSectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AtlasColors.vaultGold.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AtlasColors.vaultGold.withValues(alpha: 0.24),
                  ),
                ),
                child: Icon(icon, color: AtlasColors.vaultGold, size: 22),
              ),
              const SizedBox(width: AtlasSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AtlasTypography.headingSmall),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AtlasTypography.bodySmall.copyWith(
                        color: AtlasColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AtlasSpacing.md),
          child,
        ],
      ),
    );
  }
}
