import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';

class AtlasBootLogo extends StatelessWidget {
  const AtlasBootLogo({
    super.key,
    required this.pulse,
  });

  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, child) {
        final glow = 24 + (pulse.value * 18);

        return Container(
          width: 132,
          height: 132,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AtlasColors.surface,
            border: Border.all(
              color: AtlasColors.vaultGold,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AtlasColors.intelligenceBlue.withValues(
                  alpha: 0.25 + (pulse.value * 0.25),
                ),
                blurRadius: glow,
                spreadRadius: 4 + pulse.value * 4,
              ),
            ],
          ),
          child: const Icon(
            Icons.shield,
            size: 64,
            color: AtlasColors.vaultGold,
          ),
        );
      },
    );
  }
}