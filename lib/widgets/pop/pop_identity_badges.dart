import 'package:flutter/material.dart';

import '../../../atlas/identity/pop/pop_identity_engine.dart';
import '../../../models/pop.dart';
import '../../../theme/atlas_spacing.dart';
import '../atlas/components/atlas_chip.dart';

class PopIdentityBadges extends StatelessWidget {
  const PopIdentityBadges({
    super.key,
    required this.pop,
    this.showStandardBadge = true,
  });

  final Pop pop;
  final bool showStandardBadge;

  @override
  Widget build(BuildContext context) {
    const identityEngine = PopIdentityEngine();

    final badges = identityEngine.buildBadges(pop);

    if (badges.isEmpty && showStandardBadge) {
      return const AtlasChip(label: '📦 Common / Standard');
    }

    if (badges.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: AtlasSpacing.sm,
      runSpacing: AtlasSpacing.sm,
      children: badges
          .map((badge) => AtlasChip(label: badge.displayLabel))
          .toList(growable: false),
    );
  }
}
