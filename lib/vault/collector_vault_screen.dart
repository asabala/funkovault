import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../atlas/repositories/vault_repository.dart';
import '../atlas/taxonomy/services/atlas_vault_room_classifier.dart';
import '../screens/catalog/funko_catalog_screen.dart';
import '../screens/pop/add_pop_screen.dart';
import '../screens/profile/edit_collector_profile_screen.dart';
import '../screens/vault/atlas_room_screen.dart';
import '../screens/vault/collections_screen.dart';
import '../screens/vault/entire_vault_screen.dart';
import '../screens/vault/vault_health_screen.dart';
import '../screens/vault/wishlist_screen.dart';
import '../services/app_state.dart';
import '../theme/atlas_colors.dart';
import '../theme/atlas_spacing.dart';
import '../theme/atlas_typography.dart';
import 'health/vault_health_engine.dart';
import '../widgets/atlas/atlas_glass_card.dart';
import '../widgets/vault/collection_rooms_card.dart';
import '../widgets/vault/vault_health_summary_card.dart';
import '../widgets/vault/vault_scroll_view.dart';

class CollectorVaultScreen extends StatelessWidget {
  const CollectorVaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    const repository = VaultRepository();
    const vaultHealthEngine = VaultHealthEngine();

    final allPops = repository.allPops(appState);
    final vaultHealth = vaultHealthEngine.calculate(allPops);
    final profile = appState.collectorProfile;

    final totalValue = vaultHealth.totalValue;
    final missingValueCount = vaultHealth.needsValueCount;
    final duplicateGroupCount = vaultHealth.duplicateGroupCount;
    final health = vaultHealth.healthScore;
    final healthPriority = vaultHealth.priority;

    final ownedCount = allPops.where((pop) => !pop.isWishlist).length;
    final wishlistCount = allPops.where((pop) => pop.isWishlist).length;

    const roomClassifier = AtlasVaultRoomClassifier();
    final roomCounts = roomClassifier.countsFor(allPops);
    final animeCount = roomCounts[AtlasVaultRoom.anime] ?? 0;
    final marvelCount = roomCounts[AtlasVaultRoom.marvel] ?? 0;
    final dcCount = roomCounts[AtlasVaultRoom.dc] ?? 0;
    final starWarsCount = roomCounts[AtlasVaultRoom.starWars] ?? 0;
    final moviesTvCount = roomCounts[AtlasVaultRoom.moviesAndTv] ?? 0;
    final gamingCount = roomCounts[AtlasVaultRoom.gaming] ?? 0;
    final sportsCount = roomCounts[AtlasVaultRoom.sports] ?? 0;
    final musicCount = roomCounts[AtlasVaultRoom.music] ?? 0;
    final iconsCount = roomCounts[AtlasVaultRoom.icons] ?? 0;
    final retroToysCount = roomCounts[AtlasVaultRoom.retroToys] ?? 0;
    final originalsCount = roomCounts[AtlasVaultRoom.originals] ?? 0;
    final asiaInternationalCount =
        roomCounts[AtlasVaultRoom.asiaInternational] ?? 0;
    final otherCount = roomCounts[AtlasVaultRoom.other] ?? 0;

