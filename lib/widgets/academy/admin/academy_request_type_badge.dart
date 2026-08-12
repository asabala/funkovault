import 'package:flutter/material.dart';

import '../../../academy/models/academy_request.dart';
import '../../../theme/atlas_colors.dart';
import '../../atlas/components/atlas_status_chip.dart';

class AcademyRequestTypeBadge extends StatelessWidget {
  const AcademyRequestTypeBadge({
    super.key,
    required this.request,
  });

  final AcademyRequest request;

  @override
  Widget build(BuildContext context) {
    return AtlasStatusChip(
      label: request.typeLabel,
      icon: _icon,
      accentColor: _accentColor,
      size: AtlasStatusChipSize.compact,
    );
  }

  IconData get _icon {
    switch (request.type) {
      case AcademyRequestType.topic:
        return Icons.lightbulb_outline_rounded;

      case AcademyRequestType.track:
        return Icons.route_rounded;
    }
  }

  Color get _accentColor {
    switch (request.type) {
      case AcademyRequestType.topic:
        return AtlasColors.vaultGold;

      case AcademyRequestType.track:
        return AtlasColors.intelligenceBlue;
    }
  }
}