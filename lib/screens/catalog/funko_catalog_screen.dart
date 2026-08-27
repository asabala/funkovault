import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../atlas/catalog/models/atlas_catalog_product.dart';
import '../../atlas/catalog/services/atlas_catalog_service.dart';
import '../../services/app_state.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/components/atlas_empty_state.dart';
import '../../widgets/atlas/components/atlas_info_banner.dart';
import '../../widgets/atlas/components/atlas_product_image.dart';
import '../../widgets/atlas/components/atlas_section_header.dart';
import '../../widgets/atlas/components/atlas_status_chip.dart';
import '../pop/add_pop_screen.dart';

class FunkoCatalogScreen extends StatefulWidget {
  const FunkoCatalogScreen({super.key, this.collectionName});

  final String? collectionName;

  @override
  State<FunkoCatalogScreen> createState() {
    return _FunkoCatalogScreenState();
  }
}

class _FunkoCatalogScreenState extends State<FunkoCatalogScreen> {
  final TextEditingController _searchController = TextEditingController();

  String? _capturedCollectionName;

  List<AtlasCatalogProduct> _catalog = <AtlasCatalogProduct>[];

  List<AtlasCatalogProduct> _results = <AtlasCatalogProduct>[];

  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _capturedCollectionName ??=
        widget.collectionName ?? context.read<AppState>().selectedCollection;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCatalog() async {
    try {
      final List<AtlasCatalogProduct> catalog = await AtlasCatalogService
          .instance
          .search(categoryCode: 'FNK', productLine: 'Pop! Vinyl', limit: 5000);

      if (!mounted) {
        return;
      }

      setState(() {
        _catalog = catalog;
        _results = catalog;
        _loading = false;
        _loadError = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _loadError = 'Atlas could not load the Funko catalog.';
      });
    }
  }

