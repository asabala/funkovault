import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';
import '../../theme/atlas_icons.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../atlas/atlas_section_card.dart';

class TodayMemoryCard extends StatelessWidget {
  const TodayMemoryCard({
    super.key,
    required this.title,
    required this.message,
    required this.footer,
  });

  final String title;
  final String message;
  final String footer;

  @override
  Widget build(BuildContext context) {
    return AtlasSectionCard(
      title: 'Today in Your Collection',
      icon: AtlasIcons.timeline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AtlasTypography.headingSmall,
          ),

          const SizedBox(height: AtlasSpacing.sm),

          Text(
            message,
            style: AtlasTypography.bodyMedium,
          ),

          const SizedBox(height: AtlasSpacing.md),

          Text(
            footer,
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.vaultGold,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}