import 'package:flutter/material.dart';

import '../../../theme/atlas_spacing.dart';
import '../stats/profile_stat_tile.dart';
import '../stats/profile_stats_row.dart';

class ProfileStatsCard extends StatelessWidget {
  const ProfileStatsCard({
    required this.totalPops,
    required this.totalValue,
    required this.grailCount,
    required this.wishlistCount,
    super.key,
  });

  final int totalPops;
  final double totalValue;
  final int grailCount;
  final int wishlistCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileStatsRow(
          children: [
            ProfileStatTile(
              icon: Icons.inventory_2_outlined,
              value: '$totalPops',
              label: 'Pops',
            ),
            ProfileStatTile(
              icon: Icons.attach_money,
              value: '\$${totalValue.toStringAsFixed(0)}',
              label: 'Value',
            ),
          ],
        ),
        const SizedBox(height: AtlasSpacing.sm),
        ProfileStatsRow(
          children: [
            ProfileStatTile(
              icon: Icons.diamond_outlined,
              value: '$grailCount',
              label: 'Grails',
            ),
            ProfileStatTile(
              icon: Icons.favorite_outline,
              value: '$wishlistCount',
              label: 'Wishlist',
            ),
          ],
        ),
      ],
    );
  }
}