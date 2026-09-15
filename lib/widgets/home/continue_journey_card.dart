import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';
import '../../theme/atlas_icons.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../atlas/atlas_glass_card.dart';
import '../atlas/atlas_glass_panel.dart';

class ContinueJourneyCard extends StatelessWidget {
  const ContinueJourneyCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = AtlasIcons.vault,
    this.buttonLabel = 'Continue',
    this.onContinue,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String buttonLabel;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Continue Your Journey', style: AtlasTypography.headingSmall),
          const SizedBox(height: AtlasSpacing.md),
          AtlasGlassPanel(
            child: Row(
              children: [
                Icon(icon, color: AtlasColors.vaultGold, size: 30),
                const SizedBox(width: AtlasSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AtlasTypography.headingSmall,
                      ),
                      const SizedBox(height: AtlasSpacing.xs),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AtlasTypography.bodySmall.copyWith(
                          color: AtlasColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AtlasSpacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: onContinue,
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }
}
