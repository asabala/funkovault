import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';
import '../../theme/atlas_icons.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../atlas/atlas_section_card.dart';

class CollectorDNACard extends StatelessWidget {
  const CollectorDNACard({
    super.key,
    required this.primaryTrait,
    required this.secondaryTrait,
    required this.confidence,
    required this.summary,
  });

  final String primaryTrait;
  final String secondaryTrait;
  final double confidence;
  final String summary;

  @override
  Widget build(BuildContext context) {
    return AtlasSectionCard(
      title: 'Collector DNA',
      icon: AtlasIcons.dna,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DNAStat(
            label: 'Primary Trait',
            value: primaryTrait,
          ),

          const SizedBox(height: AtlasSpacing.md),

          _DNAStat(
            label: 'Secondary Trait',
            value: secondaryTrait,
          ),

          const SizedBox(height: AtlasSpacing.lg),

          Text(
            'Atlas Confidence',
            style: AtlasTypography.label,
          ),

          const SizedBox(height: AtlasSpacing.sm),

          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: confidence / 100,
              minHeight: 10,
              backgroundColor: AtlasColors.surface,
              valueColor: const AlwaysStoppedAnimation(
                AtlasColors.intelligenceBlue,
              ),
            ),
          ),

          const SizedBox(height: AtlasSpacing.sm),

          Text(
            '${confidence.toStringAsFixed(0)}%',
            style: AtlasTypography.headingSmall,
          ),

          const SizedBox(height: AtlasSpacing.lg),

          Text(
            summary,
            style: AtlasTypography.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _DNAStat extends StatelessWidget {
  const _DNAStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AtlasTypography.label.copyWith(
              color: AtlasColors.textMuted,
            ),
          ),
        ),
        Text(
          value,
          style: AtlasTypography.headingSmall,
        ),
      ],
    );
  }
}