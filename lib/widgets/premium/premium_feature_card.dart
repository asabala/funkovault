import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../atlas/atlas_glass_card.dart';
import '../atlas/components/atlas_action_row.dart';
import '../atlas/components/atlas_section_header.dart';
import 'premium_badge.dart';

class PremiumFeatureCard extends StatelessWidget {
  const PremiumFeatureCard({
    super.key,
    required this.title,
    required this.description,
    this.actionLabel = 'Upgrade to Premium',
    this.icon = Icons.workspace_premium_rounded,
    this.onAction,
  });

  final String title;
  final String description;
  final String actionLabel;
  final IconData icon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      accentColor: AtlasColors.vaultGold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AtlasSectionHeader(
            title: title,
            subtitle: description,
            icon: icon,
            accentColor: AtlasColors.vaultGold,
            badge: const PremiumBadge(),
          ),
          const SizedBox(height: AtlasSpacing.lg),
          AtlasActionRow(
            title: actionLabel,
            description:
                'Unlock this Premium feature and additional advanced Atlas tools.',
            icon: Icons.lock_open_rounded,
            accentColor: AtlasColors.vaultGold,
            onTap: onAction,
          ),
        ],
      ),
    );
  }
}
