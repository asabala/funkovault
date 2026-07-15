import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pop/edit_pop_screen.dart';
import 'duplicate_group_review_screen.dart';
import '../../atlas/repositories/vault_repository.dart';
import '../../models/pop.dart';
import '../../services/app_state.dart';
import '../../services/hive_service.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../vault/duplicate_review/duplicate_review_engine.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/atlas_glass_panel.dart';
import '../../widgets/atlas/atlas_stat_tile.dart';
import '../../widgets/atlas/components/atlas_empty_state.dart';
import '../../widgets/atlas/components/atlas_info_banner.dart';
import '../../widgets/atlas/components/atlas_section_header.dart';
import '../../widgets/vault/components/duplicate_review_section.dart';
import '../../vault/utils/vault_display_utils.dart';
import '../../widgets/vault/sections/vault_controls_section.dart';
import '../../widgets/vault/sections/vault_list_section.dart';
import '../../widgets/vault/sections/vault_search_section.dart';
import '../../widgets/vault/sections/vault_status_section.dart';
import '../../widgets/vault/vault_breakdown_card.dart';

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
  Future<void> _openDuplicateReviewGroup(
      DuplicateReviewGroup group,
      ) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => DuplicateGroupReviewScreen(
          groupKey: group.key,
        ),
      ),
    );
  }

  Future<void> _openValueEditor(Pop pop) async {
    await Navigator.push<Pop>(
      context,
      MaterialPageRoute(
        builder: (_) => EditPopScreen(
          pop: pop,
          focusValueField: true,
        ),
      ),
    );
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
    const duplicateReviewEngine = DuplicateReviewEngine();

    final pops = repository.allPops(appState);
    final searchedPops = _filterBySearch(pops);
    final filteredPops = _sortPops(
      _filterByMode(
        searchedPops,
      ),
    );

    final duplicateReviewGroups =
    _filterMode == _VaultFilterMode.duplicates
        ? duplicateReviewEngine.buildGroups(filteredPops)
        : <DuplicateReviewGroup>[];

    final visibleDuplicateReviewGroups =
    duplicateReviewEngine.takeVisibleGroups(
      duplicateReviewGroups,
      _visibleLimit,
    );

    final visiblePops =
    _filterMode == _VaultFilterMode.duplicates
        ? visibleDuplicateReviewGroups
        .expand(
          (group) => group.pops,
    )
        .toList()
        : filteredPops.take(_visibleLimit).toList();

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

    final currentViewDuplicateGroupCount =
    duplicateReviewEngine.countGroups(
      searchedPops,
    );

    final hasActiveReviewControls = _searchQuery.trim().isNotEmpty ||
        _filterMode != _VaultFilterMode.all ||
        _sortMode != _VaultSortMode.nameAz ||
        _showImages;

    final missingValueCount = pops.where((pop) => pop.value <= 0).length;

    final ownedCount = pops.where((pop) => !pop.isWishlist).length;
    final wishlistCount = pops.where((pop) => pop.isWishlist).length;
    final exclusiveCount = pops
        .where((pop) => hasMeaningfulVaultValue(pop.retailExclusive))
        .length;
    final variantCount = pops
        .where((pop) => hasMeaningfulVaultValue(pop.variant))
        .length;
    final stickerCount = pops
        .where((pop) => hasMeaningfulVaultValue(pop.eventSticker))
        .length;
    final signedCount = pops
        .where((pop) => hasMeaningfulVaultValue(pop.signature))
        .length;
    final limitedCount = pops
        .where((pop) => hasMeaningfulVaultValue(pop.limitedEdition))
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
                    const AtlasSectionHeader(
                      title: 'Entire Vault',
                      subtitle:
                      'Review every Pop currently saved in your collection.',
                      icon: Icons.inventory_2_rounded,
                      titleStyle: AtlasTypography.headingLarge,
                    ),
                    const SizedBox(height: AtlasSpacing.lg),
                    AtlasGlassPanel(
                      child: Row(
                        children: [
                          Expanded(
                            child: AtlasStatTile(
                              value: '${pops.length}',
                              label: 'Pops',
                            ),
                          ),
                          Expanded(
                            child: AtlasStatTile(
                              value: '\$${totalValue.toStringAsFixed(0)}',
                              label: 'Value',
                            ),
                          ),
                          Expanded(
                            child: AtlasStatTile(
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

              if (_filterMode == _VaultFilterMode.needsValue) ...[
                const SizedBox(height: AtlasSpacing.md),
                const AtlasInfoBanner(
                  icon: Icons.attach_money_rounded,
                  title: 'Value Cleanup',
                  message:
                  'These Pops are missing values. Add trusted values when available so Atlas can calculate vault health and collection strength more accurately.',
                ),
              ],

              if (_filterMode == _VaultFilterMode.duplicates) ...[
                const SizedBox(height: AtlasSpacing.md),
                const AtlasInfoBanner(
                  icon: Icons.info_outline_rounded,
                  title: 'Duplicate Review',
                  message:
                  'These are possible duplicate or variant review groups. Check Chase, stickers, exclusives, signed, limited edition, and variant details before making changes.',
                ),
              ],

              const SizedBox(height: AtlasSpacing.lg),

              VaultSearchSection(
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

              VaultControlsSection<_VaultFilterMode, _VaultSortMode>(
                selectedFilter: _filterMode,
                selectedSort: _sortMode,
                filterValues: _VaultFilterMode.values,
                sortValues: _VaultSortMode.values,
                filterLabelBuilder: (value) => value.label,
                sortLabelBuilder: (value) => value.label,
                hasActiveControls: hasActiveReviewControls,
                showImages: _showImages,
                isDefaultFilter: (value) {
                  return value == _VaultFilterMode.all;
                },
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
                onImageVisibilityChanged: (value) async {
                  setState(() {
                    _showImages = value;
                  });

                  await _saveVaultPreferences();
                },
                onReset: _resetVaultReviewControls,
              ),

              const SizedBox(height: AtlasSpacing.md),

              VaultStatusSection(
                visibleCount: filteredPops.length,
                totalCount: pops.length,
                searchedCount: searchedPops.length,
                filterLabel: _filterMode.label,
                sortLabel: _sortMode.label,
                searchQuery: _searchQuery,
                resultCount: filteredPops.length,
                currentValue: currentViewValue,
                missingValueCount: currentViewMissingValueCount,
                duplicateGroupCount: currentViewDuplicateGroupCount,
                showDuplicateGroups:
                _filterMode == _VaultFilterMode.duplicates,
                cleanupFocusTitle: _cleanupFocusTitle,
                cleanupFocusMessage: _cleanupFocusMessage,
                onClearCleanupFocus:
                _cleanupFocusTitle != null &&
                    _cleanupFocusMessage != null
                    ? _clearCleanupFocus
                    : null,
              ),

              const SizedBox(height: AtlasSpacing.lg),
              if (pops.isEmpty)
                const AtlasEmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: 'Your Vault Is Empty',
                  message:
                  'Your vault is ready. Add your first Pop to begin building your collection.',
                )
              else if (filteredPops.isEmpty)
                AtlasEmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'No Results Found',
                  message: _emptyStateMessage(
                    filterMode: _filterMode,
                    searchQuery: _searchQuery,
                  ),
                )
              else if (_filterMode == _VaultFilterMode.duplicates)
                  DuplicateReviewSection(
                    groups: visibleDuplicateReviewGroups,
                    totalGroupCount: duplicateReviewGroups.length,
                    totalPopCount: filteredPops.length,
                    visiblePopCount: visiblePops.length,
                    hasMoreResults: hasMoreResults,
                    sortLabel: _sortMode.label,
                    showImages: _showImages,
                    onReviewGroup: _openDuplicateReviewGroup,
                    onLoadMore: () {
                      _loadMoreResults(
                        filteredPops.length,
                      );
                    },
                  )
                else
                  VaultListSection(
                    pops: visiblePops,
                    totalResultCount: filteredPops.length,
                    hasMoreResults: hasMoreResults,
                    filterLabel: _filterMode.label,
                    sortLabel: _sortMode.label,
                    showImages: _showImages,
                    onAddValue:
                    _filterMode == _VaultFilterMode.needsValue
                        ? _openValueEditor
                        : null,
                    onLoadMore: () {
                      _loadMoreResults(
                        filteredPops.length,
                      );
                    },
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

  String _emptyStateMessage({
    required _VaultFilterMode filterMode,
    required String searchQuery,
  }) {
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
              (pop) => hasMeaningfulVaultValue(pop.retailExclusive),
        )
            .toList();

      case _VaultFilterMode.signed:
        return pops
            .where(
              (pop) => hasMeaningfulVaultValue(pop.signature),
        )
            .toList();

      case _VaultFilterMode.limited:
        return pops
            .where(
              (pop) => hasMeaningfulVaultValue(pop.limitedEdition),
        )
            .toList();

      case _VaultFilterMode.variants:
        return pops
            .where(
              (pop) => hasMeaningfulVaultValue(pop.variant),
        )
            .toList();

      case _VaultFilterMode.stickers:
        return pops
            .where(
              (pop) => hasMeaningfulVaultValue(pop.eventSticker),
        )
            .toList();

      case _VaultFilterMode.duplicates:
        return const DuplicateReviewEngine().filterReviewPops(pops);
    }
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
