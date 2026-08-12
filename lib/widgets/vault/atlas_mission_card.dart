import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';
import '../../theme/atlas_icons.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../atlas/atlas_glass_card.dart';
import '../atlas/atlas_glass_panel.dart';
import '../atlas/components/atlas_section_header.dart';
import '../atlas/components/atlas_status_chip.dart';

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
      accentColor: AtlasColors.vaultGold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AtlasSectionHeader(
            title: "Today's Atlas Mission",
            subtitle:
            'A focused next step based on your current collector profile and vault.',
            icon: AtlasIcons.intelligence,
            accentColor: AtlasColors.vaultGold,
          ),
          const SizedBox(
            height: AtlasSpacing.md,
          ),
          AtlasGlassPanel(
            child: Text(
              mission,
              style: AtlasTypography.bodyMedium,
            ),
          ),
          const SizedBox(
            height: AtlasSpacing.md,
          ),
          Wrap(
            spacing: AtlasSpacing.sm,
            runSpacing: AtlasSpacing.sm,
            children: [
              AtlasStatusChip(
                label: collectorType,
                icon: Icons.person_search_rounded,
                accentColor: AtlasColors.vaultGold,
                size: AtlasStatusChipSize.compact,
              ),
              AtlasStatusChip(
                label: '$confidence% Confidence',
                icon: Icons.verified_rounded,
                accentColor: AtlasColors.vaultGold,
                size: AtlasStatusChipSize.compact,
              ),
            ],
          ),
          if (onContinue != null) ...[
            const SizedBox(
              height: AtlasSpacing.md,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: onContinue,
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                ),
                label: const Text(
                  'Continue',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}