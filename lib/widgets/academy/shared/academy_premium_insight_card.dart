import 'package:flutter/material.dart';

import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';
import '../../../theme/atlas_typography.dart';
import '../../atlas/atlas_glass_card.dart';
import '../../atlas/atlas_glass_panel.dart';

class AcademyPremiumInsightCard extends StatelessWidget {
  const AcademyPremiumInsightCard({
    super.key,
    this.title = 'Premium Insight',
    this.message =
    'Atlas Premium will connect this topic to your Vault, value trends, condition risks, and smarter collecting decisions.',
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: AtlasGlassPanel(
        child: Padding(
          padding: const EdgeInsets.all(AtlasSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AtlasColors.vaultGold.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: AtlasColors.vaultGold,
                ),
              ),
              const SizedBox(width: AtlasSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AtlasTypography.headingSmall.copyWith(
                        color: AtlasColors.vaultGold,
                      ),
                    ),
                    const SizedBox(height: AtlasSpacing.xs),
                    Text(
                      message,
                      style: AtlasTypography.bodySmall.copyWith(
                        color: AtlasColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}