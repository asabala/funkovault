import 'package:flutter/material.dart';

import '../theme/atlas_animation.dart';
import '../theme/atlas_colors.dart';
import '../theme/atlas_icons.dart';
import '../theme/atlas_radius.dart';
import '../theme/atlas_spacing.dart';
import '../theme/atlas_typography.dart';

class AtlasGreetingCard extends StatelessWidget {
  const AtlasGreetingCard({
    super.key,
    required this.title,
    required this.message,
    this.icon = AtlasIcons.atlas,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AtlasAnimation.standard,
      curve: AtlasAnimation.standardCurve,
      decoration: BoxDecoration(
        color: AtlasColors.surface,
        borderRadius: BorderRadius.circular(
          AtlasRadius.lg,
        ),
        border: Border.all(
          color: AtlasColors.border,
        ),
      ),
      padding: const EdgeInsets.all(
        AtlasSpacing.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(
              AtlasSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AtlasColors.intelligenceBlue.withValues(
                alpha: 0.15,
              ),
              borderRadius: BorderRadius.circular(
                AtlasRadius.md,
              ),
            ),
            child: Icon(
              icon,
              color: AtlasColors.vaultGold,
              size: 28,
            ),
          ),

          const SizedBox(
            width: AtlasSpacing.lg,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AtlasTypography.headingMedium,
                ),

                const SizedBox(
                  height: AtlasSpacing.sm,
                ),

                Text(
                  message,
                  style: AtlasTypography.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}