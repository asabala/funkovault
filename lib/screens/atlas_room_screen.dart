import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../atlas/repositories/vault_repository.dart';
import '../models/pop.dart';
import '../services/app_state.dart';
import '../theme/atlas_colors.dart';
import '../theme/atlas_spacing.dart';
import '../theme/atlas_typography.dart';
import '../widgets/atlas/atlas_glass_card.dart';
import '../widgets/atlas/atlas_glass_panel.dart';
import '../widgets/atlas/atlas_stat_tile.dart';
import '../widgets/vault_scroll_view.dart';
import 'funko_catalog_screen.dart';

class AtlasRoomScreen extends StatelessWidget {
  const AtlasRoomScreen({
    super.key,
    required this.roomName,
    required this.description,
    required this.icon,
    this.categoryName,
  });

  final String roomName;
  final String description;
  final IconData icon;
  final String? categoryName;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    const repository = VaultRepository();

    final allPops = repository.allPops(appState);
    final roomPops = _roomPops(allPops);
    final roomValue = roomPops.fold<double>(
      0,
          (total, pop) => total + pop.value,
    );
    final wishlistCount = roomPops.where((pop) => pop.isWishlist).length;
    final missingValueCount = roomPops.where((pop) => pop.value <= 0).length;
    final previewPops = roomPops.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(roomName),
      ),
      body: VaultScrollView(
        children: [
          AtlasGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  size: 48,
                  color: AtlasColors.vaultGold,
                ),
                const SizedBox(height: AtlasSpacing.lg),
                Text(
                  roomName,
                  style: AtlasTypography.headingLarge,
                ),
                const SizedBox(height: AtlasSpacing.sm),
                Text(
                  description,
                  style: AtlasTypography.bodyMedium.copyWith(
                    color: AtlasColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AtlasSpacing.lg),
                _RoomStatsPanel(
                  totalPops: roomPops.length,
                  totalValue: roomValue,
                  wishlistCount: wishlistCount,
                ),
                const SizedBox(height: AtlasSpacing.lg),
                Text(
                  _roomStatusText(roomPops.length),
                  style: AtlasTypography.headingSmall,
                ),
                const SizedBox(height: AtlasSpacing.sm),
                Text(
                  _roomDescriptionText(roomPops.length),
                  style: AtlasTypography.bodyMedium.copyWith(
                    color: AtlasColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AtlasSpacing.xl),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FunkoCatalogScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.search_rounded),
                  label: const Text('Browse Catalog'),
                ),
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
          _RoomPopPreviewCard(
            roomName: roomName,
            roomPops: previewPops,
            totalRoomPops: roomPops.length,
          ),
        ],
      ),
    );
  }

  List<Pop> _roomPops(List<Pop> pops) {
    final category = categoryName?.trim().toLowerCase();

    if (category == null || category.isEmpty) {
      return pops;
    }

    return pops.where((pop) {
      return pop.category.trim().toLowerCase() == category;
    }).toList();
  }

  String _roomStatusText(int roomPopCount) {
    if (categoryName == null || categoryName!.trim().isEmpty) {
      return 'Room filters are coming soon.';
    }

    if (roomPopCount == 0) {
      return 'No matching Pops found yet.';
    }

    return 'Atlas found $roomPopCount matching Pop${roomPopCount == 1 ? '' : 's'}.';
  }

  String _roomDescriptionText(int roomPopCount) {
    if (categoryName == null || categoryName!.trim().isEmpty) {
      return 'This room will eventually show matching Pops from your vault, quick stats, value insights, missing grails, wishlist targets, and Atlas recommendations for this category.';
    }

    if (roomPopCount == 0) {
      return 'Once you add Pops in this category, this room will show vault stats, value insights, wishlist targets, and Atlas recommendations.';
    }

    return 'This room is now connected to your vault data. Next, we can add grail tracking, missing value warnings, and room-specific recommendations.';
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
              icon: Icons.attach_money,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Atlas Room Insight',
            style: AtlasTypography.headingSmall,
          ),
          const SizedBox(height: AtlasSpacing.md),
          AtlasGlassPanel(
            child: Text(
              _insight,
              style: AtlasTypography.bodyMedium.copyWith(
                color: AtlasColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _insight {
    if (totalPops == 0) {
      return '$roomName is ready. Add matching Pops to unlock room insights, value tracking, and wishlist recommendations.';
    }

    if (missingValueCount > 0) {
      return '$roomName has $missingValueCount Pop${missingValueCount == 1 ? '' : 's'} missing values. Updating those will improve Atlas accuracy for this room.';
    }

    if (wishlistCount > 0) {
      return '$roomName has $wishlistCount wishlist target${wishlistCount == 1 ? '' : 's'}. Atlas can use this room to help prioritize future pickups.';
    }

    if (totalValue >= 500) {
      return '$roomName is becoming one of your stronger value rooms with an estimated value of \$${totalValue.toStringAsFixed(0)}.';
    }

    return '$roomName is connected to your vault. Atlas will continue learning from this room as you add more Pops.';
  }
}

class _RoomPopPreviewCard extends StatelessWidget {
  const _RoomPopPreviewCard({
    required this.roomName,
    required this.roomPops,
    required this.totalRoomPops,
  });

  final String roomName;
  final List<Pop> roomPops;
  final int totalRoomPops;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Room Preview',
            style: AtlasTypography.headingSmall,
          ),
          const SizedBox(height: AtlasSpacing.sm),
          Text(
            _previewSubtitle,
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
          const SizedBox(height: AtlasSpacing.md),
          if (roomPops.isEmpty)
            AtlasGlassPanel(
              child: Text(
                'No Pops found in this room yet.',
                style: AtlasTypography.bodyMedium.copyWith(
                  color: AtlasColors.textSecondary,
                ),
              ),
            )
          else
            ...roomPops.map(
                  (pop) => Padding(
                padding: const EdgeInsets.only(bottom: AtlasSpacing.sm),
                child: _RoomPopPreviewTile(pop: pop),
              ),
            ),
        ],
      ),
    );
  }

  String get _previewSubtitle {
    if (totalRoomPops == 0) {
      return '$roomName is ready when your matching Pops are added.';
    }

    if (totalRoomPops <= roomPops.length) {
      return 'Showing all $totalRoomPops matching Pop${totalRoomPops == 1 ? '' : 's'}.';
    }

    return 'Showing ${roomPops.length} of $totalRoomPops matching Pops.';
  }
}

class _RoomPopPreviewTile extends StatelessWidget {
  const _RoomPopPreviewTile({
    required this.pop,
  });

  final Pop pop;

  @override
  Widget build(BuildContext context) {
    final numberLabel = pop.number.trim().isEmpty ? 'No #' : '#${pop.number}';
    final valueLabel =
    pop.value <= 0 ? 'Value needed' : '\$${pop.value.toStringAsFixed(0)}';

    return AtlasGlassPanel(
      child: Row(
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            color: AtlasColors.vaultGold,
          ),
          const SizedBox(width: AtlasSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pop.name,
                  style: AtlasTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AtlasSpacing.xs),
                Text(
                  '$numberLabel • ${pop.category}',
                  style: AtlasTypography.bodySmall.copyWith(
                    color: AtlasColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AtlasSpacing.md),
          Text(
            valueLabel,
            style: AtlasTypography.bodySmall.copyWith(
              color: pop.value <= 0
                  ? AtlasColors.textSecondary
                  : AtlasColors.vaultGold,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}