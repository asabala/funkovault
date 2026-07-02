import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../atlas/repositories/vault_repository.dart';
import '../services/app_state.dart';
import '../theme/atlas_spacing.dart';
import '../widgets/vault/atlas_recommendation_card.dart';
import '../widgets/vault/collection_rooms_card.dart';
import '../widgets/vault/collector_tools_card.dart';
import '../widgets/vault/hero_collector_card.dart';
import '../widgets/vault_scroll_view.dart';
import '../screens/add_pop_screen.dart';
import '../screens/scan_screen.dart';
import '../screens/wishlist_screen.dart';
import '../screens/funko_catalog_screen.dart';
import '../screens/edit_collector_profile_screen.dart';
import '../atlas/core/atlas_intelligence.dart';
import '../widgets/vault/atlas_mission_card.dart';

class CollectorVaultScreen extends StatelessWidget {
  const CollectorVaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    const repository = VaultRepository();
    const intelligence = AtlasIntelligence();

    final allPops = repository.allPops(appState);
    final recommendation =
    intelligence.getRecommendation(allPops);

    final mission =
    intelligence.getTodayMission(allPops);

    final confidence =
    intelligence.getCollectorConfidence(allPops);

    final collectorType =
    intelligence.getCollectorType(allPops);

    final favoriteCategory =
    intelligence.getFavoriteCategory(allPops);
    final totalValue = repository.totalValue(appState);
    final profile = appState.collectorProfile;


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
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
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
            onEditProfile: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EditCollectorProfileScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: AtlasSpacing.lg),

          AtlasMissionCard(
            mission: mission,
            collectorType: collectorType,
            confidence: confidence.round(),
            onContinue: () {},
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
            onSearch: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FunkoCatalogScreen(),
                ),
              );
            },
            onValueLookup: () {},
            onAtlasAi: () {},
          ),

          const SizedBox(height: AtlasSpacing.lg),

          CollectionRoomsCard(
            totalPops: allPops.length,
            onEntireVault: () {},
            onWishlist: () {},
            onAnime: () {},
            onMarvel: () {},
            onDc: () {},
            onStarWars: () {},
            onMoviesTv: () {},
            onGaming: () {},
          ),

          const SizedBox(height: AtlasSpacing.lg),

          AtlasRecommendationCard(
            message: recommendation,
            confidence: confidence.round(),
            estimatedCost: favoriteCategory,
            difficulty: collectorType,
            onViewDetails: () {},
          ),
        ],
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