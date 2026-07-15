import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import 'atlas_glass_panel.dart';

enum AtlasStatTileLayout {
  centered,
  leading,
}

class AtlasStatTile extends StatelessWidget {
  const AtlasStatTile({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.accentColor = AtlasColors.vaultGold,
    this.layout = AtlasStatTileLayout.centered,
    this.showPanel = false,
    this.onTap,
    this.valueColor,
    this.valueStyle,
    this.maxValueLines = 1,
    this.maxLabelLines = 1,
  });

  final String value;
  final String label;
  final IconData? icon;
  final Color accentColor;
  final AtlasStatTileLayout layout;
  final bool showPanel;
  final VoidCallback? onTap;
  final Color? valueColor;
  final TextStyle? valueStyle;
  final int maxValueLines;
  final int maxLabelLines;

  bool get _isTappable => onTap != null;

  @override
  Widget build(BuildContext context) {
    final content = switch (layout) {
      AtlasStatTileLayout.centered => _buildCentered(),
      AtlasStatTileLayout.leading => _buildLeading(),
    };

    final interactiveContent = _isTappable
        ? InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: content,
    )
        : content;

    if (!showPanel) {
      return interactiveContent;
    }

    return AtlasGlassPanel(
      child: interactiveContent,
    );
  }

  Widget _buildCentered() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 24,
            color: accentColor,
          ),
          const SizedBox(height: AtlasSpacing.sm),
        ],
        Text(
          value,
          maxLines: maxValueLines,
          overflow: TextOverflow.ellipsis,
          style: valueStyle ??
              AtlasTypography.headingSmall.copyWith(
                color: valueColor ?? accentColor,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AtlasSpacing.xs),
        Text(
          label,
          maxLines: maxLabelLines,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AtlasTypography.bodySmall.copyWith(
            color: AtlasColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLeading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null)
              Icon(
                icon,
                size: 20,
                color: accentColor,
              ),
            if (_isTappable) ...[
              const Spacer(),
              Icon(
                Icons.chevron_right_rounded,
                color: accentColor,
                size: 20,
              ),
            ],
          ],
        ),
        const SizedBox(height: AtlasSpacing.sm),
        Text(
          value,
          maxLines: maxValueLines,
          overflow: TextOverflow.ellipsis,
          style: valueStyle ??
              AtlasTypography.headingSmall.copyWith(
                color: valueColor ?? AtlasColors.textPrimary,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: maxLabelLines,
          overflow: TextOverflow.ellipsis,
          style: AtlasTypography.bodySmall.copyWith(
            color: AtlasColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}