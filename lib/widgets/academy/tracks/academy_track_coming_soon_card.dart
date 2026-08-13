import 'package:flutter/material.dart';

import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';
import '../../atlas/atlas_glass_card.dart';
import '../../atlas/components/atlas_action_row.dart';
import '../../atlas/components/atlas_info_banner.dart';
import '../../atlas/components/atlas_section_header.dart';
import '../../atlas/components/atlas_status_chip.dart';

class AcademyTrackComingSoonCard extends StatelessWidget {
  const AcademyTrackComingSoonCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.icon,
    required this.onNotifyTap,
  });

  final String title;
  final String subtitle;
  final String status;
  final IconData icon;
  final VoidCallback onNotifyTap;

  @override
  Widget build(BuildContext context) {
    final String cleanedTitle = title.trim();
    final String cleanedSubtitle = subtitle.trim();
    final String cleanedStatus = status.trim();

    return AtlasGlassCard(
      accentColor: AtlasColors.vaultGold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AtlasSectionHeader(
            title: cleanedTitle.isEmpty ? 'Academy Track' : cleanedTitle,
            subtitle: cleanedSubtitle.isEmpty
                ? 'This Academy learning path is planned for a future release.'
                : cleanedSubtitle,
            icon: icon,
            accentColor: AtlasColors.vaultGold,
            badge: AtlasStatusChip(
              label: cleanedStatus.isEmpty ? 'Coming Soon' : cleanedStatus,
              icon: Icons.schedule_rounded,
              accentColor: AtlasColors.vaultGold,
              size: AtlasStatusChipSize.compact,
            ),
          ),
          const SizedBox(height: AtlasSpacing.lg),
          const AtlasInfoBanner(
            icon: Icons.auto_awesome_rounded,
            title: 'Built One Track at a Time',
            message:
                'Atlas Academy expands one collectible category at a time so lessons stay useful, accurate, and collector-first.',
          ),
          const SizedBox(height: AtlasSpacing.lg),
          AtlasActionRow(
            title: 'Request This Track',
            description: 'Add this learning path to the Academy request queue.',
            icon: Icons.notifications_active_rounded,
            accentColor: AtlasColors.vaultGold,
            onTap: onNotifyTap,
          ),
        ],
      ),
    );
  }
}
