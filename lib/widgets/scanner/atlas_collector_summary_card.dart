import 'package:flutter/material.dart';

import 'package:funkovault2/atlas/intelligence/models/atlas_collector_summary.dart';

class AtlasCollectorSummaryCard extends StatelessWidget {
  const AtlasCollectorSummaryCard({
    required this.summary,
    required this.imageUrl,
    super.key,
  });

  final AtlasCollectorSummary summary;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          18,
          18,
          18,
          20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProductImage(
              imageUrl: imageUrl,
            ),
            const SizedBox(
              height: 12,
            ),
            Text(
              summary.productName,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (summary.productNumber.isNotEmpty) ...[
              const SizedBox(
                height: 4,
              ),
              Text(
                '#${summary.productNumber}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.center,
              child: Chip(
                avatar: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 18,
                ),
                label: Text(
                  summary.variantLabel,
                ),
              ),
            ),
            const Divider(
              height: 32,
            ),
            Row(
              children: [
                Expanded(
                  child: _SummaryMetric(
                    icon: Icons.attach_money_rounded,
                    label: 'Estimated Market Value',
                    value: summary.formattedMarketValue,
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: _SummaryMetric(
                    icon: _trendIcon,
                    label: 'Trend',
                    value: summary.formattedTrend,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            Row(
              children: [
                Expanded(
                  child: _SummaryMetric(
                    icon: Icons.inventory_2_outlined,
                    label: 'Owned',
                    value: summary.formattedOwnership,
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: _SummaryMetric(
                    icon: Icons.collections_bookmark_outlined,
                    label: 'Collection',
                    value: summary.collectionName,
                  ),
                ),
              ],
            ),
            const Divider(
              height: 32,
            ),
            _RecommendationSection(
              title: summary.recommendation,
              message: summary.recommendationMessage,
              icon: _recommendationIcon,
            ),
          ],
        ),
      ),
    );
  }

  IconData get _trendIcon {
    final double? trend = summary.trendPercent;

    if (trend == null || !trend.isFinite) {
      return Icons.horizontal_rule_rounded;
    }

    if (trend > 0) {
      return Icons.trending_up_rounded;
    }

    if (trend < 0) {
      return Icons.trending_down_rounded;
    }

    return Icons.trending_flat_rounded;
  }

  IconData get _recommendationIcon {
    switch (summary.recommendation) {
      case 'Already Owned':
        return Icons.verified_rounded;

      case 'Review Variant':
        return Icons.compare_arrows_rounded;

      case 'Market Value Unavailable':
        return Icons.price_check_outlined;

      case 'New to Vault':
        return Icons.add_box_outlined;

      default:
        return Icons.auto_awesome_rounded;
    }
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final String normalizedImageUrl = imageUrl.trim();

    return SizedBox(
      height: 285,
      child: normalizedImageUrl.isEmpty
          ? const _ImagePlaceholder()
          : Image.network(
        normalizedImageUrl,
        width: double.infinity,
        height: 285,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (
            BuildContext context,
            Object error,
            StackTrace? stackTrace,
            ) {
          return const _ImagePlaceholder();
        },
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 72,
          ),
          SizedBox(
            height: 12,
          ),
          Text(
            'Product image unavailable',
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(
        minHeight: 108,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.dividerColor,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _RecommendationSection extends StatelessWidget {
  const _RecommendationSection({
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 30,
        ),
        const SizedBox(
          width: 12,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Atlas Recommendation',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                message,
              ),
            ],
          ),
        ),
      ],
    );
  }
}