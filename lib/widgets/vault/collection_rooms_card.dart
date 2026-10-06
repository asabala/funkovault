import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';
import '../../theme/atlas_icons.dart';
import '../../theme/atlas_spacing.dart';
import '../atlas/components/atlas_section_header.dart';
import 'vault_room_card.dart';

class CollectionRoomsCard extends StatelessWidget {
  const CollectionRoomsCard({
    super.key,
    required this.totalPops,
    required this.wishlistCount,
    required this.animeCount,
    required this.marvelCount,
    required this.dcCount,
    required this.starWarsCount,
    required this.moviesTvCount,
    required this.gamingCount,
    required this.sportsCount,
    required this.musicCount,
    required this.iconsCount,
    required this.retroToysCount,
    required this.originalsCount,
    required this.asiaInternationalCount,
    required this.otherCount,
    this.onEntireVault,
    this.onWishlist,
    this.onAnime,
    this.onMarvel,
    this.onDc,
    this.onStarWars,
    this.onMoviesTv,
    this.onGaming,
    this.onSports,
    this.onMusic,
    this.onIcons,
    this.onRetroToys,
    this.onOriginals,
    this.onAsiaInternational,
    this.onOther,
  });

  final int totalPops;
  final int wishlistCount;
  final int animeCount;
  final int marvelCount;
  final int dcCount;
  final int starWarsCount;
  final int moviesTvCount;
  final int gamingCount;
  final int sportsCount;
  final int musicCount;
  final int iconsCount;
  final int retroToysCount;
  final int originalsCount;
  final int asiaInternationalCount;
  final int otherCount;
  final VoidCallback? onEntireVault;
  final VoidCallback? onWishlist;
  final VoidCallback? onAnime;
  final VoidCallback? onMarvel;
  final VoidCallback? onDc;
  final VoidCallback? onStarWars;
  final VoidCallback? onMoviesTv;
  final VoidCallback? onGaming;
  final VoidCallback? onSports;
  final VoidCallback? onMusic;
  final VoidCallback? onIcons;
  final VoidCallback? onRetroToys;
  final VoidCallback? onOriginals;
  final VoidCallback? onAsiaInternational;
  final VoidCallback? onOther;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AtlasSectionHeader(
          title: 'Vault Rooms',
          subtitle: 'Browse your collection by shelf and category.',
          icon: Icons.grid_view_rounded,
          accentColor: AtlasColors.vaultGold,
        ),
        const SizedBox(height: AtlasSpacing.md),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AtlasSpacing.md,
          mainAxisSpacing: AtlasSpacing.md,
          childAspectRatio: 1.16,
          children: [
            VaultRoomCard(
              title: 'Entire Vault',
              subtitle: _countLabel(totalPops),
              icon: AtlasIcons.collection,
              onTap: onEntireVault,
            ),
            VaultRoomCard(
              title: 'Wishlist',
              subtitle: _itemLabel(wishlistCount),
              icon: AtlasIcons.wishlist,
              onTap: onWishlist,
            ),
            VaultRoomCard(
              title: 'Anime',
              subtitle: _countLabel(animeCount),
              icon: Icons.auto_awesome,
              onTap: onAnime,
            ),
            VaultRoomCard(
              title: 'Marvel',
              subtitle: _countLabel(marvelCount),
              icon: Icons.flash_on,
              onTap: onMarvel,
            ),
            VaultRoomCard(
              title: 'DC',
              subtitle: _countLabel(dcCount),
              icon: Icons.shield,
              onTap: onDc,
            ),
            VaultRoomCard(
              title: 'Star Wars',
              subtitle: _countLabel(starWarsCount),
              icon: Icons.star,
              onTap: onStarWars,
            ),
            VaultRoomCard(
              title: 'Movies & TV',
              subtitle: _countLabel(moviesTvCount),
              icon: Icons.movie_filter_outlined,
              onTap: onMoviesTv,
            ),
            VaultRoomCard(
              title: 'Gaming',
              subtitle: _countLabel(gamingCount),
              icon: Icons.sports_esports,
              onTap: onGaming,
            ),
            VaultRoomCard(
              title: 'Sports',
              subtitle: _countLabel(sportsCount),
              icon: Icons.sports_football_rounded,
              onTap: onSports,
            ),
            VaultRoomCard(
              title: 'Music / Rocks',
              subtitle: _countLabel(musicCount),
              icon: Icons.music_note_rounded,
              onTap: onMusic,
            ),
            VaultRoomCard(
              title: 'Icons',
              subtitle: _countLabel(iconsCount),
              icon: Icons.workspace_premium_rounded,
              onTap: onIcons,
            ),
            VaultRoomCard(
              title: 'Retro Toys',
              subtitle: _countLabel(retroToysCount),
              icon: Icons.toys_rounded,
              onTap: onRetroToys,
            ),
            VaultRoomCard(
              title: 'Originals',
              subtitle: _countLabel(originalsCount),
              icon: Icons.auto_awesome_rounded,
              onTap: onOriginals,
            ),
            VaultRoomCard(
              title: 'Asia / International',
              subtitle: _countLabel(asiaInternationalCount),
              icon: Icons.public_rounded,
              onTap: onAsiaInternational,
            ),
            VaultRoomCard(
              title: 'Other',
              subtitle: _countLabel(otherCount),
              icon: Icons.inventory_2_outlined,
              onTap: onOther,
            ),
          ],
        ),
      ],
    );
  }

  static String _countLabel(int count) =>
      '$count ${count == 1 ? 'Pop' : 'Pops'}';

  static String _itemLabel(int count) =>
      '$count ${count == 1 ? 'Item' : 'Items'}';
}
