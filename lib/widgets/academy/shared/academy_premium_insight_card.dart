import 'package:flutter/material.dart';

import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';
import '../../atlas/atlas_glass_card.dart';
import '../../atlas/components/atlas_info_banner.dart';
import '../../atlas/components/atlas_section_header.dart';
import '../../premium/premium_badge.dart';

class AcademyPremiumInsightCard extends StatelessWidget {
  const AcademyPremiumInsightCard({
    super.key,
    this.title = 'Premium Insight',
    this.message =
        'Atlas Premium can connect this topic to deeper collector intelligence, personalization, value context, and smarter collection decisions.',
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final String cleanedTitle = title.trim();
    final String cleanedMessage = message.trim();

    return AtlasGlassCard(
      accentColor: AtlasColors.vaultGold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AtlasSectionHeader(
            title: cleanedTitle.isEmpty ? 'Premium Insight' : cleanedTitle,
            subtitle: 'Advanced Academy intelligence for Atlas Premium.',
            icon: Icons.workspace_premium_rounded,
            accentColor: AtlasColors.vaultGold,
            badge: const PremiumBadge(),
          ),
          const SizedBox(height: AtlasSpacing.md),
          AtlasInfoBanner(
            icon: Icons.auto_awesome_rounded,
            title: 'Premium Intelligence',
            message: cleanedMessage.isEmpty
                ? 'More Premium Academy intelligence is planned for this topic.'
                : cleanedMessage,
            accentColor: AtlasColors.vaultGold,
          ),
        ],
      ),
    );
  }
}
