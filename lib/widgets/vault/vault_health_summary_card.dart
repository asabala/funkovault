import 'package:flutter/material.dart';

import '../atlas/components/atlas_action_card.dart';

class VaultHealthSummaryCard extends StatelessWidget {
  const VaultHealthSummaryCard({
    super.key,
    required this.healthScore,
    required this.priority,
    required this.needsValueCount,
    required this.duplicateGroupCount,
    this.onTap,
  });

  final double healthScore;
  final String priority;
  final int needsValueCount;
  final int duplicateGroupCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final roundedHealth = healthScore.round();

    return AtlasActionCard(
      icon: Icons.health_and_safety_rounded,
      title: 'Vault Health',
      highlight: '$roundedHealth% • $priority Priority',
      message:
          'Needs Value: $needsValueCount • Duplicates: $duplicateGroupCount',
      onTap: onTap,
    );
  }
}
