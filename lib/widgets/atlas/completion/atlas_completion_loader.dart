import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:funkovault2/atlas/catalog/converters/atlas_catalog_converter.dart';
import 'package:funkovault2/atlas/catalog/models/atlas_catalog_product.dart';
import 'package:funkovault2/atlas/catalog/services/atlas_catalog_service.dart';
import 'package:funkovault2/atlas/completion/models/atlas_completion_result.dart';
import 'package:funkovault2/atlas/completion/services/atlas_completion_service.dart';
import 'package:funkovault2/atlas/identity/product/atlas_product_id.dart';
import 'package:funkovault2/models/pop.dart';
import 'package:funkovault2/services/app_state.dart';
import 'package:funkovault2/theme/atlas_colors.dart';
import 'package:funkovault2/theme/atlas_spacing.dart';
import 'package:funkovault2/theme/atlas_symbols.dart';
import 'package:funkovault2/theme/atlas_typography.dart';
import 'package:funkovault2/widgets/atlas/atlas_glass_card.dart';
import 'package:funkovault2/widgets/atlas/completion/atlas_completion_card.dart';

enum AtlasCompletionLoaderState {
  loading,
  loaded,
  unavailable,
  error,
}

class AtlasCompletionLoader extends StatefulWidget {
  const AtlasCompletionLoader({
    super.key,
    required this.pop,
    this.collectionName = 'All Atlas Collections',
    this.maxVisibleItemsPerSection = 3,
    this.showItemBreakdown = true,
  });

  final Pop pop;

  final String collectionName;

  final int maxVisibleItemsPerSection;

  final bool showItemBreakdown;

  @override
  State<AtlasCompletionLoader> createState() {
    return _AtlasCompletionLoaderState();
  }
}

