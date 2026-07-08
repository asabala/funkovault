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
import '../pop/pop_details_screen.dart';

class EntireVaultScreen extends StatefulWidget {
  const EntireVaultScreen({super.key});

  @override
  State<EntireVaultScreen> createState() => _EntireVaultScreenState();
}

class _EntireVaultScreenState extends State<EntireVaultScreen> {
  static const int _pageSize = 50;

  final _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _searchQuery = '';
  int _visibleLimit = _pageSize;
  bool _showBackToTop = false;
  _VaultSortMode _sortMode = _VaultSortMode.nameAz;
  _VaultFilterMode _filterMode = _VaultFilterMode.all;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScrollPosition);
  }

  void _handleScrollPosition() {
    final shouldShow = _scrollController.offset > 500;

    if (shouldShow != _showBackToTop) {
      setState(() {
        _showBackToTop = shouldShow;
      });
    }
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) {
      return;
    }

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScrollPosition);
    _scrollController.dispose();
    _searchController.dispose();

    super.dispose();
  }

  void _resetVisibleLimit() {
    _visibleLimit = _pageSize;
  }

  void _loadMoreResults(int totalResults) {
    setState(() {
      _visibleLimit = (_visibleLimit + _pageSize)
          .clamp(
        0,
        totalResults,
      )
          .toInt();
    });
  }

  void _resetVaultReviewControls() {
    _searchController.clear();

    setState(() {
      _searchQuery = '';
      _filterMode = _VaultFilterMode.all;
      _sortMode = _VaultSortMode.nameAz;
      _resetVisibleLimit();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    const repository = VaultRepository();

    final pops = repository.allPops(appState);
    final searchedPops = _filterBySearch(pops);
    final filteredPops = _sortPops(
      _filterByMode(
        searchedPops,
      ),
    );

    final visiblePops = filteredPops.take(_visibleLimit).toList();
    final hasMoreResults = visiblePops.length < filteredPops.length;

    final totalValue = pops.fold<double>(
      0,
          (total, pop) => total + pop.value,
    );

    final hasActiveReviewControls = _searchQuery.trim().isNotEmpty ||
        _filterMode != _VaultFilterMode.all ||
        _sortMode != _VaultSortMode.nameAz;

    final missingValueCount = pops.where((pop) => pop.value <= 0).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entire Vault'),
      ),
      floatingActionButton: _showBackToTop
          ? FloatingActionButton.extended(
        onPressed: _scrollToTop,
        icon: const Icon(Icons.keyboard_arrow_up_rounded),
        label: const Text('Top'),
      )
          : null,
        body: SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                _resetVisibleLimit();
              });
            },
            onClear: () {
              _searchController.clear();

              setState(() {
                _searchQuery = '';
                _resetVisibleLimit();
              });
            },
          ),
          const SizedBox(height: AtlasSpacing.lg),
          _VaultControlsCard(
            selectedFilter: _filterMode,
            selectedSort: _sortMode,
            hasActiveControls: hasActiveReviewControls,
            onFilterChanged: (filterMode) {
              setState(() {
                _filterMode = filterMode;
                _resetVisibleLimit();
              });
            },
            onSortChanged: (sortMode) {
              setState(() {
                _sortMode = sortMode;
                _resetVisibleLimit();
              });
            },
            onReset: _resetVaultReviewControls,
          ),
          const SizedBox(height: AtlasSpacing.md),
          _VaultResultSummaryBar(
            visibleCount: filteredPops.length,
            totalCount: pops.length,
            searchedCount: searchedPops.length,
            filterMode: _filterMode,
            sortMode: _sortMode,
            searchQuery: _searchQuery,
          ),
          const SizedBox(height: AtlasSpacing.lg),
          if (pops.isEmpty)
            const _EmptyVaultCard()
          else if (filteredPops.isEmpty)
            const _NoSearchResultsCard()
          else
            _VaultPopListCard(
              pops: visiblePops,
              totalFilteredCount: filteredPops.length,
              hasMoreResults: hasMoreResults,
              sortMode: _sortMode,
              filterMode: _filterMode,
              onLoadMore: () => _loadMoreResults(filteredPops.length),
            ),
        ],
      ),
            ),
        ),
    );
  }

  List<Pop> _filterBySearch(List<Pop> pops) {
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

  List<Pop> _filterByMode(List<Pop> pops) {
    switch (_filterMode) {
      case _VaultFilterMode.all:
        return pops;

      case _VaultFilterMode.owned:
        return pops
            .where(
              (pop) => !pop.isWishlist,
        )
            .toList();

      case _VaultFilterMode.wishlist:
        return pops
            .where(
              (pop) => pop.isWishlist,
        )
            .toList();

      case _VaultFilterMode.needsValue:
        return pops
            .where(
              (pop) => pop.value <= 0,
        )
            .toList();

      case _VaultFilterMode.hasValue:
        return pops
            .where(
              (pop) => pop.value > 0,
        )
            .toList();

      case _VaultFilterMode.exclusives:
        return pops
            .where(
              (pop) => _hasMeaningfulValue(pop.retailExclusive),
        )
            .toList();

      case _VaultFilterMode.signed:
        return pops
            .where(
              (pop) => _hasMeaningfulValue(pop.signature),
        )
            .toList();

      case _VaultFilterMode.limited:
        return pops
            .where(
              (pop) => _hasMeaningfulValue(pop.limitedEdition),
        )
            .toList();

      case _VaultFilterMode.variants:
        return pops
            .where(
              (pop) => _hasMeaningfulValue(pop.variant),
        )
            .toList();
    }
  }

  bool _hasMeaningfulValue(String value) {
    final cleaned = value.trim().toLowerCase();

    if (cleaned.isEmpty) {
      return false;
    }

    return cleaned != 'none' &&
        cleaned != 'common' &&
        cleaned != 'standard' &&
        cleaned != 'unsigned' &&
        cleaned != 'no' &&
        cleaned != 'n/a' &&
        cleaned != 'na';
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

enum _VaultFilterMode {
  all,
  owned,
  wishlist,
  needsValue,
  hasValue,
  exclusives,
  signed,
  limited,
  variants,
}

extension _VaultFilterModeLabel on _VaultFilterMode {
  String get label {
    switch (this) {
      case _VaultFilterMode.all:
        return 'All';
      case _VaultFilterMode.owned:
        return 'Owned';
      case _VaultFilterMode.wishlist:
        return 'Wishlist';
      case _VaultFilterMode.needsValue:
        return 'Needs Value';
      case _VaultFilterMode.hasValue:
        return 'Has Value';
      case _VaultFilterMode.exclusives:
        return 'Exclusives';
      case _VaultFilterMode.signed:
        return 'Signed';
      case _VaultFilterMode.limited:
        return 'Limited';
      case _VaultFilterMode.variants:
        return 'Variants';
    }
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

class _VaultControlsCard extends StatelessWidget {
  const _VaultControlsCard({
    required this.selectedFilter,
    required this.selectedSort,
    required this.hasActiveControls,
    required this.onFilterChanged,
    required this.onSortChanged,
    required this.onReset,
  });

  final _VaultFilterMode selectedFilter;
  final _VaultSortMode selectedSort;
  final bool hasActiveControls;
  final ValueChanged<_VaultFilterMode> onFilterChanged;
  final ValueChanged<_VaultSortMode> onSortChanged;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Controls',
            style: AtlasTypography.headingSmall,
          ),
          const SizedBox(height: AtlasSpacing.sm),
          Text(
            'Filter and sort your vault without taking up extra space.',
            style: AtlasTypography.bodyMedium.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
          const SizedBox(height: AtlasSpacing.md),
          Row(
            children: [
              Expanded(
                child: _VaultDropdown<_VaultFilterMode>(
                  label: 'Filter Vault',
                  icon: Icons.filter_list_rounded,
                  value: selectedFilter,
                  values: _VaultFilterMode.values,
                  labelBuilder: (value) => value.label,
                  onChanged: onFilterChanged,
                ),
              ),
              const SizedBox(width: AtlasSpacing.sm),
              Container(
                width: 1,
                height: 48,
                color: AtlasColors.textSecondary.withValues(alpha: 0.20),
              ),
              const SizedBox(width: AtlasSpacing.sm),
              Expanded(
                child: _VaultDropdown<_VaultSortMode>(
                  label: 'Sort Vault',
                  icon: Icons.sort_rounded,
                  value: selectedSort,
                  values: _VaultSortMode.values,
                  labelBuilder: (value) => value.label,
                  onChanged: onSortChanged,
                ),
              ),
            ],
          ),
          if (hasActiveControls) ...[
            const SizedBox(height: AtlasSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text('Reset Search, Filter, and Sort'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VaultDropdown<T> extends StatelessWidget {
  const _VaultDropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.values,
    required this.labelBuilder,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final T value;
  final List<T> values;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AtlasSpacing.sm,
          vertical: AtlasSpacing.sm,
        ),
      ),
      items: values
          .map(
            (item) => DropdownMenuItem<T>(
          value: item,
          child: Text(
            labelBuilder(item),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      )
          .toList(),
      onChanged: (newValue) {
        if (newValue == null) {
          return;
        }

        onChanged(newValue);
      },
    );
  }
}

class _VaultResultSummaryBar extends StatelessWidget {
  const _VaultResultSummaryBar({
    required this.visibleCount,
    required this.totalCount,
    required this.searchedCount,
    required this.filterMode,
    required this.sortMode,
    required this.searchQuery,
  });

  final int visibleCount;
  final int totalCount;
  final int searchedCount;
  final _VaultFilterMode filterMode;
  final _VaultSortMode sortMode;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    final hasSearch = searchQuery.trim().isNotEmpty;
    final searchLabel = hasSearch ? 'Search: "${searchQuery.trim()}"' : 'Search: None';

    return AtlasGlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Showing $visibleCount of $totalCount Pops',
            style: AtlasTypography.bodyMedium.copyWith(
              color: AtlasColors.vaultGold,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AtlasSpacing.xs),
          Text(
            'Filter: ${filterMode.label} • Sort: ${sortMode.label}',
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
          if (hasSearch) ...[
            const SizedBox(height: AtlasSpacing.xs),
            Text(
              '$searchLabel • Search matched $searchedCount',
              style: AtlasTypography.bodySmall.copyWith(
                color: AtlasColors.textSecondary,
              ),
            ),
          ],
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
        'No Pops matched your search or filter. Try clearing search, choosing All, or using a different filter.',
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
    required this.totalFilteredCount,
    required this.hasMoreResults,
    required this.sortMode,
    required this.filterMode,
    required this.onLoadMore,
  });

  final List<Pop> pops;
  final int totalFilteredCount;
  final bool hasMoreResults;
  final _VaultSortMode sortMode;
  final _VaultFilterMode filterMode;
  final VoidCallback onLoadMore;

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
            'Showing ${pops.length} of $totalFilteredCount result${totalFilteredCount == 1 ? '' : 's'} • Filtered by ${filterMode.label} • Sorted by ${sortMode.label}. Tap any Pop to open details.',
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
          if (hasMoreResults) ...[
            const SizedBox(height: AtlasSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onLoadMore,
                icon: const Icon(Icons.expand_more_rounded),
                label: const Text('Load More Pops'),
              ),
            ),
          ],
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