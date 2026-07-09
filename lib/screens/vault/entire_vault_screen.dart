import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../atlas/repositories/vault_repository.dart';
import '../../models/pop.dart';
import '../../services/app_state.dart';
import '../../services/hive_service.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/atlas_glass_panel.dart';
import '../../widgets/vault/vault_breakdown_card.dart';
import '../pop/pop_details_screen.dart';

class EntireVaultScreen extends StatefulWidget {
  const EntireVaultScreen({
    super.key,
    this.initialFilterKey,
  });

  final String? initialFilterKey;

  @override
  State<EntireVaultScreen> createState() => _EntireVaultScreenState();
}

class _EntireVaultScreenState extends State<EntireVaultScreen> {
  static const int _pageSize = 50;
  static const String _preferencesStorageKey = 'entire_vault_preferences';

  final _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _searchQuery = '';
  int _visibleLimit = _pageSize;
  bool _showBackToTop = false;
  bool _showImages = false;
  bool _isCleanupFocusActive = false;
  _VaultSortMode _sortMode = _VaultSortMode.nameAz;
  _VaultFilterMode _filterMode = _VaultFilterMode.all;

  @override
  void initState() {
    super.initState();
    _loadVaultPreferences();
    _applyInitialFilter();
    _scrollController.addListener(_handleScrollPosition);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScrollPosition);
    _scrollController.dispose();
    _searchController.dispose();