    final profileName = profile.displayName.trim().isEmpty
        ? 'Collector'
        : profile.displayName.trim();
    final profileInitial = profileName[0].toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Collector's Vault"),
        actions: [
          IconButton(
            tooltip: 'Manage Collections',
            onPressed: () {
              Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const CollectionsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.folder_copy_outlined),
          ),
          IconButton(
            tooltip: 'Vault Health',
            onPressed: () => _openVaultHealth(context),
            icon: const Icon(Icons.health_and_safety_outlined),
          ),
          Padding(
            padding: const EdgeInsets.only(right: AtlasSpacing.sm),
            child: IconButton(
              tooltip: 'Edit collector profile',
              onPressed: () => _openEditProfile(context),
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AtlasColors.vaultGold,
                    child: Text(
                      profileInitial,
                      style: const TextStyle(
                        color: AtlasColors.background,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -1,
                    bottom: -1,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AtlasColors.background,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: VaultScrollView(
        children: [
          _VaultSummaryCard(
            collectorName: profileName,
            ownedCount: ownedCount,
            totalValue: totalValue,
            health: health,
          ),
          const SizedBox(height: AtlasSpacing.md),
          _VaultActionBar(
            onSearch: () => _openCatalog(context),
            onAdd: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddPopScreen()),
              );
            },
          ),
          const SizedBox(height: AtlasSpacing.lg),
          CollectionRoomsCard(
            totalPops: ownedCount,
            wishlistCount: wishlistCount,
            animeCount: animeCount,
            marvelCount: marvelCount,
            dcCount: dcCount,
            starWarsCount: starWarsCount,
            moviesTvCount: moviesTvCount,
            gamingCount: gamingCount,
            sportsCount: sportsCount,
            musicCount: musicCount,
            iconsCount: iconsCount,
            retroToysCount: retroToysCount,
            originalsCount: originalsCount,
            asiaInternationalCount: asiaInternationalCount,
            otherCount: otherCount,
            onEntireVault: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EntireVaultScreen()),
              );
            },
            onWishlist: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WishlistScreen()),
              );
            },
            onAnime: () => _openRoom(
              context,
              roomName: 'Anime Room',
              room: AtlasVaultRoom.anime,
              description: 'Explore the Anime collectibles in your Vault.',
              icon: Icons.auto_awesome_rounded,
            ),
            onMarvel: () => _openRoom(
              context,
              roomName: 'Marvel Room',
              room: AtlasVaultRoom.marvel,
              description: 'Explore the Marvel collectibles in your Vault.',
              icon: Icons.bolt_rounded,
            ),
            onDc: () => _openRoom(
              context,
              roomName: 'DC Room',
              room: AtlasVaultRoom.dc,
              description: 'Explore the DC collectibles in your Vault.',
              icon: Icons.shield_rounded,
            ),
            onStarWars: () => _openRoom(
              context,
              roomName: 'Star Wars Room',
              room: AtlasVaultRoom.starWars,
              description: 'Explore the Star Wars collectibles in your Vault.',
              icon: Icons.star_rounded,
            ),
            onMoviesTv: () => _openRoom(
              context,
              roomName: 'Movies & TV Room',
              room: AtlasVaultRoom.moviesAndTv,
              description:
                  'Explore the Movies & TV collectibles in your Vault.',
              icon: Icons.movie_filter_rounded,
            ),
            onGaming: () => _openRoom(
              context,
              roomName: 'Gaming Room',
              room: AtlasVaultRoom.gaming,
              description: 'Explore the Gaming collectibles in your Vault.',
              icon: Icons.sports_esports_rounded,
            ),
            onSports: () => _openRoom(
              context,
              roomName: 'Sports Room',
              room: AtlasVaultRoom.sports,
              description: 'Explore the Sports collectibles in your Vault.',
              icon: Icons.sports_football_rounded,
            ),
            onMusic: () => _openRoom(
              context,
              roomName: 'Music / Rocks Room',
              room: AtlasVaultRoom.music,
              description:
                  'Explore the Music and Rocks collectibles in your Vault.',
              icon: Icons.music_note_rounded,
            ),
            onIcons: () => _openRoom(
              context,
              roomName: 'Icons Room',
              room: AtlasVaultRoom.icons,
              description:
                  'Explore the Icons and Ad Icons collectibles in your Vault.',
              icon: Icons.workspace_premium_rounded,
            ),
            onRetroToys: () => _openRoom(
              context,
              roomName: 'Retro Toys Room',
              room: AtlasVaultRoom.retroToys,
              description: 'Explore the Retro Toys collectibles in your Vault.',
              icon: Icons.toys_rounded,
            ),
            onOriginals: () => _openRoom(
              context,
              roomName: 'Originals Room',
              room: AtlasVaultRoom.originals,
              description: 'Explore the Funko Originals in your Vault.',
              icon: Icons.auto_awesome_rounded,
            ),
            onAsiaInternational: () => _openRoom(
              context,
              roomName: 'Asia / International Room',
              room: AtlasVaultRoom.asiaInternational,
              description:
                  'Explore Asia and international collectibles in your Vault.',
              icon: Icons.public_rounded,
            ),
            onOther: () => _openRoom(
              context,
              roomName: 'Other Room',
              room: AtlasVaultRoom.other,
              description:
                  'Explore collectibles outside the primary Vault Rooms.',
              icon: Icons.inventory_2_outlined,
            ),
          ),
          const SizedBox(height: AtlasSpacing.lg),
          VaultHealthSummaryCard(
            healthScore: health,
            priority: healthPriority,
            needsValueCount: missingValueCount,
            duplicateGroupCount: duplicateGroupCount,
            onTap: () => _openVaultHealth(context),
          ),
        ],
      ),
    );
  }

  static void _openEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditCollectorProfileScreen()),
    );
  }

  static void _openCatalog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FunkoCatalogScreen()),
    );
  }

  static void _openVaultHealth(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VaultHealthScreen()),
    );
  }

  static void _openRoom(
    BuildContext context, {
    required String roomName,
    required String description,
    required IconData icon,
    required AtlasVaultRoom room,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AtlasRoomScreen(
          roomName: roomName,
          description: description,
          icon: icon,
          vaultRoom: room,
        ),
      ),
    );
  }
}

