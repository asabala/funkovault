import 'package:flutter/material.dart';

import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_typography.dart';
import '../../atlas/components/atlas_section_header.dart';

class AcademyHeroHeader extends StatelessWidget {
  const AcademyHeroHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final String cleanedTitle = title.trim();
    final String cleanedSubtitle = subtitle.trim();

    return AtlasSectionHeader(
      title: cleanedTitle.isEmpty
          ? 'Atlas Academy'
          : cleanedTitle,
      subtitle: cleanedSubtitle.isEmpty
          ? 'Learn collector knowledge, strategy, and terminology inside Atlas.'
          : cleanedSubtitle,
      icon: Icons.school_rounded,
      accentColor: AtlasColors.vaultGold,
      titleStyle: AtlasTypography.headingLarge,
    );
  }
}