    super.dispose();
  }

  void _loadVaultPreferences() {
    final data = HiveService.loadData(
      _preferencesStorageKey,
    );

    if (data == null) {
      return;
    }

    _filterMode = _filterModeFromStorage(
      data['filterMode'],
    );

    _sortMode = _sortModeFromStorage(
      data['sortMode'],
    );

    _showImages = data['showImages'] == true;
  }

  void _applyInitialFilter() {
    final initialFilter = _filterModeFromStorage(
      widget.initialFilterKey,
    );

    if (initialFilter == _VaultFilterMode.all) {
      return;
    }

    _filterMode = initialFilter;
    _isCleanupFocusActive = true;
    _resetVisibleLimit();
  }

  Future<void> _saveVaultPreferences() async {
    await HiveService.saveData(
      _preferencesStorageKey,
      {
        'filterMode': _filterMode.name,
        'sortMode': _sortMode.name,
        'showImages': _showImages,
      },
    );
  }

  _VaultFilterMode _filterModeFromStorage(dynamic value) {
    if (value is! String) {
      return _VaultFilterMode.all;
    }

    for (final mode in _VaultFilterMode.values) {
      if (mode.name == value) {
        return mode;
      }
    }

    return _VaultFilterMode.all;
  }

  _VaultSortMode _sortModeFromStorage(dynamic value) {
    if (value is! String) {
      return _VaultSortMode.nameAz;
    }

    for (final mode in _VaultSortMode.values) {
      if (mode.name == value) {
        return mode;
      }
    }

    return _VaultSortMode.nameAz;
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

  Future<void> _resetVaultReviewControls() async {
    _searchController.clear();

    setState(() {
      _searchQuery = '';
      _filterMode = _VaultFilterMode.all;
      _sortMode = _VaultSortMode.nameAz;
      _showImages = false;
      _resetVisibleLimit();
    });

    await _saveVaultPreferences();
  }

  void _clearCleanupFocus() {
    setState(() {
      _isCleanupFocusActive = false;
      _filterMode = _VaultFilterMode.all;
      _resetVisibleLimit();
    });
  }

  String? get _cleanupFocusTitle {
    if (!_isCleanupFocusActive || _filterMode == _VaultFilterMode.all) {
      return null;
    }

    return 'Cleanup Focus Active';
  }

  String? get _cleanupFocusMessage {
    if (!_isCleanupFocusActive) {
      return null;
    }

    switch (_filterMode) {
      case _VaultFilterMode.needsValue:
        return 'Showing Pops that need value.';
      case _VaultFilterMode.wishlist:
        return 'Showing wishlist Pops.';
      case _VaultFilterMode.variants:
        return 'Showing Pops with variant details.';
      case _VaultFilterMode.exclusives:
        return 'Showing exclusive Pops.';
      case _VaultFilterMode.signed:
        return 'Showing signed Pops.';
      case _VaultFilterMode.limited:
        return 'Showing limited edition Pops.';
      case _VaultFilterMode.stickers:
        return 'Showing Pops with sticker details.';
      case _VaultFilterMode.duplicates:
        return 'Showing possible duplicate or variant review groups.';
      case _VaultFilterMode.all:
      case _VaultFilterMode.owned:
      case _VaultFilterMode.hasValue:
        return null;
    }
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

    final currentViewValue = filteredPops.fold<double>(
      0,
          (total, pop) => total + pop.value,
    );

    final currentViewMissingValueCount = filteredPops
        .where(
          (pop) => pop.value <= 0,
    )
        .length;

    final hasActiveReviewControls = _searchQuery.trim().isNotEmpty ||
        _filterMode != _VaultFilterMode.all ||
        _sortMode != _VaultSortMode.nameAz ||
        _showImages;

    final missingValueCount = pops.where((pop) => pop.value <= 0).length;

    final ownedCount = pops.where((pop) => !pop.isWishlist).length;
    final wishlistCount = pops.where((pop) => pop.isWishlist).length;
    final exclusiveCount = pops
        .where((pop) => _hasMeaningfulValue(pop.retailExclusive))
        .length;
    final variantCount = pops
        .where((pop) => _hasMeaningfulValue(pop.variant))
        .length;
    final stickerCount = pops
        .where((pop) => _hasMeaningfulValue(pop.eventSticker))
        .length;
    final signedCount = pops
        .where((pop) => _hasMeaningfulValue(pop.signature))
        .length;
    final limitedCount = pops
        .where((pop) => _hasMeaningfulValue(pop.limitedEdition))
        .length;

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
              VaultBreakdownCard(
                ownedCount: ownedCount,
                wishlistCount: wishlistCount,
                exclusiveCount: exclusiveCount,
                variantCount: variantCount,
                stickerCount: stickerCount,
                signedCount: signedCount,
                limitedCount: limitedCount,
                needsValueCount: missingValueCount,
              ),
              if (_cleanupFocusTitle != null &&
                  _cleanupFocusMessage != null) ...[
                const SizedBox(height: AtlasSpacing.md),
                _CleanupFocusCard(
                  title: _cleanupFocusTitle!,
                  message: _cleanupFocusMessage!,
                  onClearFocus: _clearCleanupFocus,
                ),
              ],

              if (_filterMode == _VaultFilterMode.needsValue) ...[
                const SizedBox(height: AtlasSpacing.md),
                const _ValueCleanupBanner(),
              ],

              if (_filterMode == _VaultFilterMode.duplicates) ...[
                const SizedBox(height: AtlasSpacing.md),
                const _DuplicateReviewBanner(),
              ],
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
                onFilterChanged: (filterMode) async {
                  setState(() {
                    _filterMode = filterMode;
                    _resetVisibleLimit();
                  });

                  await _saveVaultPreferences();
                },
                onSortChanged: (sortMode) async {
                  setState(() {
                    _sortMode = sortMode;
                    _resetVisibleLimit();
                  });

                  await _saveVaultPreferences();
                },
                onReset: _resetVaultReviewControls,
              ),
              const SizedBox(height: AtlasSpacing.md),
              _VaultImageToggleCard(
                showImages: _showImages,
                onChanged: (value) async {
                  setState(() {
                    _showImages = value;
                  });

                  await _saveVaultPreferences();
                },
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
              const SizedBox(height: AtlasSpacing.md),
              _CurrentViewStatsCard(
                resultCount: filteredPops.length,
                value: currentViewValue,
                missingValueCount: currentViewMissingValueCount,
              ),
              const SizedBox(height: AtlasSpacing.lg),
              if (pops.isEmpty)
                const _EmptyVaultCard()
              else if (filteredPops.isEmpty)
                _NoSearchResultsCard(
                  filterMode: _filterMode,
                  searchQuery: _searchQuery,
                )
              else
                _VaultPopListCard(
                  pops: visiblePops,
                  totalFilteredCount: filteredPops.length,
                  hasMoreResults: hasMoreResults,
                  sortMode: _sortMode,
                  filterMode: _filterMode,
                  showImages: _showImages,
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

      case _VaultFilterMode.stickers:
        return pops
            .where(
              (pop) => _hasMeaningfulValue(pop.eventSticker),
        )
            .toList();

      case _VaultFilterMode.duplicates:
        return _filterDuplicatePops(pops);
    }
  }

  List<Pop> _filterDuplicatePops(List<Pop> pops) {
    final duplicateKeys = <String>{};
    final countsByKey = <String, int>{};

    for (final pop in pops) {
      final key = _duplicateReviewKey(pop);

      if (key.isEmpty) {
        continue;
      }

      countsByKey[key] = (countsByKey[key] ?? 0) + 1;
    }

    for (final entry in countsByKey.entries) {
      if (entry.value > 1) {
        duplicateKeys.add(entry.key);
      }
    }

    return pops
        .where(
          (pop) => duplicateKeys.contains(
        _duplicateReviewKey(pop),
      ),
    )
        .toList();
  }

  String _duplicateReviewKey(Pop pop) {
    final name = pop.name.trim().toLowerCase();
    final number = pop.number.trim().toLowerCase();

    if (name.isEmpty || number.isEmpty) {
      return '';
    }

    return '$name|$number';
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
  stickers,
  duplicates,
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
      case _VaultFilterMode.stickers:
        return 'Stickers';
      case _VaultFilterMode.duplicates:
        return 'Duplicates';
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

class _CleanupFocusCard extends StatelessWidget {
  const _CleanupFocusCard({
    required this.title,
    required this.message,
    required this.onClearFocus,
  });

  final String title;
  final String message;
  final VoidCallback onClearFocus;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.filter_alt_rounded,
                color: AtlasColors.vaultGold,
              ),
              const SizedBox(width: AtlasSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AtlasTypography.bodyMedium.copyWith(
                        color: AtlasColors.vaultGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AtlasSpacing.xs),
                    Text(
                      message,
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
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onClearFocus,
              icon: const Icon(Icons.close_rounded),
              label: const Text('Clear Focus'),
            ),
          ),
        ],
      ),
    );
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