class _AtlasCompletionLoaderState
    extends State<AtlasCompletionLoader> {
  final AtlasCatalogService _catalogService =
      AtlasCatalogService.instance;

  final AtlasCompletionService _completionService =
      AtlasCompletionService.instance;

  AtlasCompletionLoaderState _loaderState =
      AtlasCompletionLoaderState.loading;

  AtlasCompletionResult? _result;

  String? _errorMessage;

  String? _loadedDependencyKey;

  int _requestId = 0;

  @override
  void didUpdateWidget(
      AtlasCompletionLoader oldWidget,
      ) {
    super.didUpdateWidget(
      oldWidget,
    );

    if (oldWidget.pop.collectibleIdentityKey !=
        widget.pop.collectibleIdentityKey ||
        oldWidget.pop.lastUpdated !=
            widget.pop.lastUpdated ||
        oldWidget.pop.quantity !=
            widget.pop.quantity ||
        oldWidget.pop.isWishlist !=
            widget.pop.isWishlist) {
      _loadedDependencyKey = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppState appState =
    context.watch<AppState>();

    final List<Pop> collectionPops =
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

    final Set<String> wishlistIdentityKeys =
        appState.allOwnedWishlistIdentityKeys;

    final String dependencyKey =
    _buildDependencyKey(
      collectionPops: collectionPops,
      wishlistIdentityKeys:
      wishlistIdentityKeys,
    );

    if (_loadedDependencyKey != dependencyKey) {
      _loadedDependencyKey = dependencyKey;

      WidgetsBinding.instance.addPostFrameCallback(
            (_) {
          if (!mounted ||
              _loadedDependencyKey !=
                  dependencyKey) {
            return;
          }

          _loadCompletion(
            collectionPops: collectionPops,
            wishlistIdentityKeys:
            wishlistIdentityKeys,
          );
        },
      );
    }

    return switch (_loaderState) {
      AtlasCompletionLoaderState.loading =>
      const _CompletionLoadingCard(),
      AtlasCompletionLoaderState.loaded =>
          _buildLoadedCard(),
      AtlasCompletionLoaderState.unavailable =>
      const _CompletionUnavailableCard(),
      AtlasCompletionLoaderState.error =>
          _CompletionErrorCard(
            message: _errorMessage,
            onRetry: () {
              _loadedDependencyKey = null;

              setState(
                    () {
                  _loaderState =
                      AtlasCompletionLoaderState.loading;
                  _errorMessage = null;
                },
              );
            },
          ),
    };
  }

  Widget _buildLoadedCard() {
    final AtlasCompletionResult? result =
        _result;

    if (result == null) {
      return const _CompletionUnavailableCard();
    }

    return AtlasCompletionCard(
      result: result,
      maxVisibleItemsPerSection:
      widget.maxVisibleItemsPerSection,
      showItemBreakdown:
      widget.showItemBreakdown,
    );
  }

  Future<void> _loadCompletion({
    required List<Pop> collectionPops,
    required Set<String> wishlistIdentityKeys,
  }) async {
    final int requestId =
    ++_requestId;

    if (mounted) {
      setState(
            () {
          _loaderState =
              AtlasCompletionLoaderState.loading;
          _errorMessage = null;
        },
      );
    }

    try {
      final AtlasCatalogProduct? catalogProduct =
      await _resolveCatalogProduct(
        widget.pop,
      );

      if (!mounted ||
          requestId != _requestId) {
        return;
      }

      if (catalogProduct == null) {
        setState(
              () {
            _result = null;
            _loaderState =
                AtlasCompletionLoaderState.unavailable;
          },
        );

        return;
      }

      final AtlasCompletionResult result =
      await _completionService
          .evaluateVariantFamily(
        selectedProduct: catalogProduct,
        collectionPops: collectionPops,
        ownedWishlistIdentityKeys:
        wishlistIdentityKeys,
        collectionName:
        widget.collectionName,
      );

      if (!mounted ||
          requestId != _requestId) {
        return;
      }

      setState(
            () {
          _result = result;
          _loaderState =
              AtlasCompletionLoaderState.loaded;
          _errorMessage = null;
        },
      );
    } catch (error) {
      if (!mounted ||
          requestId != _requestId) {
        return;
      }

      setState(
            () {
          _result = null;
          _loaderState =
              AtlasCompletionLoaderState.error;
          _errorMessage =
          'Atlas could not calculate collector progress.';
        },
      );
    }
  }

  Future<AtlasCatalogProduct?>
  _resolveCatalogProduct(
      Pop pop,
      ) async {
    final AtlasProductId? atlasProductId =
    _parseAtlasProductId(
      pop.sourceCatalogId,
    );

    if (atlasProductId != null) {
      final AtlasCatalogProduct? exactProduct =
      await _catalogService
          .findByProductId(
        atlasProductId,
      );

      if (exactProduct != null) {
        return exactProduct;
      }
    }

    final String barcode =
    pop.sourceUpc.trim();

    if (barcode.isNotEmpty) {
      final List<AtlasCatalogProduct>
      barcodeMatches =
      await _catalogService.findByBarcode(
        barcode,
      );

      final AtlasCatalogProduct?
      bestBarcodeMatch =
      _selectBestMatch(
        pop: pop,
        candidates: barcodeMatches,
      );

      if (bestBarcodeMatch != null) {
        return bestBarcodeMatch;
      }
    }

    final List<AtlasCatalogProduct>
    searchMatches =
    await _catalogService.search(
      query: pop.name.trim().isEmpty
          ? null
          : pop.name.trim(),
      productNumber:
      pop.number.trim().isEmpty
          ? null
          : pop.number.trim(),
      variantName:
      _searchableVariant(
        pop.variant,
      ),
      limit: 100,
    );

    return _selectBestMatch(
      pop: pop,
      candidates: searchMatches,
    );
  }

  AtlasCatalogProduct? _selectBestMatch({
    required Pop pop,
    required Iterable<AtlasCatalogProduct>
    candidates,
  }) {
    AtlasCatalogProduct? bestMatch;
    int bestScore = -1;

    final String targetIdentityKey =
    pop.collectibleIdentityKey.trim();

    final String targetName =
    _normalizeText(
      pop.name,
    );

    final String targetNumber =
    _normalizeText(
      pop.number,
    );

    final String targetCollectibleId =
    pop.sourceCollectibleId
        .trim()
        .toLowerCase();

    for (final AtlasCatalogProduct candidate
    in candidates) {
      final Pop candidatePop =
      AtlasCatalogConverter.toPop(
        candidate,
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          1,
        ),
      );

      int score = 0;

      final String candidateIdentityKey =
      candidatePop.collectibleIdentityKey
          .trim();

      if (targetIdentityKey.isNotEmpty &&
          candidateIdentityKey.isNotEmpty &&
          targetIdentityKey ==
              candidateIdentityKey) {
        score += 1000;
      }

      final String candidateCollectibleId =
      candidatePop.sourceCollectibleId
          .trim()
          .toLowerCase();

      if (targetCollectibleId.isNotEmpty &&
          candidateCollectibleId.isNotEmpty &&
          targetCollectibleId ==
              candidateCollectibleId) {
        score += 900;
      }

      final String candidateName =
      _normalizeText(
        candidate.displayName,
      );

      if (targetName.isNotEmpty &&
          candidateName == targetName) {
        score += 300;
      } else if (targetName.isNotEmpty &&
          (
              candidateName.contains(
                targetName,
              ) ||
                  targetName.contains(
                    candidateName,
                  )
          )) {
        score += 150;
      }

      final String candidateNumber =
      _normalizeText(
        candidate.productNumber ?? '',
      );

      if (targetNumber.isNotEmpty &&
          candidateNumber == targetNumber) {
        score += 250;
      }

      if (_barcodesOverlap(
        pop.sourceUpc,
        candidatePop.sourceUpc,
      )) {
        score += 800;
      }

      if (score > bestScore) {
        bestScore = score;
        bestMatch = candidate;
      }
    }

    if (bestScore <= 0) {
      return null;
    }

    return bestMatch;
  }

  AtlasProductId? _parseAtlasProductId(
      String value,
      ) {
    final RegExpMatch? match =
    RegExp(
      r'^ATLAS-([A-Za-z0-9]+)-([0-9]+)$',
      caseSensitive: false,
    ).firstMatch(
      value.trim(),
    );

    if (match == null) {
      return null;
    }

    final String? categoryCode =
    match.group(
      1,
    );

    final int? numericId =
    int.tryParse(
      match.group(
        2,
      ) ??
          '',
    );

    if (categoryCode == null ||
        categoryCode.trim().isEmpty ||
        numericId == null ||
        numericId <= 0) {
      return null;
    }

    return AtlasProductId(
      categoryCode: categoryCode,
      numericId: numericId,
    );
  }

  String? _searchableVariant(
      String value,
      ) {
    final String cleaned =
    value.trim();

    final String normalized =
    cleaned.toLowerCase();

    if (cleaned.isEmpty ||
        normalized == 'common' ||
        normalized == 'standard' ||
        normalized == 'none' ||
        normalized == 'not entered') {
      return null;
    }

    return cleaned;
  }

  bool _barcodesOverlap(
      String first,
      String second,
      ) {
    final Set<String> firstCandidates =
    _barcodeCandidates(
      first,
    );

    final Set<String> secondCandidates =
    _barcodeCandidates(
      second,
    );

    return firstCandidates.isNotEmpty &&
        secondCandidates.isNotEmpty &&
        firstCandidates.any(
          secondCandidates.contains,
        );
  }

  Set<String> _barcodeCandidates(
      String value,
      ) {
    final String normalized =
    value.replaceAll(
      RegExp(r'[^0-9A-Za-z]'),
      '',
    );

    if (normalized.isEmpty) {
      return const <String>{};
    }

    final Set<String> candidates =
    <String>{
      normalized,
    };

    if (normalized.length == 13 &&
        normalized.startsWith('0')) {
      candidates.add(
        normalized.substring(
          1,
        ),
      );
    }

    if (normalized.length == 12) {
      candidates.add(
        '0$normalized',
      );
    }

    return candidates;
  }

  String _normalizeText(
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
    )
        .trim();
  }

  String _buildDependencyKey({
    required List<Pop> collectionPops,
    required Set<String> wishlistIdentityKeys,
  }) {
    final List<String> collectionParts =
    collectionPops
        .map(
          (
          Pop collectionPop,
          ) {
        return <String>[
          collectionPop.id,
          collectionPop
              .collectibleIdentityKey,
          '${collectionPop.quantity}',
          '${collectionPop.isWishlist}',
          collectionPop.lastUpdated,
        ].join(
          '|',
        );
      },
    )
        .toList(
      growable: false,
    )
      ..sort();

    final List<String> wishlistParts =
    wishlistIdentityKeys.toList(
      growable: false,
    )
      ..sort();

    return <String>[
      widget.pop.collectibleIdentityKey,
      widget.pop.sourceCatalogId,
      widget.pop.sourceCollectibleId,
      widget.pop.sourceUpc,
      widget.pop.lastUpdated,
      ...collectionParts,
      ...wishlistParts,
    ].join(
      '::',
    );
  }
}

