import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:funkovault2/atlas/catalog/models/atlas_catalog_product.dart';
import 'package:funkovault2/atlas/completion/models/atlas_completion_result.dart';
import 'package:funkovault2/atlas/completion/services/atlas_completion_service.dart';
import 'package:funkovault2/atlas/intelligence/engines/atlas_collector_insight_engine.dart';
import 'package:funkovault2/atlas/intelligence/models/atlas_collector_insight.dart';
import 'package:funkovault2/atlas/search/services/atlas_catalog_search_coordinator.dart';
import 'package:funkovault2/models/pop.dart';
import 'package:funkovault2/screens/pop/pop_details_screen.dart';
import 'package:funkovault2/services/app_state.dart';
import 'package:funkovault2/theme/atlas_colors.dart';
import 'package:funkovault2/theme/atlas_motion.dart';
import 'package:funkovault2/theme/atlas_spacing.dart';
import 'package:funkovault2/theme/atlas_typography.dart';
import 'package:funkovault2/widgets/atlas/atlas_glass_card.dart';
import 'package:funkovault2/widgets/atlas/components/atlas_empty_state.dart';
import 'package:funkovault2/widgets/atlas/components/atlas_error_state.dart';
import 'package:funkovault2/widgets/atlas/components/atlas_insight_panel.dart';
import 'package:funkovault2/widgets/atlas/components/atlas_loading_state.dart';
import 'package:funkovault2/widgets/atlas/components/atlas_product_image.dart';
import 'package:funkovault2/widgets/atlas/components/atlas_status_chip.dart';
import 'package:funkovault2/widgets/atlas/components/atlas_search_status.dart';
import 'package:funkovault2/widgets/atlas/components/atlas_search_field.dart';
import 'package:funkovault2/widgets/atlas/completion/atlas_completion_preview_card.dart';

class AtlasCollectorSearchScreen extends StatefulWidget {
  const AtlasCollectorSearchScreen({
    super.key,
  });

  @override
  State<AtlasCollectorSearchScreen> createState() =>
      _AtlasCollectorSearchScreenState();
}

