import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../atlas/repositories/vault_repository.dart';
import '../../models/pop.dart';
import '../../services/app_state.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/atlas_glass_panel.dart';
import '../../widgets/vault_scroll_view.dart';
import '../pop/pop_details_screen.dart';

class EntireVaultScreen extends StatefulWidget {
  const EntireVaultScreen({super.key});

  @override
  State<EntireVaultScreen> createState() => _EntireVaultScreenState();
}

class _EntireVaultScreenState extends State<EntireVaultScreen> {
  final _searchController = TextEditingController();

  String _searchQuery = '';
  _VaultSortMode _sortMode = _VaultSortMode.nameAz;

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    const repository = VaultRepository();

    final pops = repository.allPops(appState);
    final filteredPops = _sortPops(_filterPops(pops));

    final totalValue = pops.fold<double>(
      0,
          (total, pop) => total + pop.value,
    );
    final missingValueCount = pops.where((pop) => pop.value <= 0).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entire Vault'),
      ),
      body: VaultScrollView(
        children: [
          AtlasGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Entire Vault',
                  style: AtlasTypography.headingLarge,
                ),
                const SizedBox(height: AtlasSpacing.sm),
                Text(
                  'Review every Pop currently saved in your collection.',
                  style: AtlasTypography.bodyMedium.copyWith(
                    color: AtlasColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AtlasSpacing.lg),
                AtlasGlassPanel(
                  child: Row(
                    children: [
                      Expanded(
                        child: _VaultSummaryItem(
                          value: '${pops.length}',
                          label: 'Pops',
                        ),
                      ),
                      Expanded(
                        child: _VaultSummaryItem(
                          value: '\$${totalValue.toStringAsFixed(0)}',
                          label: 'Value',
                        ),
                      ),
                      Expanded(
                        child: _VaultSummaryItem(
                          value: '$missingValueCount',
                          label: 'Need Value',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AtlasSpacing.lg),
          _VaultSearchCard(
            controller: _searchController,
            resultCount: filteredPops.length,
            totalCount: pops.length,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            onClear: () {
              _searchController.clear();

              setState(() {
                _searchQuery = '';
              });
            },
          ),
          const SizedBox(height: AtlasSpacing.lg),
          _VaultSortCard(
            selectedSort: _sortMode,
            onChanged: (sortMode) {
              setState(() {
                _sortMode = sortMode;
              });
            },
          ),
          const SizedBox(height: AtlasSpacing.lg),
          if (pops.isEmpty)
            const _EmptyVaultCard()
          else if (filteredPops.isEmpty)
            const _NoSearchResultsCard()
          else
            _VaultPopListCard(
              pops: filteredPops,
              sortMode: _sortMode,
            ),
        ],
      ),
    );
  }

  List<Pop> _filterPops(List<Pop> pops) {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return List<Pop>.from(pops);
    }

    return pops.where((pop) {
      final name = pop.name.toLowerCase();
      final number = pop.number.toLowerCase();
      final category = pop.category.toLowerCase();
      final series = pop.series.toLowerCase();
      final owner = pop.owner.toLowerCase();

      return name.contains(query) ||
          number.contains(query) ||
          category.contains(query) ||
          series.contains(query) ||
          owner.contains(query);
    }).toList();
  }

  List<Pop> _sortPops(List<Pop> pops) {
    final sorted = List<Pop>.from(pops);

    switch (_sortMode) {
      case _VaultSortMode.nameAz:
        sorted.sort(
              (a, b) => a.name.toLowerCase().compareTo(
            b.name.toLowerCase(),
          ),
        );
        break;

      case _VaultSortMode.highestValue:
        sorted.sort(
              (a, b) => b.value.compareTo(a.value),
        );
        break;

      case _VaultSortMode.needsValue:
        sorted.sort((a, b) {
          final aNeedsValue = a.value <= 0;
          final bNeedsValue = b.value <= 0;

          if (aNeedsValue && !bNeedsValue) {
            return -1;
          }

          if (!aNeedsValue && bNeedsValue) {
            return 1;
          }

          return a.name.toLowerCase().compareTo(
            b.name.toLowerCase(),
          );
        });
        break;

      case _VaultSortMode.newestAdded:
        sorted.sort(
              (a, b) => _dateScore(b.dateAdded).compareTo(
            _dateScore(a.dateAdded),
          ),
        );
        break;

      case _VaultSortMode.recentlyUpdated:
        sorted.sort(
              (a, b) => _dateScore(b.lastUpdated).compareTo(
            _dateScore(a.lastUpdated),
          ),
        );
        break;
    }

    return sorted;
  }

  int _dateScore(String value) {
    final parsed = DateTime.tryParse(value.trim());

    if (parsed == null) {
      return 0;
    }

    return parsed.millisecondsSinceEpoch;
  }
}

enum _VaultSortMode {
  nameAz,
  highestValue,
  needsValue,
  newestAdded,
  recentlyUpdated,
}

extension _VaultSortModeLabel on _VaultSortMode {
  String get label {
    switch (this) {
      case _VaultSortMode.nameAz:
        return 'Name A-Z';
      case _VaultSortMode.highestValue:
        return 'Highest Value';
      case _VaultSortMode.needsValue:
        return 'Needs Value';
      case _VaultSortMode.newestAdded:
        return 'Newest Added';
      case _VaultSortMode.recentlyUpdated:
        return 'Recently Updated';
    }
  }
}

