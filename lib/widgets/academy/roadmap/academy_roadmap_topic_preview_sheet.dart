import 'package:flutter/material.dart';

import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';
import '../../atlas/atlas_glass_card.dart';
import '../../atlas/components/atlas_info_banner.dart';
import '../../atlas/components/atlas_section_header.dart';
import '../../premium/premium_badge.dart';
import '../shared/academy_premium_insight_card.dart';

class AcademyRoadmapTopicPreviewSheet extends StatelessWidget {
  const AcademyRoadmapTopicPreviewSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isPremium,
  });

  final String title;
  final String subtitle;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final String cleanedTitle = title.trim();

    final String cleanedSubtitle = subtitle.trim();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AtlasSpacing.md,
          AtlasSpacing.sm,
          AtlasSpacing.md,
          AtlasSpacing.xl,
        ),
        child: AtlasGlassCard(
          accentColor: isPremium
              ? AtlasColors.vaultGold
              : AtlasColors.intelligenceBlue,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AtlasSectionHeader(
                title: cleanedTitle.isEmpty
                    ? 'Academy Roadmap Topic'
                    : cleanedTitle,
                subtitle: cleanedSubtitle.isEmpty
                    ? 'More details for this Academy topic are coming soon.'
                    : cleanedSubtitle,
                icon: isPremium
                    ? Icons.workspace_premium_rounded
                    : Icons.route_rounded,
                accentColor: isPremium
                    ? AtlasColors.vaultGold
                    : AtlasColors.intelligenceBlue,
                badge: isPremium
                    ? const PremiumBadge()
                    : null,
              ),
              const SizedBox(
                height: AtlasSpacing.lg,
              ),
              if (isPremium)
                const AcademyPremiumInsightCard()
              else
                const AtlasInfoBanner(
                  icon: Icons.schedule_rounded,
                  title: 'Roadmap Topic',
                  message:
                  'This topic is planned for a future Atlas Academy lesson.',
                ),
            ],
          ),
        ),
      ),
    );
  }
}