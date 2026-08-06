import 'package:flutter/material.dart';

import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_icons.dart';
import '../../../theme/atlas_spacing.dart';
import '../../../theme/atlas_symbols.dart';
import '../../../theme/atlas_typography.dart';
import '../../../widgets/atlas/atlas_expandable_section.dart';
import '../../../widgets/atlas/atlas_glass_card.dart';
import '../../../widgets/atlas/atlas_glass_panel.dart';
import '../../../widgets/atlas/components/atlas_insight_panel.dart';
import '../../../widgets/atlas/components/atlas_metric_panel.dart';
import '../../../widgets/atlas/components/atlas_progress_bar.dart';
import '../../../widgets/atlas/components/atlas_section_header.dart';
import '../../../widgets/atlas/components/atlas_status_chip.dart';
import '../../../widgets/vault/vault_scroll_view.dart';

class AtlasDesignSystemShowcaseScreen extends StatelessWidget {
  const AtlasDesignSystemShowcaseScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Atlas Design System',
        ),
      ),
      body: const VaultScrollView(
        children: [
          _ShowcaseHero(),
          SizedBox(
            height: AtlasSpacing.lg,
          ),
          _DesignTokensSection(),
          SizedBox(
            height: AtlasSpacing.lg,
          ),
          _FoundationsSection(),
          SizedBox(
            height: AtlasSpacing.lg,
          ),
          _MetricsSection(),
          SizedBox(
            height: AtlasSpacing.lg,
          ),
          _StatusSection(),
          SizedBox(
            height: AtlasSpacing.lg,
          ),
          _InsightsSection(),
          SizedBox(
            height: AtlasSpacing.lg,
          ),
          _MotionSection(),
          SizedBox(
            height: AtlasSpacing.lg,
          ),
          _LoadingSection(),
          SizedBox(
            height: AtlasSpacing.lg,
          ),
          _EmptyStatesSection(),
        ],
      ),
    );
  }
}

class _ShowcaseHero extends StatelessWidget {
  const _ShowcaseHero();

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      accentColor: AtlasColors.intelligenceBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AtlasSectionHeader(
            title: 'Atlas Design System 2.0',
            subtitle:
            'A living component gallery for building consistent Atlas experiences.',
            icon: Icons.dashboard_customize_rounded,
            accentColor: AtlasColors.intelligenceBlue,
            badge: AtlasStatusChip(
              label: 'Version 2',
              icon: Icons.layers_rounded,
              accentColor: AtlasColors.intelligenceBlue,
              size: AtlasStatusChipSize.compact,
            ),
          ),
          const SizedBox(
            height: AtlasSpacing.lg,
          ),
          AtlasInsightPanel(
            eyebrow: 'Design System',
            title: 'Simple. Scalable. Beautiful.',
            message:
            'Every reusable Atlas component should be documented, tested, and represented in this Showcase.',
            icon: Icons.psychology_rounded,
            tone: AtlasInsightPanelTone.intelligence,
          ),
        ],
      ),
    );
  }
}

class _DesignTokensSection extends StatelessWidget {
  const _DesignTokensSection();

