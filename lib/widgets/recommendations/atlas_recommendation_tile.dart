import 'package:flutter/material.dart';

import '../../atlas/recommendations/models/atlas_recommendation.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../atlas/atlas_glass_panel.dart';
import '../atlas/components/atlas_status_chip.dart';

/// Reusable presentation for one completed Atlas recommendation.
///
/// This widget never determines recommendation priority or type. Those values
/// must already be supplied by AtlasRecommendationEngine.
class AtlasRecommendationTile extends StatelessWidget {
  const AtlasRecommendationTile({
    super.key,
    required this.recommendation,
    this.onAction,
    this.showAction = true,
    this.compact = false,
  });

  final AtlasRecommendation recommendation;

  /// The parent owns navigation and mutation behavior.
  final ValueChanged<AtlasRecommendation>? onAction;

  final bool showAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassPanel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PriorityIndicator(priorityName: recommendation.priority.name),
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
                        recommendation.title,
                        style: AtlasTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: AtlasSpacing.sm),
                    AtlasStatusChip(
                      label: _formatEnumName(recommendation.priority.name),
                      icon: _iconForPriority(recommendation.priority.name),
                      accentColor: AtlasColors.vaultGold,
                      size: AtlasStatusChipSize.compact,
                    ),
                  ],
                ),
                const SizedBox(height: AtlasSpacing.xs),
                Text(
                  recommendation.description,
                  style: AtlasTypography.bodySmall.copyWith(
                    color: AtlasColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(height: AtlasSpacing.sm),
                  _RecommendationReason(reason: recommendation.reason),
                ],
                if (showAction && onAction != null) ...[
                  const SizedBox(height: AtlasSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => onAction!(recommendation),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: Text(recommendation.actionLabel),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityIndicator extends StatelessWidget {
  const _PriorityIndicator({required this.priorityName});

  final String priorityName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AtlasColors.vaultGold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        _iconForPriority(priorityName),
        color: AtlasColors.vaultGold,
        size: 21,
      ),
    );
  }
}

class _RecommendationReason extends StatelessWidget {
  const _RecommendationReason({required this.reason});

  final String reason;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.psychology_alt_outlined,
          size: 17,
          color: AtlasColors.vaultGold,
        ),
        const SizedBox(width: AtlasSpacing.sm),
        Expanded(
          child: Text(
            reason,
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

IconData _iconForPriority(String priorityName) {
  switch (priorityName.toLowerCase()) {
    case 'critical':
      return Icons.warning_amber_rounded;
    case 'high':
      return Icons.priority_high_rounded;
    case 'medium':
      return Icons.insights_outlined;
    case 'low':
      return Icons.lightbulb_outline_rounded;
    default:
      return Icons.auto_awesome_rounded;
  }
}

String _formatEnumName(String value) {
  final cleaned = value.trim();

  if (cleaned.isEmpty) {
    return 'Recommendation';
  }

  return cleaned
      .replaceAllMapped(
        RegExp(r'([a-z])([A-Z])'),
        (match) => '${match.group(1)} ${match.group(2)}',
      )
      .split(RegExp(r'[_\s]+'))
      .where((word) => word.isNotEmpty)
      .map(
        (word) => '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
      )
      .join(' ');
}
