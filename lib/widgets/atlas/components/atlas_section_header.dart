import 'package:flutter/material.dart';

import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';
import '../../../theme/atlas_typography.dart';

class AtlasSectionHeader extends StatelessWidget {
  const AtlasSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.titleStyle,
    this.iconColor = AtlasColors.vaultGold,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final TextStyle? titleStyle;
  final Color iconColor;

  bool get _hasSubtitle {
    return subtitle != null && subtitle!.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            color: iconColor,
          ),
          const SizedBox(width: AtlasSpacing.sm),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: titleStyle ?? AtlasTypography.headingSmall,
              ),
              if (_hasSubtitle) ...[
                const SizedBox(height: AtlasSpacing.xs),
                Text(
                  subtitle!,
                  style: AtlasTypography.bodyMedium.copyWith(
                    color: AtlasColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AtlasSpacing.sm),
          trailing!,
        ],
      ],
    );
  }
}