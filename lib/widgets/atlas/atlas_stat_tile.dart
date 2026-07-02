import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';

class AtlasStatTile extends StatelessWidget {
  const AtlasStatTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.accentColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final effectiveAccent = accentColor ?? AtlasColors.vaultGold;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 24,
          color: effectiveAccent,
        ),

        const SizedBox(height: AtlasSpacing.sm),

        Text(
          value,
          style: AtlasTypography.headingMedium,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AtlasSpacing.xs),

        Text(
          label,
          textAlign: TextAlign.center,
          style: AtlasTypography.bodySmall.copyWith(
            color: AtlasColors.textSecondary,
          ),
        ),
      ],
    );
  }
}