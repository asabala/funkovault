import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pop.dart';
import 'edit_pop_screen.dart';
import '../services/app_state.dart';

class PopDetailsScreen extends StatefulWidget {
  final Pop pop;

  const PopDetailsScreen({
    super.key,
    required this.pop,
  });

  @override
  State<PopDetailsScreen> createState() =>
      _PopDetailsScreenState();
}

class _PopDetailsScreenState
    extends State<PopDetailsScreen> {
  late Pop pop;

  @override
  void initState() {
    super.initState();
    pop = widget.pop;
  }

  Future<void> _editPop() async {
    final updatedPop = await Navigator.push<Pop>(
      context,
      MaterialPageRoute(
        builder: (_) => EditPopScreen(
          pop: pop,
        ),
      ),
    );

    if (updatedPop != null) {
      setState(() {
        pop = updatedPop;
      });
    }
  }

  Future<void> _toggleWishlist() async {
    final updatedPop = Pop(
      id: pop.id,
      name: pop.name,
      number: pop.number,
      category: pop.category,
      series: pop.series,
      value: pop.value,
      pricePaid: pop.pricePaid,
      quantity: pop.quantity,
      itemCondition: pop.itemCondition,
      boxCondition: pop.boxCondition,
      imageUrl: pop.imageUrl,
      owner: pop.owner,
      isWishlist: !pop.isWishlist,
    );

    await context
        .read<AppState>()
        .updatePop(updatedPop);

    setState(() {
      pop = updatedPop;
    });
  }

  Future<void> _updateQuantity(
      int newQuantity,
      ) async {
    if (newQuantity < 1) return;

    final updatedPop = Pop(
      id: pop.id,
      name: pop.name,
      number: pop.number,
      category: pop.category,
      series: pop.series,
      value: pop.value,
      pricePaid: pop.pricePaid,
      quantity: newQuantity,
      itemCondition: pop.itemCondition,
      boxCondition: pop.boxCondition,
      imageUrl: pop.imageUrl,
      owner: pop.owner,
      isWishlist: pop.isWishlist,
    );

    await context
        .read<AppState>()
        .updatePop(updatedPop);

    setState(() {
      pop = updatedPop;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pop.name),
        actions: [
          IconButton(
            icon: Icon(
              pop.isWishlist
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: _toggleWishlist,
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editPop,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding:
                const EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    children: [
                      pop.imageUrl.isNotEmpty
                          ? Image.network(
                        pop.imageUrl,
                        height: 150,
                        errorBuilder: (
                            context,
                            error,
                            stackTrace,
                            ) {
                          return const Icon(
                            Icons.inventory_2,
                            size: 80,
                          );
                        },
                      )
                          : const Icon(
                        Icons.inventory_2,
                        size: 80,
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      Text(
                        pop.name,
                        style:
                        const TextStyle(
                          fontSize: 24,
                          fontWeight:
                          FontWeight.bold,
                        ),
                        textAlign:
                        TextAlign.center,
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Chip(
                        label: Text(
                          pop.owner,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            _DetailRow(
              label: 'Number',
              value: pop.number,
            ),

            _DetailRow(
              label: 'Category',
              value: pop.category,
            ),

            _DetailRow(
              label: 'Series',
              value: pop.series,
            ),

            _DetailRow(
              label: 'Owner',
              value: pop.owner,
            ),

            _DetailRow(
              label: 'Value',
              value:
              '\$${pop.value.toStringAsFixed(2)}',
            ),

            _DetailRow(
              label: 'Paid',
              value:
              '\$${pop.pricePaid.toStringAsFixed(2)}',
            ),

            Padding(
              padding:
              const EdgeInsets.symmetric(
                vertical: 8,
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 120,
                    child: Text(
                      'Quantity',
                      style: TextStyle(
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.remove_circle,
                    ),
                    onPressed: () {
                      _updateQuantity(
                        pop.quantity - 1,
                      );
                    },
                  ),
                  Text(
                    pop.quantity.toString(),
                    style:
                    const TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle,
                    ),
                    onPressed: () {
                      _updateQuantity(
                        pop.quantity + 1,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}