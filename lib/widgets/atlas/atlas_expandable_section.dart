import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';
import '../../theme/atlas_motion.dart';
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

  /// Compact summary shown in the section header.
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
  State<AtlasExpandableSection> createState() {
    return _AtlasExpandableSectionState();
  }
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
  void didUpdateWidget(
      covariant AtlasExpandableSection oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initiallyExpanded !=
        widget.initiallyExpanded) {
      _isExpanded = widget.initiallyExpanded;
    }
  }

  void _toggleExpanded() {
    setState(
          () {
        _isExpanded = !_isExpanded;
      },
    );

    widget.onExpandedChanged?.call(
      _isExpanded,
    );
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
            '${widget.title}, '
                '${_isExpanded ? 'expanded' : 'collapsed'}',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _toggleExpanded,
                borderRadius: BorderRadius.circular(
                  AtlasSpacing.lg,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AtlasSpacing.xs,
                  ),
                  child: LayoutBuilder(
                    builder: (
                        BuildContext context,
                        BoxConstraints constraints,
                        ) {
                      final bool useCompactHeader =
                          constraints.maxWidth < 430;

                      return _ExpandableHeader(
                        title: widget.title,
                        subtitle: widget.subtitle,
                        icon: widget.icon,
                        badge: widget.badge,
                        accentColor: widget.accentColor,
                        isExpanded: _isExpanded,
                        useCompactHeader: useCompactHeader,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          ClipRect(
            child: AnimatedSize(
              duration: AtlasMotion.expandDuration,
              curve: AtlasMotion.expandCurve,
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

class _ExpandableHeader extends StatelessWidget {
  const _ExpandableHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.badge,
    required this.accentColor,
    required this.isExpanded,
    required this.useCompactHeader,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? badge;
  final Color accentColor;
  final bool isExpanded;
  final bool useCompactHeader;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          _ExpandableIcon(
            icon: icon!,
            accentColor: accentColor,
          ),
          const SizedBox(
            width: AtlasSpacing.md,
          ),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AtlasTypography.headingSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null &&
                  subtitle!.trim().isNotEmpty) ...[
                const SizedBox(
                  height: AtlasSpacing.xs,
                ),
                Text(
                  subtitle!,
                  maxLines: isExpanded ? null : 2,
                  overflow: isExpanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                  style: AtlasTypography.bodySmall.copyWith(
                    color: AtlasColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
              if (useCompactHeader &&
                  badge != null) ...[
                const SizedBox(
                  height: AtlasSpacing.sm,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: badge!,
                ),
              ],
            ],
          ),
        ),
        if (!useCompactHeader &&
            badge != null) ...[
          const SizedBox(
            width: AtlasSpacing.sm,
          ),
          badge!,
        ],
        const SizedBox(
          width: AtlasSpacing.sm,
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: 7,
          ),
          child: AnimatedRotation(
            turns: isExpanded ? 0.5 : 0,
            duration: AtlasMotion.expandDuration,
            curve: AtlasMotion.expandCurve,
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: isExpanded
                  ? accentColor
                  : AtlasColors.textSecondary,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }
}

class _ExpandableIcon extends StatelessWidget {
  const _ExpandableIcon({
    required this.icon,
    required this.accentColor,
  });

  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: accentColor.withValues(
          alpha: 0.12,
        ),
        borderRadius: BorderRadius.circular(
          14,
        ),
        border: Border.all(
          color: accentColor.withValues(
            alpha: 0.22,
          ),
        ),
      ),
      child: Icon(
        icon,
        color: accentColor,
        size: 22,
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
        color: color.withValues(
          alpha: 0.10,
        ),
        borderRadius: BorderRadius.circular(
          999,
        ),
        border: Border.all(
          color: color.withValues(
            alpha: 0.28,
          ),
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
            const SizedBox(
              width: AtlasSpacing.xs,
            ),
          ],
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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