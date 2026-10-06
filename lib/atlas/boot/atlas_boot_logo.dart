import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';

class AtlasBootLogo extends StatelessWidget {
  const AtlasBootLogo({super.key, required this.pulse});

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
            border: Border.all(color: AtlasColors.vaultGold, width: 2),
            boxShadow: [
              BoxShadow(
                color: AtlasColors.vaultGold.withValues(
                  alpha: 0.16 + (pulse.value * 0.18),
                ),
                blurRadius: glow,
                spreadRadius: 4 + pulse.value * 4,
              ),
            ],
          ),
          child: const _AtlasMark(),
        );
      },
    );
  }
}

class _AtlasMark extends StatelessWidget {
  const _AtlasMark();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const Icon(
          Icons.shield_outlined,
          size: 68,
          color: AtlasColors.vaultGold,
        ),
        Transform.translate(
          offset: const Offset(0, -1),
          child: const Icon(
            Icons.inventory_2_outlined,
            size: 28,
            color: AtlasColors.vaultGold,
          ),
        ),
        Transform.translate(
          offset: const Offset(24, -24),
          child: const Icon(
            Icons.auto_awesome,
            size: 17,
            color: AtlasColors.vaultGold,
          ),
        ),
      ],
    );
  }
}
