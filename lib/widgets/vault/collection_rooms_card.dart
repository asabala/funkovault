import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';
import '../../theme/atlas_icons.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import 'vault_room_card.dart';

class CollectionRoomsCard extends StatelessWidget {
  const CollectionRoomsCard({
    super.key,
    required this.totalPops,
    this.onEntireVault,
    this.onWishlist,
    this.onAnime,
    this.onMarvel,
    this.onDc,
    this.onStarWars,
    this.onMoviesTv,
    this.onGaming,
  });

  final int totalPops;
  final VoidCallback? onEntireVault;
  final VoidCallback? onWishlist;
  final VoidCallback? onAnime;
  final VoidCallback? onMarvel;
  final VoidCallback? onDc;
  final VoidCallback? onStarWars;
  final VoidCallback? onMoviesTv;
  final VoidCallback? onGaming;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vault Rooms',
          style: AtlasTypography.headingSmall.copyWith(
            color: AtlasColors.vaultGold,
          ),
        ),
        const SizedBox(height: AtlasSpacing.md),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AtlasSpacing.md,
          mainAxisSpacing: AtlasSpacing.md,
          childAspectRatio: 0.82,
          children: [
            VaultRoomCard(
              title: 'Entire Vault',
              subtitle: '$totalPops Pops',
              icon: AtlasIcons.collection,
              lastAdded: 'Recently Updated',
              onTap: onEntireVault,
            ),
            VaultRoomCard(
              title: 'Wishlist',
              subtitle: 'Items to hunt',
              icon: AtlasIcons.wishlist,
              lastAdded: 'Target List',
              onTap: onWishlist,
            ),
            VaultRoomCard(
              title: 'Anime',
              subtitle: 'Manga shelf',
              icon: Icons.auto_awesome,
              lastAdded: 'New Hero',
              onTap: onAnime,
            ),
            VaultRoomCard(
              title: 'Marvel',
              subtitle: 'Power shelf',
              icon: Icons.flash_on,
              lastAdded: 'Spider-Man',
              onTap: onMarvel,
            ),
            VaultRoomCard(
              title: 'DC',
              subtitle: 'Hero shelf',
              icon: Icons.shield,
              lastAdded: 'Batman Beyond',
              onTap: onDc,
            ),
            VaultRoomCard(
              title: 'Star Wars',
              subtitle: 'Galaxy shelf',
              icon: Icons.star,
              lastAdded: 'Darth Vader',
              onTap: onStarWars,
            ),
            VaultRoomCard(
              title: 'Movies & TV',
              subtitle: 'Screen shelf',
              icon: Icons.movie_filter_outlined,
              lastAdded: 'New Release',
              onTap: onMoviesTv,
            ),
            VaultRoomCard(
              title: 'Gaming',
              subtitle: 'Arcade shelf',
              icon: Icons.sports_esports,
              lastAdded: 'Player One',
              onTap: onGaming,
            ),
          ],
        ),
      ],
    );
  }
}