class _ActiveFilterBadge extends StatelessWidget {
  const _ActiveFilterBadge({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AtlasSpacing.md,
        vertical: AtlasSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AtlasColors.vaultGold.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AtlasColors.vaultGold.withValues(alpha: 0.34),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.filter_alt_rounded,
            color: AtlasColors.vaultGold,
            size: 16,
          ),
          const SizedBox(width: AtlasSpacing.xs),
          Text(
            'Active Filter: $label',
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.vaultGold,
              fontWeight: FontWeight.bold,
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
            'Filter and sort your vault. Filter, sort, and image settings are remembered.',
            style: AtlasTypography.bodyMedium.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
          if (selectedFilter != _VaultFilterMode.all) ...[
            const SizedBox(height: AtlasSpacing.md),
            _ActiveFilterBadge(
              label: selectedFilter.label,
            ),
          ],
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
            AtlasGlassPanel(
              child: Row(
                children: [
                  const Icon(
                    Icons.bookmark_added_outlined,
                    color: AtlasColors.vaultGold,
                  ),
                  const SizedBox(width: AtlasSpacing.md),
                  Expanded(
                    child: Text(
                      'Custom view active. Filter, sort, and image settings will be remembered.',
                      style: AtlasTypography.bodySmall.copyWith(
                        color: AtlasColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AtlasSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text('Reset View'),
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

class _VaultImageToggleCard extends StatelessWidget {
  const _VaultImageToggleCard({
    required this.showImages,
    required this.onChanged,
  });

  final bool showImages;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassPanel(
      child: Row(
        children: [
          Icon(
            showImages
                ? Icons.image_rounded
                : Icons.image_not_supported_outlined,
            color: AtlasColors.vaultGold,
          ),
          const SizedBox(width: AtlasSpacing.md),
          Expanded(
            child: Text(
              showImages
                  ? 'Images are on. Scrolling may be slower.'
                  : 'Images are off for faster scrolling.',
              style: AtlasTypography.bodySmall.copyWith(
                color: AtlasColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              onChanged(!showImages);
            },
            child: Text(
              showImages ? 'Hide Images' : 'Show Images',
            ),
          ),
        ],
      ),
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
    final searchLabel =
    hasSearch ? 'Search: "${searchQuery.trim()}"' : 'Search: None';

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

class _CurrentViewStatsCard extends StatelessWidget {
  const _CurrentViewStatsCard({
    required this.resultCount,
    required this.value,
    required this.missingValueCount,
  });

  final int resultCount;
  final double value;
  final int missingValueCount;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current View',
            style: AtlasTypography.bodyMedium.copyWith(
              color: AtlasColors.vaultGold,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AtlasSpacing.md),
          Row(
            children: [
              Expanded(
                child: _VaultSummaryItem(
                  value: '$resultCount',
                  label: 'Results',
                ),
              ),
              Expanded(
                child: _VaultSummaryItem(
                  value: '\$${value.toStringAsFixed(0)}',
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
  const _NoSearchResultsCard({
    required this.filterMode,
    required this.searchQuery,
  });

  final _VaultFilterMode filterMode;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    final message = _messageForCurrentView();

    return AtlasGlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.search_off_rounded,
            color: AtlasColors.vaultGold,
          ),
          const SizedBox(width: AtlasSpacing.md),
          Expanded(
            child: Text(
              message,
              style: AtlasTypography.bodyMedium.copyWith(
                color: AtlasColors.textSecondary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _messageForCurrentView() {
    final hasSearch = searchQuery.trim().isNotEmpty;

    if (hasSearch) {
      return 'No Pops matched your search. Try a different name, number, category, series, or owner.';
    }

    switch (filterMode) {
      case _VaultFilterMode.needsValue:
        return 'No Pops need values in this view. Your vault is looking more complete.';

      case _VaultFilterMode.duplicates:
        return 'No duplicate review groups found. Nice cleanup.';

      case _VaultFilterMode.wishlist:
        return 'No wishlist Pops found in this view.';

      case _VaultFilterMode.exclusives:
        return 'No exclusive Pops found in this view.';

      case _VaultFilterMode.signed:
        return 'No signed Pops found in this view.';

      case _VaultFilterMode.limited:
        return 'No limited edition Pops found in this view.';

      case _VaultFilterMode.variants:
        return 'No variant Pops found in this view.';

      case _VaultFilterMode.stickers:
        return 'No stickered Pops found in this view.';

      case _VaultFilterMode.owned:
        return 'No owned Pops found in this view.';

      case _VaultFilterMode.hasValue:
        return 'No Pops with values found in this view.';

      case _VaultFilterMode.all:
        return 'No Pops matched this view. Try clearing search, choosing All, or using a different filter.';
    }
  }
}

class _VaultPopListCard extends StatelessWidget {
  const _VaultPopListCard({
    required this.pops,
    required this.totalFilteredCount,
    required this.hasMoreResults,
    required this.sortMode,
    required this.filterMode,
    required this.showImages,
    required this.onLoadMore,
  });

  final List<Pop> pops;
  final int totalFilteredCount;
  final bool hasMoreResults;
  final _VaultSortMode sortMode;
  final _VaultFilterMode filterMode;
  final bool showImages;
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
              child: _VaultPopTile(
                pop: pop,
                showImage: showImages,
              ),
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
    required this.showImage,
  });

  final Pop pop;
  final bool showImage;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showImage) ...[
              Center(
                child: _VaultPopThumbnail(
                  imageUrl: pop.imageUrl,
                ),
              ),
              const SizedBox(height: AtlasSpacing.md),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!showImage) ...[
                  const Icon(
                    Icons.inventory_2_outlined,
                    color: AtlasColors.vaultGold,
                  ),
                  const SizedBox(width: AtlasSpacing.md),
                ],
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
                      _VaultPopBadges(
                        pop: pop,
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
          ],
        ),
      ),
    );
  }
}

class _VaultPopBadges extends StatelessWidget {
  const _VaultPopBadges({
    required this.pop,
  });

  final Pop pop;

  @override
  Widget build(BuildContext context) {
    final badges = _buildBadges();

    if (badges.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: AtlasSpacing.xs,
      runSpacing: AtlasSpacing.xs,
      children: badges
          .map(
            (badge) => _VaultPopBadge(
          label: badge,
        ),
      )
          .toList(),
    );
  }

  List<String> _buildBadges() {
    final badges = <String>[];

    if (pop.value <= 0) {
      badges.add('Needs Value');
    }

    if (pop.isWishlist) {
      badges.add('Wishlist');
    }

    if (_hasMeaningfulValue(pop.variant)) {
      badges.add(_cleanBadgeLabel(pop.variant));
    }

    if (_hasMeaningfulValue(pop.retailExclusive)) {
      badges.add('Exclusive');
    }

    if (_hasMeaningfulValue(pop.eventSticker)) {
      badges.add('Sticker');
    }

    if (_hasMeaningfulValue(pop.limitedEdition)) {
      badges.add('Limited');
    }

    if (_hasMeaningfulValue(pop.signature)) {
      badges.add('Signed');
    }

    return badges;
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

  String _cleanBadgeLabel(String value) {
    final cleaned = value.trim();

    if (cleaned.length <= 16) {
      return cleaned;
    }

    return '${cleaned.substring(0, 16)}...';
  }
}

class _VaultPopBadge extends StatelessWidget {
  const _VaultPopBadge({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AtlasSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: AtlasColors.vaultGold.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AtlasColors.vaultGold.withValues(alpha: 0.34),
        ),
      ),
      child: Text(
        label,
        style: AtlasTypography.bodySmall.copyWith(
          color: AtlasColors.vaultGold,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _VaultPopThumbnail extends StatelessWidget {
  const _VaultPopThumbnail({
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final cleanImageUrl = imageUrl.trim();

    return Container(
      width: 54,
      height: 68,
      decoration: BoxDecoration(
        color: AtlasColors.textSecondary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AtlasSpacing.sm),
        border: Border.all(
          color: AtlasColors.vaultGold.withValues(alpha: 0.28),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: cleanImageUrl.isEmpty
          ? const Icon(
        Icons.inventory_2_rounded,
        size: 28,
      )
          : Image.network(
        cleanImageUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }

          return const Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.broken_image_rounded,
            size: 28,
          );
        },
      ),
    );
  }
}

class _ValueCleanupBanner extends StatelessWidget {
  const _ValueCleanupBanner();

  @override
  Widget build(BuildContext context) {
    return AtlasGlassPanel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.attach_money_rounded,
            color: AtlasColors.vaultGold,
          ),
          const SizedBox(width: AtlasSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Value Cleanup',
                  style: AtlasTypography.bodyMedium.copyWith(
                    color: AtlasColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AtlasSpacing.xs),
                Text(
                  'These Pops are missing values. Add trusted values when available so Atlas can calculate vault health and collection strength more accurately.',
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

class _DuplicateReviewBanner extends StatelessWidget {
  const _DuplicateReviewBanner();

  @override
  Widget build(BuildContext context) {
    return AtlasGlassPanel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AtlasColors.vaultGold,
          ),
          const SizedBox(width: AtlasSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Duplicate Review',
                  style: AtlasTypography.bodyMedium.copyWith(
                    color: AtlasColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AtlasSpacing.xs),
                Text(
                  'These are possible duplicate or variant review groups. Check Chase, stickers, exclusives, signed, limited edition, and variant details before making changes.',
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
