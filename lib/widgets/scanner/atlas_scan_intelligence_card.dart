import 'package:flutter/material.dart';

import '../../atlas/intelligence/models/atlas_scan_intelligence.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../atlas/atlas_glass_card.dart';
import '../atlas/atlas_glass_panel.dart';

class AtlasScanIntelligenceCard extends StatelessWidget {
  const AtlasScanIntelligenceCard({
    required this.intelligence,
    super.key,
  });

  final AtlasScanIntelligence intelligence;

  @override
  Widget build(BuildContext context) {
    if (intelligence.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<AtlasScanInsight> insights =
        intelligence.prioritizedInsights;

    return AtlasGlassCard(
      accentColor: intelligence.hasHighPriorityInsights
          ? AtlasColors.warning
          : AtlasColors.intelligenceBlue,
      padding: const EdgeInsets.all(
        AtlasSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _IntelligenceHeader(
            intelligence: intelligence,
          ),
          const SizedBox(
            height: AtlasSpacing.lg,
          ),
          for (
          int index = 0;
          index < insights.length;
          index++
          ) ...[
            _AtlasScanInsightTile(
              insight: insights[index],
            ),
            if (index < insights.length - 1)
              const SizedBox(
                height: AtlasSpacing.md,
              ),
          ],
        ],
      ),
    );
  }
}

class _IntelligenceHeader extends StatelessWidget {
  const _IntelligenceHeader({
    required this.intelligence,
  });

  final AtlasScanIntelligence intelligence;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AtlasColors.intelligenceBlue.withValues(
              alpha: 0.14,
            ),
            borderRadius: BorderRadius.circular(
              15,
            ),
            border: Border.all(
              color: AtlasColors.intelligenceBlue.withValues(
                alpha: 0.32,
              ),
            ),
          ),
          child: const Icon(
            Icons.psychology_alt_rounded,
            color: AtlasColors.intelligenceBlue,
            size: 27,
          ),
        ),
        const SizedBox(
          width: AtlasSpacing.md,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🧠 Atlas Intelligence',
                style: AtlasTypography.headingSmall,
              ),
              const SizedBox(
                height: AtlasSpacing.xs,
              ),
              Text(
                intelligence.hasHighPriorityInsights
                    ? 'Atlas found information that may need your attention.'
                    : 'Collector-focused findings from this scan.',
                style: AtlasTypography.bodySmall.copyWith(
                  color: AtlasColors.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          width: AtlasSpacing.sm,
        ),
        _InsightCountBadge(
          count: intelligence.insightCount,
          hasHighPriorityInsights:
          intelligence.hasHighPriorityInsights,
        ),
      ],
    );
  }
}

class _AtlasScanInsightTile extends StatelessWidget {
  const _AtlasScanInsightTile({
    required this.insight,
  });

  final AtlasScanInsight insight;

