import 'package:flutter/material.dart';

import '../../models/funko_catalog_item.dart';
import '../../services/funko_catalog_service.dart';

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
  List<FunkoCatalogItem> _catalog = [];

  List<FunkoCatalogItem> _results = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    final catalog =
    await FunkoCatalogService
        .loadCatalog();

    if (!mounted) return;

    setState(() {
      _catalog = catalog;
      _results = catalog;
      _loading = false;
    });
  }

  void _search(String query) {
    final search =
    query.trim().toLowerCase();

    if (search.isEmpty) {
      setState(() {
        _results = _catalog;
      });

      return;
    }

    setState(() {
      _results =
          _catalog.where((item) {
            return item.title
                .toLowerCase()
                .contains(search) ||
                item.series.any(
                      (series) => series
                      .toLowerCase()
                      .contains(search),
                );
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Funko Catalog',
        ),
      ),
      body: _loading
          ? const Center(
        child:
        CircularProgressIndicator(),
      )
          : Column(
        children: [
          Padding(
            padding:
            const EdgeInsets.all(
              16,
            ),
            child: TextField(
              decoration:
              const InputDecoration(
                hintText:
                'Search Funko Pops...',
                prefixIcon:
                Icon(Icons.search),
                border:
                OutlineInputBorder(),
              ),
              onChanged: _search,
            ),
          ),
          Padding(
            padding:
            const EdgeInsets.only(
              bottom: 8,
            ),
            child: Text(
              '${_results.length} Results',
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount:
              _results.length,
              itemBuilder:
                  (context, index) {
                final item =
                _results[index];

                return Card(
                  margin:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: item.imageName.isNotEmpty
                        ? Image.network(
                      item.imageName,
                      width: 50,
                      errorBuilder: (
                          context,
                          error,
                          stackTrace,
                          ) {
                        return const Icon(
                          Icons.inventory_2,
                        );
                      },
                    )
                        : const Icon(
                      Icons.inventory_2,
                    ),
                    title: Text(
                      item.title,
                    ),
                    subtitle: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.series.join(' • '),
                          maxLines: 1,
                          overflow:
                          TextOverflow.ellipsis,
                        ),
                        Text(
                          item.handle,
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
                        MaterialPageRoute(
                          builder: (_) =>
                              AddPopScreen(
                                catalogItem: item,
                              ),
                        ),
                      );
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