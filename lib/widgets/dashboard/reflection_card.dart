import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';
import '../../theme/atlas_icons.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../atlas_section_card.dart';

class ReflectionCard extends StatelessWidget {
  const ReflectionCard({
    super.key,
    required this.title,
    required this.message,
    required this.tone,
  });

  final String title;
  final String message;
  final String tone;

  @override
  Widget build(BuildContext context) {
    return AtlasSectionCard(
      title: title,
      icon: AtlasIcons.atlas,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: AtlasTypography.bodyMedium,
          ),
          const SizedBox(height: AtlasSpacing.md),
          Text(
            _quoteForTone(),
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.vaultGold,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  String _quoteForTone() {
    switch (tone) {
      case 'reflection':
        return 'Every collection has a story worth remembering.';
      case 'guidance':
        return 'Small updates today create stronger insights tomorrow.';
      case 'morning':
        return 'Today’s mission is waiting.';
      default:
        return 'Atlas is ready.';
    }
  }
}