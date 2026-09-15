import 'package:flutter/material.dart';

import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_typography.dart';

class AcademyAdminMoreRequestsLabel extends StatelessWidget {
  const AcademyAdminMoreRequestsLabel({
    super.key,
    required this.hiddenRequestCount,
  });

  final int hiddenRequestCount;

  @override
  Widget build(BuildContext context) {
    if (hiddenRequestCount <= 0) {
      return const SizedBox.shrink();
    }

    final String label = hiddenRequestCount == 1
        ? '+1 more request'
        : '+$hiddenRequestCount more requests';

    return Text(
      label,
      style: AtlasTypography.bodySmall.copyWith(
        color: AtlasColors.textSecondary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
