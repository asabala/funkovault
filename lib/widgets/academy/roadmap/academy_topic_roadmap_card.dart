import 'package:flutter/material.dart';

import '../../../academy/models/academy_topic.dart';
import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';
import '../../../theme/atlas_typography.dart';
import '../../atlas/atlas_glass_card.dart';
import '../../atlas/atlas_glass_panel.dart';

class AcademyTopicRoadmapCard extends StatelessWidget {
  const AcademyTopicRoadmapCard({
    super.key,
    required this.topic,
    required this.onTap,
  });

  final AcademyTopic topic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: AtlasGlassPanel(
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AtlasSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopicStatusIcon(
                  isPremium: topic.isPremium,
                  isAvailable: topic.isAvailable,
                ),
                const SizedBox(width: AtlasSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: AtlasSpacing.sm,
                        runSpacing: AtlasSpacing.xs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            topic.title,
                            style: AtlasTypography.headingSmall,
                          ),
                          if (topic.isPremium)
                            const _TopicBadge(
                              label: 'Premium',
                              icon: Icons.workspace_premium,
                            ),
                        ],
                      ),
                      const SizedBox(height: AtlasSpacing.xs),
                      Text(
                        topic.subtitle,
                        style: AtlasTypography.bodySmall.copyWith(
                          color: AtlasColors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: AtlasSpacing.sm),
                      Text(
                        topic.category,
                        style: AtlasTypography.label.copyWith(
                          color: AtlasColors.vaultGold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AtlasSpacing.sm),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AtlasColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopicStatusIcon extends StatelessWidget {
  const _TopicStatusIcon({
    required this.isPremium,
    required this.isAvailable,
  });

  final bool isPremium;
  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    final icon = isPremium
        ? Icons.workspace_premium
        : isAvailable
        ? Icons.check_circle_outline
        : Icons.auto_stories_outlined;

    final color = isPremium
        ? AtlasColors.vaultGold
        : isAvailable
        ? AtlasColors.success
        : AtlasColors.intelligenceBlue;

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        icon,
        color: color,
      ),
    );
  }
}

class _TopicBadge extends StatelessWidget {
  const _TopicBadge({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AtlasColors.vaultGold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AtlasColors.vaultGold.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: AtlasColors.vaultGold,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AtlasTypography.label.copyWith(
              color: AtlasColors.vaultGold,
            ),
          ),
        ],
      ),
    );
  }
}