class _AtlasCollectorSearchScreenState
    extends State<AtlasCollectorSearchScreen> {
  final TextEditingController _searchController =
  TextEditingController();

  final FocusNode _searchFocusNode =
  FocusNode();

  final AtlasCatalogSearchCoordinator
  _searchCoordinator =
  AtlasCatalogSearchCoordinator();
  final AtlasCompletionService
  _completionService =
      AtlasCompletionService.instance;
  final Map<String, AtlasCompletionPreviewState>
  _completionStates =
  <String, AtlasCompletionPreviewState>{};

  final Map<String, AtlasCompletionResult>
  _completionResults =
  <String, AtlasCompletionResult>{};

  final Map<String, String> _completionErrors =
  <String, String>{};

  final Set<String> _expandedCompletionKeys =
  <String>{};

  final Map<String, int> _completionRequestIds =
  <String, int>{};

  int _nextCompletionRequestId = 0;

  Timer? _searchDebounce;

  List<_AtlasSearchEntry> _searchEntries =
  const <_AtlasSearchEntry>[];

  String _query = '';
  String? _searchError;

  bool _isSearching = false;

  int _searchRequestId = 0;

  String _buildSearchStatusText({
    required String query,
    required int resultCount,
    required bool isSearching,
  }) {
    final bool hasQuery = query.trim().isNotEmpty;

    if (!hasQuery) {
      return 'Catalog + Vault Intelligence';
    }

    if (isSearching && resultCount == 0) {
      return 'Searching Atlas catalog...';
    }

    return '$resultCount result'
        '${resultCount == 1 ? '' : 's'} • Catalog + Vault';
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
          (_) {
        if (mounted) {
          _searchFocusNode.requestFocus();
        }
      },
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppState appState =
    context.watch<AppState>();

    final List<_AtlasSearchEntry> rankedResults =
    _rankEntries(
      entries: _searchEntries,
      query: _query,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search Atlas',
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AtlasSpacing.md,
                AtlasSpacing.md,
                AtlasSpacing.md,
                AtlasSpacing.sm,
              ),
              child: AtlasSearchField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                hintText: 'Search Pops, variants, UPCs...',
                onChanged: (
                    String value,
                    ) {
                  _scheduleSearch(
                    query: value,
                    appState: appState,
                  );
                },
                onClear: _clearSearch,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AtlasSpacing.md,
              ),
              child: AtlasSearchStatus(
                statusText: _buildSearchStatusText(
                  query: _query,
                  resultCount: rankedResults.length,
                  isSearching: _isSearching,
                ),
              ),
            ),
            const SizedBox(
              height: AtlasSpacing.sm,
            ),
            Expanded(
              child: _buildBody(
                context: context,
                appState: appState,
                results: rankedResults,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scheduleSearch({
    required String query,
    required AppState appState,
  }) {
    _searchDebounce?.cancel();

    final String cleanedQuery =
    query.trim();

    setState(
          () {
        _query = query;
        _searchError = null;

        _clearCompletionState();

        if (cleanedQuery.isEmpty) {
          _searchEntries =
          const <_AtlasSearchEntry>[];

          _isSearching = false;
        }
      },
    );

    if (cleanedQuery.isEmpty) {
      _searchRequestId++;

      return;
    }

    _searchDebounce = Timer(
      AtlasMotion.searchDebounceDuration,
          () {
        _runSearch(
          query: cleanedQuery,
          appState: appState,
        );
      },
    );
  }

  Future<void> _runSearch({
    required String query,
    required AppState appState,
  }) async {
    final int requestId =
    ++_searchRequestId;

    if (mounted) {
      setState(
            () {
          _isSearching = true;
          _searchError = null;
        },
      );
    }

    try {
      final List<AtlasCatalogSearchCandidate>
      candidates =
      await _searchCoordinator.search(
        query: query,
        collections: appState.collections,
        limit: 200,
      );

      if (!mounted ||
          requestId != _searchRequestId) {
        return;
      }

      final List<_AtlasSearchEntry> entries =
      candidates
          .map(
            (
            AtlasCatalogSearchCandidate
            candidate,
            ) {
              return _AtlasSearchEntry(
                pop: candidate.pop,
                catalogProduct: candidate.catalogProduct,
                sourceLabel: candidate.sourceLabel,
                isCatalogBacked: candidate.isCatalogBacked,
                collectionNames: candidate.collectionNames,
              );
        },
      )
          .toList(
        growable: false,
      );

      setState(
            () {
          _searchEntries =
          List<_AtlasSearchEntry>
              .unmodifiable(
            entries,
          );

          _isSearching = false;
        },
      );
    } catch (error) {
      if (!mounted ||
          requestId != _searchRequestId) {
        return;
      }

      setState(
            () {
          _searchEntries =
          const <_AtlasSearchEntry>[];

          _isSearching = false;

          _searchError =
          'Atlas could not search the catalog. '
              'Please try again.';
        },
      );
    }
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchRequestId++;

    _searchController.clear();

    setState(
          () {
        _query = '';
        _searchEntries =
        const <_AtlasSearchEntry>[];

        _searchError = null;
        _isSearching = false;

        _clearCompletionState();
      },
    );

    _searchFocusNode.requestFocus();
  }
  void _clearCompletionState() {
    _completionStates.clear();
    _completionResults.clear();
    _completionErrors.clear();
    _expandedCompletionKeys.clear();
    _completionRequestIds.clear();
  }
  void _handleCompletionPressed({
    required _AtlasSearchEntry entry,
    required AppState appState,
  }) {
    if (!entry.canLoadCompletion) {
      return;
    }

    final String completionKey =
    _completionKeyFor(
      entry,
    );

    final AtlasCompletionPreviewState state =
        _completionStates[completionKey] ??
            AtlasCompletionPreviewState.idle;

    if (state ==
        AtlasCompletionPreviewState.loading) {
      return;
    }

    if (state ==
        AtlasCompletionPreviewState.loaded) {
      setState(
            () {
          if (_expandedCompletionKeys.contains(
            completionKey,
          )) {
            _expandedCompletionKeys.remove(
              completionKey,
            );
          } else {
            _expandedCompletionKeys.add(
              completionKey,
            );
          }
        },
      );

      return;
    }

    setState(
          () {
        _expandedCompletionKeys.add(
          completionKey,
        );

        _completionStates[completionKey] =
            AtlasCompletionPreviewState.loading;

        _completionErrors.remove(
          completionKey,
        );
      },
    );

    _loadCompletion(
      entry: entry,
      appState: appState,
      completionKey: completionKey,
    );
  }

  Future<void> _loadCompletion({
    required _AtlasSearchEntry entry,
    required AppState appState,
    required String completionKey,
  }) async {
    final AtlasCatalogProduct? catalogProduct =
        entry.catalogProduct;

    if (catalogProduct == null) {
      return;
    }

    final int requestId =
    ++_nextCompletionRequestId;

    _completionRequestIds[completionKey] =
        requestId;

    final List<Pop> vaultPops =
    appState.collections.values
        .expand(
          (
          List<Pop> collection,
          ) {
        return collection;
      },
    )
        .toList(
      growable: false,
    );

    try {
      final AtlasCompletionResult result =
      await _completionService
          .evaluateVariantFamily(
        selectedProduct: catalogProduct,
        collectionPops: vaultPops,
        ownedWishlistIdentityKeys:
        appState.allOwnedWishlistIdentityKeys,
        collectionName:
        'All Atlas Collections',
      );

      if (!mounted ||
          _completionRequestIds[completionKey] !=
              requestId) {
        return;
      }

      setState(
            () {
          _completionResults[completionKey] =
              result;

          _completionStates[completionKey] =
              AtlasCompletionPreviewState.loaded;

          _completionErrors.remove(
            completionKey,
          );
        },
      );
    } catch (error) {
      if (!mounted ||
          _completionRequestIds[completionKey] !=
              requestId) {
        return;
      }

      setState(
            () {
          _completionStates[completionKey] =
              AtlasCompletionPreviewState.error;

          _completionErrors[completionKey] =
          'Unable to calculate progress. Tap to retry.';
        },
      );
    }
  }

  String _completionKeyFor(
      _AtlasSearchEntry entry,
      ) {
    final String catalogProductId =
        entry.catalogProduct
            ?.productId.value
            .trim()
            .toLowerCase() ??
            '';

    if (catalogProductId.isNotEmpty) {
      return 'catalog:$catalogProductId';
    }

    final String sourceCatalogId =
    entry.pop.sourceCatalogId
        .trim()
        .toLowerCase();

    if (sourceCatalogId.isNotEmpty) {
      return 'catalog:$sourceCatalogId';
    }

    return <String>[
      'release',
      _normalizeSearchText(
        entry.pop.name,
      ),
      _normalizeSearchText(
        entry.pop.number,
      ),
      _normalizeSearchText(
        entry.pop.variant,
      ),
    ].join(
      ':',
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required AppState appState,
    required List<_AtlasSearchEntry> results,
  }) {
    if (_query.trim().isEmpty) {
      return const Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(
            AtlasSpacing.xl,
          ),
          child: AtlasEmptyState(
            eyebrow: 'Search',
            icon: Icons.manage_search_rounded,
            title: 'Search the Atlas Catalog',
            message:
            'Search by name, number, series, category, variant, retailer, sticker, UPC, or catalog ID.',
            tone: AtlasEmptyStateTone.intelligence,
          ),
        ),
      );
    }

    if (_isSearching &&
        results.isEmpty) {
      return const Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(
            AtlasSpacing.xl,
          ),
          child: AtlasLoadingState(
            title: 'Searching the Atlas catalog',
            message:
            'Atlas is checking catalog records and your Vault for the best matches.',
            progressLabel: 'Atlas Search',
            compact: true,
          ),
        ),
      );
    }

    if (_searchError != null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(
            AtlasSpacing.xl,
          ),
          child: AtlasErrorState(
            eyebrow: 'Search',
            title: 'Search unavailable',
            message: _searchError!,
            tone: AtlasErrorStateTone.warning,
            actionLabel: 'Try Again',
            onAction: () {
              final String cleanedQuery =
              _query.trim();

              if (cleanedQuery.isEmpty) {
                return;
              }

              _runSearch(
                query: cleanedQuery,
                appState: appState,
              );
            },
          ),
        ),
      );
    }

    if (results.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(
            AtlasSpacing.xl,
          ),
          child: AtlasEmptyState(
            eyebrow: 'Search',
            icon: Icons.search_off_rounded,
            title: 'No Results Found',
            message:
            'Atlas could not find a catalog or Vault record matching “${_query.trim()}”.',
            tone: AtlasEmptyStateTone.neutral,
          ),
        ),
      );
    }

    final List<Pop> vaultPops =
    appState.collections.values
        .expand(
          (
          List<Pop> collection,
          ) {
        return collection;
      },
    )
        .toList(
      growable: false,
    );

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.fromLTRB(
            AtlasSpacing.md,
            AtlasSpacing.sm,
            AtlasSpacing.md,
            AtlasSpacing.xl,
          ),
          itemCount: results.length,
          itemBuilder: (
              BuildContext context,
              int index,
              ) {
            final _AtlasSearchEntry entry =
            results[index];

            final String completionKey =
            _completionKeyFor(
              entry,
            );

            final AtlasCompletionPreviewState
            completionState =
                _completionStates[completionKey] ??
                    AtlasCompletionPreviewState.idle;

            final AtlasCompletionResult?
            completionResult =
            _completionResults[completionKey];

            final bool isCompletionExpanded =
            _expandedCompletionKeys.contains(
              completionKey,
            );

            final AtlasCollectorInsight insight =
            const AtlasCollectorInsightEngine()
                .evaluateProduct(
              product: entry.pop,

              // Important:
              // Only actual Vault records are passed
              // into ownership evaluation.
              collectionPops: vaultPops,

              collectionName:
              'All Atlas Collections',

              ownedWishlistIdentityKeys:
              appState
                  .allOwnedWishlistIdentityKeys,

              source:
              entry.isCatalogBacked
                  ? 'Atlas Catalog Search'
                  : 'Atlas Vault Search',
            );

            return Padding(
              padding: const EdgeInsets.only(
                bottom: AtlasSpacing.md,
              ),
              child: _AtlasSearchResultCard(
                entry: entry,
                insight: insight,
                completionState:
                completionState,
                completionResult:
                completionResult,
                completionError:
                _completionErrors[completionKey],
                isCompletionExpanded:
                isCompletionExpanded,
                onCompletionPressed:
                entry.canLoadCompletion
                    ? () {
                  _handleCompletionPressed(
                    entry: entry,
                    appState: appState,
                  );
                }
                    : null,
                onPressed: () {
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) {
                        return PopDetailsScreen(
                          pop: _detailsPopFor(
                            entry: entry,
                            insight: insight,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            );
          },
        ),
        if (_isSearching)
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }

  Pop _detailsPopFor({
    required _AtlasSearchEntry entry,
    required AtlasCollectorInsight insight,
  }) {
    final Pop? ownedMatch =
        insight.state.primaryOwnedMatch;

    if (ownedMatch != null) {
      return ownedMatch;
    }

    return entry.pop;
  }

  List<_AtlasSearchEntry> _rankEntries({
    required List<_AtlasSearchEntry> entries,
    required String query,
  }) {
    final String normalizedQuery =
    _normalizeSearchText(
      query,
    );

    if (normalizedQuery.isEmpty) {
      return const <_AtlasSearchEntry>[];
    }

    final List<_RankedSearchEntry>
    rankedResults =
    <_RankedSearchEntry>[];

    for (final _AtlasSearchEntry entry
    in entries) {
      final int score = _searchScore(
        entry: entry,
        normalizedQuery:
        normalizedQuery,
      );

      if (score < 0) {
        continue;
      }

      rankedResults.add(
        _RankedSearchEntry(
          entry: entry,
          score: score,
        ),
      );
    }

    rankedResults.sort(
          (
          _RankedSearchEntry first,
          _RankedSearchEntry second,
          ) {
        final int scoreComparison =
        second.score.compareTo(
          first.score,
        );

        if (scoreComparison != 0) {
          return scoreComparison;
        }

        final int nameComparison =
        first.entry.pop.name
            .toLowerCase()
            .compareTo(
          second.entry.pop.name
              .toLowerCase(),
        );

        if (nameComparison != 0) {
          return nameComparison;
        }

        final int numberComparison =
        first.entry.pop.number.compareTo(
          second.entry.pop.number,
        );

        if (numberComparison != 0) {
          return numberComparison;
        }

        return first.entry.pop
            .sourceCatalogId
            .compareTo(
          second.entry.pop
              .sourceCatalogId,
        );
      },
    );

    return List<_AtlasSearchEntry>.unmodifiable(
      rankedResults
          .map(
            (
            _RankedSearchEntry result,
            ) {
          return result.entry;
        },
      )
          .toList(
        growable: false,
      ),
    );
  }

  int _searchScore({
    required _AtlasSearchEntry entry,
    required String normalizedQuery,
  }) {
    final Pop pop =
        entry.pop;

    final String normalizedName =
    _normalizeSearchText(
      pop.name,
    );

    final String normalizedNumber =
    _normalizeSearchText(
      pop.number,
    );

    final String normalizedUpc =
    _normalizeSearchText(
      pop.sourceUpc,
    );

    final String normalizedCatalogId =
    _normalizeSearchText(
      pop.sourceCatalogId,
    );

    final String normalizedCollectibleId =
    _normalizeSearchText(
      pop.sourceCollectibleId,
    );

    final String completeSearchText =
    _searchTextForEntry(
      entry,
    );

    if (normalizedName ==
        normalizedQuery) {
      return 1000;
    }

    if (normalizedNumber ==
        normalizedQuery) {
      return 950;
    }

    if (normalizedUpc ==
        normalizedQuery) {
      return 940;
    }

    if (normalizedCatalogId ==
        normalizedQuery ||
        normalizedCollectibleId ==
            normalizedQuery) {
      return 930;
    }

    if (normalizedName.startsWith(
      normalizedQuery,
    )) {
      return 800;
    }

    if (normalizedName.contains(
      normalizedQuery,
    )) {
      return 700;
    }

    if (normalizedNumber.startsWith(
      normalizedQuery,
    )) {
      return 650;
    }

    if (completeSearchText.contains(
      normalizedQuery,
    )) {
      return 500;
    }

    return -1;
  }

  String _searchTextForEntry(
      _AtlasSearchEntry entry,
      ) {
    final Pop pop =
        entry.pop;

    return _normalizeSearchText(
      <String>[
        pop.name,
        pop.number,
        pop.category,
        pop.series,
        pop.edition,
        pop.variant,
        pop.retailExclusive,
        pop.eventSticker,
        pop.limitedEdition,
        pop.signature,
        pop.owner,
        pop.sourceUpc,
        pop.sourceCatalogId,
        pop.sourceCollectibleId,
        pop.collectorLabel,
        entry.sourceLabel,
        ...entry.collectionNames,
        entry.isCatalogBacked
            ? 'catalog'
            : 'vault',
        pop.isWishlist
            ? 'wishlist'
            : '',
      ].join(
        ' ',
      ),
    );
  }

  String _normalizeSearchText(
      String value,
      ) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(
      RegExp(
        r'[^a-z0-9]+',
      ),
      ' ',
    )
        .replaceAll(
      RegExp(
        r'\s+',
      ),
      ' ',
    )
        .trim();
  }
}

