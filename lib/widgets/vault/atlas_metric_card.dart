import 'package:flutter/material.dart';

import '../../theme/atlas_animation.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_radius.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';

class AtlasMetricCard extends StatelessWidget {
  const AtlasMetricCard({
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
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AtlasRadius.lg),
        onTap: onTap,
        child: AnimatedContainer(
          duration: AtlasAnimation.fast,
          curve: AtlasAnimation.standardCurve,
          padding: const EdgeInsets.symmetric(
            horizontal: AtlasSpacing.lg,
            vertical: AtlasSpacing.md,
          ),
          child: Row(
            children: [
              Icon(icon, color: AtlasColors.vaultGold),

              const SizedBox(width: AtlasSpacing.md),

              Expanded(child: Text(title, style: AtlasTypography.bodyLarge)),

              Text(value, style: AtlasTypography.metricSmall),
            ],
          ),
        ),
      ),
    );
  }
}
