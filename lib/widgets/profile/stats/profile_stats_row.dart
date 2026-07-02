import 'package:flutter/material.dart';

import '../../../theme/atlas_spacing.dart';
import 'profile_stat_tile.dart';

class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({
    required this.children,
    super.key,
  });

  final List<ProfileStatTile> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < children.length; i++) ...[
          Expanded(child: children[i]),
          if (i != children.length - 1)
            const SizedBox(width: AtlasSpacing.sm),
        ],
      ],
    );
  }
}