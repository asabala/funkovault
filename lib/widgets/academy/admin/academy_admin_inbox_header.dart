import 'package:flutter/material.dart';

import '../../../theme/atlas_colors.dart';
import '../../atlas/components/atlas_section_header.dart';
import '../../atlas/components/atlas_status_chip.dart';

class AcademyAdminInboxHeader extends StatelessWidget {
  const AcademyAdminInboxHeader({
    super.key,
    required this.requestCount,
  });

  final int requestCount;

  @override
  Widget build(BuildContext context) {
    final bool hasRequests =
        requestCount > 0;

    final String requestLabel =
    requestCount == 1
        ? '1 Request'
        : '$requestCount Requests';

    return AtlasSectionHeader(
      title: 'Admin Request Inbox',
      subtitle: hasRequests
          ? '$requestLabel available for Academy review.'
          : 'No Academy requests are currently waiting for review.',
      icon:
      Icons.admin_panel_settings_rounded,
      accentColor:
      AtlasColors.vaultGold,
      badge: AtlasStatusChip(
        label: hasRequests
            ? requestLabel
            : 'Inbox Clear',
        icon: hasRequests
            ? Icons
            .mark_email_unread_outlined
            : Icons.mark_email_read_outlined,
        accentColor: hasRequests
            ? AtlasColors.vaultGold
            : AtlasColors.success,
        size:
        AtlasStatusChipSize.compact,
      ),
    );
  }
}