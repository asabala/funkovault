import 'package:flutter/material.dart';

import '../theme/atlas_animation.dart';
import '../theme/atlas_colors.dart';
import '../theme/atlas_radius.dart';
import '../theme/atlas_spacing.dart';
import '../theme/atlas_typography.dart';

class AtlasStatTile extends StatelessWidget {
  const AtlasStatTile({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(
            AtlasRadius.lg,
          ),
          onTap: onTap,
          child: AnimatedContainer(
            duration: AtlasAnimation.fast,
            curve: AtlasAnimation.standardCurve,
            padding: const EdgeInsets.all(
              AtlasSpacing.lg,
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 28,
                  color: AtlasColors.vaultGold,
                ),
                const SizedBox(height: AtlasSpacing.md),
                Text(
                  value,
                  style: AtlasTypography.metricMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AtlasSpacing.sm),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AtlasTypography.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}