import 'package:flutter/material.dart';

import '../../../theme/atlas_colors.dart';

class AtlasAvatar extends StatelessWidget {
  const AtlasAvatar({
    required this.displayName,
    this.avatarUrl = '',
    this.size = 88,
    super.key,
  });

  final String displayName;
  final String avatarUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AtlasColors.vaultGold.withValues(alpha: 0.16),
        border: Border.all(
          color: AtlasColors.vaultGold.withValues(alpha: 0.60),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          _initials(displayName),
          style: TextStyle(
            color: AtlasColors.vaultGold,
            fontSize: size * 0.34,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');

    if (parts.isEmpty || parts.first.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
