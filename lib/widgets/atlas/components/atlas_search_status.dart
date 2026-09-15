import 'package:flutter/material.dart';

import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';
import '../../../theme/atlas_typography.dart';

class AtlasSearchStatus extends StatelessWidget {
  const AtlasSearchStatus({
    super.key,
    required this.statusText,
    this.contextLabel = 'Atlas Intelligence',
    this.icon = Icons.hub_outlined,
    this.accentColor = AtlasColors.intelligenceBlue,
  });

  final String statusText;
  final String contextLabel;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            statusText,
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
        ),
        Icon(icon, size: 16, color: accentColor),
        const SizedBox(width: AtlasSpacing.xs),
        Flexible(
          child: Text(
            contextLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AtlasTypography.bodySmall.copyWith(
              color: accentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