class _VaultSearchCard extends StatelessWidget {
  const _VaultSearchCard({
    required this.controller,
    required this.resultCount,
    required this.totalCount,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final int resultCount;
  final int totalCount;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final hasSearch = controller.text.trim().isNotEmpty;

    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search Vault',
            style: AtlasTypography.headingSmall,
          ),
          const SizedBox(height: AtlasSpacing.md),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Search by name, number, category, series, or owner...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: hasSearch
                  ? IconButton(
                tooltip: 'Clear search',
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded),
              )
                  : null,
              border: const OutlineInputBorder(),
            ),
            onChanged: onChanged,
          ),
          const SizedBox(height: AtlasSpacing.sm),
          Text(
            hasSearch
                ? '$resultCount of $totalCount Pops match your search.'
                : '$totalCount Pops in your vault.',
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _VaultSortCard extends StatelessWidget {
  const _VaultSortCard({
    required this.selectedSort,
    required this.onChanged,
  });

  final _VaultSortMode selectedSort;
  final ValueChanged<_VaultSortMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sort Vault',
            style: AtlasTypography.headingSmall,
          ),
          const SizedBox(height: AtlasSpacing.sm),
          Text(
            'Choose how you want to review your collection.',
            style: AtlasTypography.bodyMedium.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
          const SizedBox(height: AtlasSpacing.md),
          Wrap(
            spacing: AtlasSpacing.sm,
            runSpacing: AtlasSpacing.sm,
            children: _VaultSortMode.values
                .map(
                  (sortMode) => ChoiceChip(
                label: Text(sortMode.label),
                selected: selectedSort == sortMode,
                onSelected: (_) => onChanged(sortMode),
                selectedColor:
                AtlasColors.vaultGold.withValues(alpha: 0.22),
                labelStyle: AtlasTypography.bodySmall.copyWith(
                  color: selectedSort == sortMode
                      ? AtlasColors.vaultGold
                      : AtlasColors.textSecondary,
                  fontWeight: selectedSort == sortMode
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
                side: BorderSide(
                  color: selectedSort == sortMode
                      ? AtlasColors.vaultGold.withValues(alpha: 0.70)
                      : AtlasColors.textSecondary.withValues(alpha: 0.22),
                ),
              ),
            )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _VaultSummaryItem extends StatelessWidget {
  const _VaultSummaryItem({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

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

class _EmptyVaultCard extends StatelessWidget {
  const _EmptyVaultCard();

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: Text(
        'Your vault is ready. Add your first Pop to begin building your collection.',
        style: AtlasTypography.bodyMedium.copyWith(
          color: AtlasColors.textSecondary,
        ),
      ),
    );
  }
}

class _NoSearchResultsCard extends StatelessWidget {
  const _NoSearchResultsCard();

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: Text(
        'No Pops matched your search. Try a different name, number, category, series, or owner.',
        style: AtlasTypography.bodyMedium.copyWith(
          color: AtlasColors.textSecondary,
        ),
      ),
    );
  }
}

class _VaultPopListCard extends StatelessWidget {
  const _VaultPopListCard({
    required this.pops,
    required this.sortMode,
  });

  final List<Pop> pops;
  final _VaultSortMode sortMode;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vault List',
            style: AtlasTypography.headingSmall,
          ),
          const SizedBox(height: AtlasSpacing.sm),
          Text(
            '${pops.length} result${pops.length == 1 ? '' : 's'} • Sorted by ${sortMode.label}. Tap any Pop to open details.',
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
          const SizedBox(height: AtlasSpacing.md),
          ...pops.map(
                (pop) => Padding(
              padding: const EdgeInsets.only(bottom: AtlasSpacing.sm),
              child: _VaultPopTile(pop: pop),
            ),
          ),
        ],
      ),
    );
  }
}

class _VaultPopTile extends StatelessWidget {
  const _VaultPopTile({
    required this.pop,
  });

  final Pop pop;

  void _openDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PopDetailsScreen(pop: pop),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final numberLabel = pop.number.trim().isEmpty ? 'No #' : '#${pop.number}';
    final categoryLabel =
    pop.category.trim().isEmpty ? 'No category' : pop.category.trim();
    final seriesLabel =
    pop.series.trim().isEmpty ? 'No series' : pop.series.trim();
    final valueLabel =
    pop.value <= 0 ? 'Value needed' : '\$${pop.value.toStringAsFixed(0)}';
    final addedLabel = _formatDateLabel(pop.dateAdded);
    final updatedLabel = _formatDateLabel(pop.lastUpdated);

    return InkWell(
      borderRadius: BorderRadius.circular(AtlasSpacing.md),
      onTap: () => _openDetails(context),
      child: AtlasGlassPanel(
        child: Row(
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              color: AtlasColors.vaultGold,
            ),
            const SizedBox(width: AtlasSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pop.name,
                    style: AtlasTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AtlasSpacing.xs),
                  Text(
                    '$numberLabel • $categoryLabel',
                    style: AtlasTypography.bodySmall.copyWith(
                      color: AtlasColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AtlasSpacing.xs),
                  Text(
                    seriesLabel,
                    style: AtlasTypography.bodySmall.copyWith(
                      color: AtlasColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AtlasSpacing.xs),
                  Text(
                    'Added: $addedLabel • Updated: $updatedLabel',
                    style: AtlasTypography.bodySmall.copyWith(
                      color: AtlasColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AtlasSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  valueLabel,
                  style: AtlasTypography.bodySmall.copyWith(
                    color: pop.value <= 0
                        ? AtlasColors.textSecondary
                        : AtlasColors.vaultGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AtlasSpacing.xs),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AtlasColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDateLabel(String value) {
  final cleaned = value.trim();

  if (cleaned.isEmpty) {
    return 'Before tracking';
  }

  final parsed = DateTime.tryParse(cleaned);

  if (parsed == null) {
    return cleaned;
  }

  final month = parsed.month.toString().padLeft(2, '0');
  final day = parsed.day.toString().padLeft(2, '0');
  final year = parsed.year.toString().substring(2);

  return '$month/$day/$year';
}