class _VaultSummaryCard extends StatelessWidget {
  const _VaultSummaryCard({
    required this.collectorName,
    required this.ownedCount,
    required this.totalValue,
    required this.health,
  });

  final String collectorName;
  final int ownedCount;
  final double totalValue;
  final double health;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      accentColor: AtlasColors.vaultGold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$collectorName's Vault",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AtlasTypography.headingLarge,
          ),
          const SizedBox(height: AtlasSpacing.xs),
          Text(
            'Your collection at a glance.',
            style: AtlasTypography.bodyMedium.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
          const SizedBox(height: AtlasSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(
                  icon: Icons.inventory_2_outlined,
                  value: '$ownedCount',
                  label: 'Pops',
                ),
              ),
              Expanded(
                child: _SummaryMetric(
                  icon: Icons.attach_money_rounded,
                  value: _formatMoney(totalValue),
                  label: 'Value',
                ),
              ),
              Expanded(
                child: _SummaryMetric(
                  icon: Icons.health_and_safety_outlined,
                  value: '${health.round()}%',
                  label: 'Vault Health',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatMoney(double value) {
    final whole = value.round().toString();
    final buffer = StringBuffer(r'$');

    for (var index = 0; index < whole.length; index++) {
      if (index > 0 && (whole.length - index) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(whole[index]);
    }

    return buffer.toString();
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AtlasColors.vaultGold, size: 26),
        const SizedBox(height: AtlasSpacing.xs),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            maxLines: 1,
            style: AtlasTypography.metricSmall.copyWith(
              color: AtlasColors.vaultGold,
              fontSize: 22,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AtlasTypography.bodySmall.copyWith(
            color: AtlasColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _VaultActionBar extends StatelessWidget {
  const _VaultActionBar({required this.onSearch, required this.onAdd});

  final VoidCallback onSearch;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      onTap: onSearch,
      accentColor: AtlasColors.vaultGold,
      padding: const EdgeInsets.symmetric(
        horizontal: AtlasSpacing.md,
        vertical: AtlasSpacing.sm,
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AtlasColors.intelligenceBlue),
          const SizedBox(width: AtlasSpacing.md),
          Expanded(
            child: Text(
              'Search Vault...',
              style: AtlasTypography.bodyLarge.copyWith(
                color: AtlasColors.textSecondary,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 34,
            color: Colors.white.withValues(alpha: 0.08),
          ),
          const SizedBox(width: AtlasSpacing.sm),
          IconButton(
            tooltip: 'Add Pop',
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, color: AtlasColors.vaultGold),
          ),
        ],
      ),
    );
  }
}
