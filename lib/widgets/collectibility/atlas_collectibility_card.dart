import 'package:flutter/material.dart';

import '../../atlas/collectibility/models/atlas_collectibility_signal.dart';
import '../../atlas/collectibility/models/atlas_collectibility_summary.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../atlas/atlas_expandable_section.dart';
import '../atlas/atlas_glass_panel.dart';

/// Reusable presentation for completed Atlas collectibility intelligence.
///
/// This widget does not calculate collectibility, inspect a Pop, or recreate
/// any AtlasCollectibilityEngine rules. It only renders the supplied summary.
class AtlasCollectibilityCard extends StatelessWidget {
  const AtlasCollectibilityCard({
    super.key,
    required this.summary,
    this.maxSignals = 4,
    this.maxStrengths = 3,
    this.maxOpportunities = 3,
    this.showStrengths = true,
    this.showOpportunities = true,
    this.showSignals = true,
    this.initiallyExpanded = false,
    this.onViewDetails,
  });

  final AtlasCollectibilitySummary summary;

  /// Maximum number of intelligence signals displayed in the compact card.
  final int maxSignals;

  /// Maximum number of strengths displayed in the compact card.
  final int maxStrengths;

  /// Maximum number of opportunities displayed in the compact card.
  final int maxOpportunities;

  final bool showStrengths;
  final bool showOpportunities;
  final bool showSignals;
  final bool initiallyExpanded;

  /// Optional callback for a future expanded intelligence screen or sheet.
  final VoidCallback? onViewDetails;

