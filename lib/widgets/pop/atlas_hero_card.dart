import 'package:flutter/material.dart';

import '../../../atlas/hero/models/atlas_hero_summary.dart';

class AtlasHeroCard extends StatelessWidget {
  const AtlasHeroCard({
    super.key,
    required this.summary,
    this.onViewScoreDetails,
  });

  final AtlasHeroSummary summary;

  /// Optional action that can later open a score explanation sheet.
  final VoidCallback? onViewScoreDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final normalizedScore = summary.normalizedScore;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroHeader(
              emoji: summary.primaryEmoji,
              classification: summary.classification,
              scoreLabel: summary.scoreLabel,
            ),
            const SizedBox(height: 20),
            _CollectorScoreSection(
              score: normalizedScore,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 20),
            Text(
              summary.headline,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              summary.summary,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            if (summary.hasScoreReasons) ...[
              const SizedBox(height: 20),
              _SectionLabel(
                icon: Icons.auto_awesome_rounded,
                label: 'Why it stands out',
                color: colorScheme.primary,
              ),
              const SizedBox(height: 10),
              ...summary.scoreReasons.take(4).map(
                    (reason) => _HeroDetailRow(
                  icon: Icons.add_circle_outline_rounded,
                  text: reason,
                  iconColor: colorScheme.primary,
                ),
              ),
            ],
            if (summary.hasImprovementSuggestions) ...[
              const SizedBox(height: 20),
              _SectionLabel(
                icon: Icons.lightbulb_outline_rounded,
                label: 'Strengthen this profile',
                color: colorScheme.secondary,
              ),
              const SizedBox(height: 10),
              ...summary.improvementSuggestions.take(3).map(
                    (suggestion) => _HeroDetailRow(
                  icon: Icons.arrow_circle_up_rounded,
                  text: suggestion,
                  iconColor: colorScheme.secondary,
                ),
              ),
            ],
            if (onViewScoreDetails != null) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onViewScoreDetails,
                  icon: const Icon(
                    Icons.analytics_outlined,
                    size: 18,
                  ),
                  label: const Text('View score details'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.emoji,
    required this.classification,
    required this.scoreLabel,
  });

  final String emoji;
  final String classification;
  final String scoreLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 25),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                classification,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                scoreLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CollectorScoreSection extends StatelessWidget {
  const _CollectorScoreSection({
    required this.score,
    required this.colorScheme,
  });

  final int score;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Collector Score $score out of 100',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Collector Score',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$score',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    TextSpan(
                      text: ' / 100',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 9,
              backgroundColor: colorScheme.surfaceContainerHighest,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroDetailRow extends StatelessWidget {
  const _HeroDetailRow({
    required this.icon,
    required this.text,
    required this.iconColor,
  });

  final IconData icon;
  final String text;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              icon,
              size: 17,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}