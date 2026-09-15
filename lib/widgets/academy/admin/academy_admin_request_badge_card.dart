import 'package:flutter/material.dart';

import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';
import '../../../theme/atlas_typography.dart';
import '../../atlas/atlas_glass_card.dart';
import '../../atlas/components/atlas_status_chip.dart';

class AcademyAdminRequestBadgeCard extends StatelessWidget {
  const AcademyAdminRequestBadgeCard({
    super.key,
    required this.newRequestCount,
  });

  final int newRequestCount;

  @override
  Widget build(BuildContext context) {
    final bool hasNewRequests = newRequestCount > 0;

    return AtlasGlassCard(
      accentColor: hasNewRequests
          ? AtlasColors.vaultGold
          : AtlasColors.textSecondary,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: hasNewRequests
                  ? AtlasColors.vaultGold.withValues(alpha: 0.14)
                  : AtlasColors.textSecondary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              hasNewRequests
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_none_rounded,
              color: hasNewRequests
                  ? AtlasColors.vaultGold
                  : AtlasColors.textSecondary,
            ),
          ),
          const SizedBox(width: AtlasSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasNewRequests
                      ? '$newRequestCount new '
                            '${newRequestCount == 1 ? 'Academy request' : 'Academy requests'}'
                      : 'No New Academy Requests',
                  style: AtlasTypography.headingSmall,
                ),
                const SizedBox(height: AtlasSpacing.xs),
                Text(
                  hasNewRequests
                      ? 'Review requested topics and future track interest.'
                      : 'Topic and track requests will appear here when submitted.',
                  style: AtlasTypography.bodySmall.copyWith(
                    color: AtlasColors.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: AtlasSpacing.sm),
                AtlasStatusChip(
                  label: hasNewRequests
                      ? '$newRequestCount New'
                      : 'Inbox Clear',
                  icon: hasNewRequests
                      ? Icons.mark_email_unread_outlined
                      : Icons.mark_email_read_outlined,
                  accentColor: hasNewRequests
                      ? AtlasColors.vaultGold
                      : AtlasColors.success,
                  size: AtlasStatusChipSize.compact,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
