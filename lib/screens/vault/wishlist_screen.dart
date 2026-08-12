import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/pop.dart';
import '../../services/app_state.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/components/atlas_empty_state.dart';
import '../../widgets/atlas/components/atlas_section_header.dart';
import '../../widgets/vault/components/vault_pop_tile.dart';
import '../../widgets/vault/vault_scroll_view.dart';

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
      body: VaultScrollView(
        children: [
          AtlasGlassCard(
            accentColor: AtlasColors.vaultGold,
            child: AtlasSectionHeader(
              title: 'Wishlist',
              subtitle: wishlistPops.isEmpty
                  ? 'Save collectibles you want to hunt for later.'
                  : '${wishlistPops.length} '
                  'wishlist '
                  '${wishlistPops.length == 1 ? 'item' : 'items'} '
                  'currently tracked.',
              icon: Icons.favorite_border_rounded,
              accentColor: AtlasColors.vaultGold,
            ),
          ),

          const SizedBox(
            height: AtlasSpacing.lg,
          ),

          if (wishlistPops.isEmpty)
            const AtlasEmptyState(
              eyebrow: 'Wishlist',
              title: 'No Wishlist Items',
              message:
              'Tap the heart on a collectible to add it to your wishlist.',
              icon: Icons.favorite_border_rounded,
              compact: true,
            )
          else
            ...wishlistPops.map(
                  (Pop pop) => Padding(
                padding: const EdgeInsets.only(
                  bottom: AtlasSpacing.sm,
                ),
                child: VaultPopTile(
                  pop: pop,
                  showImage: true,
                ),
              ),
            ),
        ],
      ),
    );
  }
}