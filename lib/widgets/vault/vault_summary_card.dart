import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';
import '../../theme/atlas_icons.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../atlas_section_card.dart';

class VaultSummaryCard extends StatelessWidget {
  const VaultSummaryCard({
    super.key,
    required this.totalPops,
    required this.totalValue,
    required this.health,
  });

  final int totalPops;
  final double totalValue;
  final double health;

  @override
  Widget build(BuildContext context) {
    return AtlasSectionCard(
      title: 'Vault Summary',
      icon: AtlasIcons.collection,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _Stat(
            label: 'Collectibles',
            value: '$totalPops',
          ),
          _Stat(
            label: 'Value',
            value: '\$${totalValue.toStringAsFixed(0)}',
          ),
          _Stat(
            label: 'Health',
            value: '${health.toStringAsFixed(0)}%',
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AtlasTypography.headingMedium,
        ),
        const SizedBox(height: AtlasSpacing.xs),
        Text(
          label,
          style: AtlasTypography.bodySmall.copyWith(
            color: AtlasColors.textMuted,
          ),
        ),
      ],
    );
  }
}