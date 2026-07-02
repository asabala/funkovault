import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';
import '../../theme/atlas_icons.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../atlas/atlas_glass_card.dart';
import '../atlas/atlas_glass_panel.dart';

class AtlasMissionCard extends StatelessWidget {
  const AtlasMissionCard({
    super.key,
    required this.mission,
    required this.collectorType,
    required this.confidence,
    this.onContinue,
  });

  final String mission;
  final String collectorType;
  final int confidence;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                AtlasIcons.intelligence,
                color: AtlasColors.vaultGold,
              ),
              const SizedBox(width: AtlasSpacing.sm),
              Expanded(
                child: Text(
                  "Today's Atlas Mission",
                  style: AtlasTypography.headingSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: AtlasSpacing.md),
          AtlasGlassPanel(
            child: Text(
              mission,
              style: AtlasTypography.bodyMedium,
            ),
          ),
          const SizedBox(height: AtlasSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Type: $collectorType',
                  style: AtlasTypography.bodySmall.copyWith(
                    color: AtlasColors.textSecondary,
                  ),
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
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: onContinue,
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}