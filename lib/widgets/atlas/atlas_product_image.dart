import 'package:flutter/material.dart';

import 'package:funkovault2/theme/atlas_colors.dart';
import 'package:funkovault2/theme/atlas_spacing.dart';
import 'package:funkovault2/theme/atlas_typography.dart';

class AtlasProductImage extends StatelessWidget {
  const AtlasProductImage({
    required this.imageUrl,
    this.height = 195,
    this.accentColor = AtlasColors.vaultGold,
    super.key,
  });

  final String imageUrl;
  final double height;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final String normalizedImageUrl = imageUrl.trim();

    return SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: height * 0.85,
            height: height * 0.85,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accentColor.withValues(
                    alpha: 0.18,
                  ),
                  accentColor.withValues(
                    alpha: 0.05,
                  ),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          if (normalizedImageUrl.isEmpty)
            const _AtlasProductImagePlaceholder()
          else
            Image.network(
              normalizedImageUrl,
              width: double.infinity,
              height: height,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              gaplessPlayback: true,
              errorBuilder: (
                  BuildContext context,
                  Object error,
                  StackTrace? stackTrace,
                  ) {
                return const _AtlasProductImagePlaceholder();
              },
              loadingBuilder: (
                  BuildContext context,
                  Widget child,
                  ImageChunkEvent? loadingProgress,
                  ) {
                if (loadingProgress == null) {
                  return child;
                }

                final int? expectedBytes =
                    loadingProgress.expectedTotalBytes;

                final double? progress = expectedBytes == null
                    ? null
                    : loadingProgress.cumulativeBytesLoaded /
                    expectedBytes;

                return Center(
                  child: CircularProgressIndicator(
                    value: progress,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _AtlasProductImagePlaceholder extends StatelessWidget {
  const _AtlasProductImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 56,
            color: AtlasColors.textSecondary,
          ),
          SizedBox(
            height: AtlasSpacing.sm,
          ),
          Text(
            'Product image unavailable',
            style: AtlasTypography.bodySmall,
          ),
        ],
      ),
    );
  }
}