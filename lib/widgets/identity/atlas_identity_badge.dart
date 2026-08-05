import 'package:flutter/material.dart';

import 'package:funkovault2/atlas/identity/pop/pop_identity_rule.dart';
import 'package:funkovault2/theme/atlas_colors.dart';
import 'package:funkovault2/theme/atlas_spacing.dart';
import 'package:funkovault2/theme/atlas_typography.dart';

class AtlasIdentityBadge extends StatelessWidget {
  const AtlasIdentityBadge({
    required this.badge,
    super.key,
  });

  final PopIdentityBadgeData badge;

  @override
  Widget build(BuildContext context) {
    final Color accentColor = _accentColorFor(
      badge.id,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AtlasSpacing.md,
        vertical: AtlasSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: accentColor.withValues(
          alpha: 0.12,
        ),
        borderRadius: BorderRadius.circular(
          999,
        ),
        border: Border.all(
          color: accentColor.withValues(
            alpha: 0.38,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(
              alpha: 0.10,
            ),
            blurRadius: 12,
            offset: const Offset(
              0,
              5,
            ),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            badge.emoji,
            style: const TextStyle(
              fontSize: 15,
              height: 1,
            ),
          ),
          const SizedBox(
            width: AtlasSpacing.sm,
          ),
          Flexible(
            child: Text(
              badge.label,
              style: AtlasTypography.bodySmall.copyWith(
                color: AtlasColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _accentColorFor(
      String badgeId,
      ) {
    switch (badgeId.trim().toLowerCase()) {
      case 'chase':
        return AtlasColors.warning;

      case 'glow':
        return AtlasColors.success;

      case 'blacklight':
        return const Color(
          0xFF9B5DE5,
        );

      case 'diamond':
        return const Color(
          0xFF4DD0E1,
        );

      case 'flocked':
        return const Color(
          0xFFBCAAA4,
        );

      case 'metallic':
        return AtlasColors.atlasSilver;

      case 'scented':
        return const Color(
          0xFFF48FB1,
        );

      case 'art_series':
        return const Color(
          0xFFFF8A65,
        );

      case 'nft':
        return AtlasColors.intelligenceBlue;

      case 'translucent':
        return const Color(
          0xFF80DEEA,
        );

      case 'oversized':
        return const Color(
          0xFFFFB74D,
        );

      case 'vaulted':
        return AtlasColors.textSecondary;

      case 'bloody':
        return AtlasColors.danger;

      case 'pearlescent':
        return const Color(
          0xFFCE93D8,
        );

      case 'patina':
        return const Color(
          0xFF80CBC4,
        );

      case 'light_up':
        return const Color(
          0xFFFFD54F,
        );

      case 'sound':
        return const Color(
          0xFF7986CB,
        );

      case 'pop_cover':
        return const Color(
          0xFF9575CD,
        );

      case 'prototype':
        return const Color(
          0xFF26A69A,
        );

      case 'funko_shop':
      case 'retail_exclusive':
      case 'exclusive':
        return AtlasColors.intelligenceBlue;

      case 'event_sticker':
        return AtlasColors.danger;

      case 'grail':
        return AtlasColors.vaultGold;

      case 'limited_edition':
        return const Color(
          0xFF7E57C2,
        );

      case 'signed':
        return const Color(
          0xFFFFCA28,
        );

      case 'wishlist':
        return const Color(
          0xFFEC407A,
        );

      case 'custom_variant':
        return const Color(
          0xFFAB47BC,
        );

      default:
        return AtlasColors.intelligenceBlue;
    }
  }
}