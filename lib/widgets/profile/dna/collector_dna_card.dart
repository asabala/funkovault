import 'package:flutter/material.dart';

import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';
import '../../../theme/atlas_typography.dart';
import '../../atlas/atlas_glass_card.dart';

class CollectorDnaCard extends StatelessWidget {
  const CollectorDnaCard({
    required this.primaryTrait,
    required this.secondaryTrait,
    required this.confidence,
    required this.summary,
    super.key,
  });

  final String primaryTrait;
  final String secondaryTrait;
  final double confidence;
  final String summary;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Collector DNA', style: AtlasTypography.headingSmall),
          const SizedBox(height: AtlasSpacing.md),
          Row(
            children: [
              Expanded(
                child: _DnaTraitTile(label: 'Primary', value: primaryTrait),
              ),
              const SizedBox(width: AtlasSpacing.sm),
              Expanded(
                child: _DnaTraitTile(label: 'Secondary', value: secondaryTrait),
              ),
            ],
          ),
          const SizedBox(height: AtlasSpacing.md),
          Text(
            'Atlas Confidence ${confidence.toStringAsFixed(0)}%',
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.vaultGold,
            ),
          ),
          const SizedBox(height: AtlasSpacing.sm),
          LinearProgressIndicator(value: (confidence / 100).clamp(0.0, 1.0)),
          const SizedBox(height: AtlasSpacing.md),
          Text(
            summary,
            style: AtlasTypography.bodyMedium.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DnaTraitTile extends StatelessWidget {
  const _DnaTraitTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AtlasSpacing.md),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AtlasColors.vaultGold.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AtlasTypography.headingSmall.copyWith(
              color: AtlasColors.vaultGold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