  Future<void> _retryLoadCatalog() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });

    await _loadCatalog();
  }

  void _search(String query) {
    final String search = query.trim().toLowerCase();

    if (search.isEmpty) {
      setState(() {
        _results = _catalog;
      });

      return;
    }

    setState(() {
      _results = _catalog
          .where((AtlasCatalogProduct product) {
            return _matchesSearch(product, search);
          })
          .toList(growable: false);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _search('');
  }

  bool _matchesSearch(AtlasCatalogProduct product, String search) {
    final List<String> searchableValues = <String>[
      product.displayName,
      product.productNumber ?? '',
      product.series ?? '',
      product.characterName ?? '',
      product.variantName ?? '',
      product.brand ?? '',
      product.productLine ?? '',
      ...product.barcodes,
    ];

    return searchableValues.any((String value) {
      return value.toLowerCase().contains(search);
    });
  }

  String _imageUrlFrom(AtlasCatalogProduct product) {
    final Object? value = product.attributes['imageUrl'];

    return value?.toString().trim() ?? '';
  }

  String _subtitleFrom(AtlasCatalogProduct product) {
    final List<String> parts = <String>[
      if ((product.series ?? '').trim().isNotEmpty) product.series!.trim(),
      if ((product.productNumber ?? '').trim().isNotEmpty)
        '#${product.productNumber!.trim()}',
      if ((product.variantName ?? '').trim().isNotEmpty)
        product.variantName!.trim(),
    ];

    if (parts.isEmpty) {
      return product.productLine ?? 'Pop! Vinyl';
    }

    return parts.join(' • ');
  }

  String _identifierFrom(AtlasCatalogProduct product) {
    if (product.barcodes.isNotEmpty) {
      return product.barcodes.first;
    }

    return product.productId.value;
  }

  void _openProduct(AtlasCatalogProduct product) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return AddPopScreen(
            atlasProduct: product,
            collectionName: _capturedCollectionName,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Funko Catalog')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AtlasSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: AtlasSpacing.md),
                Text(
                  'Loading Funko Catalog...',
                  style: AtlasTypography.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final String? loadError = _loadError;

    if (loadError != null) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AtlasSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AtlasInfoBanner(
                icon: Icons.cloud_off_rounded,
                title: 'Catalog Unavailable',
                message: loadError,
              ),
              const SizedBox(height: AtlasSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _retryLoadCatalog,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try Again'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final bool hasSearch = _searchController.text.trim().isNotEmpty;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AtlasSpacing.md,
              AtlasSpacing.md,
              AtlasSpacing.md,
              0,
            ),
            child: AtlasGlassCard(
              accentColor: AtlasColors.vaultGold,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AtlasSectionHeader(
                    title: 'Funko Catalog',
                    subtitle:
                        'Search Atlas catalog data by name, number, series, variant, or barcode.',
                    icon: Icons.search_rounded,
                    accentColor: AtlasColors.vaultGold,
                  ),
                  const SizedBox(height: AtlasSpacing.md),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText:
                          'Search name, number, series, variant, or barcode...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: hasSearch
                          ? IconButton(
                              tooltip: 'Clear search',
                              onPressed: _clearSearch,
                              icon: const Icon(Icons.close_rounded),
                            )
                          : null,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: _search,
                  ),
                  const SizedBox(height: AtlasSpacing.md),
                  Wrap(
                    spacing: AtlasSpacing.sm,
                    runSpacing: AtlasSpacing.sm,
                    children: [
                      AtlasStatusChip(
                        label: '${_results.length} Results',
                        icon: Icons.inventory_2_outlined,
                        accentColor: AtlasColors.vaultGold,
                        size: AtlasStatusChipSize.compact,
                      ),
                      AtlasStatusChip(
                        label: '${_catalog.length} Catalog Items',
                        icon: Icons.dataset_outlined,
                        accentColor: AtlasColors.vaultGold,
                        size: AtlasStatusChipSize.compact,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AtlasSpacing.md),

          Expanded(
            child: _results.isEmpty
                ? SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.all(AtlasSpacing.md),
                    child: AtlasEmptyState(
                      eyebrow: 'Funko Catalog',
                      title: 'No Matching Pops',
                      message: hasSearch
                          ? 'No catalog items matched your search. Try a different name, number, series, variant, or barcode.'
                          : 'No Funko catalog items are currently available.',
                      icon: Icons.search_off_rounded,
                      compact: true,
                    ),
                  )
                : ListView.builder(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(
                      AtlasSpacing.md,
                      0,
                      AtlasSpacing.md,
                      100,
                    ),
                    itemCount: _results.length,
                    itemBuilder: (BuildContext context, int index) {
                      final AtlasCatalogProduct product = _results[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AtlasSpacing.sm),
                        child: _CatalogProductCard(
                          product: product,
                          imageUrl: _imageUrlFrom(product),
                          subtitle: _subtitleFrom(product),
                          identifier: _identifierFrom(product),
                          onTap: () {
                            _openProduct(product);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CatalogProductCard extends StatelessWidget {
  const _CatalogProductCard({
    required this.product,
    required this.imageUrl,
    required this.subtitle,
    required this.identifier,
    required this.onTap,
  });

  final AtlasCatalogProduct product;
  final String imageUrl;
  final String subtitle;
  final String identifier;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AtlasProductImage(
            imageUrl: imageUrl,
            width: 58,
            height: 72,
            borderRadius: AtlasSpacing.sm,
            showBorder: true,
          ),

          const SizedBox(width: AtlasSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.displayName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AtlasTypography.bodyMedium.copyWith(
                    color: AtlasColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: AtlasSpacing.xs),

                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AtlasTypography.bodySmall.copyWith(
                    color: AtlasColors.textSecondary,
                  ),
                ),

                const SizedBox(height: AtlasSpacing.xs),

                Text(
                  identifier,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AtlasTypography.bodySmall.copyWith(
                    color: AtlasColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: AtlasSpacing.sm),

          const Icon(
            Icons.add_circle_outline_rounded,
            color: AtlasColors.vaultGold,
          ),
        ],
      ),
    );
  }
}
