import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/pop.dart';
import '../../services/app_state.dart';
import '../pop/pop_details_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final AppState appState =
    context.watch<AppState>();

    final List<Pop> wishlistPops =
        appState.wishlistPops;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Wishlist',
        ),
      ),
      body: wishlistPops.isEmpty
          ? const _EmptyWishlist()
          : ListView.builder(
        padding: const EdgeInsets.symmetric(
          vertical: 6,
        ),
        itemCount: wishlistPops.length,
        itemBuilder: (
            BuildContext context,
            int index,
            ) {
          final Pop pop =
          wishlistPops[index];

          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage:
                pop.imageUrl.trim().isNotEmpty
                    ? NetworkImage(
                  pop.imageUrl,
                )
                    : null,
                child:
                pop.imageUrl.trim().isEmpty
                    ? const Icon(
                  Icons.favorite,
                )
                    : null,
              ),
              title: Text(
                pop.name,
              ),
              subtitle: Text(
                _subtitleForPop(
                  pop,
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right,
              ),
              onTap: () {
                Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) {
                      return PopDetailsScreen(
                        pop: pop,
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _subtitleForPop(
      Pop pop,
      ) {
    final List<String> parts = <String>[
      pop.owner,
    ];

    if (pop.number.trim().isNotEmpty) {
      parts.add(
        '#${pop.number.trim()}',
      );
    }

    if (pop.value > 0) {
      parts.add(
        '\$${pop.value.toStringAsFixed(2)}',
      );
    }

    if (!pop.isWishlist) {
      parts.add(
        'Owned',
      );
    }

    return parts.join(
      ' • ',
    );
  }
}

class _EmptyWishlist extends StatelessWidget {
  const _EmptyWishlist();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(
          24,
        ),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              'No Wishlist Items',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              'Tap the heart on a collectible to add it here.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}