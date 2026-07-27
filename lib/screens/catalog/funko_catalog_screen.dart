import 'package:flutter/material.dart';

import '../../atlas/catalog/models/atlas_catalog_product.dart';
import '../../atlas/catalog/services/atlas_catalog_service.dart';
import '../pop/add_pop_screen.dart';

class FunkoCatalogScreen extends StatefulWidget {
  const FunkoCatalogScreen({
    super.key,
  });

  @override
  State<FunkoCatalogScreen> createState() =>
      _FunkoCatalogScreenState();
}

class _FunkoCatalogScreenState
    extends State<FunkoCatalogScreen> {
  List<AtlasCatalogProduct> _catalog =
  <AtlasCatalogProduct>[];

  List<AtlasCatalogProduct> _results =
  <AtlasCatalogProduct>[];

  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    try {
      final List<AtlasCatalogProduct> catalog =
      await AtlasCatalogService.instance.search(
        categoryCode: 'FNK',
        productLine: 'Pop! Vinyl',
        limit: 5000,
      );

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
        _loadError =
        'Atlas could not load the Funko catalog.';
      });
    }
  }

  void _search(
      String query,
      ) {
    final String search =
    query.trim().toLowerCase();

    if (search.isEmpty) {
      setState(() {
        _results = _catalog;
      });

      return;
    }

    setState(() {
      _results = _catalog.where(
            (AtlasCatalogProduct product) {
          return _matchesSearch(
            product,
            search,
          );
        },
      ).toList(
        growable: false,
      );
    });
  }

  bool _matchesSearch(
      AtlasCatalogProduct product,
      String search,
      ) {
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

    return searchableValues.any(
          (String value) {
        return value.toLowerCase().contains(search);
      },
    );
  }

  String _imageUrlFrom(
      AtlasCatalogProduct product,
      ) {
    final Object? value =
    product.attributes['imageUrl'];

    return value?.toString().trim() ?? '';
  }

  String _subtitleFrom(
      AtlasCatalogProduct product,
      ) {
    final List<String> parts = <String>[
      if ((product.series ?? '').trim().isNotEmpty)
        product.series!.trim(),
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

  String _identifierFrom(
      AtlasCatalogProduct product,
      ) {
    if (product.barcodes.isNotEmpty) {
      return product.barcodes.first;
    }

    return product.productId.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Funko Catalog',
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final String? loadError = _loadError;

    if (loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                loadError,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  setState(() {
                    _loading = true;
                    _loadError = null;
                  });

                  _loadCatalog();
                },
                icon: const Icon(
                  Icons.refresh_rounded,
                ),
                label: const Text(
                  'Try Again',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: const InputDecoration(
              hintText:
              'Search name, number, series, variant, or barcode...',
              prefixIcon: Icon(
                Icons.search,
              ),
              border: OutlineInputBorder(),
            ),
            onChanged: _search,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            bottom: 8,
          ),
          child: Text(
            '${_results.length} Results',
          ),
        ),
        Expanded(
          child: _results.isEmpty
              ? const Center(
            child: Text(
              'No matching Funko Pops found.',
            ),
          )
              : ListView.builder(
            itemCount: _results.length,
            itemBuilder: (
                BuildContext context,
                int index,
                ) {
              final AtlasCatalogProduct product =
              _results[index];

              final String imageUrl =
              _imageUrlFrom(product);

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: ListTile(
                  leading: SizedBox(
                    width: 50,
                    height: 64,
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (
                          BuildContext context,
                          Object error,
                          StackTrace? stackTrace,
                          ) {
                        return const Icon(
                          Icons.inventory_2,
                        );
                      },
                    )
                        : const Icon(
                      Icons.inventory_2,
                    ),
                  ),
                  title: Text(
                    product.displayName,
                  ),
                  subtitle: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _subtitleFrom(product),
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                      ),
                      Text(
                        _identifierFrom(product),
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(
                    Icons.add_circle_outline,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (
                            BuildContext context,
                            ) {
                          return AddPopScreen(
                            atlasProduct: product,
                          );
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}