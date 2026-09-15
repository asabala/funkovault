import 'package:flutter/material.dart';

import '../../../../theme/atlas_colors.dart';
import '../../../../theme/atlas_spacing.dart';
import '../../../../theme/atlas_typography.dart';
import '../atlas_glass_panel.dart';

class AtlasMetricPanel extends StatelessWidget {
  const AtlasMetricPanel({
    super.key,
    required this.label,
    required this.value,
    this.supportingText,
    this.icon,
    this.accentColor = AtlasColors.vaultGold,
    this.alignment = CrossAxisAlignment.start,
    this.minHeight = 118,
  });

  final String label;
  final String value;
  final String? supportingText;
  final IconData? icon;
  final Color accentColor;
  final CrossAxisAlignment alignment;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final String cleanedSupportingText = supportingText?.trim() ?? '';

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: AtlasGlassPanel(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: alignment,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: accentColor),
                  const SizedBox(width: AtlasSpacing.xs),
                ],
                Flexible(
                  child: Text(
                    label.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AtlasTypography.bodySmall.copyWith(
                      color: AtlasColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AtlasSpacing.sm),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: _textAlign,
              style: AtlasTypography.headingSmall.copyWith(
                color: accentColor,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (cleanedSupportingText.isNotEmpty) ...[
              const SizedBox(height: AtlasSpacing.xs),
              Text(
                cleanedSupportingText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: _textAlign,
                style: AtlasTypography.bodySmall.copyWith(
                  color: AtlasColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  TextAlign get _textAlign {
    return switch (alignment) {
      CrossAxisAlignment.center => TextAlign.center,
      CrossAxisAlignment.end => TextAlign.end,
      _ => TextAlign.start,
    };
  }
}