class _CompletionLoadingCard
    extends StatelessWidget {
  const _CompletionLoadingCard();

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      accentColor:
      AtlasColors.intelligenceBlue,
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                AtlasSymbols.completion,
                style: const TextStyle(
                  fontSize: 22,
                ),
              ),
              const SizedBox(
                width: AtlasSpacing.md,
              ),
              Expanded(
                child: Text(
                  'Collector Progress',
                  style: AtlasTypography
                      .headingSmall,
                ),
              ),
              const SizedBox(
                width: 20,
                height: 20,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: AtlasSpacing.md,
          ),
          Text(
            'Atlas is calculating this variant family.',
            style: AtlasTypography.bodySmall
                .copyWith(
              color:
              AtlasColors.textSecondary,
            ),
          ),
          const SizedBox(
            height: AtlasSpacing.md,
          ),
          const LinearProgressIndicator(
            minHeight: 7,
            backgroundColor:
            AtlasColors.surface,
          ),
        ],
      ),
    );
  }
}

class _CompletionUnavailableCard
    extends StatelessWidget {
  const _CompletionUnavailableCard();

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      accentColor:
      AtlasColors.textSecondary,
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            AtlasSymbols.completion,
            style: const TextStyle(
              fontSize: 22,
            ),
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
                  'Collector Progress',
                  style: AtlasTypography
                      .headingSmall,
                ),
                const SizedBox(
                  height: AtlasSpacing.xs,
                ),
                Text(
                  'Atlas could not connect this Vault record to a catalog release yet.',
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
    );
  }
}

class _CompletionErrorCard
    extends StatelessWidget {
  const _CompletionErrorCard({
    required this.message,
    required this.onRetry,
  });

  final String? message;

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      accentColor: AtlasColors.warning,
      onTap: onRetry,
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            AtlasSymbols.reviewVariant,
            style: const TextStyle(
              fontSize: 22,
            ),
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
                  'Collector Progress Unavailable',
                  style: AtlasTypography
                      .headingSmall,
                ),
                const SizedBox(
                  height: AtlasSpacing.xs,
                ),
                Text(
                  message ??
                      'Atlas could not calculate progress.',
                  style: AtlasTypography
                      .bodySmall
                      .copyWith(
                    color: AtlasColors
                        .textSecondary,
                  ),
                ),
                const SizedBox(
                  height: AtlasSpacing.sm,
                ),
                Text(
                  'Tap to retry',
                  style: AtlasTypography
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
            Icons.refresh_rounded,
            color: AtlasColors.warning,
          ),
        ],
      ),
    );
  }
}