import 'package:flutter/material.dart';

import 'package:funkovault2/atlas/intelligence/models/atlas_collector_summary.dart';
import 'package:funkovault2/theme/atlas_colors.dart';
import 'package:funkovault2/theme/atlas_spacing.dart';
import 'package:funkovault2/widgets/atlas/atlas_glass_card.dart';
import 'package:funkovault2/widgets/atlas/atlas_intelligence_feed.dart';
import 'package:funkovault2/widgets/atlas/components/atlas_insight_panel.dart';
import 'package:funkovault2/widgets/atlas/components/atlas_section_header.dart';
import 'package:funkovault2/widgets/atlas/components/atlas_status_chip.dart';

class AtlasCollectorSummaryCard extends StatelessWidget {
  const AtlasCollectorSummaryCard({
    required this.summary,
    super.key,
  });

  final AtlasCollectorSummary summary;

  @override
  Widget build(BuildContext context) {
    final Color ownershipAccent = summary.isOwned
        ? AtlasColors.success
        : AtlasColors.intelligenceBlue;

    return AtlasGlassCard(
      accentColor: ownershipAccent,
      padding: const EdgeInsets.all(AtlasSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AtlasSectionHeader(
            title: 'Collector Summary',
            subtitle: 'How this scan relates to your collection.',
            icon: Icons.collections_bookmark_rounded,
            accentColor: ownershipAccent,
            badge: AtlasStatusChip(
              label: summary.formattedOwnership,
              icon: summary.isOwned
                  ? Icons.verified_rounded
                  : Icons.add_box_outlined,
              accentColor: ownershipAccent,
              size: AtlasStatusChipSize.compact,
            ),
          ),
          const SizedBox(height: AtlasSpacing.lg),
          Wrap(
            spacing: AtlasSpacing.sm,
            runSpacing: AtlasSpacing.sm,
            children: [
              AtlasStatusChip(
                label: summary.isOwned ? 'Owned' : 'Not owned',
                icon: summary.isOwned
                    ? Icons.inventory_2_rounded
                    : Icons.inventory_2_outlined,
                accentColor: ownershipAccent,
              ),
              AtlasStatusChip(
                label: summary.collectionName,
                icon: Icons.folder_copy_outlined,
                accentColor: AtlasColors.intelligenceBlue,
              ),
            ],
          ),
          const SizedBox(height: AtlasSpacing.lg),
          AtlasInsightPanel(
            eyebrow: 'Collection Context',
            title: summary.isOwned
                ? 'Already in your vault'
                : 'Not currently in this collection',
            message: summary.isOwned
                ? 'Atlas found this collectible in ${summary.collectionName}. '
                'Use the actions below to review the existing item or manage its collection state.'
                : 'Atlas did not find this collectible in ${summary.collectionName}. '
                'Use the available actions below if you want to add or track it.',
            icon: summary.isOwned
                ? Icons.verified_user_rounded
                : Icons.travel_explore_rounded,
            tone: summary.isOwned
                ? AtlasInsightPanelTone.success
                : AtlasInsightPanelTone.intelligence,
          ),
          if (summary.recommendations.isNotEmpty) ...[
            const SizedBox(height: AtlasSpacing.lg),
            const AtlasSectionHeader(
              title: 'Collector Guidance',
              subtitle: 'Recommendations based on your current collection.',
              icon: Icons.auto_awesome_rounded,
              accentColor: AtlasColors.vaultGold,
            ),
            const SizedBox(height: AtlasSpacing.md),
            AtlasIntelligenceFeed(
              recommendations: summary.recommendations,
              maxVisibleRecommendations: 3,
            ),
          ],
        ],
      ),
    );
  }
}