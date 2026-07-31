import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import 'atlas_glass_card.dart';

/// Reusable Atlas accordion section.
///
/// This widget only manages presentation and expanded state.
/// It does not calculate or alter the supplied content.
class AtlasExpandableSection extends StatefulWidget {
  const AtlasExpandableSection({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.icon,
    this.badge,
    this.initiallyExpanded = false,
    this.onExpandedChanged,
    this.accentColor = AtlasColors.vaultGold,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;

  /// Compact summary shown in the collapsed header.
  ///
  /// Examples:
  /// - 53 / 100
  /// - High Confidence
  /// - 4 Signals
  /// - 2 Actions
  final Widget? badge;

  final Widget child;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onExpandedChanged;
  final Color accentColor;

  @override
  State<AtlasExpandableSection> createState() =>
      _AtlasExpandableSectionState();
}

class _AtlasExpandableSectionState
    extends State<AtlasExpandableSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  void didUpdateWidget(covariant AtlasExpandableSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initiallyExpanded != widget.initiallyExpanded) {
      _isExpanded = widget.initiallyExpanded;
    }
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    widget.onExpandedChanged?.call(_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      accentColor: widget.accentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            button: true,
            expanded: _isExpanded,
            label:
            '${widget.title}, ${_isExpanded ? 'expanded' : 'collapsed'}',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _toggleExpanded,
                borderRadius: BorderRadius.circular(AtlasSpacing.lg),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AtlasSpacing.xs,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Container(
                          width: 42,
                          height: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: widget.accentColor.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: widget.accentColor.withValues(
                                alpha: 0.22,
                              ),
                            ),
                          ),
                          child: Icon(
                            widget.icon,
                            color: widget.accentColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: AtlasSpacing.md),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: AtlasTypography.headingSmall.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (widget.subtitle != null &&
                                widget.subtitle!.trim().isNotEmpty) ...[
                              const SizedBox(height: AtlasSpacing.xs),
                              Text(
                                widget.subtitle!,
                                maxLines: _isExpanded ? null : 2,
                                overflow: _isExpanded
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                                style: AtlasTypography.bodySmall.copyWith(
                                  color: AtlasColors.textSecondary,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (widget.badge != null) ...[
                        const SizedBox(width: AtlasSpacing.sm),
                        widget.badge!,
                      ],
                      const SizedBox(width: AtlasSpacing.sm),
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: _isExpanded
                              ? widget.accentColor
                              : AtlasColors.textSecondary,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: _isExpanded
                  ? Padding(
                padding: const EdgeInsets.only(
                  top: AtlasSpacing.lg,
                ),
                child: widget.child,
              )
                  : const SizedBox(
                width: double.infinity,
                height: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact pill used in expandable-section headers.
class AtlasExpandableBadge extends StatelessWidget {
  const AtlasExpandableBadge({
    super.key,
    required this.label,
    this.icon,
    this.color = AtlasColors.vaultGold,
  });

  final String label;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AtlasSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 15,
              color: color,
            ),
            const SizedBox(width: AtlasSpacing.xs),
          ],
          Text(
            label,
            style: AtlasTypography.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}