import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';
import '../../theme/atlas_radius.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';

class AtlasPriorityChip extends StatelessWidget {
  const AtlasPriorityChip({super.key, required this.severity});

  final String severity;

  @override
  Widget build(BuildContext context) {
    final priority = _priorityStyle(severity);

    return Chip(
      avatar: Icon(priority.icon, size: 18, color: priority.foreground),
      label: Text(
        priority.label,
        style: AtlasTypography.label.copyWith(color: priority.foreground),
      ),
      backgroundColor: priority.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AtlasRadius.pill),
        side: BorderSide(color: priority.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AtlasSpacing.sm),
    );
  }

  _PriorityStyle _priorityStyle(String severity) {
    switch (severity) {
      case 'High':
        return const _PriorityStyle(
          label: 'HIGH',
          icon: Icons.warning,
          background: AtlasColors.danger,
          foreground: AtlasColors.textPrimary,
          border: AtlasColors.danger,
        );

      case 'Medium':
        return const _PriorityStyle(
          label: 'MEDIUM',
          icon: Icons.error_outline,
          background: AtlasColors.warning,
          foreground: AtlasColors.midnight,
          border: AtlasColors.warning,
        );

      default:
        return const _PriorityStyle(
          label: 'LOW',
          icon: Icons.check_circle_outline,
          background: AtlasColors.success,
          foreground: AtlasColors.midnight,
          border: AtlasColors.success,
        );
    }
  }
}

class _PriorityStyle {
  const _PriorityStyle({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.border,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final Color border;
}
