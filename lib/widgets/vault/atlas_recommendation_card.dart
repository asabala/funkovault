import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';
import '../../theme/atlas_icons.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../atlas/atlas_glass_card.dart';
import '../atlas/atlas_glass_panel.dart';

class AtlasRecommendationCard extends StatelessWidget {
  const AtlasRecommendationCard({
    super.key,
    required this.message,
    this.confidence = 98,
    this.estimatedCost,
    this.difficulty,
    this.onViewDetails,
  });

  final String message;
  final int confidence;
  final String? estimatedCost;
  final String? difficulty;
  final VoidCallback? onViewDetails;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      accentColor: AtlasColors.vaultGold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                AtlasIcons.intelligence,
                color: AtlasColors.vaultGold,
                size: 22,
              ),
              const SizedBox(width: AtlasSpacing.sm),
              Expanded(
                child: Text(
                  'Atlas Recommendation',
                  style: AtlasTypography.headingSmall,
                ),
              ),
              Text(
                '$confidence%',
                style: AtlasTypography.headingSmall.copyWith(
                  color: AtlasColors.vaultGold,
                ),
              ),
            ],
          ),

          const SizedBox(height: AtlasSpacing.md),

          AtlasGlassPanel(
            child: Text(
              message,
              style: AtlasTypography.bodyMedium.copyWith(
                color: AtlasColors.textPrimary,
              ),
            ),
          ),

          const SizedBox(height: AtlasSpacing.md),

          Row(
            children: [
              Expanded(
                child: _RecommendationMeta(
                  label: 'Estimated Cost',
                  value: estimatedCost ?? 'Learning',
                ),
              ),
              const SizedBox(width: AtlasSpacing.sm),
              Expanded(
                child: _RecommendationMeta(
                  label: 'Difficulty',
                  value: difficulty ?? 'Analyzing',
                ),
              ),
            ],
          ),

          const SizedBox(height: AtlasSpacing.md),

          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: onViewDetails,
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('View Details'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationMeta extends StatelessWidget {
  const _RecommendationMeta({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassPanel(
      padding: const EdgeInsets.all(AtlasSpacing.sm),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
          const SizedBox(height: AtlasSpacing.xs),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AtlasTypography.headingSmall.copyWith(
              color: AtlasColors.vaultGold,
            ),
          ),
        ],
      ),
    );
  }
}