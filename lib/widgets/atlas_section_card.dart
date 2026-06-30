import 'package:flutter/material.dart';

import '../theme/atlas_colors.dart';
import '../theme/atlas_radius.dart';
import '../theme/atlas_spacing.dart';
import '../theme/atlas_typography.dart';

class AtlasSectionCard extends StatelessWidget {
  const AtlasSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.icon,
  });

  final String title;
  final Widget child;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(
          AtlasSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(
                      AtlasSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AtlasColors.surface,
                      borderRadius: BorderRadius.circular(
                        AtlasRadius.md,
                      ),
                      border: Border.all(
                        color: AtlasColors.border,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: AtlasColors.vaultGold,
                    ),
                  ),
                  const SizedBox(width: AtlasSpacing.md),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: AtlasTypography.headingMedium,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AtlasSpacing.md),

            child,
          ],
        ),
      ),
    );
  }
}