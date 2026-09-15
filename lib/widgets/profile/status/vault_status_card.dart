import 'package:flutter/material.dart';

import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_icons.dart';
import '../../../theme/atlas_spacing.dart';
import '../../../theme/atlas_typography.dart';
import '../../atlas/atlas_glass_card.dart';

class VaultStatusCard extends StatelessWidget {
  const VaultStatusCard({required this.isPremium, super.key});

  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Atlas Systems', style: AtlasTypography.headingSmall),
          const SizedBox(height: AtlasSpacing.md),
          Row(
            children: [
              const Expanded(
                child: _StatusPill(
                  icon: AtlasIcons.intelligence,
                  label: 'Intelligence',
                  value: 'Online',
                ),
              ),
              const SizedBox(width: AtlasSpacing.sm),
              const Expanded(
                child: _StatusPill(
                  icon: Icons.shield_outlined,
                  label: 'Vault',
                  value: 'Secure',
                ),
              ),
            ],
          ),
          const SizedBox(height: AtlasSpacing.sm),
          Row(
            children: [
              const Expanded(
                child: _StatusPill(
                  icon: Icons.cloud_done_outlined,
                  label: 'Sync',
                  value: 'Ready',
                ),
              ),
              const SizedBox(width: AtlasSpacing.sm),
              Expanded(
                child: _StatusPill(
                  icon: isPremium ? Icons.workspace_premium : Icons.lock_open,
                  label: 'Membership',
                  value: isPremium ? 'Premium' : 'Basic',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AtlasSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AtlasColors.vaultGold.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: AtlasColors.vaultGold, size: 20),
          const SizedBox(height: AtlasSpacing.xs),
          Text(
            value,
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.vaultGold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