class _AtlasSearchResultCard
    extends StatelessWidget {
  const _AtlasSearchResultCard({
    required this.entry,
    required this.insight,
    required this.completionState,
    required this.completionResult,
    required this.isCompletionExpanded,
    required this.onPressed,
    this.completionError,
    this.onCompletionPressed,
  });

  final _AtlasSearchEntry entry;

  final AtlasCollectorInsight insight;

  final AtlasCompletionPreviewState
  completionState;

  final AtlasCompletionResult?
  completionResult;

  final String? completionError;

  final bool isCompletionExpanded;

  final VoidCallback? onCompletionPressed;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final Pop pop =
        entry.pop;

    return AtlasGlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onPressed,
            borderRadius:
            BorderRadius.circular(
              28,
            ),
            child: Padding(
              padding: const EdgeInsets.all(
                AtlasSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      AtlasProductImage(
                        imageUrl: pop.imageUrl,
                        width: 64,
                        height: 74,
                        borderRadius: 12,
                        placeholderIcon: Icons.inventory_2_outlined,
                        errorIcon: Icons.broken_image_outlined,
                        showBorder: false,
                      ),
                      const SizedBox(
                        width:
                        AtlasSpacing.md,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                          children: [
                            Text(
                              pop.name,
                              style:
                              AtlasTypography
                                  .headingSmall,
                            ),
                            if (pop.number
                                .trim()
                                .isNotEmpty) ...[
                              const SizedBox(
                                height:
                                AtlasSpacing.xs,
                              ),
                              Text(
                                '#${pop.number.trim()}',
                                style:
                                AtlasTypography
                                    .bodySmall
                                    .copyWith(
                                  color: AtlasColors
                                      .textSecondary,
                                ),
                              ),
                            ],
                            const SizedBox(
                              height:
                              AtlasSpacing.xs,
                            ),
                            Text(
                              entry.sourceLabel,
                              style:
                              AtlasTypography
                                  .bodySmall
                                  .copyWith(
                                color: AtlasColors
                                    .intelligenceBlue,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons
                            .chevron_right_rounded,
                      ),
                    ],
                  ),
                  if (insight.summary
                      .hasIdentityBadges) ...[
                    const SizedBox(
                      height:
                      AtlasSpacing.md,
                    ),
                    Wrap(
                      spacing:
                      AtlasSpacing.sm,
                      runSpacing:
                      AtlasSpacing.sm,
                      children: [
                        for (final badge
                        in insight.summary.identityBadges)
                          AtlasStatusChip(
                            label: badge.displayLabel,
                            accentColor: AtlasColors.vaultGold,
                            size: AtlasStatusChipSize.compact,
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(
                    height: AtlasSpacing.md,
                  ),
                  Wrap(
                    spacing: AtlasSpacing.sm,
                    runSpacing: AtlasSpacing.sm,
                    children: [
                      AtlasStatusChip(
                        label: insight.isOwned
                            ? 'Owned x${insight.ownedQuantity}'
                            : 'Missing from Vault',
                        icon: insight.isOwned
                            ? Icons.inventory_2_rounded
                            : Icons.inventory_2_outlined,
                        accentColor: insight.isOwned
                            ? AtlasColors.success
                            : AtlasColors.textSecondary,
                        size: AtlasStatusChipSize.compact,
                      ),
                      if (insight.isWishlisted)
                        const AtlasStatusChip(
                          label: 'Wishlist',
                          icon: Icons.favorite_rounded,
                          accentColor: AtlasColors.warning,
                          size: AtlasStatusChipSize.compact,
                        ),
                      AtlasStatusChip(
                        label:
                        insight.summary.formattedMarketValue,
                        icon: Icons.attach_money_rounded,
                        accentColor: AtlasColors.vaultGold,
                        size: AtlasStatusChipSize.compact,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: AtlasSpacing.md,
                  ),
                  AtlasInsightPanel(
                    eyebrow:
                    insight.summary.recommendation.categoryLabel,
                    title:
                    insight.summary.recommendationTitle,
                    message:
                    insight.summary.recommendationMessage,
                    icon: Icons.psychology_rounded,
                    tone: AtlasInsightPanelTone.intelligence,
                  ),
                  Container(
                    width: double.infinity,
                    padding:
                    const EdgeInsets.all(
                      AtlasSpacing.md,
                    ),
                    decoration:
                    BoxDecoration(
                      borderRadius:
                      BorderRadius.circular(
                        14,
                      ),
                      color: AtlasColors
                          .intelligenceBlue
                          .withValues(
                        alpha: 0.08,
                      ),
                      border: Border.all(
                        color: AtlasColors
                            .intelligenceBlue
                            .withValues(
                          alpha: 0.20,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Text(
                          insight
                              .summary
                              .recommendation
                              .categoryLabel
                              .toUpperCase(),
                          style: AtlasTypography
                              .bodySmall
                              .copyWith(
                            color: AtlasColors
                                .intelligenceBlue,
                            fontWeight:
                            FontWeight.bold,
                            letterSpacing:
                            0.7,
                          ),
                        ),
                        const SizedBox(
                          height:
                          AtlasSpacing.xs,
                        ),
                        Text(
                          insight.summary
                              .recommendationTitle,
                          style:
                          AtlasTypography
                              .headingSmall,
                        ),
                        const SizedBox(
                          height:
                          AtlasSpacing.xs,
                        ),
                        Text(
                          insight.summary
                              .recommendationMessage,
                          style: AtlasTypography
                              .bodySmall
                              .copyWith(
                            color: AtlasColors
                                .textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (entry.canLoadCompletion &&
              onCompletionPressed != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AtlasSpacing.lg,
                0,
                AtlasSpacing.lg,
                AtlasSpacing.lg,
              ),
              child: AtlasCompletionPreviewCard(
                state: completionState,
                result: completionResult,
                isExpanded:
                isCompletionExpanded,
                errorMessage:
                completionError,
                onTap:
                onCompletionPressed,
              ),
            ),
        ],
      ),
    );
  }
}

class _AtlasSearchEntry {
  const _AtlasSearchEntry({
    required this.pop,
    required this.catalogProduct,
    required this.sourceLabel,
    required this.isCatalogBacked,
    required this.collectionNames,
  });

  final Pop pop;

  final AtlasCatalogProduct? catalogProduct;

  final String sourceLabel;

  final bool isCatalogBacked;

  final List<String> collectionNames;

  bool get canLoadCompletion {
    return isCatalogBacked &&
        catalogProduct != null;
  }
}

class _RankedSearchEntry {
  const _RankedSearchEntry({
    required this.entry,
    required this.score,
  });

  final _AtlasSearchEntry entry;

  final int score;
}