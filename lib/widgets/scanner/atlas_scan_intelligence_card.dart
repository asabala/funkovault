import 'package:flutter/material.dart';

import '../../atlas/intelligence/models/atlas_scan_intelligence.dart';

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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.psychology_alt_rounded,
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    'Atlas Intelligence',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _InsightCountBadge(
                  count: intelligence.insightCount,
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            for (int index = 0;
            index < intelligence.insights.length;
            index++) ...[
              _AtlasScanInsightTile(
                insight: intelligence.insights[index],
              ),
              if (index < intelligence.insights.length - 1)
                const Divider(
                  height: 28,
                ),
            ],
          ],
        ),
      ),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          _iconForInsight(insight),
          size: 28,
        ),
        const SizedBox(
          width: 12,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                insight.title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                insight.message,
              ),
              if (insight.hasDetails) ...[
                const SizedBox(
                  height: 10,
                ),
                for (final String detail in insight.details)
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 4,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• '),
                        Expanded(
                          child: Text(detail),
                        ),
                      ],
                    ),
                  ),
              ],
              if (insight.hasRecommendation) ...[
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Recommendation',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  insight.recommendation!,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  IconData _iconForInsight(
      AtlasScanInsight insight,
      ) {
    switch (insight.type) {
      case AtlasScanInsightType.identity:
        return Icons.fingerprint_rounded;

      case AtlasScanInsightType.collection:
        return Icons.inventory_2_outlined;

      case AtlasScanInsightType.variant:
        return Icons.auto_awesome_rounded;

      case AtlasScanInsightType.market:
        return Icons.show_chart_rounded;

      case AtlasScanInsightType.recommendation:
        return Icons.lightbulb_outline_rounded;

      case AtlasScanInsightType.warning:
        return insight.priority ==
            AtlasScanInsightPriority.critical
            ? Icons.error_outline_rounded
            : Icons.warning_amber_rounded;
    }
  }
}

class _InsightCountBadge extends StatelessWidget {
  const _InsightCountBadge({
    required this.count,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Text(
        '$count',
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}