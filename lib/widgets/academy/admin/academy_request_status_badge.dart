import 'package:flutter/material.dart';

import '../../../academy/models/academy_request.dart';
import '../../../theme/atlas_colors.dart';
import '../../atlas/components/atlas_status_chip.dart';

class AcademyRequestStatusBadge extends StatelessWidget {
  const AcademyRequestStatusBadge({super.key, required this.request});

  final AcademyRequest request;

  @override
  Widget build(BuildContext context) {
    return AtlasStatusChip(
      label: request.statusLabel,
      icon: _icon,
      accentColor: _accentColor,
      size: AtlasStatusChipSize.compact,
    );
  }

  IconData get _icon {
    switch (request.status) {
      case AcademyRequestStatus.newRequest:
        return Icons.mark_email_unread_outlined;

      case AcademyRequestStatus.reviewed:
        return Icons.visibility_outlined;

      case AcademyRequestStatus.approved:
        return Icons.check_circle_outline_rounded;

      case AcademyRequestStatus.declined:
        return Icons.cancel_outlined;
    }
  }

  Color get _accentColor {
    switch (request.status) {
      case AcademyRequestStatus.newRequest:
        return AtlasColors.intelligenceBlue;

      case AcademyRequestStatus.reviewed:
        return AtlasColors.warning;

      case AcademyRequestStatus.approved:
        return AtlasColors.success;

      case AcademyRequestStatus.declined:
        return AtlasColors.warning;
    }
  }
}
