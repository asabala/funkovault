import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'entire_vault_screen.dart';
import '../../atlas/repositories/vault_repository.dart';
import '../../atlas/taxonomy/services/atlas_vault_room_classifier.dart';
import '../../models/pop.dart';
import '../../services/app_state.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/atlas_glass_panel.dart';
import '../../widgets/atlas/atlas_stat_tile.dart';
import '../../widgets/atlas/components/atlas_empty_state.dart';
import '../../widgets/atlas/components/atlas_info_banner.dart';
import '../../widgets/atlas/components/atlas_section_header.dart';
import '../../widgets/vault/components/vault_pop_tile.dart';
import '../catalog/funko_catalog_screen.dart';
import '../scanner/atlas_shelf_scan_screen.dart';

class AtlasRoomScreen extends StatelessWidget {
  const AtlasRoomScreen({
    super.key,
    required this.roomName,
    required this.description,
    required this.icon,
    this.categoryName,
    this.vaultRoom,
    this.collectionName,
  });

  final String roomName;
  final String description;
  final IconData icon;
  final String? categoryName;
  final AtlasVaultRoom? vaultRoom;
  final String? collectionName;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    const repository = VaultRepository();

    final allPops = collectionName == null
        ? repository.allPops(appState)
        : appState.popsForCollection(collectionName!);

    final roomPops = _roomPops(allPops);

    final roomValue = roomPops.fold<double>(
      0,
      (total, pop) => total + pop.value,
    );

    final wishlistCount = roomPops.where((pop) => pop.isWishlist).length;

    final missingValueCount = roomPops.where((pop) => pop.value <= 0).length;

