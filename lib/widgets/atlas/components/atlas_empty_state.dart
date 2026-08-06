import 'package:flutter/material.dart';

import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';
import '../../../theme/atlas_symbols.dart';
import '../../../theme/atlas_typography.dart';
import '../atlas_glass_card.dart';

enum AtlasEmptyStateTone {
  intelligence,
  recommendation,
  neutral,
}

class AtlasEmptyState extends StatelessWidget {
  const AtlasEmptyState({
    super.key,
    this.icon,
    this.symbol,
    required this.title,
    required this.message,
    this.eyebrow,
    this.tone = AtlasEmptyStateTone.neutral,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  }) : assert(
  icon == null || symbol == null,
  'Use either icon or symbol, not both.',
  );

  final IconData? icon;
  final String? symbol;

  final String title;
  final String message;
  final String? eyebrow;

  final AtlasEmptyStateTone tone;

  final String? actionLabel;
  final VoidCallback? onAction;

  final bool compact;

  bool get _hasAction {
    return actionLabel?.trim().isNotEmpty == true &&
        onAction != null;
  }

  Color get _accentColor {
    return switch (tone) {
      AtlasEmptyStateTone.intelligence =>
      AtlasColors.intelligenceBlue,
      AtlasEmptyStateTone.recommendation =>
      AtlasColors.vaultGold,
      AtlasEmptyStateTone.neutral =>
      AtlasColors.textSecondary,
    };
  }

  IconData get _resolvedIcon {
    return icon ??
        switch (tone) {
          AtlasEmptyStateTone.intelligence =>
          Icons.search_rounded,
          AtlasEmptyStateTone.recommendation =>
          Icons.add_circle_outline_rounded,
          AtlasEmptyStateTone.neutral =>
          Icons.inbox_outlined,
        };
  }

  String get _resolvedSymbol {
    return symbol ?? AtlasSymbols.empty;
  }

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      accentColor: _accentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _EmptyStateIdentity(
            icon: icon,
            symbol: symbol,
            resolvedIcon: _resolvedIcon,
            resolvedSymbol: _resolvedSymbol,
            accentColor: _accentColor,
            compact: compact,
          ),
          SizedBox(
            height: compact
                ? AtlasSpacing.sm
                : AtlasSpacing.md,
          ),
          if (eyebrow?.trim().isNotEmpty == true) ...[
            Text(
              eyebrow!.trim().toUpperCase(),
              style: AtlasTypography.bodySmall.copyWith(
                color: _accentColor,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(
              height: AtlasSpacing.xs,
            ),
          ],
          Text(
            title,
            style: AtlasTypography.headingSmall.copyWith(
              color: AtlasColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: AtlasSpacing.xs,
          ),
          Text(
            message,
            maxLines: compact ? 2 : null,
            overflow: compact
                ? TextOverflow.ellipsis
                : TextOverflow.visible,
            style: AtlasTypography.bodyMedium.copyWith(
              color: AtlasColors.textSecondary,
              height: 1.35,
            ),
          ),
          if (_hasAction) ...[
            const SizedBox(
              height: AtlasSpacing.md,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: onAction,
                icon: Icon(
                  _actionIcon,
                  color: _accentColor,
                ),
                label: Text(
                  actionLabel!.trim(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData get _actionIcon {
    return switch (tone) {
      AtlasEmptyStateTone.intelligence =>
      Icons.search_rounded,
      AtlasEmptyStateTone.recommendation =>
      Icons.add_circle_outline_rounded,
      AtlasEmptyStateTone.neutral =>
      Icons.refresh_rounded,
    };
  }
}

class _EmptyStateIdentity extends StatelessWidget {
  const _EmptyStateIdentity({
    required this.icon,
    required this.symbol,
    required this.resolvedIcon,
    required this.resolvedSymbol,
    required this.accentColor,
    required this.compact,
  });

  final IconData? icon;
  final String? symbol;

  final IconData resolvedIcon;
  final String resolvedSymbol;

  final Color accentColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double size = compact ? 40 : 46;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: accentColor.withValues(
          alpha: 0.10,
        ),
        borderRadius: BorderRadius.circular(
          compact ? 13 : 16,
        ),
        border: Border.all(
          color: accentColor.withValues(
            alpha: 0.24,
          ),
        ),
      ),
      child: symbol != null
          ? Text(
        resolvedSymbol,
        style: TextStyle(
          fontSize: compact ? 18 : 21,
        ),
      )
          : Icon(
        resolvedIcon,
        color: accentColor,
        size: compact ? 21 : 26,
      ),
    );
  }
}