import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';
import '../../theme/atlas_icons.dart';
import '../../theme/atlas_spacing.dart';
import '../atlas/atlas_action_tile.dart';
import '../atlas/components/atlas_section_header.dart';

class CollectorToolsCard extends StatelessWidget {
  const CollectorToolsCard({
    super.key,
    this.onAddPop,
    this.onScan,
    this.onWishlist,
    this.onSearch,
    this.onValueLookup,
    this.onAtlasAi,
  });

  final VoidCallback? onAddPop;
  final VoidCallback? onScan;
  final VoidCallback? onWishlist;
  final VoidCallback? onSearch;
  final VoidCallback? onValueLookup;
  final VoidCallback? onAtlasAi;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AtlasSectionHeader(
          title: 'Collector Tools',
          subtitle:
              'Quick access to collection management and Atlas intelligence.',
          icon: Icons.dashboard_customize_outlined,
          accentColor: AtlasColors.vaultGold,
        ),
        const SizedBox(height: AtlasSpacing.md),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AtlasSpacing.sm,
          mainAxisSpacing: AtlasSpacing.sm,
          childAspectRatio: 0.98,
          children: [
            AtlasActionTile(icon: Icons.add, label: 'Add Pop', onTap: onAddPop),
            AtlasActionTile(
              icon: Icons.qr_code_scanner,
              label: 'Scan',
              onTap: onScan,
            ),
            AtlasActionTile(
              icon: AtlasIcons.wishlist,
              label: 'Wishlist',
              onTap: onWishlist,
            ),
            AtlasActionTile(
              icon: Icons.search,
              label: 'Search',
              onTap: onSearch,
            ),
            AtlasActionTile(
              icon: Icons.sell_outlined,
              label: 'Values',
              onTap: onValueLookup,
            ),
            AtlasActionTile(
              icon: AtlasIcons.intelligence,
              label: 'Atlas AI',
              onTap: onAtlasAi,
            ),
          ],
        ),
      ],
    );
  }
}