  @override
  Widget build(BuildContext context) {
    return AtlasExpandableSection(
      title: 'Collectibility Intelligence',
      subtitle: _buildCollapsedSubtitle(summary),
      icon: Icons.workspace_premium_outlined,
      initiallyExpanded: initiallyExpanded,
      badge: AtlasExpandableBadge(
        label: '${summary.score} / 100',
        icon: Icons.stars_outlined,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CollectibilityOverview(summary: summary),
          const SizedBox(height: AtlasSpacing.md),
          _CollectibilityStatusGrid(summary: summary),
          if (showSignals && summary.hasSignals) ...[
            const SizedBox(height: AtlasSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Collector Signals',
                    style: AtlasTypography.headingSmall,
                  ),
                ),
                AtlasExpandableBadge(
                  label: _buildSignalCountLabel(summary.signals.length),
                  icon: Icons.insights_outlined,
                ),
              ],
            ),
            const SizedBox(height: AtlasSpacing.sm),
            ...summary.signals
                .take(maxSignals)
                .map(
                  (signal) => Padding(
                padding: const EdgeInsets.only(
                  bottom: AtlasSpacing.sm,
                ),
                child: _CollectibilitySignalPanel(
                  signal: signal,
                ),
              ),
            ),
          ],
          if (showStrengths && summary.strengths.isNotEmpty) ...[
            const SizedBox(height: AtlasSpacing.md),
            _CollectibilityTextSection(
              title: 'Profile Strengths',
              icon: Icons.add_circle_outline_rounded,
              values: summary.strengths
                  .take(maxStrengths)
                  .toList(growable: false),
            ),
          ],
          if (showOpportunities && summary.hasOpportunities) ...[
            const SizedBox(height: AtlasSpacing.md),
            _CollectibilityTextSection(
              title: 'Strengthen This Profile',
              icon: Icons.trending_up_rounded,
              values: summary.opportunities
                  .take(maxOpportunities)
                  .toList(growable: false),
            ),
          ],
          if (onViewDetails != null) ...[
            const SizedBox(height: AtlasSpacing.md),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onViewDetails,
                icon: const Icon(
                  Icons.analytics_outlined,
                  size: 18,
                ),
                label: const Text(
                  'View Collectibility Details',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CollectibilityOverview extends StatelessWidget {
  const _CollectibilityOverview({required this.summary});

  final AtlasCollectibilitySummary summary;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CollectibilityScore(score: summary.score),
              const SizedBox(width: AtlasSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AtlasSpacing.sm,
                      runSpacing: AtlasSpacing.sm,
                      children: [
                        _StatusBadge(
                          label: summary.tier,
                          icon: Icons.stars_outlined,
                        ),
                        _StatusBadge(
                          label: '${summary.confidence} Confidence',
                          icon: Icons.verified_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: AtlasSpacing.md),
                    Text(
                      summary.headline,
                      style: AtlasTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AtlasSpacing.md),
          Text(
            summary.explanation,
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

String _buildCollapsedSubtitle(
    AtlasCollectibilitySummary summary,
    ) {
  final signalCount = summary.signals.length;
  final signalLabel = _buildSignalCountLabel(signalCount);

  return '${summary.confidence} confidence • '
      '$signalLabel • '
      '${summary.marketReadiness}';
}

String _buildSignalCountLabel(int count) {
  return '$count ${count == 1 ? 'Signal' : 'Signals'}';
}

class _CollectibilityScore extends StatelessWidget {
  const _CollectibilityScore({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Collectibility score $score out of 100',
      child: Container(
        width: 76,
        height: 76,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AtlasColors.vaultGold.withValues(alpha: 0.12),
          border: Border.all(
            color: AtlasColors.vaultGold.withValues(alpha: 0.45),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$score',
              style: AtlasTypography.headingLarge.copyWith(
                color: AtlasColors.vaultGold,
              ),
            ),
            Text(
              '/ 100',
              style: AtlasTypography.bodySmall.copyWith(
                color: AtlasColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectibilityStatusGrid extends StatelessWidget {
  const _CollectibilityStatusGrid({required this.summary});

  final AtlasCollectibilitySummary summary;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useColumn = constraints.maxWidth < 390;

        final firstPanel = _CollectibilityStatusPanel(
          label: 'Market Readiness',
          value: summary.marketReadiness,
          icon: Icons.storefront_outlined,
        );

        final secondPanel = _CollectibilityStatusPanel(
          label: 'Display Profile',
          value: summary.isDisplayPiece
              ? 'Display Candidate'
              : 'Standard Profile',
          icon: Icons.collections_bookmark_outlined,
        );

        final thirdPanel = _CollectibilityStatusPanel(
          label: 'Insurance Review',
          value: summary.shouldReviewForInsurance
              ? 'Review Suggested'
              : 'Not Suggested',
          icon: Icons.shield_outlined,
        );

        if (useColumn) {
          return Column(
            children: [
              firstPanel,
              const SizedBox(height: AtlasSpacing.sm),
              secondPanel,
              const SizedBox(height: AtlasSpacing.sm),
              thirdPanel,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: firstPanel),
            const SizedBox(width: AtlasSpacing.sm),
            Expanded(child: secondPanel),
            const SizedBox(width: AtlasSpacing.sm),
            Expanded(child: thirdPanel),
          ],
        );
      },
    );
  }
}

class _CollectibilityStatusPanel extends StatelessWidget {
  const _CollectibilityStatusPanel({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassPanel(
      padding: const EdgeInsets.all(AtlasSpacing.sm),
      borderRadius: 16,
      child: Column(
        children: [
          Icon(icon, color: AtlasColors.vaultGold, size: 21),
          const SizedBox(height: AtlasSpacing.sm),
          Text(
            value,
            textAlign: TextAlign.center,
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.vaultGold,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AtlasSpacing.xs),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectibilitySignalPanel extends StatelessWidget {
  const _CollectibilitySignalPanel({required this.signal});

  final AtlasCollectibilitySignal signal;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassPanel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AtlasColors.vaultGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              signal.isStrongSignal
                  ? Icons.auto_awesome_rounded
                  : Icons.insights_outlined,
              color: AtlasColors.vaultGold,
              size: 21,
            ),
          ),
          const SizedBox(width: AtlasSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        signal.label,
                        style: AtlasTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: AtlasSpacing.sm),
                    _SignalPoints(points: signal.points),
                  ],
                ),
                const SizedBox(height: AtlasSpacing.xs),
                Text(
                  signal.category,
                  style: AtlasTypography.bodySmall.copyWith(
                    color: AtlasColors.vaultGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AtlasSpacing.xs),
                Text(
                  signal.description,
                  style: AtlasTypography.bodySmall.copyWith(
                    color: AtlasColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SignalPoints extends StatelessWidget {
  const _SignalPoints({required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AtlasSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AtlasColors.vaultGold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AtlasColors.vaultGold.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        '+$points',
        style: AtlasTypography.bodySmall.copyWith(
          color: AtlasColors.vaultGold,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AtlasSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AtlasColors.vaultGold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AtlasColors.vaultGold.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AtlasColors.vaultGold),
          const SizedBox(width: AtlasSpacing.xs),
          Text(
            label,
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.vaultGold,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectibilityTextSection extends StatelessWidget {
  const _CollectibilityTextSection({
    required this.title,
    required this.icon,
    required this.values,
  });

  final String title;
  final IconData icon;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AtlasTypography.headingSmall),
          const SizedBox(height: AtlasSpacing.sm),
          ...values.map(
            (value) => Padding(
              padding: const EdgeInsets.only(bottom: AtlasSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 18, color: AtlasColors.vaultGold),
                  const SizedBox(width: AtlasSpacing.sm),
                  Expanded(
                    child: Text(
                      value,
                      style: AtlasTypography.bodySmall.copyWith(
                        color: AtlasColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
