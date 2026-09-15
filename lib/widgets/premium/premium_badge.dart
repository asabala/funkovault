import 'package:flutter/material.dart';

import '../atlas/components/atlas_chip.dart';

class PremiumBadge extends StatelessWidget {
  const PremiumBadge({
    super.key,
    this.label = 'Premium',
    this.icon = Icons.workspace_premium_rounded,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AtlasChip(label: label, icon: icon, size: AtlasChipSize.compact);
  }
}
