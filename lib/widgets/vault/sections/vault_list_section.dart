import 'package:flutter/material.dart';

import '../../../models/pop.dart';
import '../../../theme/atlas_spacing.dart';
import '../../atlas/atlas_glass_card.dart';
import '../../atlas/components/atlas_section_header.dart';
import '../components/vault_pop_tile.dart';

class VaultListSection extends StatelessWidget {
  const VaultListSection({
    super.key,
    required this.pops,
    required this.totalResultCount,
    required this.hasMoreResults,
    required this.filterLabel,
    required this.sortLabel,
    required this.showImages,
    required this.onLoadMore,
    this.onAddValue,
  });

  final List<Pop> pops;
  final int totalResultCount;
  final bool hasMoreResults;
  final String filterLabel;
  final String sortLabel;
  final bool showImages;
  final VoidCallback onLoadMore;
  final ValueChanged<Pop>? onAddValue;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AtlasSectionHeader(
            title: 'Vault List',
            subtitle:
            'Showing ${pops.length} of $totalResultCount '
                'result${totalResultCount == 1 ? '' : 's'} • '
                'Filtered by $filterLabel • '
                'Sorted by $sortLabel. '
                'Tap any Pop to open details.',
            icon: Icons.view_list_rounded,
          ),
          const SizedBox(height: AtlasSpacing.md),
          ...pops.map(
                (pop) => Padding(
              padding: const EdgeInsets.only(
                bottom: AtlasSpacing.sm,
              ),
              child: VaultPopTile(
                pop: pop,
                showImage: showImages,
                onAddValue: onAddValue == null
                    ? null
                    : () {
                  onAddValue!(pop);
                },
              ),
            ),
          ),
          if (hasMoreResults) ...[
            const SizedBox(height: AtlasSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onLoadMore,
                icon: const Icon(
                  Icons.expand_more_rounded,
                ),
                label: const Text(
                  'Load More Pops',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}