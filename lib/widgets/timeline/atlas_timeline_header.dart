import 'package:flutter/material.dart';

import 'package:funkovault2/atlas/timeline/models/atlas_timeline_summary.dart';
import 'package:funkovault2/theme/atlas_colors.dart';
import 'package:funkovault2/theme/atlas_spacing.dart';
import 'package:funkovault2/theme/atlas_typography.dart';
import 'package:funkovault2/widgets/atlas/atlas_glass_panel.dart';

class AtlasTimelineHeader extends StatelessWidget {
  const AtlasTimelineHeader({
    super.key,
    required this.summary,
  });

  final AtlasTimelineSummary summary;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.timeline_rounded,
                color: AtlasColors.vaultGold,
              ),
              const SizedBox(width: AtlasSpacing.sm),
              Expanded(
                child: Text(
                  'Timeline',
                  style: AtlasTypography.headingSmall,
                ),
              ),
              _EventCountBadge(
                count: summary.totalEvents,
              ),
            ],
          ),
          const SizedBox(height: AtlasSpacing.md),
          if (summary.totalEvents == 0)
            Text(
              'No Timeline events recorded yet.',
              style: AtlasTypography.bodySmall.copyWith(
                color: AtlasColors.textSecondary,
              ),
            )
          else
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _TimelineSummaryItem(
                        label: 'First Event',
                        value: _formatDate(
                          summary.firstEvent?.occurredAt,
                        ),
                      ),
                    ),
                    const SizedBox(width: AtlasSpacing.md),
                    Expanded(
                      child: _TimelineSummaryItem(
                        label: 'Latest Activity',
                        value: _formatDate(
                          summary.latestEvent?.occurredAt,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AtlasSpacing.md),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _TimelineSummaryItem(
                    label: 'Collector History',
                    value: _historyDurationLabel(
                      firstEvent:
                      summary.firstEvent?.occurredAt,
                      latestEvent:
                      summary.latestEvent?.occurredAt,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  static String _formatDate(
      DateTime? value,
      ) {
    if (value == null) {
      return 'Not available';
    }

    final localDate = value.toLocal();

    const monthNames = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final month = monthNames[localDate.month - 1];

    return '$month ${localDate.day}, ${localDate.year}';
  }

  static String _historyDurationLabel({
    required DateTime? firstEvent,
    required DateTime? latestEvent,
  }) {
    if (firstEvent == null || latestEvent == null) {
      return 'Not available';
    }

    final first = firstEvent.toLocal();
    final latest = latestEvent.toLocal();

    if (latest.isBefore(first)) {
      return 'Not available';
    }

    final firstDate = DateTime(
      first.year,
      first.month,
      first.day,
    );

    final latestDate = DateTime(
      latest.year,
      latest.month,
      latest.day,
    );

    final totalDays =
        latestDate.difference(firstDate).inDays;

    if (totalDays <= 0) {
      return 'Started today';
    }

    var totalMonths =
        (latestDate.year - firstDate.year) * 12 +
            latestDate.month -
            firstDate.month;

    if (latestDate.day < firstDate.day) {
      totalMonths--;
    }

    if (totalMonths >= 12) {
      final years = totalMonths ~/ 12;
      final remainingMonths = totalMonths % 12;

      final yearLabel =
          '$years ${years == 1 ? 'year' : 'years'}';

      if (remainingMonths == 0) {
        return yearLabel;
      }

      final monthLabel =
          '$remainingMonths '
          '${remainingMonths == 1 ? 'month' : 'months'}';

      return '$yearLabel, $monthLabel';
    }

    if (totalMonths >= 1) {
      return '$totalMonths '
          '${totalMonths == 1 ? 'month' : 'months'}';
    }

    if (totalDays == 1) {
      return '1 day';
    }

    return '$totalDays days';
  }
}

class _EventCountBadge extends StatelessWidget {
  const _EventCountBadge({
    required this.count,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AtlasSpacing.sm,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AtlasColors.vaultGold.withValues(
          alpha: 0.14,
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AtlasColors.vaultGold.withValues(
            alpha: 0.36,
          ),
        ),
      ),
      child: Text(
        '$count Timeline ${count == 1 ? 'Event' : 'Events'}',
        style: AtlasTypography.bodySmall.copyWith(
          color: AtlasColors.vaultGold,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _TimelineSummaryItem extends StatelessWidget {
  const _TimelineSummaryItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AtlasTypography.bodySmall.copyWith(
            color: AtlasColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AtlasSpacing.xs),
        Text(
          value,
          style: AtlasTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}