  @override
  Widget build(BuildContext context) {
    final Color accentColor =
    _accentColorForInsight(
      insight,
    );

    return AtlasGlassPanel(
      accentColor: accentColor,
      padding: const EdgeInsets.all(
        AtlasSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accentColor.withValues(
                alpha: 0.14,
              ),
              borderRadius: BorderRadius.circular(
                14,
              ),
            ),
            child: Text(
              insight.emoji,
              style: const TextStyle(
                fontSize: 21,
                height: 1,
              ),
            ),
          ),
          const SizedBox(
            width: AtlasSpacing.md,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        insight.displayTitle,
                        style:
                        AtlasTypography.headingSmall.copyWith(
                          color: AtlasColors.textPrimary,
                        ),
                      ),
                    ),
                    if (insight.requiresOnline)
                      const Padding(
                        padding: EdgeInsets.only(
                          left: AtlasSpacing.sm,
                        ),
                        child: Tooltip(
                          message:
                          'Connected intelligence',
                          child: Icon(
                            Icons.cloud_outlined,
                            size: 18,
                            color:
                            AtlasColors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(
                  height: AtlasSpacing.sm,
                ),
                Text(
                  insight.message,
                  style: AtlasTypography.bodyMedium.copyWith(
                    color: AtlasColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                if (insight.hasDetails) ...[
                  const SizedBox(
                    height: AtlasSpacing.md,
                  ),
                  for (
                  final String detail
                  in insight.details
                  )
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: AtlasSpacing.xs,
                      ),
                      child: Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            '•',
                            style:
                            AtlasTypography.bodyMedium.copyWith(
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            width: AtlasSpacing.sm,
                          ),
                          Expanded(
                            child: Text(
                              detail,
                              style:
                              AtlasTypography.bodySmall.copyWith(
                                color:
                                AtlasColors.textSecondary,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
                if (insight.hasRecommendation) ...[
                  const SizedBox(
                    height: AtlasSpacing.md,
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(
                      AtlasSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(
                        alpha: 0.10,
                      ),
                      borderRadius: BorderRadius.circular(
                        14,
                      ),
                      border: Border.all(
                        color: accentColor.withValues(
                          alpha: 0.24,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          '💡 Atlas Recommendation',
                          style:
                          AtlasTypography.bodySmall.copyWith(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: AtlasSpacing.xs,
                        ),
                        Text(
                          insight.recommendation!,
                          style:
                          AtlasTypography.bodyMedium.copyWith(
                            color: AtlasColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(
                  height: AtlasSpacing.sm,
                ),
                _InsightMetadataRow(
                  insight: insight,
                  accentColor: accentColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _accentColorForInsight(
      AtlasScanInsight insight,
      ) {
    if (insight.priority ==
        AtlasScanInsightPriority.critical) {
      return AtlasColors.danger;
    }

    if (insight.priority ==
        AtlasScanInsightPriority.high) {
      return AtlasColors.warning;
    }

    switch (insight.type) {
      case AtlasScanInsightType.identity:
        return AtlasColors.intelligenceBlue;

      case AtlasScanInsightType.collection:
        return AtlasColors.success;

      case AtlasScanInsightType.variant:
        return const Color(
          0xFF9B5DE5,
        );

      case AtlasScanInsightType.market:
        return AtlasColors.vaultGold;

      case AtlasScanInsightType.recommendation:
        return const Color(
          0xFF7E57C2,
        );

      case AtlasScanInsightType.warning:
        return AtlasColors.warning;
    }
  }
}

class _InsightMetadataRow extends StatelessWidget {
  const _InsightMetadataRow({
    required this.insight,
    required this.accentColor,
  });

  final AtlasScanInsight insight;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AtlasSpacing.sm,
      runSpacing: AtlasSpacing.xs,
      children: [
        _MetadataBadge(
          icon: _sourceIcon(
            insight.source,
          ),
          label: _sourceLabel(
            insight.source,
          ),
          accentColor: accentColor,
        ),
        if (insight.requiresOnline)
          _MetadataBadge(
            icon: Icons.cloud_outlined,
            label: 'Online',
            accentColor:
            AtlasColors.intelligenceBlue,
          )
        else
          _MetadataBadge(
            icon: Icons.offline_bolt_outlined,
            label: 'Offline Ready',
            accentColor: AtlasColors.success,
          ),
      ],
    );
  }

  IconData _sourceIcon(
      AtlasScanInsightSource source,
      ) {
    switch (source) {
      case AtlasScanInsightSource.scan:
        return Icons.qr_code_scanner_rounded;

      case AtlasScanInsightSource.identity:
        return Icons.fingerprint_rounded;

      case AtlasScanInsightSource.collection:
        return Icons.inventory_2_outlined;

      case AtlasScanInsightSource.market:
        return Icons.show_chart_rounded;

      case AtlasScanInsightSource.recommendation:
        return Icons.lightbulb_outline_rounded;

      case AtlasScanInsightSource.system:
        return Icons.settings_suggest_outlined;
    }
  }

  String _sourceLabel(
      AtlasScanInsightSource source,
      ) {
    switch (source) {
      case AtlasScanInsightSource.scan:
        return 'Scan';

      case AtlasScanInsightSource.identity:
        return 'Identity';

      case AtlasScanInsightSource.collection:
        return 'Vault';

      case AtlasScanInsightSource.market:
        return 'Market';

      case AtlasScanInsightSource.recommendation:
        return 'Recommendation';

      case AtlasScanInsightSource.system:
        return 'System';
    }
  }
}

class _MetadataBadge extends StatelessWidget {
  const _MetadataBadge({
    required this.icon,
    required this.label,
    required this.accentColor,
  });

  final IconData icon;
  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AtlasSpacing.sm,
        vertical: AtlasSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: accentColor.withValues(
          alpha: 0.08,
        ),
        borderRadius: BorderRadius.circular(
          999,
        ),
        border: Border.all(
          color: accentColor.withValues(
            alpha: 0.20,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: accentColor,
          ),
          const SizedBox(
            width: AtlasSpacing.xs,
          ),
          Text(
            label,
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCountBadge extends StatelessWidget {
  const _InsightCountBadge({
    required this.count,
    required this.hasHighPriorityInsights,
  });

  final int count;
  final bool hasHighPriorityInsights;

  @override
  Widget build(BuildContext context) {
    final Color accentColor =
    hasHighPriorityInsights
        ? AtlasColors.warning
        : AtlasColors.intelligenceBlue;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AtlasSpacing.sm,
        vertical: AtlasSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: accentColor.withValues(
          alpha: 0.12,
        ),
        borderRadius: BorderRadius.circular(
          999,
        ),
        border: Border.all(
          color: accentColor.withValues(
            alpha: 0.30,
          ),
        ),
      ),
      child: Text(
        '$count',
        style: AtlasTypography.bodySmall.copyWith(
          color: accentColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}