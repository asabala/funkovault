import 'package:flutter/material.dart';

import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';
import '../../../theme/atlas_typography.dart';
import '../../../vault/duplicate_review/duplicate_review_engine.dart';
import '../../atlas/atlas_glass_card.dart';
import '../../atlas/atlas_glass_panel.dart';
import '../../atlas/components/atlas_chip.dart';
import '../../atlas/components/atlas_section_header.dart';
import 'vault_pop_tile.dart';

class DuplicateReviewSection extends StatelessWidget {
  const DuplicateReviewSection({
    super.key,
    required this.groups,
    required this.totalGroupCount,
    required this.totalPopCount,
    required this.visiblePopCount,
    required this.hasMoreResults,
    required this.sortLabel,
    required this.showImages,
    required this.onLoadMore,
  });

  final List<DuplicateReviewGroup> groups;
  final int totalGroupCount;
  final int totalPopCount;
  final int visiblePopCount;
  final bool hasMoreResults;
  final String sortLabel;
  final bool showImages;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AtlasSectionHeader(
            title: 'Duplicate Review Groups',
            subtitle:
            'Showing ${groups.length} of $totalGroupCount '
                'group${totalGroupCount == 1 ? '' : 's'} and '
                '$visiblePopCount of $totalPopCount '
                'Pop${totalPopCount == 1 ? '' : 's'} • '
                'Sorted by $sortLabel. '
                'Review every item before making changes.',
            icon: Icons.content_copy_rounded,
          ),
          const SizedBox(height: AtlasSpacing.lg),
          ...groups.map(
                (group) => Padding(
              padding: const EdgeInsets.only(
                bottom: AtlasSpacing.md,
              ),
              child: _DuplicateReviewGroupCard(
                group: group,
                showImages: showImages,
              ),
            ),
          ),
          if (hasMoreResults) ...[
            const SizedBox(height: AtlasSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onLoadMore,
                icon: const Icon(Icons.expand_more_rounded),
                label: const Text('Load More Groups'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DuplicateReviewGroupCard extends StatelessWidget {
  const _DuplicateReviewGroupCard({
    required this.group,
    required this.showImages,
  });

  final DuplicateReviewGroup group;
  final bool showImages;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AtlasColors.vaultGold.withValues(
                    alpha: 0.14,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.content_copy_rounded,
                  color: AtlasColors.vaultGold,
                  size: 20,
                ),
              ),
              const SizedBox(width: AtlasSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${group.name} ${group.number}',
                      style: AtlasTypography.bodyMedium.copyWith(
                        color: AtlasColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AtlasSpacing.xs),
                    Text(
                      'Possible duplicate or variant review group • '
                          '${group.itemCount} '
                          'item${group.itemCount == 1 ? '' : 's'}',
                      style: AtlasTypography.bodySmall.copyWith(
                        color: AtlasColors.textSecondary,
                      ),
                    ),
                    if (group.differenceLabels.isNotEmpty) ...[
                      const SizedBox(height: AtlasSpacing.sm),
                      Wrap(
                        spacing: AtlasSpacing.xs,
                        runSpacing: AtlasSpacing.xs,
                        children: group.differenceLabels
                            .map(
                              (label) => AtlasChip(
                            label: label,
                            icon: Icons.compare_arrows_rounded,
                            size: AtlasChipSize.compact,
                          ),
                        )
                            .toList(),
                      ),
                    ] else ...[
                      const SizedBox(height: AtlasSpacing.sm),
                      Text(
                        'No saved metadata differences detected. '
                            'Compare images and item details manually.',
                        style: AtlasTypography.bodySmall.copyWith(
                          color: AtlasColors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AtlasSpacing.md),
          Divider(
            color: AtlasColors.textSecondary.withValues(
              alpha: 0.18,
            ),
          ),
          const SizedBox(height: AtlasSpacing.md),
          ...group.pops.map(
                (pop) => Padding(
              padding: const EdgeInsets.only(
                bottom: AtlasSpacing.sm,
              ),
              child: VaultPopTile(
                pop: pop,
                showImage: showImages,
              ),
            ),
          ),
        ],
      ),
    );
  }
}