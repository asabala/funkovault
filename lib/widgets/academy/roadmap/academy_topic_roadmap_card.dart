import 'package:flutter/material.dart';

import '../../../academy/models/academy_topic.dart';
import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';
import '../../../theme/atlas_typography.dart';
import '../../atlas/atlas_glass_card.dart';
import '../../atlas/components/atlas_status_chip.dart';

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
    final Color accentColor = _accentColorForTopic(
      topic,
    );

    return AtlasGlassCard(
      onTap: onTap,
      accentColor: accentColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TopicStatusIcon(
            isPremium: topic.isPremium,
            isAvailable: topic.isAvailable,
          ),
          const SizedBox(
            width: AtlasSpacing.md,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  topic.title,
                  style: AtlasTypography.headingSmall,
                ),
                const SizedBox(
                  height: AtlasSpacing.xs,
                ),
                Text(
                  topic.subtitle,
                  style: AtlasTypography.bodySmall.copyWith(
                    color: AtlasColors.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(
                  height: AtlasSpacing.sm,
                ),
                Wrap(
                  spacing: AtlasSpacing.sm,
                  runSpacing: AtlasSpacing.sm,
                  children: [
                    AtlasStatusChip(
                      label: topic.category,
                      icon: Icons.category_outlined,
                      accentColor:
                      AtlasColors.vaultGold,
                      size:
                      AtlasStatusChipSize.compact,
                    ),
                    AtlasStatusChip(
                      label: _statusLabel(
                        topic,
                      ),
                      icon: _statusIcon(
                        topic,
                      ),
                      accentColor:
                      accentColor,
                      size:
                      AtlasStatusChipSize.compact,
                    ),
                    if (topic.isPremium)
                      const AtlasStatusChip(
                        label: 'Premium',
                        icon: Icons
                            .workspace_premium_rounded,
                        accentColor:
                        AtlasColors.vaultGold,
                        size:
                        AtlasStatusChipSize.compact,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            width: AtlasSpacing.sm,
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AtlasColors.textSecondary,
          ),
        ],
      ),
    );
  }

  static String _statusLabel(
      AcademyTopic topic,
      ) {
    if (topic.isAvailable) {
      return 'Available';
    }

    return 'Roadmap';
  }

  static IconData _statusIcon(
      AcademyTopic topic,
      ) {
    if (topic.isAvailable) {
      return Icons.check_circle_outline_rounded;
    }

    return Icons.schedule_rounded;
  }

  static Color _accentColorForTopic(
      AcademyTopic topic,
      ) {
    if (topic.isPremium) {
      return AtlasColors.vaultGold;
    }

    if (topic.isAvailable) {
      return AtlasColors.success;
    }

    return AtlasColors.intelligenceBlue;
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
    final IconData icon;

    final Color color;

    if (isPremium) {
      icon = Icons.workspace_premium_rounded;
      color = AtlasColors.vaultGold;
    } else if (isAvailable) {
      icon = Icons.check_circle_outline_rounded;
      color = AtlasColors.success;
    } else {
      icon = Icons.auto_stories_outlined;
      color = AtlasColors.intelligenceBlue;
    }

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.14,
        ),
        borderRadius: BorderRadius.circular(
          16,
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        color: color,
      ),
    );
  }
}