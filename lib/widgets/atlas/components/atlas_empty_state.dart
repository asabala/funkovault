import 'package:flutter/material.dart';

import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';
import '../../../theme/atlas_typography.dart';
import '../atlas_glass_card.dart';

class AtlasEmptyState extends StatelessWidget {
  const AtlasEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  bool get _hasAction {
    return actionLabel != null && onAction != null;
  }

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AtlasColors.vaultGold,
            size: 28,
          ),
          const SizedBox(height: AtlasSpacing.md),
          Text(
            title,
            style: AtlasTypography.headingSmall.copyWith(
              color: AtlasColors.textPrimary,
            ),
          ),
          const SizedBox(height: AtlasSpacing.xs),
          Text(
            message,
            style: AtlasTypography.bodyMedium.copyWith(
              color: AtlasColors.textSecondary,
              height: 1.35,
            ),
          ),
          if (_hasAction) ...[
            const SizedBox(height: AtlasSpacing.md),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: onAction,
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                ),
                label: Text(actionLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}