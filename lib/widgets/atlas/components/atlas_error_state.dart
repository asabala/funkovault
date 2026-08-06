import 'package:flutter/material.dart';

import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_symbols.dart';
import 'atlas_insight_panel.dart';

enum AtlasErrorStateTone {
  warning,
  danger,
  neutral,
}

class AtlasErrorState extends StatelessWidget {
  const AtlasErrorState({
    super.key,
    this.eyebrow = 'Error',
    required this.title,
    required this.message,
    this.symbol = AtlasSymbols.warning,
    this.tone = AtlasErrorStateTone.warning,
    this.actionLabel = 'Try Again',
    this.onAction,
    this.compact = false,
  });

  final String eyebrow;
  final String title;
  final String message;
  final String symbol;
  final AtlasErrorStateTone tone;

  final String actionLabel;
  final VoidCallback? onAction;

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final String cleanedActionLabel =
    actionLabel.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AtlasInsightPanel(
          eyebrow: eyebrow,
          title: title,
          message: message,
          symbol: symbol,
          tone: _insightTone,
          maxMessageLines: compact ? 2 : null,
        ),
        if (onAction != null &&
            cleanedActionLabel.isNotEmpty) ...[
          const SizedBox(
            height: 12,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: onAction,
              icon: Icon(
                Icons.refresh_rounded,
                color: _accentColor,
              ),
              label: Text(
                cleanedActionLabel,
              ),
            ),
          ),
        ],
      ],
    );
  }

  AtlasInsightPanelTone get _insightTone {
    return switch (tone) {
      AtlasErrorStateTone.warning =>
      AtlasInsightPanelTone.warning,
      AtlasErrorStateTone.danger =>
      AtlasInsightPanelTone.danger,
      AtlasErrorStateTone.neutral =>
      AtlasInsightPanelTone.neutral,
    };
  }

  Color get _accentColor {
    return switch (tone) {
      AtlasErrorStateTone.warning =>
      AtlasColors.warning,
      AtlasErrorStateTone.danger =>
      AtlasColors.danger,
      AtlasErrorStateTone.neutral =>
      AtlasColors.textSecondary,
    };
  }
}