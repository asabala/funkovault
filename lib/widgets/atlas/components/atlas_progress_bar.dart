import 'package:flutter/material.dart';

import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_motion.dart';
import '../../../theme/atlas_spacing.dart';
import '../../../theme/atlas_typography.dart';

class AtlasProgressBar extends StatelessWidget {
  const AtlasProgressBar({
    super.key,
    required this.value,
    this.label,
    this.trailingLabel,
    this.accentColor = AtlasColors.vaultGold,
    this.backgroundColor = AtlasColors.surface,
    this.height = 10,
    this.showPercentage = false,
    this.animationDuration = AtlasMotion.progressDuration,
  }) : assert(
  value >= 0 && value <= 1,
  'AtlasProgressBar value must be between 0 and 1.',
  );

  /// Normalized progress between 0 and 1.
  final double value;

  /// Optional label displayed above the progress bar.
  final String? label;

  /// Optional right-aligned label displayed above the progress bar.
  final String? trailingLabel;

  final Color accentColor;
  final Color backgroundColor;
  final double height;
  final bool showPercentage;
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    final double safeValue = value.clamp(
      0,
      1,
    );

    final String resolvedTrailingLabel =
    trailingLabel?.trim().isNotEmpty == true
        ? trailingLabel!.trim()
        : showPercentage
        ? '${(safeValue * 100).round()}%'
        : '';

    final bool showHeader =
        label?.trim().isNotEmpty == true ||
            resolvedTrailingLabel.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          Row(
            children: [
              if (label?.trim().isNotEmpty == true)
                Expanded(
                  child: Text(
                    label!.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AtlasTypography.bodySmall.copyWith(
                      color: AtlasColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                const Spacer(),
              if (resolvedTrailingLabel.isNotEmpty)
                Text(
                  resolvedTrailingLabel,
                  style: AtlasTypography.bodySmall.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(
            height: AtlasSpacing.sm,
          ),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(
            999,
          ),
          child: Container(
            height: height,
            color: backgroundColor,
            alignment: Alignment.centerLeft,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 0,
                end: safeValue,
              ),
              duration: animationDuration,
              curve: AtlasMotion.progressCurve,
              builder: (
                  BuildContext context,
                  double animatedValue,
                  Widget? child,
                  ) {
                return FractionallySizedBox(
                  widthFactor: animatedValue,
                  alignment: Alignment.centerLeft,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(
                        999,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(
                            alpha: 0.24,
                          ),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const SizedBox.expand(),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}