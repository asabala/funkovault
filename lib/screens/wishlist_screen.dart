import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pop.dart';
import '../services/app_state.dart';
import 'pop_details_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState =
    context.watch<AppState>();

    final wishlistPops =
    appState.collections.values
        .expand(
          (collection) => collection,
    )
        .where(
          (pop) => pop.isWishlist,
    )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Wishlist',
        ),
      ),
      body: wishlistPops.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
            ),
            SizedBox(height: 16),
            Text(
              'No Wishlist Items',
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tap the heart on a Pop to add it here.',
              textAlign:
              TextAlign.center,
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount:
        wishlistPops.length,
        itemBuilder:
            (context, index) {
          final Pop pop =
          wishlistPops[index];

          return Card(
            margin:
            const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            child: ListTile(
              leading:
              const CircleAvatar(
                child: Icon(
                  Icons.favorite,
                  color: Colors.red,
                ),
              ),
              title: Text(
                pop.name,
              ),
              subtitle: Text(
                '${pop.owner} • \$${pop.value.toStringAsFixed(2)}',
              ),
              trailing:
              const Icon(
                Icons.chevron_right,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PopDetailsScreen(
                          pop: pop,
                        ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}