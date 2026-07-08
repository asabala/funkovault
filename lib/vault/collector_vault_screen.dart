import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../atlas/core/atlas_intelligence.dart';
import '../atlas/repositories/vault_repository.dart';
import '../screens/add_pop_screen.dart';
import '../screens/atlas_room_screen.dart';
import '../screens/edit_collector_profile_screen.dart';
import '../screens/funko_catalog_screen.dart';
import '../screens/scan_screen.dart';
import '../screens/wishlist_screen.dart';
import '../services/app_state.dart';
import '../theme/atlas_colors.dart';
import '../theme/atlas_spacing.dart';
import '../widgets/vault/atlas_mission_card.dart';
import '../widgets/vault/atlas_recommendation_card.dart';
import '../widgets/vault/collection_rooms_card.dart';
import '../widgets/vault/collector_tools_card.dart';
import '../widgets/vault/hero_collector_card.dart';
import '../widgets/vault_scroll_view.dart';
import '../screens/entire_vault_screen.dart';

class CollectorVaultScreen extends StatelessWidget {
  const CollectorVaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    const repository = VaultRepository();
    const intelligence = AtlasIntelligence();

    final allPops = repository.allPops(appState);
    final recommendation = intelligence.getRecommendation(allPops);
    final mission = intelligence.getTodayMission(allPops);
    final confidence = intelligence.getCollectorConfidence(allPops);
    final collectorType = intelligence.getCollectorType(allPops);
    final favoriteCategory = intelligence.getFavoriteCategory(allPops);
    final totalValue = repository.totalValue(appState);
    final profile = appState.collectorProfile;

    final profileInitial = profile.displayName.trim().isEmpty
        ? 'A'
        : profile.displayName.trim()[0].toUpperCase();

    final duplicateCount = repository.duplicatePopGroups(appState).length;
    final missingValueCount = allPops.where((pop) => pop.value <= 0).length;

    final health = _calculateVaultHealth(
      totalPops: allPops.length,
      duplicateCount: duplicateCount,
      missingValueCount: missingValueCount,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Collector's Vault"),
        actions: [
          IconButton(
            tooltip: 'Search',
            onPressed: () => _openCatalog(context),
            icon: const Icon(Icons.search),
          ),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => _showComingSoonMessage(
              context,
              'Notifications are coming soon.',
            ),
            icon: const Icon(Icons.notifications_none),
          ),
          Padding(
            padding: const EdgeInsets.only(right: AtlasSpacing.sm),
            child: IconButton(
              tooltip: 'Signed in as ${profile.displayName}',
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
          HeroCollectorCard(
            collectorName: profile.displayName,
            collectorTitle: profile.collectorTitle,
            collectorBio: profile.bio,
            favoriteCategory: profile.favoriteCategory,
            collectorLevel: profile.collectorLevel,
            isPremium: profile.isPremium,
            totalPops: allPops.length,
            totalValue: totalValue,
            health: health,
            onEditProfile: () => _openEditProfile(context),
          ),
          const SizedBox(height: AtlasSpacing.lg),
          AtlasMissionCard(
            mission: mission,
            collectorType: collectorType,
            confidence: confidence.round(),
            onContinue: () => _openCatalogWithMessage(
              context,
              'Opening the catalog so you can keep building your vault.',
            ),
          ),
          const SizedBox(height: AtlasSpacing.lg),
          CollectorToolsCard(
            onAddPop: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddPopScreen(),
                ),
              );
            },
            onScan: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ScanScreen(),
                ),
              );
            },
            onWishlist: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const WishlistScreen(),
                ),
              );
            },
            onSearch: () => _openCatalog(context),
            onValueLookup: () => _openCatalogWithMessage(
              context,
              'Value lookup will use the catalog for now.',
            ),
            onAtlasAi: () => _openCatalogWithMessage(
              context,
              'Atlas AI insights are coming soon. Opening catalog for now.',
            ),
          ),
          const SizedBox(height: AtlasSpacing.lg),
          CollectionRoomsCard(
            totalPops: allPops.length,
            onEntireVault: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EntireVaultScreen(),
                ),
              );
            },
            onWishlist: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const WishlistScreen(),
                ),
              );
            },
            onAnime: () => _openRoom(
              context,
              roomName: 'Anime Room',
              categoryName: 'Anime',
              description:
              'Explore anime Pops in your vault, future wishlist targets, grails, and Atlas recommendations.',
              icon: Icons.auto_awesome_rounded,
            ),
            onMarvel: () => _openRoom(
              context,
              roomName: 'Marvel Room',
              categoryName: 'Marvel',
              description:
              'Track Marvel Pops, value trends, missing heroes, variants, and future vault opportunities.',
              icon: Icons.bolt_rounded,
            ),
            onDc: () => _openRoom(
              context,
              roomName: 'DC Room',
              categoryName: 'DC',
              description:
              'Review DC Pops, villains, heroes, exclusives, and collection opportunities.',
              icon: Icons.shield_rounded,
            ),
            onStarWars: () => _openRoom(
              context,
              roomName: 'Star Wars Room',
              categoryName: 'Star Wars',
              description:
              'Explore Star Wars Pops, sagas, exclusives, character groups, and collecting opportunities.',
              icon: Icons.public_rounded,
            ),
            onMoviesTv: () => _openRoom(
              context,
              roomName: 'Movies & TV Room',
              categoryName: 'Movies & TV',
              description:
              'Review movie and TV Pops across your vault, future targets, and recommendation paths.',
              icon: Icons.movie_filter_rounded,
            ),
            onGaming: () => _openRoom(
              context,
              roomName: 'Gaming Room',
              categoryName: 'Gaming',
              description:
              'Explore gaming Pops, franchises, vault gaps, wishlist targets, and collector insights.',
              icon: Icons.sports_esports_rounded,
            ),
          ),
          const SizedBox(height: AtlasSpacing.lg),
          AtlasRecommendationCard(
            message: recommendation,
            confidence: confidence.round(),
            estimatedCost: favoriteCategory,
            difficulty: collectorType,
            onViewDetails: () => _openCatalogWithMessage(
              context,
              'Opening catalog details for now.',
            ),
          ),
        ],
      ),
    );
  }

  static void _openEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EditCollectorProfileScreen(),
      ),
    );
  }

  static void _openCatalog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FunkoCatalogScreen(),
      ),
    );
  }

  static void _openCatalogWithMessage(
      BuildContext context,
      String message,
      ) {
    _showComingSoonMessage(context, message);
    _openCatalog(context);
  }

  static void _openRoom(
      BuildContext context, {
        required String roomName,
        required String description,
        required IconData icon,
        required String categoryName,
      }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AtlasRoomScreen(
          roomName: roomName,
          description: description,
          icon: icon,
          categoryName: categoryName,
        ),
      ),
    );
  }

  static void _showComingSoonMessage(
      BuildContext context,
      String message,
      ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  double _calculateVaultHealth({
    required int totalPops,
    required int duplicateCount,
    required int missingValueCount,
  }) {
    if (totalPops == 0) {
      return 100;
    }

    final issueCount = duplicateCount + missingValueCount;
    final score = 100 - ((issueCount / totalPops) * 100);

    return score.clamp(0, 100);
  }
}