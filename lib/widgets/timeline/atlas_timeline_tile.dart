import 'package:flutter/material.dart';

import 'package:funkovault2/atlas/timeline/models/atlas_timeline_event.dart';
import 'package:funkovault2/theme/atlas_colors.dart';
import 'package:funkovault2/theme/atlas_spacing.dart';
import 'package:funkovault2/theme/atlas_typography.dart';

class AtlasTimelineTile extends StatelessWidget {
  const AtlasTimelineTile({
    super.key,
    required this.event,
    this.showConnector = true,
  });

  final AtlasTimelineEvent event;
  final bool showConnector;

  @override
  Widget build(BuildContext context) {
    final detail = _buildEventDetail(event);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 42,
            child: Column(
              children: [
                _TimelineIcon(
                  icon: _iconForType(event.type),
                  isAtlasInsight:
                  event.type == AtlasTimelineEventType.aiInsight,
                ),
                if (showConnector)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.only(
                        top: AtlasSpacing.xs,
                      ),
                      color: AtlasColors.vaultGold.withValues(
                        alpha: 0.22,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AtlasSpacing.sm),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: showConnector
                    ? AtlasSpacing.lg
                    : AtlasSpacing.sm,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(
                  AtlasSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surface
                      .withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AtlasColors.vaultGold.withValues(
                      alpha: 0.16,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            event.title.trim().isEmpty
                                ? event.type.label
                                : event.title,
                            style: AtlasTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: AtlasSpacing.sm),
                        Text(
                          _formatDate(event.occurredAt),
                          textAlign: TextAlign.right,
                          style: AtlasTypography.bodySmall.copyWith(
                            color: AtlasColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (event.hasDescription) ...[
                      const SizedBox(height: AtlasSpacing.sm),
                      Text(
                        event.description,
                        style: AtlasTypography.bodySmall.copyWith(
                          color: AtlasColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                    if (detail != null) ...[
                      const SizedBox(height: AtlasSpacing.sm),
                      detail,
                    ],
                    const SizedBox(height: AtlasSpacing.sm),
                    _CreatedByLabel(
                      createdBy: event.createdBy,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget? _buildEventDetail(
      AtlasTimelineEvent event,
      ) {
    switch (event.type) {
      case AtlasTimelineEventType.valueUpdated:
        return _ValueChangeDetail(
          previousValue: _readDouble(
            event.metadata['previousValue'],
          ),
          newValue: _readDouble(
            event.metadata['newValue'],
          ),
          source: event.metadata['source']?.toString(),
        );

      case AtlasTimelineEventType.purchased:
        return _MetadataDetail(
          rows: [
            _MetadataRow(
              label: 'Price Paid',
              value: _formatCurrencyValue(
                event.metadata['pricePaid'],
              ),
            ),
            _MetadataRow(
              label: 'Store',
              value: event.metadata['store']?.toString(),
            ),
          ],
        );

      case AtlasTimelineEventType.sold:
        return _MetadataDetail(
          rows: [
            _MetadataRow(
              label: 'Sale Price',
              value: _formatCurrencyValue(
                event.metadata['salePrice'],
              ),
            ),
            _MetadataRow(
              label: 'Platform',
              value: event.metadata['platform']?.toString(),
            ),
          ],
        );

      case AtlasTimelineEventType.convention:
        return _MetadataDetail(
          rows: [
            _MetadataRow(
              label: 'Convention',
              value:
              event.metadata['conventionName']?.toString(),
            ),
            _MetadataRow(
              label: 'Location',
              value: event.metadata['location']?.toString(),
            ),
          ],
        );

      default:
        return null;
    }
  }

  static IconData _iconForType(
      AtlasTimelineEventType type,
      ) {
    switch (type) {
      case AtlasTimelineEventType.addedToVault:
        return Icons.inventory_2_rounded;

      case AtlasTimelineEventType.valueUpdated:
        return Icons.trending_up_rounded;

      case AtlasTimelineEventType.purchased:
        return Icons.shopping_bag_rounded;

      case AtlasTimelineEventType.sold:
        return Icons.sell_rounded;

      case AtlasTimelineEventType.traded:
        return Icons.swap_horiz_rounded;

      case AtlasTimelineEventType.photoAdded:
        return Icons.add_photo_alternate_rounded;

      case AtlasTimelineEventType.noteAdded:
        return Icons.note_alt_rounded;

      case AtlasTimelineEventType.signatureAdded:
        return Icons.draw_rounded;

      case AtlasTimelineEventType.convention:
        return Icons.event_rounded;

      case AtlasTimelineEventType.collectorMoment:
        return Icons.auto_awesome_rounded;

      case AtlasTimelineEventType.displayLocationChanged:
        return Icons.location_on_rounded;

      case AtlasTimelineEventType.itemConditionChanged:
        return Icons.fact_check_rounded;

      case AtlasTimelineEventType.boxConditionChanged:
        return Icons.inventory_rounded;

      case AtlasTimelineEventType.stickerChanged:
        return Icons.local_offer_rounded;

      case AtlasTimelineEventType.variantChanged:
        return Icons.change_circle_rounded;

      case AtlasTimelineEventType.protectorAdded:
        return Icons.shield_rounded;

      case AtlasTimelineEventType.aiInsight:
        return Icons.psychology_rounded;

      case AtlasTimelineEventType.custom:
        return Icons.timeline_rounded;
    }
  }

  static String _formatDate(
      DateTime value,
      ) {
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

  static double? _readDouble(
      dynamic value,
      ) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value?.toString().trim() ?? '',
    );
  }

  static String? _formatCurrencyValue(
      dynamic value,
      ) {
    final amount = _readDouble(value);

    if (amount == null) {
      return null;
    }

    return '\$${amount.toStringAsFixed(2)}';
  }
}

class _TimelineIcon extends StatelessWidget {
  const _TimelineIcon({
    required this.icon,
    required this.isAtlasInsight,
  });

  final IconData icon;
  final bool isAtlasInsight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AtlasColors.vaultGold.withValues(
          alpha: isAtlasInsight ? 0.24 : 0.14,
        ),
        border: Border.all(
          color: AtlasColors.vaultGold.withValues(
            alpha: isAtlasInsight ? 0.72 : 0.38,
          ),
        ),
      ),
      child: Icon(
        icon,
        size: 20,
        color: AtlasColors.vaultGold,
      ),
    );
  }
}

class _ValueChangeDetail extends StatelessWidget {
  const _ValueChangeDetail({
    required this.previousValue,
    required this.newValue,
    required this.source,
  });

  final double? previousValue;
  final double? newValue;
  final String? source;

  @override
  Widget build(BuildContext context) {
    final hasValueChange =
        previousValue != null || newValue != null;

    if (!hasValueChange &&
        (source == null || source!.trim().isEmpty)) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AtlasSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AtlasColors.vaultGold.withValues(
          alpha: 0.08,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasValueChange)
            Text(
              '${_formatCurrency(previousValue)} → '
                  '${_formatCurrency(newValue)}',
              style: AtlasTypography.bodyMedium.copyWith(
                color: AtlasColors.vaultGold,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (source != null && source!.trim().isNotEmpty) ...[
            if (hasValueChange)
              const SizedBox(height: AtlasSpacing.xs),
            Text(
              'Source: ${_formatSource(source!)}',
              style: AtlasTypography.bodySmall.copyWith(
                color: AtlasColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _formatCurrency(
      double? value,
      ) {
    if (value == null) {
      return 'Not set';
    }

    return '\$${value.toStringAsFixed(2)}';
  }

  static String _formatSource(
      String value,
      ) {
    final normalized = value
        .trim()
        .replaceAll('_', ' ')
        .replaceAll('-', ' ');

    if (normalized.isEmpty) {
      return 'Unknown';
    }

    return normalized
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map(
          (word) =>
      '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
    )
        .join(' ');
  }
}

class _MetadataDetail extends StatelessWidget {
  const _MetadataDetail({
    required this.rows,
  });

  final List<_MetadataRow> rows;

  @override
  Widget build(BuildContext context) {
    final visibleRows = rows
        .where(
          (row) =>
      row.value != null &&
          row.value!.trim().isNotEmpty,
    )
        .toList();

    if (visibleRows.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AtlasSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AtlasColors.vaultGold.withValues(
          alpha: 0.08,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (var index = 0;
          index < visibleRows.length;
          index++) ...[
            _MetadataLine(
              label: visibleRows[index].label,
              value: visibleRows[index].value!,
            ),
            if (index < visibleRows.length - 1)
              const SizedBox(height: AtlasSpacing.xs),
          ],
        ],
      ),
    );
  }
}

class _MetadataRow {
  const _MetadataRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String? value;
}

class _MetadataLine extends StatelessWidget {
  const _MetadataLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: AtlasSpacing.sm),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AtlasTypography.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _CreatedByLabel extends StatelessWidget {
  const _CreatedByLabel({
    required this.createdBy,
  });

  final String createdBy;

  @override
  Widget build(BuildContext context) {
    final label = _labelForCreatedBy(createdBy);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _iconForCreatedBy(createdBy),
          size: 14,
          color: AtlasColors.textSecondary,
        ),
        const SizedBox(width: AtlasSpacing.xs),
        Text(
          label,
          style: AtlasTypography.bodySmall.copyWith(
            color: AtlasColors.textSecondary,
          ),
        ),
      ],
    );
  }

  static String _labelForCreatedBy(
      String value,
      ) {
    switch (value.trim().toLowerCase()) {
      case AtlasTimelineEvent.systemCreatedBy:
        return 'Recorded automatically';

      case AtlasTimelineEvent.importCreatedBy:
        return 'Added by import';

      case AtlasTimelineEvent.atlasAiCreatedBy:
        return 'Created by Atlas AI';

      case AtlasTimelineEvent.manualCreatedBy:
      default:
        return 'Added manually';
    }
  }

  static IconData _iconForCreatedBy(
      String value,
      ) {
    switch (value.trim().toLowerCase()) {
      case AtlasTimelineEvent.systemCreatedBy:
        return Icons.settings_rounded;

      case AtlasTimelineEvent.importCreatedBy:
        return Icons.file_download_rounded;

      case AtlasTimelineEvent.atlasAiCreatedBy:
        return Icons.auto_awesome_rounded;

      case AtlasTimelineEvent.manualCreatedBy:
      default:
        return Icons.person_outline_rounded;
    }
  }
}