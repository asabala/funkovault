import 'package:flutter/material.dart';

import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';
import '../../../theme/atlas_typography.dart';
import '../../atlas/atlas_glass_card.dart';

class MemoryPreviewCard extends StatelessWidget {
  const MemoryPreviewCard({
    required this.title,
    required this.message,
    required this.footer,
    super.key,
  });

  final String title;
  final String message;
  final String footer;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Atlas Memory', style: AtlasTypography.headingSmall),

          const SizedBox(height: AtlasSpacing.md),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AtlasColors.vaultGold.withValues(alpha: 0.14),
                ),
                child: const Icon(Icons.history, color: AtlasColors.vaultGold),
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
                      style: AtlasTypography.bodyMedium.copyWith(
                        color: AtlasColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AtlasSpacing.md),

          Text(
            footer,
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.vaultGold,
            ),
          ),
        ],
      ),
    );
  }
}
