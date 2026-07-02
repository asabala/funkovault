import 'package:flutter/material.dart';

import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';
import '../../../theme/atlas_typography.dart';

class AchievementRibbon extends StatelessWidget {
  const AchievementRibbon({
    required this.title,
    super.key,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AtlasSpacing.lg,
        vertical: AtlasSpacing.sm,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [
            AtlasColors.vaultGold.withValues(alpha: 0.90),
            AtlasColors.vaultGold.withValues(alpha: 0.60),
          ],
        ),
      ),
      child: Text(
        title.toUpperCase(),
        style: AtlasTypography.bodySmall.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}