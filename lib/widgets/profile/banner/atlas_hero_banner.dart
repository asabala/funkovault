import 'package:flutter/material.dart';

import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_icons.dart';

class AtlasHeroBanner extends StatelessWidget {
  const AtlasHeroBanner({
    this.bannerUrl = '',
    super.key,
  });

  final String bannerUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black.withValues(alpha: 0.85),
            AtlasColors.vaultGold.withValues(alpha: 0.18),
            Colors.black.withValues(alpha: 0.75),
          ],
        ),
        border: Border.all(
          color: AtlasColors.vaultGold.withValues(alpha: 0.28),
        ),
      ),
      child: const Center(
        child: Icon(
          AtlasIcons.atlas,
          color: AtlasColors.vaultGold,
          size: 52,
        ),
      ),
    );
  }
}