  @override
  Widget build(BuildContext context) {
    return AtlasExpandableSection(
      title: 'Design Tokens',
      subtitle:
      'Core colors, typography, spacing, icons, and semantic symbols used throughout Atlas.',
      icon: Icons.token_rounded,
      initiallyExpanded: true,
      accentColor: AtlasColors.intelligenceBlue,
      badge: const _MaturityBadge(
        label: 'Stable',
        status: _ComponentMaturity.stable,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TokenGroupHeader(
            title: 'Colors',
            description:
            'Semantic color tokens that define the Atlas visual language.',
            icon: Icons.palette_outlined,
          ),
          SizedBox(
            height: AtlasSpacing.md,
          ),
          AtlasGlassPanel(
            child: Column(
              children: [
                _ColorTokenRow(
                  name: 'Vault Gold',
                  color: AtlasColors.vaultGold,
                ),
                _ColorTokenRow(
                  name: 'Intelligence Blue',
                  color: AtlasColors.intelligenceBlue,
                ),
                _ColorTokenRow(
                  name: 'Success',
                  color: AtlasColors.success,
                ),
                _ColorTokenRow(
                  name: 'Warning',
                  color: AtlasColors.warning,
                ),
                _ColorTokenRow(
                  name: 'Danger',
                  color: AtlasColors.danger,
                ),
                _ColorTokenRow(
                  name: 'Surface',
                  color: AtlasColors.surface,
                ),
                _ColorTokenRow(
                  name: 'Card',
                  color: AtlasColors.card,
                  showBottomSpacing: false,
                ),
              ],
            ),
          ),
          SizedBox(
            height: AtlasSpacing.lg,
          ),
          _TokenGroupHeader(
            title: 'Typography',
            description:
            'Shared text hierarchy for headings, body content, labels, and supporting information.',
            icon: Icons.text_fields_rounded,
          ),
          SizedBox(
            height: AtlasSpacing.md,
          ),
          AtlasGlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TypographySample(
                  name: 'Heading Large',
                  sample: 'Atlas Intelligence',
                  style: AtlasTypography.headingLarge,
                ),
                _TypographySample(
                  name: 'Heading Small',
                  sample: 'Collector Progress',
                  style: AtlasTypography.headingSmall,
                ),
                _TypographySample(
                  name: 'Body Medium',
                  sample:
                  'Primary readable content used throughout Atlas.',
                  style: AtlasTypography.bodyMedium,
                ),
                _TypographySample(
                  name: 'Body Small',
                  sample:
                  'Supporting context, metadata, and secondary information.',
                  style: AtlasTypography.bodySmall,
                  showBottomSpacing: false,
                ),
              ],
            ),
          ),
          SizedBox(
            height: AtlasSpacing.lg,
          ),
          _TokenGroupHeader(
            title: 'Spacing',
            description:
            'Consistent spacing rhythm used between components, cards, and content.',
            icon: Icons.straighten_rounded,
          ),
          SizedBox(
            height: AtlasSpacing.md,
          ),
          AtlasGlassPanel(
            child: Column(
              children: [
                _SpacingTokenRow(
                  name: 'XS',
                  value: AtlasSpacing.xs,
                ),
                _SpacingTokenRow(
                  name: 'SM',
                  value: AtlasSpacing.sm,
                ),
                _SpacingTokenRow(
                  name: 'MD',
                  value: AtlasSpacing.md,
                ),
                _SpacingTokenRow(
                  name: 'LG',
                  value: AtlasSpacing.lg,
                  showBottomSpacing: false,
                ),
              ],
            ),
          ),
          SizedBox(
            height: AtlasSpacing.lg,
          ),
          _TokenGroupHeader(
            title: 'Icons',
            description:
            'Material icon choices centralized through AtlasIcons.',
            icon: Icons.apps_rounded,
          ),
          SizedBox(
            height: AtlasSpacing.md,
          ),
          AtlasGlassPanel(
            child: Wrap(
              spacing: AtlasSpacing.md,
              runSpacing: AtlasSpacing.md,
              children: [
                _IconToken(
                  label: 'Atlas',
                  icon: AtlasIcons.atlas,
                ),
                _IconToken(
                  label: 'Vault',
                  icon: AtlasIcons.vault,
                ),
                _IconToken(
                  label: 'Intelligence',
                  icon: AtlasIcons.intelligence,
                ),
                _IconToken(
                  label: 'Collection',
                  icon: AtlasIcons.collection,
                ),
                _IconToken(
                  label: 'Wishlist',
                  icon: AtlasIcons.wishlist,
                ),
                _IconToken(
                  label: 'Health',
                  icon: AtlasIcons.health,
                ),
                _IconToken(
                  label: 'Achievement',
                  icon: AtlasIcons.achievement,
                ),
                _IconToken(
                  label: 'Recommendation',
                  icon: AtlasIcons.recommendation,
                ),
              ],
            ),
          ),
          SizedBox(
            height: AtlasSpacing.lg,
          ),
          _TokenGroupHeader(
            title: 'Symbols',
            description:
            'Semantic collector-platform symbols centralized through AtlasSymbols.',
            icon: Icons.emoji_symbols_rounded,
          ),
          SizedBox(
            height: AtlasSpacing.md,
          ),
          AtlasGlassPanel(
            child: Wrap(
              spacing: AtlasSpacing.md,
              runSpacing: AtlasSpacing.md,
              children: [
                _SymbolToken(
                  label: 'Atlas',
                  symbol: AtlasSymbols.atlas,
                ),
                _SymbolToken(
                  label: 'Intelligence',
                  symbol: AtlasSymbols.intelligence,
                ),
                _SymbolToken(
                  label: 'Collection',
                  symbol: AtlasSymbols.collection,
                ),
                _SymbolToken(
                  label: 'Completion',
                  symbol: AtlasSymbols.completion,
                ),
                _SymbolToken(
                  label: 'Recommendation',
                  symbol: AtlasSymbols.recommendation,
                ),
                _SymbolToken(
                  label: 'Achievement',
                  symbol: AtlasSymbols.achievement,
                ),
                _SymbolToken(
                  label: 'Wishlist',
                  symbol: AtlasSymbols.wishlist,
                ),
                _SymbolToken(
                  label: 'Chase',
                  symbol: AtlasSymbols.chase,
                ),
                _SymbolToken(
                  label: 'Exclusive',
                  symbol: AtlasSymbols.exclusive,
                ),
                _SymbolToken(
                  label: 'Health',
                  symbol: AtlasSymbols.health,
                ),
                _SymbolToken(
                  label: 'Review Variant',
                  symbol: AtlasSymbols.reviewVariant,
                ),
                _SymbolToken(
                  label: 'Premium',
                  symbol: AtlasSymbols.premium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TokenGroupHeader extends StatelessWidget {
  const _TokenGroupHeader({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AtlasSectionHeader(
      title: title,
      subtitle: description,
      icon: icon,
      accentColor: AtlasColors.vaultGold,
      showDivider: true,
    );
  }
}

class _ColorTokenRow extends StatelessWidget {
  const _ColorTokenRow({
    required this.name,
    required this.color,
    this.showBottomSpacing = true,
  });

  final String name;
  final Color color;
  final bool showBottomSpacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: showBottomSpacing
            ? AtlasSpacing.sm
            : 0,
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 30,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(
                10,
              ),
              border: Border.all(
                color: AtlasColors.border,
              ),
            ),
          ),
          const SizedBox(
            width: AtlasSpacing.md,
          ),
          Expanded(
            child: Text(
              name,
              style: AtlasTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypographySample extends StatelessWidget {
  const _TypographySample({
    required this.name,
    required this.sample,
    required this.style,
    this.showBottomSpacing = true,
  });

  final String name;
  final String sample;
  final TextStyle style;
  final bool showBottomSpacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: showBottomSpacing
            ? AtlasSpacing.lg
            : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name.toUpperCase(),
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.vaultGold,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(
            height: AtlasSpacing.xs,
          ),
          Text(
            sample,
            style: style,
          ),
        ],
      ),
    );
  }
}

class _SpacingTokenRow extends StatelessWidget {
  const _SpacingTokenRow({
    required this.name,
    required this.value,
    this.showBottomSpacing = true,
  });

  final String name;
  final double value;
  final bool showBottomSpacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: showBottomSpacing
            ? AtlasSpacing.md
            : 0,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            child: Text(
              name,
              style: AtlasTypography.bodySmall.copyWith(
                color: AtlasColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            width: AtlasSpacing.sm,
          ),
          Container(
            width: value * 4,
            height: 12,
            decoration: BoxDecoration(
              color: AtlasColors.intelligenceBlue,
              borderRadius: BorderRadius.circular(
                999,
              ),
            ),
          ),
          const SizedBox(
            width: AtlasSpacing.md,
          ),
          Text(
            value.toStringAsFixed(0),
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

class _IconToken extends StatelessWidget {
  const _IconToken({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AtlasColors.intelligenceBlue.withValues(
                alpha: 0.10,
              ),
              borderRadius: BorderRadius.circular(
                14,
              ),
              border: Border.all(
                color: AtlasColors.intelligenceBlue.withValues(
                  alpha: 0.24,
                ),
              ),
            ),
            child: Icon(
              icon,
              color: AtlasColors.intelligenceBlue,
              size: 22,
            ),
          ),
          const SizedBox(
            height: AtlasSpacing.xs,
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SymbolToken extends StatelessWidget {
  const _SymbolToken({
    required this.label,
    required this.symbol,
  });

  final String label;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AtlasColors.vaultGold.withValues(
                alpha: 0.10,
              ),
              borderRadius: BorderRadius.circular(
                14,
              ),
              border: Border.all(
                color: AtlasColors.vaultGold.withValues(
                  alpha: 0.24,
                ),
              ),
            ),
            child: Text(
              symbol,
              style: const TextStyle(
                fontSize: 21,
              ),
            ),
          ),
          const SizedBox(
            height: AtlasSpacing.xs,
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FoundationsSection extends StatelessWidget {
  const _FoundationsSection();

  @override
  Widget build(BuildContext context) {
    return AtlasExpandableSection(
      title: 'Foundations',
      subtitle:
      'Core glass surfaces, section structure, and expandable presentation.',
      icon: Icons.foundation_rounded,
      initiallyExpanded: true,
      badge: const _MaturityBadge(
        label: 'Stable',
        status: _ComponentMaturity.stable,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ComponentLabel(
            title: 'AtlasGlassCard',
            description:
            'Primary elevated surface with accent borders and interaction support.',
          ),
          const SizedBox(
            height: AtlasSpacing.sm,
          ),
          AtlasGlassCard(
            accentColor: AtlasColors.vaultGold,
            child: Text(
              'Primary Atlas glass surface',
              style: AtlasTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            height: AtlasSpacing.lg,
          ),
          const _ComponentLabel(
            title: 'AtlasGlassPanel',
            description:
            'Lightweight nested surface for secondary information.',
          ),
          const SizedBox(
            height: AtlasSpacing.sm,
          ),
          const AtlasGlassPanel(
            child: Text(
              'Nested Atlas glass panel',
            ),
          ),
          const SizedBox(
            height: AtlasSpacing.lg,
          ),
          const _ComponentLabel(
            title: 'AtlasSectionHeader',
            description:
            'Shared visual language for standalone section headers.',
          ),
          const SizedBox(
            height: AtlasSpacing.sm,
          ),
          const AtlasGlassPanel(
            child: AtlasSectionHeader(
              title: 'Collector Intelligence',
              subtitle:
              'Reusable header with icon, badge, subtitle, and trailing support.',
              icon: Icons.psychology_rounded,
              badge: AtlasStatusChip(
                label: 'Stable',
                icon: Icons.check_circle_outline_rounded,
                accentColor: AtlasColors.success,
                size: AtlasStatusChipSize.compact,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricsSection extends StatelessWidget {
  const _MetricsSection();

  @override
  Widget build(BuildContext context) {
    return AtlasExpandableSection(
      title: 'Metrics',
      subtitle:
      'Reusable panels and progress visualization for Atlas intelligence.',
      icon: Icons.analytics_outlined,
      badge: const _MaturityBadge(
        label: 'Stable',
        status: _ComponentMaturity.stable,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ComponentLabel(
            title: 'AtlasMetricPanel',
            description:
            'Equal-height metric presentation for values, scores, confidence, and health.',
          ),
          const SizedBox(
            height: AtlasSpacing.sm,
          ),
          LayoutBuilder(
            builder: (
                BuildContext context,
                BoxConstraints constraints,
                ) {
              final bool useColumn =
                  constraints.maxWidth < 350;

              const AtlasMetricPanel valuePanel =
              AtlasMetricPanel(
                label: 'Current Value',
                value: r'$37.00',
                supportingText: 'No trend yet',
                icon: Icons.attach_money_rounded,
              );

              const AtlasMetricPanel scorePanel =
              AtlasMetricPanel(
                label: 'Collector Score',
                value: '84 / 100',
                supportingText: 'Premium Piece',
                icon: Icons.insights_rounded,
              );

              if (useColumn) {
                return const Column(
                  children: [
                    valuePanel,
                    SizedBox(
                      height: AtlasSpacing.md,
                    ),
                    scorePanel,
                  ],
                );
              }

              return const Row(
                crossAxisAlignment:
                CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: valuePanel,
                  ),
                  SizedBox(
                    width: AtlasSpacing.md,
                  ),
                  Expanded(
                    child: scorePanel,
                  ),
                ],
              );
            },
          ),
          const SizedBox(
            height: AtlasSpacing.lg,
          ),
          const _ComponentLabel(
            title: 'AtlasProgressBar',
            description:
            'Animated progress language shared by completion, health, confidence, and analytics.',
          ),
          const SizedBox(
            height: AtlasSpacing.md,
          ),
          const AtlasProgressBar(
            value: 0.25,
            label: 'Getting Started',
            showPercentage: true,
            accentColor: AtlasColors.intelligenceBlue,
          ),
          const SizedBox(
            height: AtlasSpacing.md,
          ),
          const AtlasProgressBar(
            value: 0.75,
            label: 'Near Completion',
            showPercentage: true,
            accentColor: AtlasColors.vaultGold,
          ),
          const SizedBox(
            height: AtlasSpacing.md,
          ),
          const AtlasProgressBar(
            value: 1,
            label: 'Complete',
            showPercentage: true,
            accentColor: AtlasColors.success,
          ),
        ],
      ),
    );
  }
}

class _StatusSection extends StatelessWidget {
  const _StatusSection();

  @override
  Widget build(BuildContext context) {
    return AtlasExpandableSection(
      title: 'Status',
      subtitle:
      'Shared chips for ownership, health, confidence, and collector states.',
      icon: Icons.sell_outlined,
      badge: const _MaturityBadge(
        label: 'Stable',
        status: _ComponentMaturity.stable,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ComponentLabel(
            title: 'AtlasStatusChip',
            description:
            'Consistent pill presentation with icon or Atlas symbol support.',
          ),
          const SizedBox(
            height: AtlasSpacing.md,
          ),
          Wrap(
            spacing: AtlasSpacing.sm,
            runSpacing: AtlasSpacing.sm,
            children: [
              AtlasStatusChip(
                label: 'Owned',
                symbol: AtlasSymbols.owned,
                accentColor: AtlasColors.success,
              ),
              AtlasStatusChip(
                label: 'Wishlist',
                symbol: AtlasSymbols.wishlist,
                accentColor: AtlasColors.warning,
              ),
              AtlasStatusChip(
                label: 'Missing',
                symbol: AtlasSymbols.missing,
                accentColor: AtlasColors.textSecondary,
              ),
              const AtlasStatusChip(
                label: 'High Confidence',
                icon: Icons.psychology_rounded,
                accentColor: AtlasColors.intelligenceBlue,
              ),
              const AtlasStatusChip(
                label: 'Risk: Low',
                icon: Icons.shield_outlined,
                accentColor: AtlasColors.success,
                size: AtlasStatusChipSize.compact,
              ),
              const AtlasStatusChip(
                label: 'Review Needed',
                icon: Icons.warning_amber_rounded,
                accentColor: AtlasColors.warning,
                size: AtlasStatusChipSize.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InsightsSection extends StatelessWidget {
  const _InsightsSection();

  @override
  Widget build(BuildContext context) {
    return AtlasExpandableSection(
      title: 'Insights',
      subtitle:
      'Reusable intelligence, recommendation, success, and warning presentation.',
      icon: Icons.auto_awesome_rounded,
      badge: const _MaturityBadge(
        label: 'Stable',
        status: _ComponentMaturity.stable,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ComponentLabel(
            title: 'AtlasInsightPanel',
            description:
            'Shared narrative surface for meaningful Atlas intelligence.',
          ),
          const SizedBox(
            height: AtlasSpacing.md,
          ),
          AtlasInsightPanel(
            eyebrow: 'Collector Insight',
            title: 'Strong collection fit',
            message:
            'This release complements several collectibles already stored in the Vault.',
            icon: Icons.psychology_rounded,
            tone:
            AtlasInsightPanelTone.intelligence,
          ),
          const SizedBox(
            height: AtlasSpacing.md,
          ),
          AtlasInsightPanel(
            eyebrow: 'Next Goal',
            title: 'Complete the Chase pair',
            message:
            'Only one Chase release remains in this variant family.',
            symbol: AtlasSymbols.recommendation,
            tone:
            AtlasInsightPanelTone.recommendation,
          ),
          const SizedBox(
            height: AtlasSpacing.md,
          ),
          AtlasInsightPanel(
            eyebrow: 'Milestone',
            title: 'Collection complete',
            message:
            'Every release in this catalog group is owned.',
            symbol: AtlasSymbols.achievement,
            tone: AtlasInsightPanelTone.success,
          ),
          const SizedBox(
            height: AtlasSpacing.md,
          ),
          const AtlasInsightPanel(
            eyebrow: 'Review',
            title: 'Identity confirmation needed',
            message:
            'Review the sticker and variant details before applying catalog metadata.',
            icon: Icons.warning_amber_rounded,
            tone: AtlasInsightPanelTone.warning,
          ),
        ],
      ),
    );
  }
}

class _MotionSection extends StatelessWidget {
  const _MotionSection();

  @override
  Widget build(BuildContext context) {
    return AtlasExpandableSection(
      title: 'Motion',
      subtitle:
      'Shared motion tokens and reusable transition components.',
      icon: Icons.animation_rounded,
      badge: const _MaturityBadge(
        label: 'Coming Soon',
        status: _ComponentMaturity.comingSoon,
      ),
      child: const _PlannedComponentPanel(
        title: 'Atlas Motion',
        message:
        'Future components will standardize press, reveal, expansion, loading, and navigation motion.',
        icon: Icons.animation_rounded,
      ),
    );
  }
}

class _LoadingSection extends StatelessWidget {
  const _LoadingSection();

  @override
  Widget build(BuildContext context) {
    return AtlasExpandableSection(
      title: 'Loading',
      subtitle:
      'Reusable loading states for catalog, intelligence, and Vault operations.',
      icon: Icons.hourglass_top_rounded,
      badge: const _MaturityBadge(
        label: 'Planned',
        status: _ComponentMaturity.planned,
      ),
      child: const _PlannedComponentPanel(
        title: 'Atlas Loading State',
        message:
        'A shared loading surface will replace screen-specific spinners and placeholder cards.',
        icon: Icons.sync_rounded,
      ),
    );
  }
}

class _EmptyStatesSection extends StatelessWidget {
  const _EmptyStatesSection();

  @override
  Widget build(BuildContext context) {
    return AtlasExpandableSection(
      title: 'Empty States',
      subtitle:
      'Reusable no-results, unavailable, and first-use experiences.',
      icon: Icons.inbox_outlined,
      badge: const _MaturityBadge(
        label: 'Planned',
        status: _ComponentMaturity.planned,
      ),
      child: const _PlannedComponentPanel(
        title: 'Atlas Empty State',
        message:
        'Future empty-state components will provide consistent guidance, actions, and visual hierarchy.',
        icon: Icons.inventory_2_outlined,
      ),
    );
  }
}

class _ComponentLabel extends StatelessWidget {
  const _ComponentLabel({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AtlasTypography.headingSmall.copyWith(
            color: AtlasColors.vaultGold,
          ),
        ),
        const SizedBox(
          height: AtlasSpacing.xs,
        ),
        Text(
          description,
          style: AtlasTypography.bodySmall.copyWith(
            color: AtlasColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _PlannedComponentPanel
    extends StatelessWidget {
  const _PlannedComponentPanel({
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AtlasInsightPanel(
      eyebrow: 'Roadmap',
      title: title,
      message: message,
      icon: icon,
      tone: AtlasInsightPanelTone.neutral,
    );
  }
}

enum _ComponentMaturity {
  stable,
  comingSoon,
  planned,
}

class _MaturityBadge extends StatelessWidget {
  const _MaturityBadge({
    required this.label,
    required this.status,
  });

  final String label;
  final _ComponentMaturity status;

  @override
  Widget build(BuildContext context) {
    final Color accentColor =
    switch (status) {
      _ComponentMaturity.stable =>
      AtlasColors.success,
      _ComponentMaturity.comingSoon =>
      AtlasColors.vaultGold,
      _ComponentMaturity.planned =>
      AtlasColors.textSecondary,
    };

    final IconData icon =
    switch (status) {
      _ComponentMaturity.stable =>
      Icons.check_circle_outline_rounded,
      _ComponentMaturity.comingSoon =>
      Icons.upcoming_outlined,
      _ComponentMaturity.planned =>
      Icons.schedule_rounded,
    };

    return AtlasStatusChip(
      label: label,
      icon: icon,
      accentColor: accentColor,
      size: AtlasStatusChipSize.compact,
    );
  }
}