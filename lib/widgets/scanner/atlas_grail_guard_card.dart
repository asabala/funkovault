import 'package:flutter/material.dart';

import '../../atlas/scan/authenticity/policies/inspection_recommendation_policy.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../atlas/atlas_glass_panel.dart';
import '../atlas/components/atlas_status_chip.dart';

class AtlasGrailGuardCard extends StatelessWidget {
  const AtlasGrailGuardCard({
    super.key,
    required this.recommendation,
    required this.hasCompletedInspection,
  });

  final AtlasInspectionRecommendation recommendation;
  final bool hasCompletedInspection;

  @override
  Widget build(BuildContext context) {
    if (!recommendation.isRecommended) {
      return const SizedBox.shrink();
    }

    final Color accentColor = hasCompletedInspection
        ? AtlasColors.success
        : AtlasColors.vaultGold;

    return AtlasGlassPanel(
      accentColor: accentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, color: accentColor),
              const SizedBox(width: AtlasSpacing.sm),
              Expanded(
                child: Text(
                  recommendation.badgeLabel ?? '🛡️ Grail Guard',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              AtlasStatusChip(
                label: hasCompletedInspection ? 'Inspected' : 'Recommended',
                icon: hasCompletedInspection
                    ? Icons.task_alt_rounded
                    : Icons.manage_search_rounded,
                accentColor: accentColor,
              ),
            ],
          ),
          if (recommendation.explanation?.trim().isNotEmpty == true) ...[
            const SizedBox(height: AtlasSpacing.sm),
            Text(recommendation.explanation!.trim()),
          ],
          if (recommendation.reasons.isNotEmpty) ...[
            const SizedBox(height: AtlasSpacing.sm),
            Wrap(
              spacing: AtlasSpacing.xs,
              runSpacing: AtlasSpacing.xs,
              children: recommendation.reasons
                  .map(
                    (String reason) => AtlasStatusChip(
                      label: reason,
                      icon: Icons.info_outline_rounded,
                      accentColor: AtlasColors.intelligenceBlue,
                      size: AtlasStatusChipSize.compact,
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
          const SizedBox(height: AtlasSpacing.sm),
          Text(
            'Grail Guard recommends additional inspection; it does not determine whether an item is authentic or counterfeit.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AtlasColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