    return Scaffold(
      appBar: AppBar(title: Text(roomName)),
      body: SafeArea(
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AtlasSpacing.lg,
                AtlasSpacing.lg,
                AtlasSpacing.lg,
                0,
              ),
              sliver: SliverList.list(
                children: [
                  AtlasGlassCard(
                    accentColor: AtlasColors.vaultGold,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AtlasSectionHeader(
                          title: roomName,
                          subtitle: description,
                          icon: icon,
                          titleStyle: AtlasTypography.headingLarge,
                          accentColor: AtlasColors.vaultGold,
                        ),
                        const SizedBox(height: AtlasSpacing.lg),
                        _RoomStatsPanel(
                          totalPops: roomPops.length,
                          totalValue: roomValue,
                          wishlistCount: wishlistCount,
                        ),
                        const SizedBox(height: AtlasSpacing.lg),
                        AtlasInfoBanner(
                          icon: Icons.auto_awesome_rounded,
                          title: _roomStatusText(roomPops.length),
                          message: _roomDescriptionText(roomPops.length),
                        ),
                        const SizedBox(height: AtlasSpacing.lg),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FunkoCatalogScreen(
                                    collectionName: collectionName,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.search_rounded),
                            label: const Text('Browse Catalog'),
                          ),
                        ),
                        if (collectionName != null) ...[
                          const SizedBox(height: AtlasSpacing.sm),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              key: const ValueKey('start-shelf-scan'),
                              onPressed: () {
                                Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute<bool>(
                                    builder: (_) => AtlasShelfScanScreen(
                                      collectionName: collectionName!,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.view_in_ar_outlined),
                              label: const Text('Start Shelf Scan'),
                            ),
                          ),
                          const SizedBox(height: AtlasSpacing.sm),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              key: const ValueKey('open-full-collection'),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (_) => EntireVaultScreen(
                                      collectionName: collectionName,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.inventory_2_outlined),
                              label: const Text('Open Full Collection'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AtlasSpacing.lg),
                  _RoomInsightCard(
                    roomName: roomName,
                    totalPops: roomPops.length,
                    totalValue: roomValue,
                    wishlistCount: wishlistCount,
                    missingValueCount: missingValueCount,
                  ),
                  const SizedBox(height: AtlasSpacing.lg),
                  _RoomCollectionHeader(
                    roomName: roomName,
                    totalRoomPops: roomPops.length,
                  ),
                  const SizedBox(height: AtlasSpacing.md),
                ],
              ),
            ),
            if (roomPops.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AtlasSpacing.lg,
                  0,
                  AtlasSpacing.lg,
                  100,
                ),
                sliver: const SliverToBoxAdapter(
                  child: AtlasEmptyState(
                    eyebrow: 'Your Collection',
                    title: 'No Pops Found',
                    message:
                        'No Pops found in this room yet. Add matching collectibles to start building this room.',
                    icon: Icons.inventory_2_outlined,
                    compact: true,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AtlasSpacing.lg,
                  0,
                  AtlasSpacing.lg,
                  100,
                ),
                sliver: SliverList.builder(
                  itemCount: roomPops.length,
                  itemBuilder: (context, index) {
                    final pop = roomPops[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AtlasSpacing.sm),
                      child: VaultPopTile(
                        key: ValueKey('room-pop-${pop.id}'),
                        pop: pop,
                        showImage: true,
                        collectionName: collectionName,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Pop> _roomPops(List<Pop> pops) {
    final resolvedRoom =
        vaultRoom ?? AtlasVaultRoom.fromDisplayName(categoryName);

    if (resolvedRoom != null) {
      const classifier = AtlasVaultRoomClassifier();

      return pops.where((pop) {
        return !pop.isWishlist && classifier.isInRoom(pop, resolvedRoom);
      }).toList();
    }

    final category = categoryName?.trim().toLowerCase();

    if (category == null || category.isEmpty) {
      return pops;
    }

    // Backward compatibility for any custom/legacy room that still supplies a
    // category string outside the centralized Atlas Vault Room taxonomy.
    return pops.where((pop) {
      return pop.category.trim().toLowerCase() == category;
    }).toList();
  }

  String _roomStatusText(int roomPopCount) {
    if (collectionName != null) {
      if (roomPopCount == 0) {
        return 'This collection is ready for its first Pop.';
      }

      return 'Atlas found $roomPopCount '
          'Pop${roomPopCount == 1 ? '' : 's'} in this collection.';
    }

    if (vaultRoom == null &&
        (categoryName == null || categoryName!.trim().isEmpty)) {
      return 'Room filters are coming soon.';
    }

    if (roomPopCount == 0) {
      return 'No matching Pops found yet.';
    }

    return 'Atlas found $roomPopCount matching '
        'Pop${roomPopCount == 1 ? '' : 's'}.';
  }

  String _roomDescriptionText(int roomPopCount) {
    if (collectionName != null) {
      if (roomPopCount == 0) {
        return 'Add Pops to this collection to build its stats, value '
            'insights, wishlist tracking, and Atlas recommendations.';
      }

      return 'This collection room is connected to your collection data. '
          'Use it to review stats, value insights, wishlist targets, '
          'and your current Pop preview.';
    }

    if (vaultRoom == null &&
        (categoryName == null || categoryName!.trim().isEmpty)) {
      return 'This room will eventually show matching Pops from your '
          'vault, quick stats, value insights, missing grails, wishlist '
          'targets, and Atlas recommendations for this category.';
    }

    if (roomPopCount == 0) {
      return 'Once you add Pops in this category, this room will show '
          'vault stats, value insights, wishlist targets, and Atlas '
          'recommendations.';
    }

    return 'This room is now connected to your vault data. Next, we can '
        'add grail tracking, missing value warnings, and room-specific '
        'recommendations.';
  }
}

class _RoomStatsPanel extends StatelessWidget {
  const _RoomStatsPanel({
    required this.totalPops,
    required this.totalValue,
    required this.wishlistCount,
  });

  final int totalPops;
  final double totalValue;
  final int wishlistCount;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassPanel(
      child: Row(
        children: [
          Expanded(
            child: AtlasStatTile(
              icon: Icons.inventory_2_outlined,
              value: '$totalPops',
              label: 'Pops',
            ),
          ),
          Expanded(
            child: AtlasStatTile(
              icon: Icons.attach_money_rounded,
              value: '\$${totalValue.toStringAsFixed(0)}',
              label: 'Value',
            ),
          ),
          Expanded(
            child: AtlasStatTile(
              icon: Icons.favorite_border_rounded,
              value: '$wishlistCount',
              label: 'Wishlist',
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomInsightCard extends StatelessWidget {
  const _RoomInsightCard({
    required this.roomName,
    required this.totalPops,
    required this.totalValue,
    required this.wishlistCount,
    required this.missingValueCount,
  });

  final String roomName;
  final int totalPops;
  final double totalValue;
  final int wishlistCount;
  final int missingValueCount;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      accentColor: AtlasColors.vaultGold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AtlasSectionHeader(
            title: 'Atlas Room Insight',
            subtitle: 'Collector guidance based on the current room snapshot.',
            icon: Icons.insights_rounded,
            accentColor: AtlasColors.vaultGold,
          ),
          const SizedBox(height: AtlasSpacing.md),
          AtlasInfoBanner(
            icon: Icons.auto_awesome_rounded,
            title: 'Room Analysis',
            message: _insight,
          ),
        ],
      ),
    );
  }

  String get _insight {
    if (totalPops == 0) {
      return '$roomName is ready. Add matching Pops to unlock room '
          'insights, value tracking, and wishlist recommendations.';
    }

    if (missingValueCount > 0) {
      return '$roomName has $missingValueCount '
          'Pop${missingValueCount == 1 ? '' : 's'} missing values. '
          'Updating those will improve Atlas accuracy for this room.';
    }

    if (wishlistCount > 0) {
      return '$roomName has $wishlistCount wishlist '
          'target${wishlistCount == 1 ? '' : 's'}. Atlas can use this '
          'room to help prioritize future pickups.';
    }

    if (totalValue >= 500) {
      return '$roomName is becoming one of your stronger value rooms '
          'with an estimated value of '
          '\$${totalValue.toStringAsFixed(0)}.';
    }

    return '$roomName is connected to your vault. Atlas will continue '
        'learning from this room as you add more Pops.';
  }
}

class _RoomCollectionHeader extends StatelessWidget {
  const _RoomCollectionHeader({
    required this.roomName,
    required this.totalRoomPops,
  });

  final String roomName;
  final int totalRoomPops;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      accentColor: AtlasColors.vaultGold,
      child: AtlasSectionHeader(
        title: 'Your $roomName Collection',
        subtitle: _subtitle,
        icon: Icons.inventory_2_outlined,
        accentColor: AtlasColors.vaultGold,
      ),
    );
  }

  String get _subtitle {
    if (totalRoomPops == 0) {
      return '$roomName is ready when your matching Pops are added.';
    }

    return 'Browse all $totalRoomPops matching '
        'Pop${totalRoomPops == 1 ? '' : 's'}.';
  }
}
