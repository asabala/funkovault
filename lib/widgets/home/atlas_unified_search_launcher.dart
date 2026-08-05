import 'package:flutter/material.dart';

import 'package:funkovault2/theme/atlas_colors.dart';
import 'package:funkovault2/theme/atlas_spacing.dart';
import 'package:funkovault2/theme/atlas_typography.dart';
import 'package:funkovault2/widgets/atlas/atlas_glass_card.dart';

class AtlasUnifiedSearchLauncher extends StatelessWidget {
  const AtlasUnifiedSearchLauncher({
    required this.onSearchPressed,
    required this.onBarcodePressed,
    this.hintText = 'Search collectibles...',
    super.key,
  });

  final VoidCallback onSearchPressed;
  final VoidCallback onBarcodePressed;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onSearchPressed,
              borderRadius: BorderRadius.circular(
                16,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AtlasSpacing.md,
                  vertical: AtlasSpacing.md,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      color:
                      AtlasColors.intelligenceBlue,
                    ),
                    const SizedBox(
                      width: AtlasSpacing.md,
                    ),
                    Expanded(
                      child: Text(
                        hintText,
                        style: AtlasTypography.bodyMedium
                            .copyWith(
                          color:
                          AtlasColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: 1,
            height: 32,
            color: AtlasColors.textSecondary
                .withValues(
              alpha: 0.22,
            ),
          ),
          IconButton(
            tooltip: 'Scan Barcode',
            onPressed: onBarcodePressed,
            icon: const Icon(
              Icons.qr_code_scanner_rounded,
              color: AtlasColors.vaultGold,
            ),
          ),
          const SizedBox(
            width: AtlasSpacing.xs,
          ),
        ],
      ),
    );
  }
}