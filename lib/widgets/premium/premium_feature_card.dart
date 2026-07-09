import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AtlasSpacing.lg),
      decoration: BoxDecoration(
        color: AtlasColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AtlasColors.vaultGold.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: AtlasColors.vaultGold,
              ),
              const SizedBox(width: AtlasSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AtlasColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const PremiumBadge(),
            ],
          ),
          const SizedBox(height: AtlasSpacing.sm),
          Text(
            description,
            style: const TextStyle(
              color: AtlasColors.textSecondary,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: AtlasSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.lock_open_rounded),
              label: Text(actionLabel),
            ),
          ),
        ],
      ),
    );
  }
}