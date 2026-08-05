import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:funkovault2/atlas/intelligence/engines/atlas_collector_insight_engine.dart';
import 'package:funkovault2/atlas/intelligence/models/atlas_collector_insight.dart';
import 'package:funkovault2/models/pop.dart';
import 'package:funkovault2/screens/pop/pop_details_screen.dart';
import 'package:funkovault2/services/app_state.dart';
import 'package:funkovault2/theme/atlas_colors.dart';
import 'package:funkovault2/theme/atlas_spacing.dart';
import 'package:funkovault2/theme/atlas_typography.dart';
import 'package:funkovault2/widgets/atlas/atlas_glass_card.dart';

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

  final FocusNode _searchFocusNode = FocusNode();

  String _query = '';

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
    _searchController.dispose();
    _searchFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppState appState =
    context.watch<AppState>();

    final List<_AtlasSearchEntry> allEntries =
    _buildSearchEntries(
      appState,
    );

    final List<_AtlasSearchEntry> results =
    _filterEntries(
      entries: allEntries,
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
              child: _SearchField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: (
                    String value,
                    ) {
                  setState(
                        () {
                      _query = value;
                    },
                  );
                },
                onClear: () {
                  _searchController.clear();

                  setState(
                        () {
                      _query = '';
                    },
                  );

                  _searchFocusNode.requestFocus();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AtlasSpacing.md,
              ),
              child: _SearchStatusBar(
                query: _query,
                resultCount: results.length,
                totalCount: allEntries.length,
              ),
            ),
            const SizedBox(
              height: AtlasSpacing.sm,
            ),
            Expanded(
              child: _buildBody(
                context: context,
                appState: appState,
                allEntries: allEntries,
                results: results,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required AppState appState,
    required List<_AtlasSearchEntry> allEntries,
    required List<_AtlasSearchEntry> results,
  }) {
    if (allEntries.isEmpty) {
      return const _SearchEmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'Your Vault Is Empty',
        message:
        'Add collectibles to Atlas before searching your collection.',
      );
    }

    if (_query.trim().isEmpty) {
      return const _SearchEmptyState(
        icon: Icons.manage_search_rounded,
        title: 'Search Your Entire Atlas Vault',
        message:
        'Search by name, number, series, category, variant, retailer, sticker, owner, UPC, or catalog ID.',
      );
    }

    if (results.isEmpty) {
      return _SearchEmptyState(
        icon: Icons.search_off_rounded,
        title: 'No Results Found',
        message:
        'Atlas could not find a collectible matching “${_query.trim()}”.',
      );
    }

    final List<Pop> allCollectionPops =
    allEntries
        .map(
          (_AtlasSearchEntry entry) => entry.pop,
    )
        .toList(
      growable: false,
    );

    return ListView.builder(
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

        final AtlasCollectorInsight insight =
        const AtlasCollectorInsightEngine()
            .evaluateProduct(
          product: entry.pop,
          collectionPops: allCollectionPops,
          collectionName: 'All Atlas Collections',
          ownedWishlistIdentityKeys:
          appState.allOwnedWishlistIdentityKeys,
          source: 'Atlas Home Search',
        );

        return Padding(
          padding: const EdgeInsets.only(
            bottom: AtlasSpacing.md,
          ),
          child: _AtlasSearchResultCard(
            entry: entry,
            insight: insight,
            onPressed: () {
              Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (_) {
                    return PopDetailsScreen(
                      pop: entry.pop,
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  List<_AtlasSearchEntry> _buildSearchEntries(
      AppState appState,
      ) {
    final List<_AtlasSearchEntry> entries =
    <_AtlasSearchEntry>[];

    appState.collections.forEach(
          (
          String collectionName,
          List<Pop> pops,
          ) {
        for (final Pop pop in pops) {
          entries.add(
            _AtlasSearchEntry(
              pop: pop,
              collectionName: collectionName,
            ),
          );
        }
      },
    );

    entries.sort(
          (
          _AtlasSearchEntry first,
          _AtlasSearchEntry second,
          ) {
        final int nameComparison =
        first.pop.name.toLowerCase().compareTo(
          second.pop.name.toLowerCase(),
        );

        if (nameComparison != 0) {
          return nameComparison;
        }

        return first.pop.number.compareTo(
          second.pop.number,
        );
      },
    );

    return List<_AtlasSearchEntry>.unmodifiable(
      entries,
    );
  }

  List<_AtlasSearchEntry> _filterEntries({
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

    final List<_RankedSearchEntry> rankedResults =
    <_RankedSearchEntry>[];

    for (final _AtlasSearchEntry entry in entries) {
      final int score = _searchScore(
        entry: entry,
        normalizedQuery: normalizedQuery,
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

        return first.entry.pop.number.compareTo(
          second.entry.pop.number,
        );
      },
    );

    return List<_AtlasSearchEntry>.unmodifiable(
      rankedResults
          .map(
            (_RankedSearchEntry result) =>
        result.entry,
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
    final Pop pop = entry.pop;

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

    if (normalizedName == normalizedQuery) {
      return 1000;
    }

    if (normalizedNumber == normalizedQuery) {
      return 950;
    }

    if (normalizedUpc == normalizedQuery) {
      return 940;
    }

    if (normalizedCatalogId == normalizedQuery ||
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
    final Pop pop = entry.pop;

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
        entry.collectionName,
        pop.isWishlist ? 'wishlist' : 'owned',
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
      RegExp(r'[^a-z0-9]+'),
      ' ',
    )
        .replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search Pops, cards, variants, UPCs...',
        prefixIcon: const Icon(
          Icons.search_rounded,
        ),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
          tooltip: 'Clear Search',
          onPressed: onClear,
          icon: const Icon(
            Icons.close_rounded,
          ),
        ),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            18,
          ),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _SearchStatusBar extends StatelessWidget {
  const _SearchStatusBar({
    required this.query,
    required this.resultCount,
    required this.totalCount,
  });

  final String query;
  final int resultCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final bool hasQuery =
        query.trim().isNotEmpty;

    return Row(
      children: [
        Expanded(
          child: Text(
            hasQuery
                ? '$resultCount result${resultCount == 1 ? '' : 's'} across all collections'
                : '$totalCount searchable collectible${totalCount == 1 ? '' : 's'}',
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
        ),
        const Icon(
          Icons.hub_outlined,
          size: 16,
          color: AtlasColors.intelligenceBlue,
        ),
        const SizedBox(
          width: AtlasSpacing.xs,
        ),
        Text(
          'Atlas Intelligence',
          style: AtlasTypography.bodySmall.copyWith(
            color: AtlasColors.intelligenceBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _AtlasSearchResultCard extends StatelessWidget {
  const _AtlasSearchResultCard({
    required this.entry,
    required this.insight,
    required this.onPressed,
  });

  final _AtlasSearchEntry entry;
  final AtlasCollectorInsight insight;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final Pop pop = entry.pop;

    return AtlasGlassCard(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(
          18,
        ),
        child: Padding(
          padding: const EdgeInsets.all(
            AtlasSpacing.md,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  _SearchProductImage(
                    imageUrl: pop.imageUrl,
                  ),
                  const SizedBox(
                    width: AtlasSpacing.md,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          pop.name,
                          style:
                          AtlasTypography.headingSmall,
                        ),
                        if (pop.number.trim().isNotEmpty) ...[
                          const SizedBox(
                            height: AtlasSpacing.xs,
                          ),
                          Text(
                            '#${pop.number.trim()}',
                            style: AtlasTypography.bodySmall
                                .copyWith(
                              color:
                              AtlasColors.textSecondary,
                            ),
                          ),
                        ],
                        const SizedBox(
                          height: AtlasSpacing.xs,
                        ),
                        Text(
                          entry.collectionName,
                          style: AtlasTypography.bodySmall
                              .copyWith(
                            color:
                            AtlasColors.intelligenceBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                  ),
                ],
              ),
              if (insight.summary.hasIdentityBadges) ...[
                const SizedBox(
                  height: AtlasSpacing.md,
                ),
                Wrap(
                  spacing: AtlasSpacing.sm,
                  runSpacing: AtlasSpacing.sm,
                  children: [
                    for (final badge
                    in insight.summary.identityBadges)
                      _SearchBadge(
                        label: badge.displayLabel,
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
                  _SearchStatusChip(
                    icon: insight.isOwned
                        ? Icons.inventory_2_rounded
                        : Icons.inventory_2_outlined,
                    label: insight.isOwned
                        ? 'Owned x${insight.ownedQuantity}'
                        : 'Not Owned',
                  ),
                  if (insight.isWishlisted)
                    const _SearchStatusChip(
                      icon: Icons.favorite_rounded,
                      label: 'Wishlist',
                    ),
                  _SearchStatusChip(
                    icon: Icons.attach_money_rounded,
                    label:
                    insight.summary.formattedMarketValue,
                  ),
                ],
              ),
              const SizedBox(
                height: AtlasSpacing.md,
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(
                  AtlasSpacing.md,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    14,
                  ),
                  color: AtlasColors.intelligenceBlue
                      .withValues(
                    alpha: 0.08,
                  ),
                  border: Border.all(
                    color: AtlasColors.intelligenceBlue
                        .withValues(
                      alpha: 0.20,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight.summary.recommendation
                          .categoryLabel
                          .toUpperCase(),
                      style: AtlasTypography.bodySmall
                          .copyWith(
                        color:
                        AtlasColors.intelligenceBlue,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.7,
                      ),
                    ),
                    const SizedBox(
                      height: AtlasSpacing.xs,
                    ),
                    Text(
                      insight.summary.recommendationTitle,
                      style:
                      AtlasTypography.headingSmall,
                    ),
                    const SizedBox(
                      height: AtlasSpacing.xs,
                    ),
                    Text(
                      insight.summary
                          .recommendationMessage,
                      style: AtlasTypography.bodySmall
                          .copyWith(
                        color:
                        AtlasColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchProductImage extends StatelessWidget {
  const _SearchProductImage({
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final String normalizedUrl =
    imageUrl.trim();

    return SizedBox(
      width: 64,
      height: 74,
      child: normalizedUrl.isEmpty
          ? const DecoratedBox(
        decoration: BoxDecoration(
          color: AtlasColors.surface,
          borderRadius: BorderRadius.all(
            Radius.circular(
              12,
            ),
          ),
        ),
        child: Icon(
          Icons.inventory_2_outlined,
        ),
      )
          : Image.network(
        normalizedUrl,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (
            BuildContext context,
            Object error,
            StackTrace? stackTrace,
            ) {
          return const DecoratedBox(
            decoration: BoxDecoration(
              color: AtlasColors.surface,
              borderRadius: BorderRadius.all(
                Radius.circular(
                  12,
                ),
              ),
            ),
            child: Icon(
              Icons.broken_image_outlined,
            ),
          );
        },
      ),
    );
  }
}

class _SearchBadge extends StatelessWidget {
  const _SearchBadge({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          999,
        ),
        color: AtlasColors.vaultGold.withValues(
          alpha: 0.10,
        ),
        border: Border.all(
          color: AtlasColors.vaultGold.withValues(
            alpha: 0.28,
          ),
        ),
      ),
      child: Text(
        label,
        style: AtlasTypography.bodySmall,
      ),
    );
  }
}

class _SearchStatusChip extends StatelessWidget {
  const _SearchStatusChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          999,
        ),
        color: AtlasColors.surface.withValues(
          alpha: 0.55,
        ),
        border: Border.all(
          color: AtlasColors.textSecondary.withValues(
            alpha: 0.18,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            label,
            style: AtlasTypography.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(
          AtlasSpacing.xl,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 72,
              color: AtlasColors.textSecondary,
            ),
            const SizedBox(
              height: AtlasSpacing.lg,
            ),
            Text(
              title,
              style: AtlasTypography.headingSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: AtlasSpacing.sm,
            ),
            Text(
              message,
              style: AtlasTypography.bodyMedium.copyWith(
                color: AtlasColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AtlasSearchEntry {
  const _AtlasSearchEntry({
    required this.pop,
    required this.collectionName,
  });

  final Pop pop;
  final String collectionName;
}

class _RankedSearchEntry {
  const _RankedSearchEntry({
    required this.entry,
    required this.score,
  });

  final _AtlasSearchEntry entry;
  final int score;
}