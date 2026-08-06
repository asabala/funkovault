import 'package:flutter/material.dart';

import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';

class AtlasProductImage extends StatelessWidget {
  const AtlasProductImage({
    super.key,
    required this.imageUrl,
    this.width = 180,
    this.height = 220,
    this.fit = BoxFit.contain,
    this.accentColor = AtlasColors.vaultGold,
    this.borderRadius = AtlasSpacing.lg,
    this.placeholderIcon = Icons.inventory_2_rounded,
    this.errorIcon = Icons.broken_image_rounded,
    this.showBorder = true,
  });

  final String imageUrl;

  final double width;
  final double height;
  final BoxFit fit;

  final Color accentColor;
  final double borderRadius;

  final IconData placeholderIcon;
  final IconData errorIcon;

  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final String cleanedImageUrl = imageUrl.trim();

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AtlasColors.textSecondary.withValues(
          alpha: 0.06,
        ),
        borderRadius: BorderRadius.circular(
          borderRadius,
        ),
        border: showBorder
            ? Border.all(
          color: accentColor.withValues(
            alpha: 0.28,
          ),
        )
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: cleanedImageUrl.isEmpty
          ? _ProductImageFallback(
        icon: placeholderIcon,
        accentColor: accentColor,
      )
          : Image.network(
        cleanedImageUrl,
        fit: fit,
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

          final double? progress =
          expectedBytes == null || expectedBytes <= 0
              ? null
              : loadingProgress.cumulativeBytesLoaded /
              expectedBytes;

          return Center(
            child: SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 2,
                color: accentColor,
                backgroundColor: AtlasColors.surface,
              ),
            ),
          );
        },
        errorBuilder: (
            BuildContext context,
            Object error,
            StackTrace? stackTrace,
            ) {
          return _ProductImageFallback(
            icon: errorIcon,
            accentColor: AtlasColors.textSecondary,
          );
        },
      ),
    );
  }
}

class _ProductImageFallback extends StatelessWidget {
  const _ProductImageFallback({
    required this.icon,
    required this.accentColor,
  });

  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        icon,
        size: 72,
        color: accentColor,
      ),
    );
  }
}