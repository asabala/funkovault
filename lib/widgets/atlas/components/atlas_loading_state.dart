import 'package:flutter/material.dart';

import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_symbols.dart';
import 'atlas_insight_panel.dart';

enum AtlasLoadingStateTone { intelligence, recommendation, neutral }

class AtlasLoadingState extends StatelessWidget {
  const AtlasLoadingState({
    super.key,
    this.title = 'Atlas is working',
    this.message = 'Please wait while Atlas prepares this experience.',
    this.symbol = AtlasSymbols.loading,
    this.tone = AtlasLoadingStateTone.intelligence,
    this.progress,
    this.progressLabel,
    this.compact = false,
  }) : assert(
         progress == null || (progress >= 0 && progress <= 1),
         'AtlasLoadingState progress must be between 0 and 1.',
       );

  final String title;
  final String message;
  final String symbol;
  final AtlasLoadingStateTone tone;

  /// Null means indeterminate loading.
  final double? progress;

  final String? progressLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final Color accentColor = switch (tone) {
      AtlasLoadingStateTone.intelligence => AtlasColors.intelligenceBlue,
      AtlasLoadingStateTone.recommendation => AtlasColors.vaultGold,
      AtlasLoadingStateTone.neutral => AtlasColors.textSecondary,
    };

    return AtlasInsightPanel(
      eyebrow: progressLabel?.trim().isNotEmpty == true
          ? progressLabel!.trim()
          : 'Loading',
      title: title,
      message: message,
      symbol: symbol,
      tone: _insightTone,
      trailing: SizedBox(
        width: compact ? 18 : 22,
        height: compact ? 18 : 22,
        child: CircularProgressIndicator(
          value: progress,
          strokeWidth: compact ? 2 : 2.4,
          color: accentColor,
          backgroundColor: AtlasColors.surface,
        ),
      ),
      maxMessageLines: compact ? 2 : null,
    );
  }

  AtlasInsightPanelTone get _insightTone {
    return switch (tone) {
      AtlasLoadingStateTone.intelligence => AtlasInsightPanelTone.intelligence,
      AtlasLoadingStateTone.recommendation =>
        AtlasInsightPanelTone.recommendation,
      AtlasLoadingStateTone.neutral => AtlasInsightPanelTone.neutral,
    };
  }
}
